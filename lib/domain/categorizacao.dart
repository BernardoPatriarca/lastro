import 'texto.dart';

/// Regra de categorização reduzida ao que o cálculo precisa.
class RegraSimples {
  const RegraSimples({
    required this.id,
    required this.padrao,
    required this.categoriaId,
    this.prioridade = 0,
  });

  final int id;

  /// Texto procurado na descrição (sem acento, sem diferenciar maiúsculas).
  final String padrao;
  final int categoriaId;
  final int prioridade;
}

/// Categoria sugerida para [descricao], ou `null` se nenhuma regra casar.
///
/// Uma regra casa quando a descrição normalizada **contém** o padrão
/// normalizado. Havendo várias, vence a de maior prioridade; empate → o padrão
/// mais longo (mais específico); novo empate → a regra mais antiga (menor id).
int? categoriaSugerida(String descricao, Iterable<RegraSimples> regras) {
  final alvo = normalizarTexto(descricao);
  if (alvo.isEmpty) return null;
  RegraSimples? melhor;
  var melhorPadrao = '';
  for (final r in regras) {
    final padrao = normalizarTexto(r.padrao);
    if (padrao.isEmpty || !alvo.contains(padrao)) continue;
    final ganha = melhor == null ||
        r.prioridade > melhor.prioridade ||
        (r.prioridade == melhor.prioridade &&
            (padrao.length > melhorPadrao.length ||
                (padrao.length == melhorPadrao.length && r.id < melhor.id)));
    if (ganha) {
      melhor = r;
      melhorPadrao = padrao;
    }
  }
  return melhor?.categoriaId;
}

/// Palavras de ruído comuns em extratos, ignoradas ao sugerir um padrão.
const _ruido = {
  'compra', 'compras', 'pix', 'debito', 'credito', 'pagamento', 'pagto',
  'transferencia', 'transf', 'cartao', 'cartoes', 'recebido', 'enviado',
  'para', 'de', 'do', 'da', 'no', 'na', 'em', 'a', 'o', 'via', 'ref',
  'parcela', 'saque', 'tarifa', 'ltda', 'sa', 'me', 'epp',
};

/// Sugere um padrão curto a partir de uma descrição de extrato, para a pergunta
/// "Criar regra: descrições com 'XXXX' → Categoria".
///
/// Tira números, datas e palavras de ruído e fica com as primeiras palavras
/// úteis (até 2). Ex.: `COMPRA CARTAO MERCADO LIVRE 12/03` → `mercado livre`.
String sugerirPadrao(String descricao) {
  final limpo = normalizarTexto(descricao)
      .replaceAll(RegExp(r'[0-9]+'), ' ')
      .replaceAll(RegExp(r'[^a-z\s]'), ' ');
  final palavras = [
    for (final p in limpo.split(RegExp(r'\s+')))
      if (p.length >= 3 && !_ruido.contains(p)) p,
  ];
  if (palavras.isEmpty) return normalizarTexto(descricao);
  return palavras.take(2).join(' ');
}
