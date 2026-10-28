import 'competencia.dart';
import 'enums.dart';
import 'fatura.dart';
import 'parcelas.dart';

/// Valor ainda não pago de uma fatura, para o cálculo do crédito seguro.
class ComprometimentoFatura {
  const ComprometimentoFatura(this.valor, {required this.futura});

  final int valor;

  /// `true` quando a fatura é de um ciclo posterior ao atual (só parcelas
  /// futuras caem nela); `false` para a fatura aberta do ciclo atual e as
  /// fechadas ainda não pagas.
  final bool futura;
}

/// Resultado do "Pode gastar no crédito" (CLAUDE.md 5.1).
class ResultadoCreditoSeguro {
  const ResultadoCreditoSeguro({
    required this.saldoContas,
    required this.comprometidoCartao,
    required this.fixosDescontados,
    required this.comprometidoProximasFaturas,
    required this.modo,
  });

  /// Saldo atual das contas marcadas "considerar no crédito seguro".
  final int saldoContas;

  /// O que o cartão já compromete do saldo (depende do [modo]).
  final int comprometidoCartao;

  /// Contas fixas pendentes subtraídas (0 se "descontar contas fixas" desligado).
  final int fixosDescontados;

  /// Parcelas de faturas futuras. No modo `rigido` já estão dentro de
  /// [comprometidoCartao]; no modo `parcela` são só informação.
  final int comprometidoProximasFaturas;
  final ModoParcelados modo;

  /// Quanto ainda dá para gastar no crédito (negativo = já passou do saldo).
  int get podeGastar => saldoContas - comprometidoCartao - fixosDescontados;

  bool get negativo => podeGastar < 0;

  /// Parte do saldo já comprometida, de 0 a 1 (1 quando saldo ≤ 0 e há dívida).
  double get percentualComprometido {
    final usado = comprometidoCartao + fixosDescontados;
    if (usado <= 0) return 0;
    if (saldoContas <= 0) return 1;
    return (usado / saldoContas).clamp(0, 1).toDouble();
  }
}

/// pode_gastar_no_credito =
///   saldo das contas marcadas
///   − compromisso no cartão (modo `rigido`: tudo que não foi pago, inclusive
///     parcelas futuras; modo `parcela`: só faturas abertas e fechadas)
///   − contas fixas pendentes (se [descontarFixos])
ResultadoCreditoSeguro calcularCreditoSeguro({
  required int saldoContas,
  required Iterable<ComprometimentoFatura> faturasNaoPagas,
  required int fixosPendentes,
  required ModoParcelados modo,
  required bool descontarFixos,
}) {
  var atuais = 0;
  var futuras = 0;
  for (final f in faturasNaoPagas) {
    if (f.futura) {
      futuras += f.valor;
    } else {
      atuais += f.valor;
    }
  }
  return ResultadoCreditoSeguro(
    saldoContas: saldoContas,
    comprometidoCartao: modo == ModoParcelados.rigido ? atuais + futuras : atuais,
    fixosDescontados: descontarFixos ? fixosPendentes : 0,
    comprometidoProximasFaturas: futuras,
    modo: modo,
  );
}

/// Uma fatura é "futura" quando fecha depois da fatura do ciclo de hoje.
bool faturaEhFutura(Competencia faturaCompetencia, CicloFatura cicloAtual) =>
    faturaCompetencia > cicloAtual.competencia;

/// Até quando as contas fixas pendentes entram no cálculo: o vencimento da
/// fatura do ciclo atual (o mais distante entre os cartões, para ficar do lado
/// seguro). Sem cartões, vale o fim do mês de [hoje].
DateTime horizonteContasFixas({
  required Iterable<DateTime> vencimentosFaturaAtual,
  required DateTime hoje,
}) {
  DateTime? maior;
  for (final v in vencimentosFaturaAtual) {
    if (maior == null || v.isAfter(maior)) maior = v;
  }
  return maior ?? Competencia.deData(hoje).ultimoDia;
}

/// Quanto de uma compra nova pesa no cálculo: tudo no modo `rigido`; no modo
/// `parcela`, só as parcelas que caem na fatura atual ou em faturas fechadas.
int valorQuePesaDaCompra({
  required List<ParcelaGerada> parcelas,
  required CicloFatura cicloAtual,
  required ModoParcelados modo,
}) {
  var total = 0;
  for (final p in parcelas) {
    if (modo == ModoParcelados.rigido ||
        !faturaEhFutura(p.ciclo.competencia, cicloAtual)) {
      total += p.valor;
    }
  }
  return total;
}

/// Impacto de uma compra no crédito sobre o "pode gastar".
class ImpactoCompra {
  const ImpactoCompra({required this.sobra});

  /// "Depois dessa compra sobra R$ X" (negativo = estoura).
  final int sobra;

  bool get estoura => sobra < 0;

  /// Quanto a fatura passa do saldo (positivo só quando [estoura]).
  int get acimaDoSaldo => estoura ? -sobra : 0;
}

ImpactoCompra calcularImpactoCompra({
  required ResultadoCreditoSeguro atual,
  required int valorQuePesa,
}) =>
    ImpactoCompra(sobra: atual.podeGastar - valorQuePesa);
