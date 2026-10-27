import 'package:drift/drift.dart';

import '../banco.dart';
import '../tabelas.dart';

part 'lancamentos_dao.g.dart';

@DriftAccessor(tables: [Lancamentos, ComprasParceladas])
class LancamentosDao extends DatabaseAccessor<AppDatabase>
    with _$LancamentosDaoMixin {
  LancamentosDao(super.db);

  /// Todos os lançamentos, do mais recente para o mais antigo.
  ///
  /// App pessoal: a lista inteira em memória é pequena o bastante e deixa
  /// saldos e filtros simples e sempre reativos.
  Stream<List<Lancamento>> watchTodos() => (select(lancamentos)
        ..orderBy([
          (l) => OrderingTerm.desc(l.data),
          (l) => OrderingTerm.desc(l.id),
        ]))
      .watch();

  Future<List<Lancamento>> todos() => select(lancamentos).get();

  Future<Lancamento?> obter(int id) =>
      (select(lancamentos)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<int> inserir(LancamentosCompanion l) => into(lancamentos).insert(l);

  Future<void> inserirVarios(List<LancamentosCompanion> lista) =>
      batch((b) => b.insertAll(lancamentos, lista));

  Future<bool> atualizar(Lancamento l) =>
      update(lancamentos).replace(l.copyWith(atualizadoEm: DateTime.now()));

  Future<int> excluir(int id) =>
      (delete(lancamentos)..where((l) => l.id.equals(id))).go();

  Future<List<Lancamento>> daCompra(int compraParceladaId) =>
      (select(lancamentos)
            ..where((l) => l.compraParceladaId.equals(compraParceladaId))
            ..orderBy([(l) => OrderingTerm.asc(l.parcelaNumero)]))
          .get();

  /// Chaves de importação já gravadas (para marcar duplicadas).
  Future<Set<String>> chavesImportacao() async {
    final q = selectOnly(lancamentos)
      ..addColumns([lancamentos.chaveImportacao])
      ..where(lancamentos.chaveImportacao.isNotNull());
    final linhas = await q.get();
    return {for (final r in linhas) r.read(lancamentos.chaveImportacao)!};
  }

  // ---- compras parceladas ----

  Future<CompraParcelada?> compra(int id) =>
      (select(comprasParceladas)..where((c) => c.id.equals(id)))
          .getSingleOrNull();

  Future<int> inserirCompra(ComprasParceladasCompanion c) =>
      into(comprasParceladas).insert(c);

  Future<bool> atualizarCompra(CompraParcelada c) =>
      update(comprasParceladas).replace(c);

  Future<int> excluirCompra(int id) =>
      (delete(comprasParceladas)..where((c) => c.id.equals(id))).go();
}
