import 'package:drift/drift.dart';

import '../../domain/datas.dart';
import '../../domain/enums.dart';
import '../banco.dart';
import 'servico_cartao.dart';
import 'servico_compromisso.dart';

/// Escritas de lançamentos que não envolvem cartão (ver `ServicoCartao`).
class ServicoLancamentos {
  ServicoLancamentos(this._db);
  final AppDatabase _db;

  /// Registra um lançamento simples (gasto não-crédito, ganho, transferência,
  /// aporte, resgate). Valor sempre positivo, em centavos.
  Future<int> registrar({
    required TipoLancamento tipo,
    required int valor,
    required DateTime data,
    String descricao = '',
    int? categoriaId,
    FormaPagamento? forma,
    int? contaId,
    int? contaDestinoId,
    int? investimentoId,
    int? receitaRecorrenteId,
    OrigemLancamento origem = OrigemLancamento.manual,
    String? chaveImportacao,
  }) {
    assert(valor > 0 || tipo == TipoLancamento.ajusteSaldo,
        'valor deve ser positivo');
    return _db.lancamentosDao.inserir(LancamentosCompanion.insert(
      tipo: tipo,
      valor: valor,
      data: soData(data),
      descricao: Value(descricao.trim()),
      categoriaId: Value(categoriaId),
      formaPagamento: Value(forma),
      contaId: Value(contaId),
      contaDestinoId: Value(contaDestinoId),
      investimentoId: Value(investimentoId),
      receitaRecorrenteId: Value(receitaRecorrenteId),
      origem: Value(origem),
      chaveImportacao: Value(chaveImportacao),
    ));
  }

  Future<void> atualizar(Lancamento l) => _db.lancamentosDao.atualizar(l);

  /// Exclui um lançamento. Pagamento de fatura reabre a fatura; compras no
  /// crédito passam por [ServicoCartao.excluirCompra] (que conhece o escopo).
  Future<void> excluir(int id) async {
    final l = await _db.lancamentosDao.obter(id);
    if (l == null) return;
    final cartao = ServicoCartao(_db);
    if (l.tipo == TipoLancamento.pagamentoFatura) {
      await cartao.desfazerPagamento(l);
    } else if (l.formaPagamento == FormaPagamento.credito) {
      await cartao.excluirCompra(l, EscopoParcelas.soEsta);
    } else {
      // Se o lançamento pagava uma conta fixa, ela volta a ficar pendente.
      if (l.ocorrenciaCompromissoId != null) {
        await ServicoCompromisso(_db).reabrirOcorrenciaDoLancamento(id);
      }
      await _db.lancamentosDao.excluir(id);
    }
  }

  /// "Ajustar saldo": o dono informa o saldo real do banco e o app lança a
  /// diferença como `ajusteSaldo` (positivo ou negativo). Devolve a diferença.
  Future<int> ajustarSaldo({
    required int contaId,
    required int saldoReal,
    required int saldoAtual,
    DateTime? data,
  }) async {
    final diferenca = saldoReal - saldoAtual;
    if (diferenca == 0) return 0;
    await registrar(
      tipo: TipoLancamento.ajusteSaldo,
      valor: diferenca,
      data: data ?? DateTime.now(),
      descricao: 'Ajuste de saldo',
      contaId: contaId,
    );
    return diferenca;
  }

  /// Após a 1ª importação: muda o **saldo inicial** da conta para que o saldo
  /// atual passe a bater com o do banco (sem criar lançamento de ajuste).
  Future<void> ajustarSaldoInicial({
    required Conta conta,
    required int saldoReal,
    required int saldoAtual,
  }) async {
    final novo = conta.saldoInicial + (saldoReal - saldoAtual);
    await _db.contasDao.atualizar(conta.copyWith(saldoInicial: novo));
  }
}
