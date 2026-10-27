import 'package:drift/drift.dart';

import '../banco.dart';
import '../tabelas.dart';

part 'configuracoes_dao.g.dart';

@DriftAccessor(tables: [Configuracoes])
class ConfiguracoesDao extends DatabaseAccessor<AppDatabase>
    with _$ConfiguracoesDaoMixin {
  ConfiguracoesDao(super.db);

  Stream<Map<String, String>> watchTodas() => select(configuracoes)
      .watch()
      .map((l) => {for (final c in l) c.chave: c.valor});

  Future<Map<String, String>> todas() async =>
      {for (final c in await select(configuracoes).get()) c.chave: c.valor};

  Future<String?> obter(String chave) async => (await (select(configuracoes)
            ..where((c) => c.chave.equals(chave)))
          .getSingleOrNull())
      ?.valor;

  Future<void> definir(String chave, String valor) =>
      into(configuracoes).insertOnConflictUpdate(
        ConfiguracoesCompanion.insert(chave: chave, valor: valor),
      );
}
