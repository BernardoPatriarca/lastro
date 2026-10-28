/// Gasto reduzido ao que o agrupamento por categoria precisa.
class GastoSimples {
  const GastoSimples(this.categoriaId, this.valor);
  final int? categoriaId;
  final int valor;
}

/// Total de uma categoria (ou de "sem categoria" quando [categoriaId] é nulo).
class FatiaCategoria {
  const FatiaCategoria(this.categoriaId, this.valor);
  final int? categoriaId;
  final int valor;

  @override
  String toString() => 'Fatia($categoriaId, $valor)';
}

/// Soma os gastos por categoria, da maior para a menor.
///
/// Com [agruparNoPai] as subcategorias entram na categoria-pai
/// (Mercado + Delivery → Alimentação); [categoriaPai] mapeia id → id do pai.
List<FatiaCategoria> gastosPorCategoria(
  Iterable<GastoSimples> gastos, {
  Map<int, int?> categoriaPai = const {},
  bool agruparNoPai = true,
}) {
  final soma = <int?, int>{};
  for (final g in gastos) {
    var id = g.categoriaId;
    if (agruparNoPai && id != null) id = categoriaPai[id] ?? id;
    soma[id] = (soma[id] ?? 0) + g.valor;
  }
  final lista = [for (final e in soma.entries) FatiaCategoria(e.key, e.value)]
    ..sort((a, b) => b.valor.compareTo(a.valor));
  return lista;
}

/// Mantém as [limite] maiores fatias e junta o resto em uma só (id nulo não é
/// usado aqui: o resto vai em [FatiaCategoria] com `categoriaId == -1`).
List<FatiaCategoria> limitarFatias(List<FatiaCategoria> fatias, int limite) {
  if (fatias.length <= limite) return fatias;
  final resto = fatias.skip(limite).fold<int>(0, (s, f) => s + f.valor);
  return [...fatias.take(limite), FatiaCategoria(idOutras, resto)];
}

/// Id sentinela da fatia "Outras" criada por [limitarFatias].
const idOutras = -1;

/// Uma conta que vence no mês: fatura de cartão ou conta fixa.
class ContaDoMes {
  const ContaDoMes({
    required this.descricao,
    required this.valor,
    required this.vencimento,
    required this.paga,
    required this.ehFatura,
    this.referenciaId,
    this.podePagar = true,
  });

  final String descricao;
  final int valor;
  final DateTime vencimento;
  final bool paga;
  final bool ehFatura;

  /// Id da fatura ou da ocorrência, para o atalho de pagar.
  final int? referenciaId;

  /// Falso para contas apenas previstas (ainda não geradas).
  final bool podePagar;
}

/// Quanto já foi pago e quanto falta pagar no mês.
class ResumoContasDoMes {
  const ResumoContasDoMes({required this.pago, required this.falta});
  final int pago;
  final int falta;

  int get total => pago + falta;
  double get percentualPago => total <= 0 ? 0 : pago / total;
}

ResumoContasDoMes resumirContasDoMes(Iterable<ContaDoMes> contas) {
  var pago = 0, falta = 0;
  for (final c in contas) {
    if (c.paga) {
      pago += c.valor;
    } else {
      falta += c.valor;
    }
  }
  return ResumoContasDoMes(pago: pago, falta: falta);
}
