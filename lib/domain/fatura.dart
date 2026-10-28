import 'competencia.dart';
import 'enums.dart';

/// Ciclo de uma fatura de cartão: mês de fechamento, fechamento e vencimento.
class CicloFatura {
  const CicloFatura({
    required this.competencia,
    required this.dataFechamento,
    required this.dataVencimento,
  });

  /// Mês em que a fatura **fecha**.
  final Competencia competencia;
  final DateTime dataFechamento;
  final DateTime dataVencimento;

  @override
  bool operator ==(Object other) =>
      other is CicloFatura &&
      other.competencia == competencia &&
      other.dataFechamento == dataFechamento &&
      other.dataVencimento == dataVencimento;

  @override
  int get hashCode => Object.hash(competencia, dataFechamento, dataVencimento);

  @override
  String toString() =>
      'Fatura $competencia (fecha $dataFechamento, vence $dataVencimento)';
}

/// Ciclo cuja fatura fecha no mês [competencia] (CLAUDE.md 5.3).
///
/// - Fechamento: [diaFechamento] daquele mês, limitado ao último dia
///   (fechamento dia 31 em fevereiro → 28/29).
/// - Vencimento: no mesmo mês; se o dia de vencimento for **menor** que o de
///   fechamento, cai no mês seguinte ao fechamento.
CicloFatura cicloDaCompetencia(
  Competencia competencia, {
  required int diaFechamento,
  required int diaVencimento,
}) {
  final fechamento = competencia.dia(diaFechamento);
  final mesVencimento = diaVencimento < diaFechamento
      ? competencia.somarMeses(1)
      : competencia;
  return CicloFatura(
    competencia: competencia,
    dataFechamento: fechamento,
    dataVencimento: mesVencimento.dia(diaVencimento),
  );
}

/// Fatura em que uma compra feita em [dataCompra] entra.
///
/// Antes do fechamento do mês → fatura que fecha neste mês; a partir do dia
/// do fechamento (inclusive) → fatura que fecha no mês seguinte.
CicloFatura cicloDaCompra(
  DateTime dataCompra, {
  required int diaFechamento,
  required int diaVencimento,
}) {
  var comp = Competencia.deData(dataCompra);
  final fechamento = comp.dia(diaFechamento);
  if (!dataCompra.isBefore(fechamento)) comp = comp.somarMeses(1);
  return cicloDaCompetencia(
    comp,
    diaFechamento: diaFechamento,
    diaVencimento: diaVencimento,
  );
}

/// Status "de verdade" da fatura hoje: paga continua paga; senão, fechada a
/// partir da data de fechamento e aberta antes dela.
StatusFatura statusEfetivo(
  StatusFatura gravado,
  DateTime dataFechamento,
  DateTime hoje,
) {
  if (gravado == StatusFatura.paga) return StatusFatura.paga;
  return hoje.isBefore(dataFechamento) ? StatusFatura.aberta : StatusFatura.fechada;
}
