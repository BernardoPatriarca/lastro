import 'leitura.dart';
import 'transacao_importada.dart';

/// Resultado da leitura de um arquivo OFX.
class ExtratoOfx {
  const ExtratoOfx({
    required this.transacoes,
    this.ehCartao = false,
    this.saldoFinal,
    this.dataSaldo,
    this.idConta,
    this.moeda,
  });

  final List<TransacaoImportada> transacoes;

  /// `true` para fatura de cartão (`CCSTMTRS`), `false` para conta (`STMTRS`).
  final bool ehCartao;

  /// Saldo informado pelo banco (`LEDGERBAL`), em centavos.
  final int? saldoFinal;
  final DateTime? dataSaldo;
  final String? idConta;
  final String? moeda;
}

/// Algo parece um OFX?
bool pareceOfx(String texto) {
  final t = texto.length > 4000 ? texto.substring(0, 4000) : texto;
  return t.contains('OFXHEADER') || RegExp(r'<OFX>', caseSensitive: false).hasMatch(t);
}

/// Parser de OFX, nas duas variantes: SGML (v1.x, tags sem fechamento) e XML
/// (v2.x). Lê transações (`STMTTRN`), saldo (`LEDGERBAL`) e tipo de extrato.
ExtratoOfx lerOfx(String texto) {
  final inicio = texto.toUpperCase().indexOf('<OFX>');
  final corpo = inicio >= 0 ? texto.substring(inicio) : texto;

  final blocos = RegExp(
    r'<STMTTRN>(.*?)(?=</STMTTRN>|<STMTTRN>|</BANKTRANLIST>|</CCSTMTRS>|</STMTRS>)',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(corpo);

  final transacoes = <TransacaoImportada>[];
  for (final b in blocos) {
    final campos = _campos(b.group(1)!);
    final data = _dataOfx(campos['DTPOSTED'] ?? campos['DTUSER'] ?? '');
    final valor = parseCentavos(campos['TRNAMT'] ?? '');
    if (data == null || valor == null) continue;
    transacoes.add(TransacaoImportada(
      data: data,
      descricao: _descricao(campos['NAME'], campos['MEMO']),
      valor: valor,
      fitid: campos['FITID'],
    ));
  }

  int? saldo;
  DateTime? dataSaldo;
  final bal = RegExp(
    r'<LEDGERBAL>(.*?)(?=</LEDGERBAL>|<AVAILBAL>|</STMTRS>|</CCSTMTRS>|$)',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(corpo);
  if (bal != null) {
    final c = _campos(bal.group(1)!);
    saldo = parseCentavos(c['BALAMT'] ?? '');
    dataSaldo = _dataOfx(c['DTASOF'] ?? '');
  }

  final cab = _campos(corpo.split(RegExp(r'<STMTTRN>', caseSensitive: false)).first);
  return ExtratoOfx(
    transacoes: transacoes,
    ehCartao: RegExp(r'<CCSTMTRS>', caseSensitive: false).hasMatch(corpo),
    saldoFinal: saldo,
    dataSaldo: dataSaldo,
    idConta: cab['ACCTID'],
    moeda: cab['CURDEF'],
  );
}

/// Extrai `<TAG>valor` (com ou sem tag de fechamento) de um trecho.
Map<String, String> _campos(String trecho) {
  final mapa = <String, String>{};
  for (final m in RegExp(r'<([A-Za-z0-9.]+)>([^<]*)').allMatches(trecho)) {
    final tag = m.group(1)!.toUpperCase();
    final valor = _entidades(m.group(2)!.trim());
    if (valor.isNotEmpty) mapa.putIfAbsent(tag, () => valor);
  }
  return mapa;
}

String _descricao(String? nome, String? memo) {
  final n = (nome ?? '').trim();
  final m = (memo ?? '').trim();
  if (n.isEmpty) return m;
  if (m.isEmpty || m == n) return n;
  if (m.toLowerCase().contains(n.toLowerCase())) return m;
  return '$n - $m';
}

DateTime? _dataOfx(String valor) {
  final m = RegExp(r'^(\d{4})(\d{2})(\d{2})').firstMatch(valor.trim());
  if (m == null) return null;
  final ano = int.parse(m.group(1)!);
  final mes = int.parse(m.group(2)!);
  final dia = int.parse(m.group(3)!);
  if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return null;
  return DateTime(ano, mes, dia);
}

String _entidades(String s) => s
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m.group(1)!)));
