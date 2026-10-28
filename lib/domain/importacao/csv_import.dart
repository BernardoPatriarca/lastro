import 'package:csv/csv.dart';

import '../texto.dart';
import 'leitura.dart';
import 'transacao_importada.dart';

/// Como ler as colunas de um CSV de extrato (salvo por banco).
class MapeamentoCsv {
  const MapeamentoCsv({
    required this.colunaData,
    required this.colunaDescricao,
    required this.colunaValor,
    this.colunaTipo,
    this.formatoData = 'dd/MM/yyyy',
    this.separador = ';',
    this.temCabecalho = true,
    this.positivoEhGasto = false,
  });

  final int colunaData;
  final int colunaDescricao;
  final int colunaValor;

  /// Coluna opcional com "Débito"/"Crédito" (ou D/C, Entrada/Saída).
  final int? colunaTipo;
  final String formatoData;
  final String separador;
  final bool temCabecalho;

  /// Faturas de cartão costumam trazer compras como valor positivo.
  final bool positivoEhGasto;

  MapeamentoCsv copiar({
    int? colunaData,
    int? colunaDescricao,
    int? colunaValor,
    int? Function()? colunaTipo,
    String? formatoData,
    String? separador,
    bool? temCabecalho,
    bool? positivoEhGasto,
  }) =>
      MapeamentoCsv(
        colunaData: colunaData ?? this.colunaData,
        colunaDescricao: colunaDescricao ?? this.colunaDescricao,
        colunaValor: colunaValor ?? this.colunaValor,
        colunaTipo: colunaTipo != null ? colunaTipo() : this.colunaTipo,
        formatoData: formatoData ?? this.formatoData,
        separador: separador ?? this.separador,
        temCabecalho: temCabecalho ?? this.temCabecalho,
        positivoEhGasto: positivoEhGasto ?? this.positivoEhGasto,
      );
}

/// Formatos de data oferecidos na tela de mapeamento.
const formatosDeData = [
  'dd/MM/yyyy',
  'dd/MM/yy',
  'yyyy-MM-dd',
  'dd-MM-yyyy',
  'dd.MM.yyyy',
  'MM/dd/yyyy',
];

/// Descobre o separador olhando a primeira linha: `;`, `,` ou tab.
String detectarSeparador(String texto) {
  final primeira = texto.split(RegExp(r'\r?\n')).firstWhere(
        (l) => l.trim().isNotEmpty,
        orElse: () => '',
      );
  var melhor = ';';
  var max = -1;
  for (final s in [';', '\t', ',']) {
    final n = s.allMatches(primeira).length;
    if (n > max) {
      max = n;
      melhor = s;
    }
  }
  return melhor;
}

/// Quebra o CSV em linhas de células (texto puro, sem converter números).
List<List<String>> lerCsv(String texto, {String? separador}) {
  final sep = separador ?? detectarSeparador(texto);
  final linhas = Csv(
    fieldDelimiter: sep,
    autoDetect: false,
    skipEmptyLines: true,
  ).decode(texto);
  return [
    for (final l in linhas)
      [for (final c in l) '$c'.trim()],
  ].where((l) => l.any((c) => c.isNotEmpty)).toList();
}

/// Chuta um mapeamento olhando os nomes das colunas do cabeçalho.
MapeamentoCsv sugerirMapeamento(List<String> cabecalho, {String separador = ';'}) {
  int? achar(List<String> chaves) {
    for (var i = 0; i < cabecalho.length; i++) {
      final c = normalizarTexto(cabecalho[i]);
      if (chaves.any(c.contains)) return i;
    }
    return null;
  }

  return MapeamentoCsv(
    colunaData: achar(['data', 'date', 'dt']) ?? 0,
    colunaDescricao:
        achar(['descri', 'historico', 'lancamento', 'estabelecimento', 'memo', 'detalhe']) ?? 1,
    colunaValor: achar(['valor', 'amount', 'quantia', 'montante']) ?? 2,
    colunaTipo: achar(['tipo', 'natureza', 'debito/credito', 'd/c']),
    separador: separador,
  );
}

/// Resultado da conversão de um CSV.
class ResultadoCsv {
  const ResultadoCsv(this.transacoes, this.ignoradas);
  final List<TransacaoImportada> transacoes;

  /// Linhas que não deu para ler (data ou valor inválidos).
  final int ignoradas;
}

/// Converte as linhas do CSV em transações segundo o [m].
///
/// Sinal: com coluna de tipo, "débito/saída/compra…" vira saída e
/// "crédito/entrada…" vira entrada (qualquer sinal no valor é ignorado);
/// sem ela vale o sinal do valor (negativo = saída). [MapeamentoCsv.positivoEhGasto]
/// inverte o sentido (faturas que listam compras como positivas).
ResultadoCsv converterCsv(List<List<String>> linhas, MapeamentoCsv m) {
  final corpo = m.temCabecalho ? linhas.skip(1) : linhas;
  final maior = [m.colunaData, m.colunaDescricao, m.colunaValor, m.colunaTipo ?? 0]
      .reduce((a, b) => a > b ? a : b);
  final saida = <TransacaoImportada>[];
  var ignoradas = 0;

  for (final l in corpo) {
    if (l.length <= maior) {
      ignoradas++;
      continue;
    }
    final data = parseDataComFormato(l[m.colunaData], m.formatoData);
    var valor = parseCentavos(l[m.colunaValor]);
    if (data == null || valor == null) {
      ignoradas++;
      continue;
    }
    final tipo = m.colunaTipo == null ? '' : normalizarTexto(l[m.colunaTipo!]);
    if (tipo.isNotEmpty) {
      final saidaTipo = RegExp(r'\b(d|deb|debito|saida|compra|pagamento|pagto)\b|deb|saida')
          .hasMatch(tipo);
      final entradaTipo = RegExp(r'\b(c|cred|credito|entrada|deposito)\b|cred|entrada|deposit')
          .hasMatch(tipo);
      if (saidaTipo && !entradaTipo) {
        valor = -valor.abs();
      } else if (entradaTipo && !saidaTipo) {
        valor = valor.abs();
      } else if (m.positivoEhGasto) {
        valor = -valor;
      }
    } else if (m.positivoEhGasto) {
      valor = -valor;
    }
    saida.add(TransacaoImportada(
      data: data,
      descricao: l[m.colunaDescricao].trim(),
      valor: valor,
    ));
  }
  return ResultadoCsv(saida, ignoradas);
}
