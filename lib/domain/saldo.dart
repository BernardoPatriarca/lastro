import 'enums.dart';

/// Visão mínima de um lançamento para o cálculo de saldo.
class MovimentoSaldo {
  const MovimentoSaldo({
    required this.tipo,
    required this.valor,
    required this.data,
    this.forma,
    this.contaId,
    this.contaDestinoId,
  });

  final TipoLancamento tipo;

  /// Centavos. Sempre positivo, exceto em [TipoLancamento.ajusteSaldo], onde o
  /// sinal define o sentido do ajuste.
  final int valor;
  final DateTime data;
  final FormaPagamento? forma;
  final int? contaId;
  final int? contaDestinoId;
}

/// Efeito de [m] no saldo da conta [contaId] (CLAUDE.md 5.2).
///
/// Compras no crédito **não** mexem no saldo da conta; só o pagamento da
/// fatura mexe.
int efeitoNoSaldo(MovimentoSaldo m, int contaId) {
  final naConta = m.contaId == contaId;
  switch (m.tipo) {
    case TipoLancamento.gasto:
      if (m.forma == FormaPagamento.credito) return 0;
      return naConta ? -m.valor : 0;
    case TipoLancamento.ganho:
    case TipoLancamento.resgate:
      return naConta ? m.valor : 0;
    case TipoLancamento.aporte:
    case TipoLancamento.pagamentoFatura:
      return naConta ? -m.valor : 0;
    case TipoLancamento.transferencia:
      if (naConta) return -m.valor;
      if (m.contaDestinoId == contaId) return m.valor;
      return 0;
    case TipoLancamento.ajusteSaldo:
      return naConta ? m.valor : 0;
  }
}

/// Saldo = saldo inicial + movimentos a partir da data do saldo inicial.
int calcularSaldoConta({
  required int contaId,
  required int saldoInicial,
  required DateTime dataSaldoInicial,
  required Iterable<MovimentoSaldo> movimentos,
}) {
  var saldo = saldoInicial;
  for (final m in movimentos) {
    if (m.data.isBefore(dataSaldoInicial)) continue;
    saldo += efeitoNoSaldo(m, contaId);
  }
  return saldo;
}
