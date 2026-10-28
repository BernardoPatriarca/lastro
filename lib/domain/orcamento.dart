import 'resumo_mes.dart';

/// Faixas da barra de orçamento (CLAUDE.md 4.7).
enum NivelOrcamento {
  /// Menos de 80% do limite.
  verde,

  /// De 80% a 100% do limite.
  amarelo,

  /// Passou de 100%.
  vermelho,
}

/// Nível pelo gasto e limite (centavos): verde < 80%, amarelo 80–100%,
/// vermelho > 100%. Contas feitas só com inteiros (sem double).
NivelOrcamento nivelOrcamento(int gasto, int limite) {
  if (limite <= 0) return gasto > 0 ? NivelOrcamento.vermelho : NivelOrcamento.verde;
  if (gasto * 100 > limite * 100) return NivelOrcamento.vermelho; // gasto > limite
  if (gasto * 100 >= limite * 80) return NivelOrcamento.amarelo;
  return NivelOrcamento.verde;
}

/// Quanto do limite foi usado, de 0 a 1 para a barra (pode passar de 1 no texto).
double percentualUsado(int gasto, int limite) =>
    limite <= 0 ? (gasto > 0 ? 1 : 0) : (gasto / limite);

/// Soma os gastos por categoria contando cada gasto também na **categoria-pai**,
/// de modo que um orçamento definido no pai (Alimentação) inclua as
/// subcategorias (Mercado, Delivery…). [categoriaPai] mapeia id → id do pai.
Map<int, int> gastosAcumulados(
  Iterable<GastoSimples> gastos, {
  required Map<int, int?> categoriaPai,
}) {
  final soma = <int, int>{};
  for (final g in gastos) {
    final id = g.categoriaId;
    if (id == null) continue;
    soma[id] = (soma[id] ?? 0) + g.valor;
    final pai = categoriaPai[id];
    if (pai != null) soma[pai] = (soma[pai] ?? 0) + g.valor;
  }
  return soma;
}

/// Uma categoria na tela de orçamento.
class LinhaOrcamento {
  const LinhaOrcamento({
    required this.categoriaId,
    required this.gasto,
    this.limite,
  });

  final int categoriaId;
  final int gasto;

  /// Nulo quando a categoria não tem limite no mês.
  final int? limite;

  bool get temLimite => limite != null;
  NivelOrcamento? get nivel => limite == null ? null : nivelOrcamento(gasto, limite!);
  double get percentual => limite == null ? 0 : percentualUsado(gasto, limite!);
  int get restante => (limite ?? 0) - gasto;
}

/// Monta as linhas: categorias **com limite primeiro** (as mais estouradas no
/// topo), depois as sem limite por gasto decrescente.
List<LinhaOrcamento> montarOrcamento({
  required Iterable<int> categorias,
  required Map<int, int> limites,
  required Map<int, int> gastos,
}) {
  final linhas = [
    for (final c in categorias)
      LinhaOrcamento(categoriaId: c, gasto: gastos[c] ?? 0, limite: limites[c]),
  ];
  linhas.sort((a, b) {
    if (a.temLimite != b.temLimite) return a.temLimite ? -1 : 1;
    if (a.temLimite) return b.percentual.compareTo(a.percentual);
    return b.gasto.compareTo(a.gasto);
  });
  return linhas;
}

/// Limites a criar ao "copiar do mês anterior": os do mês anterior que ainda
/// não existem no mês atual (nunca sobrescreve o que o dono já definiu).
Map<int, int> limitesACopiar({
  required Map<int, int> mesAnterior,
  required Map<int, int> mesAtual,
}) =>
    {
      for (final e in mesAnterior.entries)
        if (!mesAtual.containsKey(e.key)) e.key: e.value,
    };
