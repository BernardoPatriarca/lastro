import 'package:drift/drift.dart';

import '../banco.dart';
import '../tabelas.dart';

part 'contas_dao.g.dart';

@DriftAccessor(tables: [Contas, Lancamentos])
class ContasDao extends DatabaseAccessor<AppDatabase> with _$ContasDaoMixin {
  ContasDao(super.db);

  Stream<List<Conta>> watchTodas() =>
      (select(contas)..orderBy([(c) => OrderingTerm.asc(c.nome)])).watch();

  Future<Conta?> obter(int id) =>
      (select(contas)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> inserir(ContasCompanion conta) => into(contas).insert(conta);

  Future<bool> atualizar(Conta conta) => update(contas).replace(conta);

  /// Uma conta com lançamentos não pode ser apagada (só arquivada).
  Future<bool> temLancamentos(int id) async {
    final q = selectOnly(lancamentos)
      ..addColumns([lancamentos.id])
      ..where(lancamentos.contaId.equals(id) |
          lancamentos.contaDestinoId.equals(id))
      ..limit(1);
    return (await q.get()).isNotEmpty;
  }

  Future<int> excluir(int id) =>
      (delete(contas)..where((c) => c.id.equals(id))).go();
}
