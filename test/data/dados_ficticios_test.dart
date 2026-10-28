import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/dados_ficticios.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/data/manutencao.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/domain/enums.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('dados fictícios populam o app de forma coerente', () async {
    await popularDadosFicticios(db);
    expect((await db.select(db.contas).get()).length, 2);
    expect((await db.select(db.cartoes).get()).length, 1);
    expect((await db.lancamentosDao.todos()).length, greaterThan(30));
    expect((await db.compromissosDao.todosCompromissos()).length, 3);

    final c = ProviderContainer(overrides: [bancoProvider.overrideWithValue(db)]);
    addTearDown(c.dispose);
    for (final p in [
      contasProvider, cartoesProvider, faturasProvider, lancamentosProvider,
      compromissosProvider, ocorrenciasProvider, receitasProvider,
    ]) {
      c.listen(p, (_, _) {});
      await c.read((p as dynamic).future);
    }

    // Faturas passadas pagas, atual aberta: há dívida no cartão e saldo positivo.
    final r = c.read(creditoSeguroProvider);
    expect(r.saldoContas, isNot(0));
    expect(r.comprometidoCartao, greaterThan(0));
    expect(c.read(totaisDoMesProvider).ganhos, greaterThan(0));
    expect(c.read(gastosPorCategoriaProvider), isNotEmpty);
    expect(c.read(maioresGastosProvider).length, 5);
    expect(c.read(projecaoComprometidoProvider).values.any((v) => v > 0), isTrue);
  });

  test('apagar tudo volta ao estado inicial (com seed de categorias)', () async {
    await popularDadosFicticios(db);
    await apagarTodosOsDados(db);
    expect(await db.select(db.contas).get(), isEmpty);
    expect(await db.lancamentosDao.todos(), isEmpty);
    expect(await db.select(db.faturas).get(), isEmpty);
    expect(await db.compromissosDao.todosCompromissos(), isEmpty);
    final cats = await db.categoriasDao.todas();
    expect(cats.where((c) => c.tipo == TipoCategoria.ganho), isNotEmpty);
    expect((await db.configuracoesDao.todas())['modo_parcelados'], 'rigido');
    // dá para popular de novo depois de limpar
    await popularDadosFicticios(db);
    expect((await db.select(db.contas).get()).length, 2);
  });
}
