import '../../domain/backup.dart';
import '../banco.dart';
import '../manutencao.dart';

/// Exporta e restaura o banco inteiro (CLAUDE.md seção 6).
class ServicoBackup {
  ServicoBackup(this._db);
  final AppDatabase _db;

  /// Lê todas as tabelas e monta o [Backup].
  Future<Backup> exportar({DateTime? agora}) async {
    final tabelas = <String, List<Map<String, Object?>>>{};
    for (final t in tabelasDoApp) {
      final linhas = await _db.customSelect('SELECT * FROM $t').get();
      tabelas[t] = [for (final l in linhas) Map<String, Object?>.from(l.data)];
    }
    return Backup(
      versaoSchema: AppDatabase.versaoSchema,
      exportadoEm: agora ?? DateTime.now(),
      tabelas: tabelas,
    );
  }

  /// Lê e valida o texto de um backup (sem tocar no banco).
  Backup ler(String texto) =>
      Backup.lerJson(texto, versaoAtual: AppDatabase.versaoSchema);

  /// Substitui **todos** os dados pelos do [backup], de forma atômica: se algo
  /// falhar no meio, nada muda. As chaves estrangeiras são checadas só no fim.
  Future<void> restaurar(Backup backup) async {
    // Tabelas desconhecidas (de outra versão) travam antes de qualquer escrita.
    for (final t in backup.tabelas.keys) {
      if (!tabelasDoApp.contains(t)) {
        throw BackupInvalido('O backup tem uma tabela desconhecida: "$t".');
      }
    }
    await _db.transaction(() async {
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final t in tabelasDoApp) {
        await _db.customStatement('DELETE FROM $t');
      }
      for (final t in tabelasDoApp) {
        for (final linha in backup.tabelas[t] ?? const <Map<String, Object?>>[]) {
          final colunas = linha.keys.toList();
          // Só aceita nomes de coluna seguros (letras, números e _).
          if (colunas.any((c) => !RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(c))) {
            throw BackupInvalido('Coluna inválida na tabela "$t".');
          }
          final marcadores = List.filled(colunas.length, '?').join(', ');
          await _db.customStatement(
            'INSERT INTO $t (${colunas.join(', ')}) VALUES ($marcadores)',
            [for (final c in colunas) linha[c]],
          );
        }
      }
    });
  }
}
