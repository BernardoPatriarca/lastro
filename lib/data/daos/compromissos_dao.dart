import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../banco.dart';
import '../tabelas.dart';

part 'compromissos_dao.g.dart';

@DriftAccessor(
  tables: [Compromissos, OcorrenciasCompromisso, ReceitasRecorrentes],
)
class CompromissosDao extends DatabaseAccessor<AppDatabase>
    with _$CompromissosDaoMixin {
  CompromissosDao(super.db);

  // ---- compromissos ----

  Stream<List<Compromisso>> watchCompromissos() =>
      (select(compromissos)..orderBy([(c) => OrderingTerm.asc(c.descricao)]))
          .watch();

  Future<List<Compromisso>> todosCompromissos() => select(compromissos).get();

  Future<Compromisso?> compromisso(int id) =>
      (select(compromissos)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> inserirCompromisso(CompromissosCompanion c) =>
      into(compromissos).insert(c);

  Future<bool> atualizarCompromisso(Compromisso c) =>
      update(compromissos).replace(c);

  Future<void> excluirCompromisso(int id) async {
    await (delete(ocorrenciasCompromisso)
          ..where((o) => o.compromissoId.equals(id)))
        .go();
    await (delete(compromissos)..where((c) => c.id.equals(id))).go();
  }

  // ---- ocorrências ----

  Stream<List<OcorrenciaCompromisso>> watchOcorrencias() =>
      (select(ocorrenciasCompromisso)
            ..orderBy([(o) => OrderingTerm.asc(o.dataVencimento)]))
          .watch();

  Future<List<OcorrenciaCompromisso>> todasOcorrencias() =>
      select(ocorrenciasCompromisso).get();

  Future<OcorrenciaCompromisso?> ocorrencia(int id) =>
      (select(ocorrenciasCompromisso)..where((o) => o.id.equals(id)))
          .getSingleOrNull();

  Future<int> inserirOcorrencia(OcorrenciasCompromissoCompanion o) =>
      into(ocorrenciasCompromisso).insert(o, mode: InsertMode.insertOrIgnore);

  Future<bool> atualizarOcorrencia(OcorrenciaCompromisso o) =>
      update(ocorrenciasCompromisso).replace(o);

  Future<int> excluirOcorrencia(int id) =>
      (delete(ocorrenciasCompromisso)..where((o) => o.id.equals(id))).go();

  /// Remove ocorrências pendentes de um compromisso (ao editar valor/dia).
  Future<int> excluirPendentesDe(int compromissoId) =>
      (delete(ocorrenciasCompromisso)
            ..where((o) =>
                o.compromissoId.equals(compromissoId) &
                o.status.equalsValue(StatusOcorrencia.pendente)))
          .go();

  // ---- receitas recorrentes ----

  Stream<List<ReceitaRecorrente>> watchReceitas() =>
      (select(receitasRecorrentes)
            ..orderBy([(r) => OrderingTerm.asc(r.descricao)]))
          .watch();

  Future<List<ReceitaRecorrente>> todasReceitas() =>
      select(receitasRecorrentes).get();

  Future<ReceitaRecorrente?> receita(int id) =>
      (select(receitasRecorrentes)..where((r) => r.id.equals(id)))
          .getSingleOrNull();

  Future<int> inserirReceita(ReceitasRecorrentesCompanion r) =>
      into(receitasRecorrentes).insert(r);

  Future<bool> atualizarReceita(ReceitaRecorrente r) =>
      update(receitasRecorrentes).replace(r);

  Future<int> excluirReceita(int id) =>
      (delete(receitasRecorrentes)..where((r) => r.id.equals(id))).go();
}
