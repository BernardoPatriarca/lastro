import 'package:drift/drift.dart';

import '../banco.dart';
import '../tabelas.dart';

part 'mapeamentos_dao.g.dart';

/// Mapeamentos de colunas de CSV salvos por banco.
@DriftAccessor(tables: [MapeamentosCsv])
class MapeamentosDao extends DatabaseAccessor<AppDatabase>
    with _$MapeamentosDaoMixin {
  MapeamentosDao(super.db);

  Stream<List<MapeamentoCsvSalvo>> watchTodos() =>
      (select(mapeamentosCsv)..orderBy([(m) => OrderingTerm.asc(m.nome)])).watch();

  /// Insere ou atualiza pelo **nome** (um mapeamento por banco).
  Future<void> salvar(MapeamentosCsvCompanion m) => into(mapeamentosCsv).insert(
        m,
        onConflict: DoUpdate((_) => m, target: [mapeamentosCsv.nome]),
      );

  Future<int> excluir(int id) =>
      (delete(mapeamentosCsv)..where((m) => m.id.equals(id))).go();
}
