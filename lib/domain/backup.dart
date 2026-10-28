import 'dart:convert';

import 'datas.dart';

/// Backup do app: versão do schema + todas as linhas de todas as tabelas.
///
/// Formato JSON, legível: `{formato, versaoSchema, exportadoEm, tabelas}`.
/// Cada tabela é uma lista de linhas `{coluna: valor}` com os valores crus do
/// SQLite (inteiros, textos e nulos), de modo que restaurar reproduz o banco.
class Backup {
  const Backup({
    required this.versaoSchema,
    required this.exportadoEm,
    required this.tabelas,
  });

  static const formato = 'lastro-backup';

  final int versaoSchema;
  final DateTime exportadoEm;
  final Map<String, List<Map<String, Object?>>> tabelas;

  String paraJson() => const JsonEncoder.withIndent(' ').convert({
        'formato': formato,
        'versaoSchema': versaoSchema,
        'exportadoEm': exportadoEm.toIso8601String(),
        'tabelas': tabelas,
      });

  /// Lê e valida um backup. Lança [BackupInvalido] com mensagem amigável.
  /// [versaoAtual] é a versão do schema do app: backups de versão **mais nova**
  /// são recusados (o app não sabe lê-los); mais antigos são aceitos.
  static Backup lerJson(String texto, {required int versaoAtual}) {
    final Object? bruto;
    try {
      bruto = jsonDecode(texto);
    } on FormatException {
      throw const BackupInvalido('O arquivo não é um backup do Lastro (JSON inválido).');
    }
    if (bruto is! Map<String, dynamic> || bruto['formato'] != formato) {
      throw const BackupInvalido('Este arquivo não é um backup do Lastro.');
    }
    final versao = bruto['versaoSchema'];
    if (versao is! int || versao < 1) {
      throw const BackupInvalido('Backup sem versão válida.');
    }
    if (versao > versaoAtual) {
      throw BackupInvalido(
        'Este backup é de uma versão mais nova do app (v$versao). '
        'Atualize o Lastro para restaurá-lo.',
      );
    }
    final tabelasBrutas = bruto['tabelas'];
    if (tabelasBrutas is! Map<String, dynamic>) {
      throw const BackupInvalido('Backup sem dados.');
    }
    final tabelas = <String, List<Map<String, Object?>>>{};
    for (final e in tabelasBrutas.entries) {
      final linhas = e.value;
      if (linhas is! List) {
        throw BackupInvalido('Tabela "${e.key}" está corrompida.');
      }
      tabelas[e.key] = [
        for (final l in linhas)
          if (l is Map<String, dynamic>)
            Map<String, Object?>.from(l)
          else
            throw BackupInvalido('Tabela "${e.key}" está corrompida.'),
      ];
    }
    return Backup(
      versaoSchema: versao,
      exportadoEm: DateTime.tryParse('${bruto['exportadoEm']}') ?? DateTime.now(),
      tabelas: tabelas,
    );
  }

  /// Resumo para mostrar antes de restaurar.
  ResumoBackup resumir() {
    int contar(String t) => tabelas[t]?.length ?? 0;
    DateTime? menor, maior;
    for (final l in tabelas['lancamentos'] ?? const <Map<String, Object?>>[]) {
      final v = l['data'];
      if (v is! int) continue;
      final d = DateTime(v ~/ 10000, (v ~/ 100) % 100, v % 100);
      if (menor == null || d.isBefore(menor)) menor = d;
      if (maior == null || d.isAfter(maior)) maior = d;
    }
    return ResumoBackup(
      lancamentos: contar('lancamentos'),
      contas: contar('contas'),
      cartoes: contar('cartoes'),
      categorias: contar('categorias'),
      compromissos: contar('compromissos'),
      primeiroLancamento: menor == null ? null : soData(menor),
      ultimoLancamento: maior == null ? null : soData(maior),
      exportadoEm: exportadoEm,
      versaoSchema: versaoSchema,
    );
  }
}

class ResumoBackup {
  const ResumoBackup({
    required this.lancamentos,
    required this.contas,
    required this.cartoes,
    required this.categorias,
    required this.compromissos,
    required this.exportadoEm,
    required this.versaoSchema,
    this.primeiroLancamento,
    this.ultimoLancamento,
  });

  final int lancamentos;
  final int contas;
  final int cartoes;
  final int categorias;
  final int compromissos;
  final DateTime? primeiroLancamento;
  final DateTime? ultimoLancamento;
  final DateTime exportadoEm;
  final int versaoSchema;
}

class BackupInvalido implements Exception {
  const BackupInvalido(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}
