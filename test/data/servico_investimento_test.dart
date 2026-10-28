import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/data/servicos/servico_cartao.dart';
import 'package:lastro/data/servicos/servico_investimento.dart';
import 'package:lastro/data/servicos/servico_lancamentos.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/investimentos.dart';

void main() {
  late AppDatabase db;
  late ServicoInvestimento s;
  late int contaId;
  late int invId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    s = ServicoInvestimento(db);
    contaId = await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta',
      tipo: TipoConta.corrente,
      dataSaldoInicial: DateTime(2020, 1, 1),
      saldoInicial: const Value(500000),
    ));
    invId = await s.criar(nome: 'Reserva', tipo: TipoInvestimento.reserva);
  });
  tearDown(() => db.close());

  Future<int> saldoConta() async {
    final conta = (await db.contasDao.obter(contaId))!;
    final lancs = await db.lancamentosDao.todos();
    return lancs.fold<int>(
      conta.saldoInicial,
      (s, l) => s + _efeito(l, contaId),
    );
  }

  test('aportar: sai da conta e cria o movimento ligado ao lançamento', () async {
    final lancId = await s.aportar(
      contaId: contaId, valor: 100000, data: DateTime(2026, 3, 5), investimentoId: invId,
    );
    final l = (await db.lancamentosDao.obter(lancId))!;
    expect(l.tipo, TipoLancamento.aporte);
    expect(l.investimentoId, invId);
    final mov = (await db.investimentosDao.movimentoDoLancamento(lancId))!;
    expect(mov.tipo, TipoMovimentoInvestimento.aporte);
    expect(mov.valor, 100000);
    expect(await saldoConta(), 400000);
  });

  test('resgatar: volta para a conta', () async {
    await s.aportar(contaId: contaId, valor: 100000, data: DateTime(2026, 3, 5), investimentoId: invId);
    await s.resgatar(contaId: contaId, valor: 30000, data: DateTime(2026, 3, 20), investimentoId: invId);
    expect(await saldoConta(), 430000);
  });

  test('atualizar saldo vira um movimento sem lançamento (não mexe na conta)', () async {
    await s.aportar(contaId: contaId, valor: 100000, data: DateTime(2026, 3, 5), investimentoId: invId);
    await s.atualizarSaldo(investimentoId: invId, saldo: 108000, data: DateTime(2026, 4, 1));
    final movs = await db.select(db.movimentosInvestimento).get();
    expect(movs.length, 2);
    expect(movs.where((m) => m.lancamentoId == null).single.valor, 108000);
    expect(await saldoConta(), 400000);
  });

  test('aporte sem investimento escolhido é só um lançamento', () async {
    await s.aportar(contaId: contaId, valor: 5000, data: DateTime(2026, 3, 5));
    expect(await db.select(db.movimentosInvestimento).get(), isEmpty);
    expect((await db.lancamentosDao.todos()).single.investimentoId, isNull);
  });

  test('valor inválido é recusado', () {
    expect(() => s.aportar(contaId: contaId, valor: 0, data: DateTime(2026, 1, 1)),
        throwsA(isA<OperacaoInvalida>()));
    expect(() => s.atualizarSaldo(investimentoId: invId, saldo: -1, data: DateTime(2026, 1, 1)),
        throwsA(isA<OperacaoInvalida>()));
  });

  test('excluir o lançamento do aporte remove o movimento e devolve o dinheiro', () async {
    final lancId = await s.aportar(
        contaId: contaId, valor: 100000, data: DateTime(2026, 3, 5), investimentoId: invId);
    await ServicoLancamentos(db).excluir(lancId);
    expect(await db.select(db.movimentosInvestimento).get(), isEmpty);
    expect(await saldoConta(), 500000);
  });

  test('excluir o movimento pelo investimento leva o lançamento junto', () async {
    await s.aportar(contaId: contaId, valor: 100000, data: DateTime(2026, 3, 5), investimentoId: invId);
    final mov = (await db.select(db.movimentosInvestimento).get()).single;
    await s.excluirMovimento(mov);
    expect(await db.lancamentosDao.todos(), isEmpty);
    expect(await saldoConta(), 500000);
  });

  test('editar o lançamento do aporte atualiza o movimento', () async {
    final lancId = await s.aportar(
        contaId: contaId, valor: 100000, data: DateTime(2026, 3, 5), investimentoId: invId);
    final l = (await db.lancamentosDao.obter(lancId))!;
    await ServicoLancamentos(db).atualizar(l.copyWith(valor: 70000, data: DateTime(2026, 3, 8)));
    final mov = (await db.investimentosDao.movimentoDoLancamento(lancId))!;
    expect(mov.valor, 70000);
    expect(mov.data, DateTime(2026, 3, 8));
  });

  test('excluir o investimento mantém os lançamentos e solta as metas', () async {
    await s.aportar(contaId: contaId, valor: 100000, data: DateTime(2026, 3, 5), investimentoId: invId);
    final metaId = await s.criarMeta(
        nome: 'Viagem', valorAlvo: 500000, prazo: DateTime(2027, 1, 1), investimentoId: invId);
    await s.excluirInvestimento(invId);
    expect(await db.select(db.investimentos).get(), isEmpty);
    expect(await db.select(db.movimentosInvestimento).get(), isEmpty);
    expect((await db.lancamentosDao.todos()).single.investimentoId, isNull);
    final metas = await db.select(db.metas).get();
    expect(metas.single.id, metaId);
    expect(metas.single.investimentoId, isNull);
  });

  group('providers', () {
    late ProviderContainer c;
    setUp(() => c = ProviderContainer(overrides: [bancoProvider.overrideWithValue(db)]));
    tearDown(() => c.dispose());

    Future<void> carregar() async {
      for (final p in [
        investimentosProvider, movimentosInvestimentoProvider, metasProvider,
      ]) {
        c.listen(p, (_, _) {});
        await c.read((p as dynamic).future);
      }
    }

    test('saldo, patrimônio e meta ligada ao investimento', () async {
      final outro = await s.criar(nome: 'CDB', tipo: TipoInvestimento.cdb);
      final hoje = DateTime.now();
      await s.aportar(contaId: contaId, valor: 100000, data: hoje, investimentoId: invId);
      await s.atualizarSaldo(investimentoId: invId, saldo: 110000, data: hoje);
      await s.aportar(contaId: contaId, valor: 50000, data: hoje, investimentoId: outro);
      final metaId = await s.criarMeta(
        nome: 'Reserva de 6 meses',
        valorAlvo: 330000,
        prazo: hoje.add(const Duration(days: 180)),
        investimentoId: invId,
      );
      final geral = await s.criarMeta(
        nome: 'Patrimônio', valorAlvo: 160000, prazo: hoje.add(const Duration(days: 30)),
      );
      await carregar();

      final saldos = c.read(saldosInvestimentosProvider);
      expect(saldos[invId], 110000);
      expect(saldos[outro], 50000);
      expect(c.read(patrimonioProvider), 160000);

      final p = c.read(progressoMetasProvider);
      expect(p[metaId]!.atual, 110000);
      expect(p[metaId]!.falta, 220000);
      expect(p[metaId]!.mesesRestantes, 6);
      expect(p[metaId]!.aporteMensalNecessario, (220000 + 5) ~/ 6);
      expect(p[geral]!.atual, 160000); // sem vínculo: patrimônio total
      expect(p[geral]!.situacao, SituacaoMeta.atingida);
      expect(c.read(patrimonioMensalProvider).length, 12);
      expect(c.read(patrimonioMensalProvider).values.last, 160000);
    });
  });
}

int _efeito(Lancamento l, int contaId) {
  if (l.contaId != contaId) return 0;
  return switch (l.tipo) {
    TipoLancamento.aporte => -l.valor,
    TipoLancamento.resgate => l.valor,
    _ => 0,
  };
}
