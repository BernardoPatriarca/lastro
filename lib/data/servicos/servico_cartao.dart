import 'package:drift/drift.dart';

import '../../domain/datas.dart';
import '../../domain/enums.dart';
import '../../domain/fatura.dart';
import '../../domain/parcelas.dart';
import '../banco.dart';
import '../daos/cartoes_dao.dart';
import '../daos/lancamentos_dao.dart';

/// Operação recusada por regra de negócio (a mensagem pode ser exibida).
class OperacaoInvalida implements Exception {
  const OperacaoInvalida(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

/// Em que parcelas aplicar uma edição ou exclusão.
enum EscopoParcelas { soEsta, estaEProximas, todas }

/// Compras no crédito, faturas e pagamento de fatura.
class ServicoCartao {
  ServicoCartao(this._db);
  final AppDatabase _db;

  CartoesDao get _cartoes => _db.cartoesDao;
  LancamentosDao get _lancs => _db.lancamentosDao;

  /// Fatura do cartão para o ciclo [ciclo]; é criada sob demanda.
  Future<Fatura> obterOuCriarFatura(Cartao cartao, CicloFatura ciclo) async {
    final existente =
        await _cartoes.faturaDaCompetencia(cartao.id, ciclo.competencia.chave);
    if (existente != null) return existente;
    final id = await _cartoes.inserirFatura(FaturasCompanion.insert(
      cartaoId: cartao.id,
      competencia: ciclo.competencia.chave,
      dataFechamento: ciclo.dataFechamento,
      dataVencimento: ciclo.dataVencimento,
      status: Value(statusEfetivo(
        StatusFatura.aberta,
        ciclo.dataFechamento,
        soData(DateTime.now()),
      )),
    ));
    return (await _cartoes.faturaPorId(id))!;
  }

  CicloFatura _cicloDa(Cartao c, DateTime data) => cicloDaCompra(
        data,
        diaFechamento: c.diaFechamento,
        diaVencimento: c.diaVencimento,
      );

  /// Registra uma compra no crédito. Em [parcelas] > 1 cria a compra parcelada
  /// e um lançamento por parcela, cada um na fatura certa.
  Future<void> registrarCompra({
    required Cartao cartao,
    required int valorTotal,
    required int parcelas,
    required DateTime data,
    required String descricao,
    int? categoriaId,
    OrigemLancamento origem = OrigemLancamento.manual,
    String? chaveImportacao,
  }) {
    return _db.transaction(() async {
      final dia = soData(data);
      int? compraId;
      if (parcelas > 1) {
        compraId = await _lancs.inserirCompra(ComprasParceladasCompanion.insert(
          cartaoId: cartao.id,
          descricao: descricao.trim(),
          categoriaId: Value(categoriaId),
          valorTotal: valorTotal,
          numeroParcelas: parcelas,
          dataCompra: dia,
        ));
      }
      final geradas = gerarParcelas(
        descricao: descricao.trim(),
        valorTotal: valorTotal,
        numeroParcelas: parcelas,
        dataCompra: dia,
        diaFechamento: cartao.diaFechamento,
        diaVencimento: cartao.diaVencimento,
      );
      for (final p in geradas) {
        final fatura = await obterOuCriarFatura(cartao, p.ciclo);
        await _lancs.inserir(LancamentosCompanion.insert(
          tipo: TipoLancamento.gasto,
          valor: p.valor,
          data: p.data,
          descricao: Value(p.descricao),
          categoriaId: Value(categoriaId),
          formaPagamento: const Value(FormaPagamento.credito),
          cartaoId: Value(cartao.id),
          faturaId: Value(fatura.id),
          compraParceladaId: Value(compraId),
          parcelaNumero: Value(parcelas > 1 ? p.numero : null),
          origem: Value(origem),
          // Só a compra à vista (ou a 1ª parcela) carrega a chave de importação.
          chaveImportacao: Value(p.numero == 1 ? chaveImportacao : null),
        ));
      }
    });
  }

  Future<void> _garantirFaturaNaoPaga(Lancamento l) async {
    final id = l.faturaId;
    if (id == null) return;
    final f = await _cartoes.faturaPorId(id);
    if (f != null && f.status == StatusFatura.paga) {
      throw const OperacaoInvalida(
        'Este lançamento está numa fatura já paga. Desfaça o pagamento da '
        'fatura (excluindo o lançamento de pagamento) para alterá-lo.',
      );
    }
  }

  /// Edita uma compra à vista no crédito (pode mudar cartão, data e valor,
  /// o que pode mudá-la de fatura).
  Future<void> atualizarCompraUnica(
    Lancamento l, {
    required Cartao cartao,
    required int valor,
    required DateTime data,
    required String descricao,
    int? categoriaId,
  }) async {
    await _garantirFaturaNaoPaga(l);
    await _db.transaction(() async {
      final fatura = await obterOuCriarFatura(cartao, _cicloDa(cartao, soData(data)));
      await _lancs.atualizar(l.copyWith(
        valor: valor,
        data: soData(data),
        descricao: descricao.trim(),
        categoriaId: Value(categoriaId),
        cartaoId: Value(cartao.id),
        faturaId: Value(fatura.id),
      ));
    });
  }

  /// Parcelas de [l] afetadas pelo [escopo], em ordem.
  Future<List<Lancamento>> _alvos(Lancamento l, EscopoParcelas escopo) async {
    final todas = await _lancs.daCompra(l.compraParceladaId!);
    return switch (escopo) {
      EscopoParcelas.soEsta => [for (final p in todas) if (p.id == l.id) p],
      EscopoParcelas.estaEProximas => [
          for (final p in todas)
            if ((p.parcelaNumero ?? 0) >= (l.parcelaNumero ?? 0)) p,
        ],
      EscopoParcelas.todas => todas,
    };
  }

  /// Edita parcelas de uma compra parcelada. Data e cartão não mudam (definem
  /// a fatura). [valorParcela] vale para cada parcela afetada.
  Future<void> atualizarParcelas(
    Lancamento l,
    EscopoParcelas escopo, {
    required int valorParcela,
    required String descricaoBase,
    int? categoriaId,
  }) async {
    final alvos = await _alvos(l, escopo);
    for (final p in alvos) {
      await _garantirFaturaNaoPaga(p);
    }
    final compra = await _lancs.compra(l.compraParceladaId!);
    await _db.transaction(() async {
      for (final p in alvos) {
        await _lancs.atualizar(p.copyWith(
          valor: valorParcela,
          descricao: descricaoDaParcela(
            descricaoBase.trim(),
            p.parcelaNumero ?? 1,
            compra?.numeroParcelas ?? 1,
          ),
          categoriaId: Value(categoriaId),
        ));
      }
      if (compra != null && escopo == EscopoParcelas.todas) {
        await _lancs.atualizarCompra(compra.copyWith(
          descricao: descricaoBase.trim(),
          categoriaId: Value(categoriaId),
          valorTotal: valorParcela * compra.numeroParcelas,
        ));
      }
    });
  }

  /// Exclui uma compra no crédito (à vista ou parcelas, conforme [escopo]).
  Future<void> excluirCompra(Lancamento l, EscopoParcelas escopo) async {
    if (l.compraParceladaId == null) {
      await _garantirFaturaNaoPaga(l);
      await _lancs.excluir(l.id);
      return;
    }
    final alvos = await _alvos(l, escopo);
    for (final p in alvos) {
      await _garantirFaturaNaoPaga(p);
    }
    await _db.transaction(() async {
      for (final p in alvos) {
        await _lancs.excluir(p.id);
      }
      final restantes = await _lancs.daCompra(l.compraParceladaId!);
      if (restantes.isEmpty) await _lancs.excluirCompra(l.compraParceladaId!);
    });
  }

  /// Total (centavos) das compras de uma fatura.
  Future<int> totalDaFatura(int faturaId) async {
    final q = _db.selectOnly(_db.lancamentos)
      ..addColumns([_db.lancamentos.valor.sum()])
      ..where(_db.lancamentos.faturaId.equals(faturaId) &
          _db.lancamentos.tipo.equalsValue(TipoLancamento.gasto));
    final linha = await q.getSingle();
    return linha.read(_db.lancamentos.valor.sum()) ?? 0;
  }

  /// "Pagar fatura": gera um lançamento `pagamentoFatura` saindo de [contaId]
  /// e marca a fatura como paga. Devolve o id do lançamento de pagamento.
  Future<int> pagarFatura({
    required Fatura fatura,
    required int contaId,
    DateTime? data,
  }) {
    return _db.transaction(() async {
      final atual = (await _cartoes.faturaPorId(fatura.id))!;
      if (atual.status == StatusFatura.paga) {
        throw const OperacaoInvalida('Esta fatura já está paga.');
      }
      final total = await totalDaFatura(atual.id);
      if (total <= 0) {
        throw const OperacaoInvalida('A fatura não tem valor a pagar.');
      }
      final cartao = (await _cartoes.obter(atual.cartaoId))!;
      final pagamento = soData(data ?? DateTime.now());
      final lancId = await _lancs.inserir(LancamentosCompanion.insert(
        tipo: TipoLancamento.pagamentoFatura,
        valor: total,
        data: pagamento,
        descricao: Value('Fatura ${cartao.nome} ${atual.competencia}'),
        formaPagamento: const Value(FormaPagamento.debito),
        contaId: Value(contaId),
        cartaoId: Value(cartao.id),
        faturaId: Value(atual.id),
      ));
      await _cartoes.atualizarFatura(atual.copyWith(
        status: StatusFatura.paga,
        dataPagamento: Value(pagamento),
        lancamentoPagamentoId: Value(lancId),
      ));
      return lancId;
    });
  }

  /// Excluir o lançamento de pagamento reabre a fatura.
  Future<void> desfazerPagamento(Lancamento pagamento) async {
    await _db.transaction(() async {
      final faturaId = pagamento.faturaId;
      await _lancs.excluir(pagamento.id);
      if (faturaId == null) return;
      final f = await _cartoes.faturaPorId(faturaId);
      if (f == null) return;
      await _cartoes.atualizarFatura(f.copyWith(
        status: statusEfetivo(StatusFatura.aberta, f.dataFechamento, soData(DateTime.now())),
        dataPagamento: const Value(null),
        lancamentoPagamentoId: const Value(null),
      ));
    });
  }

  /// Fatura aberta cuja data de fechamento chegou vira `fechada`.
  Future<void> fecharVencidas([DateTime? hoje]) =>
      _cartoes.fecharFaturasVencidas(soData(hoje ?? DateTime.now()));
}
