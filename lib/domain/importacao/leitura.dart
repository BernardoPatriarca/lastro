import 'dart:convert';
import 'dart:typed_data';

/// Converte os bytes de um arquivo em texto: UTF-8 quando válido; senão
/// Latin-1 (padrão de muitos bancos, `CHARSET:1252`). Remove o BOM.
String decodificarTexto(Uint8List bytes) {
  String texto;
  try {
    texto = const Utf8Decoder().convert(bytes);
  } on FormatException {
    texto = latin1.decode(bytes);
  }
  return texto.startsWith('﻿') ? texto.substring(1) : texto;
}

/// Lê um valor em reais ("1.234,56", "-12.5", "(30,00)", "R\$ 5") como
/// centavos, **sem passar por double**. Devolve `null` se não for número.
int? parseCentavos(String entrada) {
  var s = entrada
      .replaceAll('R\$', '')
      .replaceAll(RegExp(r'[\s ]'), '');
  if (s.isEmpty) return null;

  var negativo = false;
  if (s.startsWith('(') && s.endsWith(')')) {
    negativo = true;
    s = s.substring(1, s.length - 1);
  }
  if (s.startsWith('-')) {
    negativo = !negativo;
    s = s.substring(1);
  } else if (s.startsWith('+')) {
    s = s.substring(1);
  }
  if (s.endsWith('-')) {
    negativo = !negativo;
    s = s.substring(0, s.length - 1);
  }
  if (s.isEmpty || !RegExp(r'^[0-9.,]+$').hasMatch(s)) return null;

  // Descobre qual caractere é o separador decimal.
  final ultimaVirgula = s.lastIndexOf(',');
  final ultimoPonto = s.lastIndexOf('.');
  String inteiros;
  String decimais = '';
  if (ultimaVirgula >= 0 && ultimoPonto >= 0) {
    final decimal = ultimaVirgula > ultimoPonto ? ',' : '.';
    final i = s.lastIndexOf(decimal);
    inteiros = s.substring(0, i);
    decimais = s.substring(i + 1);
  } else if (ultimaVirgula >= 0 || ultimoPonto >= 0) {
    final sep = ultimaVirgula >= 0 ? ',' : '.';
    final partes = s.split(sep);
    final depois = partes.last;
    // Vários separadores iguais, ou 3 dígitos depois de um só = milhar
    // (a menos que comece com 0: "0.126" é decimal).
    final ehMilhar = partes.length > 2 ||
        (depois.length == 3 &&
            partes.length == 2 &&
            partes.first != '0' &&
            partes.first.length <= 3);
    if (ehMilhar) {
      inteiros = partes.join();
    } else {
      inteiros = partes.first;
      decimais = depois;
    }
  } else {
    inteiros = s;
  }
  inteiros = inteiros.replaceAll(RegExp(r'[.,]'), '');
  decimais = decimais.replaceAll(RegExp(r'[.,]'), '');
  if (inteiros.isEmpty) inteiros = '0';
  if (!RegExp(r'^\d+$').hasMatch(inteiros) ||
      (decimais.isNotEmpty && !RegExp(r'^\d+$').hasMatch(decimais))) {
    return null;
  }

  var centavos = int.parse(inteiros) * 100;
  if (decimais.isNotEmpty) {
    final dois = decimais.padRight(2, '0').substring(0, 2);
    centavos += int.parse(dois);
    // Arredonda pela terceira casa (meio centavo sobe).
    if (decimais.length > 2 && int.parse(decimais[2]) >= 5) centavos += 1;
  }
  return negativo ? -centavos : centavos;
}

/// Lê uma data segundo o [formato] (`dd/MM/yyyy`, `dd/MM/yy`, `yyyy-MM-dd`,
/// `MM/dd/yyyy`, `dd-MM-yyyy`, `dd.MM.yyyy`...). Aceita hora depois da data.
DateTime? parseDataComFormato(String entrada, String formato) {
  final texto = entrada.trim();
  final numeros = RegExp(r'\d+').allMatches(texto).map((m) => m.group(0)!).toList();
  final tokens = RegExp(r'd+|M+|y+').allMatches(formato).map((m) => m.group(0)!).toList();
  if (numeros.length < tokens.length) {
    // "20260305" sem separadores
    final colado = RegExp(r'^\d{8}').firstMatch(texto);
    if (colado != null && formato.replaceAll(RegExp(r'[^dMy]'), '').length == 8) {
      return _montar(
        int.parse(texto.substring(0, 4)),
        int.parse(texto.substring(4, 6)),
        int.parse(texto.substring(6, 8)),
      );
    }
    return null;
  }
  int? dia, mes, ano;
  for (var i = 0; i < tokens.length; i++) {
    final v = int.parse(numeros[i]);
    switch (tokens[i][0]) {
      case 'd':
        dia = v;
      case 'M':
        mes = v;
      case 'y':
        ano = tokens[i].length <= 2 || numeros[i].length <= 2 ? 2000 + v : v;
    }
  }
  if (dia == null || mes == null || ano == null) return null;
  return _montar(ano, mes, dia);
}

DateTime? _montar(int ano, int mes, int dia) {
  if (mes < 1 || mes > 12 || dia < 1 || ano < 1900 || ano > 2200) return null;
  final d = DateTime(ano, mes, dia);
  // Rejeita datas que "rolaram" (31/02 vira março).
  if (d.month != mes || d.day != dia) return null;
  return d;
}
