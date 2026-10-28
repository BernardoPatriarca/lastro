import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/servicos/servico_cartao.dart';
import 'package:lastro/data/servicos/servico_lancamentos.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/saldo.dart';

void main() {
  late AppDatabase db;
  late ServicoCartao s;
  late Cartao cartao;
  late int contaId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    s = ServicoCartao(db);
    contaId = await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta',
      tipo: TipoConta.corrente,
      dataSaldoInicial: DateTime(2026, 1, 1),
      saldoInicial: const Value(100000),
    ));
    final id = await db.cartoesDao.inserir(CartoesCompanion.insert(
      nome: 'Cartão',
      diaFechamento: 10,
      diaVencimento: 17,
      limite: const Value(500000),
      contaPagamentoId: Value(contaId),
    ));
    cartao = (await db.cartoesDao.obter(id))!;
  });
  tearDown(() => db.close());

  Future<int> saldo() async {
    final lancs = await db.lancamentosDao.todos();
    return calcularSaldoConta(
      contaId: contaId,
      saldoInicial: 100000,
      dataSaldoInicial: DateTime(2026, 1, 1),
      movimentos: [
        for (final l in lancs)
          MovimentoSaldo(
            tipo: l.tipo,
            valor: l.valor,
            data: l.data,
            forma: l.formaPagamento,
            contaId: l.contaId,
            contaDestinoId: l.contaDestinoId,
          ),
      ],
    );
  }

  test('compra à vista cria a fatura e NÃO mexe no saldo', () async {
    await s.registrarCompra(
      cartao: cartao,
      valorTotal: 25000,
      parcelas: 1,
      data: DateTime(2026, 3, 5),
      descricao: 'Mercado',
    );
    final lancs = await db.lancamentosDao.todos();
    expect(lancs.length, 1);
    expect(lancs.single.formaPagamento, FormaPagamento.credito);
    expect(lancs.single.contaId, isNull);
    expect(lancs.single.compraParceladaId, isNull);
    final f = (await db.cartoesDao.todasFaturas()).single;
    expect(f.competencia, '2026-03');
    expect(lancs.single.faturaId, f.id);
    expect(await s.totalDaFatura(f.id), 25000);
    expect(await saldo(), 100000);
  });

  test('compra parcelada: R\$ 100,00 em 3x em 3 faturas', () async {
    await s.registrarCompra(
      cartao: cartao,
      valorTotal: 10000,
      parcelas: 3,
      data: DateTime(2026, 3, 5),
      descricao: 'Notebook',
    );
    final lancs = await db.lancamentosDao.todos()
      ..sort((a, b) => a.parcelaNumero!.compareTo(b.parcelaNumero!));
    expect(lancs.map((l) => l.valor), [3334, 3333, 3333]);
    expect(lancs.map((l) => l.descricao),
        ['Notebook (1/3)', 'Notebook (2/3)', 'Notebook (3/3)']);
    expect(lancs.map((l) => l.faturaId).toSet().length, 3);
    final faturas = await db.cartoesDao.todasFaturas();
    expect(faturas.map((f) => f.competencia).toSet(),
        {'2026-03', '2026-04', '2026-05'});
    final compra = (await db.lancamentosDao.compra(lancs.first.compraParceladaId!))!;
    expect(compra.valorTotal, 10000);
    expect(compra.numeroParcelas, 3);
  });

  test('duas compras no mesmo ciclo reaproveitam a fatura', () async {
    for (final dia in [2, 8]) {
      await s.registrarCompra(
        cartao: cartao, valorTotal: 1000, parcelas: 1,
        data: DateTime(2026, 3, dia), descricao: 'x',
      );
    }
    expect((await db.cartoesDao.todasFaturas()).length, 1);
  });

  test('pagar fatura: lança pagamento, marca paga e tira da conta', () async {
    await s.registrarCompra(
      cartao: cartao, valorTotal: 30000, parcelas: 1,
      data: DateTime(2026, 3, 5), descricao: 'Compra',
    );
    final f = (await db.cartoesDao.todasFaturas()).single;
    final id = await s.pagarFatura(
        fatura: f, contaId: contaId, data: DateTime(2026, 3, 17));

    final paga = (await db.cartoesDao.faturaPorId(f.id))!;
    expect(paga.status, StatusFatura.paga);
    expect(paga.dataPagamento, DateTime(2026, 3, 17));
    expect(paga.lancamentoPagamentoId, id);
    final pag = (await db.lancamentosDao.obter(id))!;
    expect(pag.tipo, TipoLancamento.pagamentoFatura);
    expect(pag.valor, 30000);
    expect(await saldo(), 70000);

    // pagar de novo não pode
    expect(() => s.pagarFatura(fatura: paga, contaId: contaId),
        throwsA(isA<OperacaoInvalida>()));
  });

  test('fatura vazia não pode ser paga', () async {
    await s.registrarCompra(
      cartao: cartao, valorTotal: 100, parcelas: 1,
      data: DateTime(2026, 3, 5), descricao: 'x',
    );
    final f = (await db.cartoesDao.todasFaturas()).single;
    final vazia = await db.cartoesDao.inserirFatura(FaturasCompanion.insert(
      cartaoId: cartao.id, competencia: '2030-01',
      dataFechamento: DateTime(2030, 1, 10), dataVencimento: DateTime(2030, 1, 17),
    ));
    expect(
      () async => s.pagarFatura(
        fatura: (await db.cartoesDao.faturaPorId(vazia))!, contaId: contaId),
      throwsA(isA<OperacaoInvalida>()),
    );
    expect(f.id, isNot(vazia));
  });

  test('compra de fatura paga não pode ser editada nem excluída', () async {
    await s.registrarCompra(
      cartao: cartao, valorTotal: 30000, parcelas: 1,
      data: DateTime(2026, 3, 5), descricao: 'Compra',
    );
    final f = (await db.cartoesDao.todasFaturas()).single;
    await s.pagarFatura(fatura: f, contaId: contaId, data: DateTime(2026, 3, 17));
    final compra = (await db.lancamentosDao.todos())
        .firstWhere((l) => l.tipo == TipoLancamento.gasto);
    expect(() => s.excluirCompra(compra, EscopoParcelas.soEsta),
        throwsA(isA<OperacaoInvalida>()));
    expect(
      () => s.atualizarCompraUnica(compra,
          cartao: cartao, valor: 1, data: compra.data, descricao: 'x'),
      throwsA(isA<OperacaoInvalida>()),
    );
  });

  test('excluir o lançamento de pagamento reabre a fatura', () async {
    await s.registrarCompra(
      cartao: cartao, valorTotal: 30000, parcelas: 1,
      data: DateTime(2026, 3, 5), descricao: 'Compra',
    );
    final f = (await db.cartoesDao.todasFaturas()).single;
    final pagId = await s.pagarFatura(
        fatura: f, contaId: contaId, data: DateTime(2026, 3, 17));

    await ServicoLancamentos(db).excluir(pagId);

    final reaberta = (await db.cartoesDao.faturaPorId(f.id))!;
    expect(reaberta.status, isNot(StatusFatura.paga));
    expect(reaberta.lancamentoPagamentoId, isNull);
    expect(reaberta.dataPagamento, isNull);
    expect(await saldo(), 100000);
  });

  test('editar compra à vista pode mudá-la de fatura', () async {
    await s.registrarCompra(
      cartao: cartao, valorTotal: 1000, parcelas: 1,
      data: DateTime(2026, 3, 5), descricao: 'x',
    );
    final l = (await db.lancamentosDao.todos()).single;
    await s.atualizarCompraUnica(l,
        cartao: cartao, valor: 2000, data: DateTime(2026, 3, 20), descricao: 'y');
    final novo = (await db.lancamentosDao.todos()).single;
    final f = (await db.cartoesDao.faturaPorId(novo.faturaId!))!;
    expect(f.competencia, '2026-04'); // depois do fechamento (dia 10)
    expect(novo.valor, 2000);
    expect(novo.descricao, 'y');
  });

  group('escopo em compras parceladas', () {
    late List<Lancamento> parcelas;

    setUp(() async {
      await s.registrarCompra(
        cartao: cartao, valorTotal: 12000, parcelas: 4,
        data: DateTime(2026, 3, 5), descricao: 'Sofá',
      );
      parcelas = (await db.lancamentosDao.todos())
        ..sort((a, b) => a.parcelaNumero!.compareTo(b.parcelaNumero!));
    });

    test('editar só esta parcela', () async {
      await s.atualizarParcelas(parcelas[1], EscopoParcelas.soEsta,
          valorParcela: 5000, descricaoBase: 'Sofá novo');
      final atual = (await db.lancamentosDao.todos())
        ..sort((a, b) => a.parcelaNumero!.compareTo(b.parcelaNumero!));
      expect(atual.map((l) => l.valor), [3000, 5000, 3000, 3000]);
      expect(atual[1].descricao, 'Sofá novo (2/4)');
      expect(atual[0].descricao, 'Sofá (1/4)');
    });

    test('editar esta e as próximas', () async {
      await s.atualizarParcelas(parcelas[2], EscopoParcelas.estaEProximas,
          valorParcela: 1000, descricaoBase: 'Sofá');
      final atual = (await db.lancamentosDao.todos())
        ..sort((a, b) => a.parcelaNumero!.compareTo(b.parcelaNumero!));
      expect(atual.map((l) => l.valor), [3000, 3000, 1000, 1000]);
    });

    test('excluir esta e as próximas mantém as anteriores', () async {
      await s.excluirCompra(parcelas[2], EscopoParcelas.estaEProximas);
      expect((await db.lancamentosDao.todos()).length, 2);
      expect(await db.select(db.comprasParceladas).get(), isNotEmpty);
    });

    test('excluir todas apaga também a compra', () async {
      await s.excluirCompra(parcelas[1], EscopoParcelas.todas);
      expect(await db.lancamentosDao.todos(), isEmpty);
      expect(await db.select(db.comprasParceladas).get(), isEmpty);
    });
  });

  test('fecharVencidas marca como fechada a fatura cujo fechamento passou',
      () async {
    await s.registrarCompra(
      cartao: cartao, valorTotal: 1000, parcelas: 1,
      data: DateTime(2099, 1, 5), descricao: 'futuro',
    );
    final antes = (await db.cartoesDao.todasFaturas()).single;
    expect(antes.status, StatusFatura.aberta);
    await s.fecharVencidas(DateTime(2099, 1, 10));
    expect((await db.cartoesDao.faturaPorId(antes.id))!.status, StatusFatura.fechada);
  });
}
