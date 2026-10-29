import 'package:drift/drift.dart';

import '../../domain/competencia.dart';
import '../../domain/datas.dart';
import '../../domain/compromissos.dart';
import '../../domain/enums.dart';
import '../../domain/fatura.dart';
import '../../domain/parcelas.dart';
import '../banco.dart';
import '../daos/compromissos_dao.dart';
import '../compromisso_calculo.dart';
import 'servico_cartao.dart';

/// Compromissos (gastos fixos), suas ocorrências mensais e receitas
/// recorrentes.
///
/// Gasto fixo **no crédito** (ex.: assinatura): em vez de uma conta pendente
/// para pagar, a cobrança entra sozinha na fatura do cartão todo mês.
class ServicoCompromisso {
  ServicoCompromisso(this._db);
  final AppDatabase _db;

  CompromissosDao get _dao => _db.compromissosDao;

  // ------------------------------------------------------------------
  // Compromissos
  // ------------------------------------------------------------------

  /// Cria o compromisso e já gera as ocorrências do mês atual e do próximo.
  Future<int> criarCompromisso({
    required String descricao,
    required int valor,
    required TipoCompromisso tipo,
    required DateTime dataInicio,
    required FormaPagamento forma,
    int? numeroParcelas,
    int? categoriaId,
    int? contaId,
    int? cartaoId,
    DateTime? hoje,
  }) async {
    if (forma == FormaPagamento.credito) {
      if (cartaoId == null) {
        throw const OperacaoInvalida('Escolha o cartão do gasto fixo.');
      }
      if (tipo != TipoCompromisso.recorrente) {
        throw const OperacaoInvalida(
          'No crédito, o gasto fixo é recorrente. Para parcelar, use as parcelas da compra.',
        );
      }
    }
    final id = await _dao.inserirCompromisso(CompromissosCompanion.insert(
      descricao: descricao.trim(),
      valor: valor,
      diaVencimento: dataInicio.day,
      dataInicio: soData(dataInicio),
      tipo: tipo,
      numeroParcelas: Value(tipo == TipoCompromisso.parcelado ? numeroParcelas : null),
      formaPagamento: Value(forma),
      categoriaId: Value(categoriaId),
      contaId: Value(forma == FormaPagamento.credito ? null : contaId),
      cartaoId: Value(forma == FormaPagamento.credito ? cartaoId : null),
    ));
    await gerarOcorrencias(hoje: hoje);
    return id;
  }

  /// Edita valor, dia, categoria, forma, conta e situação. Ocorrências
  /// **pendentes** são refeitas com os novos dados; as pagas ficam como estão.
  Future<void> atualizarCompromisso(
    Compromisso c, {
    String? descricao,
    int? valor,
    int? diaVencimento,
    FormaPagamento? forma,
    int? categoriaId,
    int? contaId,
    int? cartaoId,
    bool? ativo,
    DateTime? hoje,
  }) async {
    // Cobranças futuras já lançadas no cartão são refeitas com os novos dados.
    await _removerCobrancasFuturas(c.id, hoje: hoje);
    await _dao.atualizarCompromisso(c.copyWith(
      descricao: descricao?.trim(),
      valor: valor,
      diaVencimento: diaVencimento,
      formaPagamento: forma,
      categoriaId: Value(categoriaId ?? c.categoriaId),
      contaId: Value(contaId ?? c.contaId),
      cartaoId: Value(cartaoId ?? c.cartaoId),
      ativo: ativo,
    ));
    await _dao.excluirPendentesDe(c.id);
    await gerarOcorrencias(hoje: hoje);
  }

  Future<void> excluirCompromisso(int id) async {
    await _removerCobrancasFuturas(id);
    await _dao.excluirCompromisso(id);
  }

  /// Apaga as cobranças **futuras** (data depois de hoje) que um gasto fixo no
  /// crédito já lançou nas faturas, junto com suas ocorrências. As de hoje e do
  /// passado ficam. Faturas já pagas nunca são mexidas.
  Future<void> _removerCobrancasFuturas(int compromissoId, {DateTime? hoje}) async {
    final dia = soData(hoje ?? DateTime.now());
    await _db.transaction(() async {
      for (final o in await _dao.todasOcorrencias()) {
        if (o.compromissoId != compromissoId) continue;
        if (o.status != StatusOcorrencia.paga || !o.dataVencimento.isAfter(dia)) continue;
        final lancId = o.lancamentoId;
        if (lancId != null) {
          final l = await _db.lancamentosDao.obter(lancId);
          // Só mexe em cobrança de cartão (gasto na conta já foi pago de verdade).
          if (l == null || l.formaPagamento != FormaPagamento.credito) continue;
          final fatura = l.faturaId == null ? null : await _db.cartoesDao.faturaPorId(l.faturaId!);
          if (fatura?.status == StatusFatura.paga) continue;
          await _db.lancamentosDao.excluir(lancId);
        }
        await _dao.excluirOcorrencia(o.id);
      }
    });
  }

  /// Lança a cobrança [o] do gasto fixo [c] na fatura do cartão e marca a
  /// ocorrência como resolvida. Se a fatura daquele ciclo já foi paga, a
  /// cobrança cai no ciclo seguinte (não se mexe em fatura paga).
  Future<void> _lancarCobrancaNoCartao(Compromisso c, OcorrenciaPrevista o) async {
    final cartao = c.cartaoId == null ? null : await _db.cartoesDao.obter(c.cartaoId!);
    if (cartao == null || !cartao.ativo) return;
    await _db.transaction(() async {
      var data = o.dataVencimento;
      final ciclo = cicloDaCompra(
        data,
        diaFechamento: cartao.diaFechamento,
        diaVencimento: cartao.diaVencimento,
      );
      final fatura = await _db.cartoesDao.faturaDaCompetencia(cartao.id, ciclo.competencia.chave);
      if (fatura?.status == StatusFatura.paga) data = ciclo.dataFechamento;

      final ocId = await _dao.inserirOcorrencia(OcorrenciasCompromissoCompanion.insert(
        compromissoId: c.id,
        competencia: o.competencia.chave,
        valor: o.valor,
        dataVencimento: o.dataVencimento,
        numeroParcela: Value(o.numeroParcela),
        status: const Value(StatusOcorrencia.paga),
      ));
      if (ocId <= 0) return;
      final ids = await ServicoCartao(_db).registrarCompra(
        cartao: cartao,
        valorTotal: o.valor,
        parcelas: 1,
        data: data,
        descricao: c.descricao,
        categoriaId: c.categoriaId,
      );
      final l = (await _db.lancamentosDao.obter(ids.first))!;
      await _db.lancamentosDao.atualizar(l.copyWith(ocorrenciaCompromissoId: Value(ocId)));
      final oc = (await _dao.ocorrencia(ocId))!;
      await _dao.atualizarOcorrencia(oc.copyWith(lancamentoId: Value(l.id)));
    });
  }

  /// Gera as ocorrências que faltam até o mês seguinte ao de [hoje].
  ///
  /// Para não inundar a lista quando o compromisso começou há muito tempo,
  /// só entram ocorrências a partir do mês anterior ao atual (as mais antigas
  /// consideram-se resolvidas fora do app).
  Future<void> gerarOcorrencias({DateTime? hoje}) async {
    final agora = soData(hoje ?? DateTime.now());
    final atual = Competencia.deData(agora);
    final limite = atual.somarMeses(1);
    final piso = atual.somarMeses(-1);

    final todas = await _dao.todasOcorrencias();
    for (final c in await _dao.todosCompromissos()) {
      if (!c.ativo) continue;
      final existentes = {
        for (final o in todas)
          if (o.compromissoId == c.id) Competencia.parse(o.competencia),
      };
      final geradas = ocorrenciasDe(c, limite);
      final faltantes = ocorrenciasFaltantes(geradas, existentes)
          .where((o) => o.competencia >= piso);
      for (final o in faltantes) {
        if (c.formaPagamento == FormaPagamento.credito) {
          await _lancarCobrancaNoCartao(c, o);
          continue;
        }
        await _dao.inserirOcorrencia(OcorrenciasCompromissoCompanion.insert(
          compromissoId: c.id,
          competencia: o.competencia.chave,
          valor: o.valor,
          dataVencimento: o.dataVencimento,
          numeroParcela: Value(o.numeroParcela),
        ));
      }
    }
  }

  /// Paga uma ocorrência: cria o gasto na conta e marca como paga.
  /// [valor] permite pagar um valor diferente do previsto (ex.: conta de luz).
  Future<int> pagarOcorrencia(
    OcorrenciaCompromisso o, {
    int? contaId,
    int? valor,
    DateTime? data,
  }) {
    return _db.transaction(() async {
      final atual = (await _dao.ocorrencia(o.id))!;
      if (atual.status == StatusOcorrencia.paga) {
        throw const OperacaoInvalida('Esta conta já foi paga.');
      }
      final c = (await _dao.compromisso(atual.compromissoId))!;
      final conta = contaId ?? c.contaId;
      if (conta == null) {
        throw const OperacaoInvalida('Escolha a conta que vai pagar.');
      }
      final pago = valor ?? atual.valor;
      final lancId = await _db.lancamentosDao.inserir(LancamentosCompanion.insert(
        tipo: TipoLancamento.gasto,
        valor: pago,
        data: soData(data ?? DateTime.now()),
        descricao: Value(descricaoDaParcela(
          c.descricao,
          atual.numeroParcela ?? 1,
          c.numeroParcelas ?? 1,
        )),
        categoriaId: Value(c.categoriaId),
        formaPagamento: Value(c.formaPagamento),
        contaId: Value(conta),
        ocorrenciaCompromissoId: Value(atual.id),
      ));
      await _dao.atualizarOcorrencia(atual.copyWith(
        status: StatusOcorrencia.paga,
        valor: pago,
        lancamentoId: Value(lancId),
      ));
      // Parcelado encerra automaticamente após a última parcela.
      if (c.tipo == TipoCompromisso.parcelado &&
          atual.numeroParcela == c.numeroParcelas) {
        await _dao.atualizarCompromisso(c.copyWith(ativo: false));
      }
      return lancId;
    });
  }

  /// Usado pela importação: liga um lançamento já existente à ocorrência
  /// ("marcar parcela como paga" em vez de criar gasto novo).
  Future<void> vincularLancamento(OcorrenciaCompromisso o, Lancamento l) async {
    await _db.transaction(() async {
      final c = (await _dao.compromisso(o.compromissoId))!;
      await _db.lancamentosDao.atualizar(l.copyWith(
        ocorrenciaCompromissoId: Value(o.id),
        categoriaId: Value(l.categoriaId ?? c.categoriaId),
      ));
      await _dao.atualizarOcorrencia(o.copyWith(
        status: StatusOcorrencia.paga,
        valor: l.valor,
        lancamentoId: Value(l.id),
      ));
      if (c.tipo == TipoCompromisso.parcelado && o.numeroParcela == c.numeroParcelas) {
        await _dao.atualizarCompromisso(c.copyWith(ativo: false));
      }
    });
  }

  /// Excluir o lançamento de uma ocorrência paga a reabre (volta a pendente).
  Future<void> reabrirOcorrenciaDoLancamento(int lancamentoId) async {
    final todas = await _dao.todasOcorrencias();
    for (final o in todas.where((o) => o.lancamentoId == lancamentoId)) {
      final c = await _dao.compromisso(o.compromissoId);
      // Cobrança no crédito não tem "pagar": apagar o lançamento só a dispensa.
      final credito = c?.formaPagamento == FormaPagamento.credito;
      await _dao.atualizarOcorrencia(o.copyWith(
        status: credito ? StatusOcorrencia.paga : StatusOcorrencia.pendente,
        lancamentoId: const Value(null),
      ));
      if (credito) continue;
      if (c != null && !c.ativo) {
        await _dao.atualizarCompromisso(c.copyWith(ativo: true));
      }
    }
  }

  // ------------------------------------------------------------------
  // Receitas recorrentes
  // ------------------------------------------------------------------

  Future<int> criarReceita({
    required String descricao,
    required int valorPrevisto,
    required int contaId,
    required DateTime dataInicio,
    int? categoriaId,
    int? diaPrevisto,
  }) =>
      _dao.inserirReceita(ReceitasRecorrentesCompanion.insert(
        descricao: descricao.trim(),
        valorPrevisto: valorPrevisto,
        diaPrevisto: diaPrevisto ?? dataInicio.day,
        dataInicio: soData(dataInicio),
        contaId: contaId,
        categoriaId: Value(categoriaId),
      ));

  Future<void> atualizarReceita(ReceitaRecorrente r) => _dao.atualizarReceita(r);

  Future<void> excluirReceita(int id) => _dao.excluirReceita(id);

  /// Confirma a receita do mês: cria o ganho real (valor pode ser ajustado).
  Future<int> confirmarReceita(
    ReceitaRecorrente r, {
    int? valor,
    DateTime? data,
    int? contaId,
  }) async {
    return _db.lancamentosDao.inserir(LancamentosCompanion.insert(
      tipo: TipoLancamento.ganho,
      valor: valor ?? r.valorPrevisto,
      data: soData(data ?? DateTime.now()),
      descricao: Value(r.descricao),
      categoriaId: Value(r.categoriaId),
      contaId: Value(contaId ?? r.contaId),
      receitaRecorrenteId: Value(r.id),
    ));
  }
}
