import 'banco.dart';
import 'seed.dart';

/// Todas as tabelas do app, em ordem segura para apagar (dependentes
/// primeiro). Usada por apagar tudo, backup e restauração.
const tabelasDoApp = [
  'lancamentos',
  'ocorrencias_compromisso',
  'compras_parceladas',
  'faturas',
  'movimentos_investimento',
  'metas',
  'orcamentos',
  'regras_categorizacao',
  'mapeamentos_csv',
  'receitas_recorrentes',
  'compromissos',
  'investimentos',
  'cartoes',
  'contas',
  'categorias',
  'configuracoes',
];

/// Apaga **todos** os dados do app (contas, lançamentos, cartões...) e refaz o
/// seed de categorias e configurações. Usado ao restaurar um backup e ao
/// limpar os dados fictícios de debug. A senha (cofre seguro) não é afetada.
Future<void> apagarTodosOsDados(AppDatabase db) async {
  await db.transaction(() async {
    for (final tabela in tabelasDoApp) {
      await db.customStatement('DELETE FROM $tabela');
    }
    await db.customStatement(
      "DELETE FROM sqlite_sequence WHERE name NOT LIKE 'sqlite_%'",
    );
  });
  await semearBanco(db);
}
