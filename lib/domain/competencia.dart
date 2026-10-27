import 'datas.dart';

/// Competência = mês contábil (`ano-mês`), ex.: `2026-03`.
class Competencia implements Comparable<Competencia> {
  const Competencia(this.ano, this.mes)
      : assert(mes >= 1 && mes <= 12, 'mês inválido');

  factory Competencia.deData(DateTime d) => Competencia(d.year, d.month);

  /// Lê `2026-03`.
  factory Competencia.parse(String texto) {
    final p = texto.split('-');
    return Competencia(int.parse(p[0]), int.parse(p[1]));
  }

  final int ano;
  final int mes;

  /// Forma gravada no banco: `2026-03`.
  String get chave => '$ano-${mes.toString().padLeft(2, '0')}';

  Competencia somarMeses(int n) {
    final total = ano * 12 + (mes - 1) + n;
    return Competencia(total ~/ 12, total % 12 + 1);
  }

  DateTime get primeiroDia => DateTime(ano, mes, 1);
  DateTime get ultimoDia => DateTime(ano, mes, diasNoMes(ano, mes));

  /// Dia [d] deste mês, limitado ao último dia (dia 31 em fevereiro → 28/29).
  DateTime dia(int d) => dataLimitada(ano, mes, d);

  bool contem(DateTime d) => d.year == ano && d.month == mes;

  @override
  int compareTo(Competencia other) =>
      (ano * 12 + mes).compareTo(other.ano * 12 + other.mes);

  bool operator <(Competencia o) => compareTo(o) < 0;
  bool operator <=(Competencia o) => compareTo(o) <= 0;
  bool operator >(Competencia o) => compareTo(o) > 0;
  bool operator >=(Competencia o) => compareTo(o) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Competencia && other.ano == ano && other.mes == mes;

  @override
  int get hashCode => ano * 12 + mes;

  @override
  String toString() => chave;
}
