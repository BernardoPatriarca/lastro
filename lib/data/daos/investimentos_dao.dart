import 'package:drift/drift.dart';

import '../banco.dart';
import '../tabelas.dart';

part 'investimentos_dao.g.dart';

@DriftAccessor(
  tables: [Investimentos, MovimentosInvestimento, Metas, Orcamentos],
)
class InvestimentosDao extends DatabaseAccessor<AppDatabase>
    with _$InvestimentosDaoMixin {
  InvestimentosDao(super.db);

  // ---- investimentos ----
  Stream<List<Investimento>> watchInvestimentos() =>
      (select(investimentos)..orderBy([(i) => OrderingTerm.asc(i.nome)])).watch();
  Future<int> inserirInvestimento(InvestimentosCompanion i) =>
      into(investimentos).insert(i);
  Future<bool> atualizarInvestimento(Investimento i) =>
      update(investimentos).replace(i);

  // ---- movimentos ----
  Stream<List<MovimentoInvestimento>> watchMovimentos() =>
      (select(movimentosInvestimento)
            ..orderBy([(m) => OrderingTerm.asc(m.data), (m) => OrderingTerm.asc(m.id)]))
          .watch();
  Future<int> inserirMovimento(MovimentosInvestimentoCompanion m) =>
      into(movimentosInvestimento).insert(m);
  Future<int> excluirMovimento(int id) =>
      (delete(movimentosInvestimento)..where((m) => m.id.equals(id))).go();

  // ---- metas ----
  Stream<List<Meta>> watchMetas() =>
      (select(metas)..orderBy([(m) => OrderingTerm.asc(m.prazo)])).watch();
  Future<int> inserirMeta(MetasCompanion m) => into(metas).insert(m);
  Future<bool> atualizarMeta(Meta m) => update(metas).replace(m);
  Future<int> excluirMeta(int id) =>
      (delete(metas)..where((m) => m.id.equals(id))).go();

  // ---- orçamentos ----
  Stream<List<Orcamento>> watchOrcamentos() => select(orcamentos).watch();
  Future<void> definirOrcamento(int categoriaId, String competencia, int limite) =>
      into(orcamentos).insertOnConflictUpdate(
        OrcamentosCompanion.insert(
          categoriaId: categoriaId,
          competencia: competencia,
          limite: limite,
        ),
      );
  Future<int> excluirOrcamento(int categoriaId, String competencia) =>
      (delete(orcamentos)
            ..where((o) =>
                o.categoriaId.equals(categoriaId) &
                o.competencia.equals(competencia)))
          .go();
}
