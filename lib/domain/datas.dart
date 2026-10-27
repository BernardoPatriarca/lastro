// Utilitários de data. Datas são sempre "data local" (sem hora).

DateTime soData(DateTime d) => DateTime(d.year, d.month, d.day);

int diasNoMes(int ano, int mes) => DateTime(ano, mes + 1, 0).day;

/// Monta a data limitando o dia ao último dia do mês
/// (ex.: dia 31 em fevereiro → 28 ou 29).
DateTime dataLimitada(int ano, int mes, int dia) {
  final ultimo = diasNoMes(ano, mes);
  return DateTime(ano, mes, dia > ultimo ? ultimo : (dia < 1 ? 1 : dia));
}

/// Soma [meses] mantendo o dia, limitado ao fim do mês de destino.
DateTime somarMeses(DateTime d, int meses) {
  final total = d.year * 12 + (d.month - 1) + meses;
  return dataLimitada(total ~/ 12, total % 12 + 1, d.day);
}

bool mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
