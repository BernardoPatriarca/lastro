/// Normaliza texto para comparação: minúsculas, sem acentos, espaços únicos.
/// Usado em busca, regras de categorização e chave de deduplicação.
String normalizarTexto(String texto) {
  const de = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
  const para = 'aaaaaaceeeeiiiinooooouuuuyy';
  final buffer = StringBuffer();
  for (final r in texto.toLowerCase().runes) {
    final c = String.fromCharCode(r);
    final i = de.indexOf(c);
    buffer.write(i >= 0 ? para[i] : c);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
