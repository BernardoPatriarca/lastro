import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ajustes.dart';
import 'banco.dart';

/// Banco único do app. Os testes sobrescrevem com um banco em memória.
final bancoProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// Fluxos reativos das tabelas. Telas e cálculos derivam deles, então tudo se
// atualiza sozinho quando algo muda (drift emite de novo a cada escrita).

final contasProvider = StreamProvider<List<Conta>>(
  (ref) => ref.watch(bancoProvider).contasDao.watchTodas(),
);

final cartoesProvider = StreamProvider<List<Cartao>>(
  (ref) => ref.watch(bancoProvider).cartoesDao.watchTodos(),
);

final faturasProvider = StreamProvider<List<Fatura>>(
  (ref) => ref.watch(bancoProvider).cartoesDao.watchFaturas(),
);

final categoriasProvider = StreamProvider<List<Categoria>>(
  (ref) => ref.watch(bancoProvider).categoriasDao.watchTodas(),
);

final regrasProvider = StreamProvider<List<RegraCategorizacao>>(
  (ref) => ref.watch(bancoProvider).categoriasDao.watchRegras(),
);

final lancamentosProvider = StreamProvider<List<Lancamento>>(
  (ref) => ref.watch(bancoProvider).lancamentosDao.watchTodos(),
);

final compromissosProvider = StreamProvider<List<Compromisso>>(
  (ref) => ref.watch(bancoProvider).compromissosDao.watchCompromissos(),
);

final ocorrenciasProvider = StreamProvider<List<OcorrenciaCompromisso>>(
  (ref) => ref.watch(bancoProvider).compromissosDao.watchOcorrencias(),
);

final receitasProvider = StreamProvider<List<ReceitaRecorrente>>(
  (ref) => ref.watch(bancoProvider).compromissosDao.watchReceitas(),
);

final investimentosProvider = StreamProvider<List<Investimento>>(
  (ref) => ref.watch(bancoProvider).investimentosDao.watchInvestimentos(),
);

final movimentosInvestimentoProvider =
    StreamProvider<List<MovimentoInvestimento>>(
  (ref) => ref.watch(bancoProvider).investimentosDao.watchMovimentos(),
);

final metasProvider = StreamProvider<List<Meta>>(
  (ref) => ref.watch(bancoProvider).investimentosDao.watchMetas(),
);

final orcamentosProvider = StreamProvider<List<Orcamento>>(
  (ref) => ref.watch(bancoProvider).investimentosDao.watchOrcamentos(),
);

final mapeamentosCsvProvider = StreamProvider<List<MapeamentoCsvSalvo>>(
  (ref) => ref.watch(bancoProvider).mapeamentosDao.watchTodos(),
);

final _configuracoesBrutasProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(bancoProvider).configuracoesDao.watchTodas(),
);

/// Configurações interpretadas. Enquanto o banco abre, valem os padrões.
final ajustesProvider = Provider<AjustesApp>((ref) {
  final mapa = ref.watch(_configuracoesBrutasProvider).value;
  return mapa == null ? const AjustesApp() : AjustesApp.deMapa(mapa);
});

/// Grava uma configuração (chave/valor).
final definirAjusteProvider = Provider<Future<void> Function(String, String)>(
  (ref) => ref.watch(bancoProvider).configuracoesDao.definir,
);

/// Atalho: lista de um [AsyncValue] ou vazia enquanto carrega.
extension ListaDoAsync<T> on AsyncValue<List<T>> {
  List<T> get ou => value ?? const [];
}
