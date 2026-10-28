import 'competencia.dart';
import 'enums.dart';

/// Lançamento reduzido ao que os relatórios precisam.
class LancRelatorio {
  const LancRelatorio({
    required this.data,
    required this.tipo,
    required this.valor,
    this.categoriaId,
    this.fixo = false,
  });

  final DateTime data;
  final TipoLancamento tipo;
  final int valor;
  final int? categoriaId;

  /// Gasto fixo: paga um compromisso (aluguel, financiamento...) ou é parcela
  /// de compra parcelada no cartão. O resto é gasto variável.
  final bool fixo;
}

/// Totais de um mês para o gráfico de evolução.
class PontoMensal {
  const PontoMensal({
    required this.competencia,
    required this.ganhos,
    required this.gastos,
    required this.investido,
  });

  final Competencia competencia;
  final int ganhos;
  final int gastos;
  final int investido;

  int get saldo => ganhos - gastos;
}

/// Ganhos × gastos × investido dos últimos [meses] meses, terminando em [fim].
/// Meses sem lançamentos entram zerados (o gráfico mantém a sequência).
List<PontoMensal> evolucaoMensal(
  Iterable<LancRelatorio> lancs, {
  required Competencia fim,
  int meses = 6,
}) {
  final ganhos = <Competencia, int>{};
  final gastos = <Competencia, int>{};
  final investido = <Competencia, int>{};
  for (final l in lancs) {
    final c = Competencia.deData(l.data);
    switch (l.tipo) {
      case TipoLancamento.ganho:
        ganhos[c] = (ganhos[c] ?? 0) + l.valor;
      case TipoLancamento.gasto:
        gastos[c] = (gastos[c] ?? 0) + l.valor;
      case TipoLancamento.aporte:
        investido[c] = (investido[c] ?? 0) + l.valor;
      default:
        break;
    }
  }
  return [
    for (var i = meses - 1; i >= 0; i--)
      PontoMensal(
        competencia: fim.somarMeses(-i),
        ganhos: ganhos[fim.somarMeses(-i)] ?? 0,
        gastos: gastos[fim.somarMeses(-i)] ?? 0,
        investido: investido[fim.somarMeses(-i)] ?? 0,
      ),
  ];
}

/// Gasto por categoria em [mes] (só gastos; sem categoria fica em `null`).
Map<int?, int> gastosPorCategoriaNoMes(Iterable<LancRelatorio> lancs, Competencia mes) {
  final m = <int?, int>{};
  for (final l in lancs) {
    if (l.tipo != TipoLancamento.gasto || !mes.contem(l.data)) continue;
    m[l.categoriaId] = (m[l.categoriaId] ?? 0) + l.valor;
  }
  return m;
}

/// Uma categoria comparada com o mês anterior.
class ComparativoCategoria {
  const ComparativoCategoria({
    required this.categoriaId,
    required this.atual,
    required this.anterior,
  });

  final int? categoriaId;
  final int atual;
  final int anterior;

  int get diferenca => atual - anterior;

  /// Variação em % (inteiro). Nula quando não havia gasto no mês anterior.
  int? get variacaoPercentual =>
      anterior == 0 ? null : ((atual - anterior) * 100 / anterior).round();

  bool get ehNova => anterior == 0 && atual > 0;
}

/// Compara os gastos por categoria de dois meses; da que mais gastou agora
/// para a que menos (categorias só do mês anterior vêm por último).
List<ComparativoCategoria> comparativoPorCategoria({
  required Map<int?, int> atual,
  required Map<int?, int> anterior,
}) {
  final chaves = {...atual.keys, ...anterior.keys};
  final lista = [
    for (final c in chaves)
      ComparativoCategoria(categoriaId: c, atual: atual[c] ?? 0, anterior: anterior[c] ?? 0),
  ]..sort((a, b) {
      final porAtual = b.atual.compareTo(a.atual);
      return porAtual != 0 ? porAtual : b.anterior.compareTo(a.anterior);
    });
  return lista;
}

/// Média mensal de gasto por categoria nos últimos [meses] meses (divide
/// sempre por [meses], contando meses sem gasto como zero), da maior para a
/// menor.
List<MapEntry<int?, int>> mediaMensalPorCategoria(
  Iterable<LancRelatorio> lancs, {
  required Competencia fim,
  int meses = 6,
}) {
  final inicio = fim.somarMeses(-(meses - 1)).primeiroDia;
  final soma = <int?, int>{};
  for (final l in lancs) {
    if (l.tipo != TipoLancamento.gasto) continue;
    if (l.data.isBefore(inicio) || l.data.isAfter(fim.ultimoDia)) continue;
    soma[l.categoriaId] = (soma[l.categoriaId] ?? 0) + l.valor;
  }
  return [for (final e in soma.entries) MapEntry(e.key, e.value ~/ meses)]
    ..sort((a, b) => b.value.compareTo(a.value));
}

/// Gastos fixos × variáveis no período.
class FixosVariaveis {
  const FixosVariaveis({required this.fixos, required this.variaveis});
  final int fixos;
  final int variaveis;

  int get total => fixos + variaveis;

  /// Parte dos gastos que é fixa, de 0 a 100 (inteiro).
  int get percentualFixos => total == 0 ? 0 : (fixos * 100 / total).round();
}

FixosVariaveis fixosVariaveis(
  Iterable<LancRelatorio> lancs, {
  required Competencia fim,
  int meses = 6,
}) {
  final inicio = fim.somarMeses(-(meses - 1)).primeiroDia;
  var fixos = 0, variaveis = 0;
  for (final l in lancs) {
    if (l.tipo != TipoLancamento.gasto) continue;
    if (l.data.isBefore(inicio) || l.data.isAfter(fim.ultimoDia)) continue;
    if (l.fixo) {
      fixos += l.valor;
    } else {
      variaveis += l.valor;
    }
  }
  return FixosVariaveis(fixos: fixos, variaveis: variaveis);
}
