import 'package:drift/drift.dart';

import '../banco.dart';
import '../tabelas.dart';

part 'categorias_dao.g.dart';

@DriftAccessor(tables: [Categorias, RegrasCategorizacao, Lancamentos])
class CategoriasDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriasDaoMixin {
  CategoriasDao(super.db);

  Stream<List<Categoria>> watchTodas() => (select(categorias)
        ..orderBy([(c) => OrderingTerm.asc(c.ordem), (c) => OrderingTerm.asc(c.nome)]))
      .watch();

  Future<List<Categoria>> todas() => select(categorias).get();

  Future<Categoria?> obter(int id) =>
      (select(categorias)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> inserir(CategoriasCompanion c) => into(categorias).insert(c);

  Future<bool> atualizar(Categoria c) => update(categorias).replace(c);

  Future<bool> emUso(int id) async {
    final usada = selectOnly(lancamentos)
      ..addColumns([lancamentos.id])
      ..where(lancamentos.categoriaId.equals(id))
      ..limit(1);
    if ((await usada.get()).isNotEmpty) return true;
    final filha = selectOnly(categorias)
      ..addColumns([categorias.id])
      ..where(categorias.categoriaPaiId.equals(id))
      ..limit(1);
    return (await filha.get()).isNotEmpty;
  }

  Future<int> excluir(int id) async {
    await (delete(regrasCategorizacao)..where((r) => r.categoriaId.equals(id)))
        .go();
    return (delete(categorias)..where((c) => c.id.equals(id))).go();
  }

  // ---- regras de categorização ----

  Stream<List<RegraCategorizacao>> watchRegras() => (select(regrasCategorizacao)
        ..orderBy([(r) => OrderingTerm.desc(r.prioridade)]))
      .watch();

  Future<List<RegraCategorizacao>> todasRegras() =>
      select(regrasCategorizacao).get();

  Future<int> inserirRegra(RegrasCategorizacaoCompanion r) =>
      into(regrasCategorizacao).insert(r);

  Future<bool> atualizarRegra(RegraCategorizacao r) =>
      update(regrasCategorizacao).replace(r);

  Future<int> excluirRegra(int id) =>
      (delete(regrasCategorizacao)..where((r) => r.id.equals(id))).go();
}
