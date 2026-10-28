import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/enums.dart';
import 'conversores.dart';
import 'daos/cartoes_dao.dart';
import 'daos/categorias_dao.dart';
import 'daos/compromissos_dao.dart';
import 'daos/configuracoes_dao.dart';
import 'daos/contas_dao.dart';
import 'daos/investimentos_dao.dart';
import 'daos/lancamentos_dao.dart';
import 'daos/mapeamentos_dao.dart';
import 'seed.dart';
import 'tabelas.dart';

part 'banco.g.dart';

@DriftDatabase(
  tables: [
    Contas,
    Cartoes,
    Faturas,
    Categorias,
    Lancamentos,
    ComprasParceladas,
    Compromissos,
    OcorrenciasCompromisso,
    ReceitasRecorrentes,
    Investimentos,
    MovimentosInvestimento,
    Metas,
    Orcamentos,
    RegrasCategorizacao,
    Configuracoes,
    MapeamentosCsv,
  ],
  daos: [
    ContasDao,
    CartoesDao,
    CategoriasDao,
    LancamentosDao,
    CompromissosDao,
    InvestimentosDao,
    ConfiguracoesDao,
    MapeamentosDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'lastro'));

  /// Banco em memória / arquivo temporário para testes.
  AppDatabase.forTesting(super.e);

  /// Versão do schema. Ao mudar tabelas: incremente e trate em [onUpgrade].
  static const versaoSchema = 1;

  @override
  int get schemaVersion => versaoSchema;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await semearBanco(this);
        },
        onUpgrade: (m, de, para) async {
          // Migrations versionadas: um bloco por versão, em ordem.
          // Exemplo para a futura versão 2:
          //   if (de < 2) { await m.addColumn(lancamentos, lancamentos.nova); }
        },
        beforeOpen: (detalhes) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
