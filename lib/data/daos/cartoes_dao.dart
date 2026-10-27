import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../banco.dart';
import '../conversores.dart';
import '../tabelas.dart';

part 'cartoes_dao.g.dart';

@DriftAccessor(tables: [Cartoes, Faturas])
class CartoesDao extends DatabaseAccessor<AppDatabase> with _$CartoesDaoMixin {
  CartoesDao(super.db);

  Stream<List<Cartao>> watchTodos() =>
      (select(cartoes)..orderBy([(c) => OrderingTerm.asc(c.nome)])).watch();

  Future<Cartao?> obter(int id) =>
      (select(cartoes)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> inserir(CartoesCompanion c) => into(cartoes).insert(c);

  Future<bool> atualizar(Cartao c) => update(cartoes).replace(c);

  Future<int> excluir(int id) =>
      (delete(cartoes)..where((c) => c.id.equals(id))).go();

  // ---- faturas ----

  Stream<List<Fatura>> watchFaturas() => (select(faturas)
        ..orderBy([(f) => OrderingTerm.asc(f.dataFechamento)]))
      .watch();

  Future<List<Fatura>> todasFaturas() => select(faturas).get();

  Future<Fatura?> faturaPorId(int id) =>
      (select(faturas)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<Fatura?> faturaDaCompetencia(int cartaoId, String competencia) =>
      (select(faturas)
            ..where((f) =>
                f.cartaoId.equals(cartaoId) & f.competencia.equals(competencia)))
          .getSingleOrNull();

  Future<int> inserirFatura(FaturasCompanion f) => into(faturas).insert(f);

  Future<bool> atualizarFatura(Fatura f) => update(faturas).replace(f);

  /// Marca como `fechada` toda fatura aberta cuja data de fechamento chegou.
  Future<void> fecharFaturasVencidas(DateTime hoje) async {
    await (update(faturas)
          ..where((f) =>
              f.status.equalsValue(StatusFatura.aberta) &
              f.dataFechamento.isSmallerOrEqualValue(
                  const ConversorData().toSql(hoje))))
        .write(const FaturasCompanion(status: Value(StatusFatura.fechada)));
  }
}
