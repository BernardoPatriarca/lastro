import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/data/servicos/servicos.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/lancamentos/filtro_lancamentos.dart';
import 'package:lastro/features/lancamentos/lancamentos_page.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer c;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    c = ProviderContainer(overrides: [bancoProvider.overrideWithValue(db)]);
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  /// Riverpod 3 pausa streams sem ouvinte: mantém contas e lançamentos vivos.
  Future<void> carregar() async {
    c.listen(contasProvider, (_, _) {});
    c.listen(lancamentosProvider, (_, _) {});
    await c.read(contasProvider.future);
    await c.read(lancamentosProvider.future);
  }

  Future<int> novaConta(String nome, int saldo) => db.contasDao.inserir(
        ContasCompanion.insert(
          nome: nome,
          tipo: TipoConta.corrente,
          dataSaldoInicial: DateTime(2020, 1, 1),
          saldoInicial: Value(saldo),
        ),
      );

  test('saldo por conta e total refletem os lançamentos', () async {
    final a = await novaConta('A', 100000);
    final b = await novaConta('B', 50000);
    final s = c.read(servicoLancamentosProvider);
    final hoje = DateTime.now();
    await s.registrar(
        tipo: TipoLancamento.ganho, valor: 20000, data: hoje, contaId: a);
    await s.registrar(
        tipo: TipoLancamento.gasto,
        valor: 5000,
        data: hoje,
        contaId: a,
        forma: FormaPagamento.pix);
    await s.registrar(
        tipo: TipoLancamento.transferencia,
        valor: 30000,
        data: hoje,
        contaId: a,
        contaDestinoId: b);

    await carregar();
    final saldos = c.read(saldosPorContaProvider);
    expect(saldos[a], 100000 + 20000 - 5000 - 30000);
    expect(saldos[b], 50000 + 30000);
    expect(c.read(saldoTotalProvider), 165000);
  });

  test('lançamento futuro não entra no saldo de hoje', () async {
    final a = await novaConta('A', 1000);
    await c.read(servicoLancamentosProvider).registrar(
          tipo: TipoLancamento.ganho,
          valor: 9999,
          data: DateTime.now().add(const Duration(days: 40)),
          contaId: a,
        );
    await carregar();
    expect(c.read(saldosPorContaProvider)[a], 1000);
  });

  test('ajustar saldo cria lançamento com a diferença', () async {
    final a = await novaConta('A', 10000);
    final s = c.read(servicoLancamentosProvider);
    final dif = await s.ajustarSaldo(contaId: a, saldoReal: 7500, saldoAtual: 10000);
    expect(dif, -2500);
    await carregar();
    expect(c.read(saldosPorContaProvider)[a], 7500);
    expect(await s.ajustarSaldo(contaId: a, saldoReal: 7500, saldoAtual: 7500), 0);
  });

  test('ajustar saldo inicial faz o saldo bater sem criar lançamento', () async {
    final a = await novaConta('A', 10000);
    final conta = (await db.contasDao.obter(a))!;
    await c.read(servicoLancamentosProvider).ajustarSaldoInicial(
          conta: conta,
          saldoReal: 15000,
          saldoAtual: 10000,
        );
    expect((await db.contasDao.obter(a))!.saldoInicial, 15000);
    expect(await db.lancamentosDao.todos(), isEmpty);
  });

  test('totais do mês: ganho, gasto e aporte; transferência não conta', () {
    final mes = const Competencia(2026, 3);
    Lancamento l(TipoLancamento t, int v, DateTime d) => Lancamento(
          id: 0,
          tipo: t,
          valor: v,
          data: d,
          descricao: '',
          origem: OrigemLancamento.manual,
          criadoEm: d,
          atualizadoEm: d,
        );
    final t = calcularTotaisMes([
      l(TipoLancamento.ganho, 500000, DateTime(2026, 3, 5)),
      l(TipoLancamento.gasto, 120000, DateTime(2026, 3, 6)),
      l(TipoLancamento.aporte, 50000, DateTime(2026, 3, 7)),
      l(TipoLancamento.transferencia, 99999, DateTime(2026, 3, 8)),
      l(TipoLancamento.gasto, 77777, DateTime(2026, 4, 1)),
    ], mes);
    expect(t.ganhos, 500000);
    expect(t.gastos, 120000);
    expect(t.investido, 50000);
    expect(t.saldo, 380000);
    expect(t.taxaPoupanca, closeTo(0.1, 1e-9));
  });

  test('filtro por busca ignora acento e maiúsculas', () {
    final l = Lancamento(
      id: 1,
      tipo: TipoLancamento.gasto,
      valor: 100,
      data: DateTime(2026, 3, 1),
      descricao: 'Padaria São João',
      origem: OrigemLancamento.manual,
      criadoEm: DateTime(2026),
      atualizadoEm: DateTime(2026),
    );
    expect(const FiltroLancamentos(busca: 'sao joao').aceita(l, {}), isTrue);
    expect(const FiltroLancamentos(busca: 'MERCADO').aceita(l, {}), isFalse);
    expect(
      const FiltroLancamentos(tipos: {TipoLancamento.ganho}).aceita(l, {}),
      isFalse,
    );
  });

  test('agrupa por dia com total (ganhos − gastos)', () {
    Lancamento l(int id, TipoLancamento t, int v, DateTime d) => Lancamento(
          id: id,
          tipo: t,
          valor: v,
          data: d,
          descricao: '',
          origem: OrigemLancamento.manual,
          criadoEm: d,
          atualizadoEm: d,
        );
    final r = agruparPorDia([
      l(3, TipoLancamento.gasto, 1000, DateTime(2026, 3, 10)),
      l(2, TipoLancamento.ganho, 5000, DateTime(2026, 3, 10)),
      l(1, TipoLancamento.gasto, 200, DateTime(2026, 3, 9)),
    ]);
    expect(r.length, 5); // 2 cabeçalhos + 3 lançamentos
    expect(r[1], isA<Lancamento>());
  });
}
