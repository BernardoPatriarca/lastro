import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/data/servicos/servico_cartao.dart';
import 'package:lastro/domain/enums.dart';

/// Cenário real do dono: o crédito seguro vale para a FATURA DO MÊS (uma compra
/// de R$ 750 em 3x pesa R$ 250 agora, não R$ 750), e o saldo inicial da conta é
/// dinheiro que já existe, nunca "salário" nem ganho do mês.
void main() {
  late AppDatabase db;
  late ProviderContainer c;
  late Cartao cartao;
  final hoje = DateTime.now();

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    c = ProviderContainer(overrides: [bancoProvider.overrideWithValue(db)]);
    final id = await db.cartoesDao.inserir(CartoesCompanion.insert(
      nome: 'Cartão', diaFechamento: 10, diaVencimento: 17,
    ));
    cartao = (await db.cartoesDao.obter(id))!;
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<int> conta(int saldo, {DateTime? desde}) => db.contasDao.inserir(
        ContasCompanion.insert(
          nome: 'Conta',
          tipo: TipoConta.corrente,
          dataSaldoInicial: desde ?? DateTime(hoje.year, hoje.month, hoje.day),
          saldoInicial: Value(saldo),
        ),
      );

  Future<void> carregar() async {
    for (final p in [
      contasProvider, cartoesProvider, faturasProvider, lancamentosProvider,
      compromissosProvider, ocorrenciasProvider, receitasProvider,
      categoriasProvider, orcamentosProvider, investimentosProvider,
      movimentosInvestimentoProvider, metasProvider,
    ]) {
      c.listen(p, (_, _) {});
      await c.read((p as dynamic).future);
    }
    c.listen(ajustesProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 40));
  }

  Future<void> comprar(int valor, int parcelas) => ServicoCartao(db).registrarCompra(
        cartao: cartao, valorTotal: valor, parcelas: parcelas,
        data: hoje, descricao: 'Compra',
      );

  test('padrão: R\$ 750 em 3x com saldo zero → −R\$ 250 (só a fatura do mês)', () async {
    await conta(0);
    await comprar(75000, 3);
    await carregar();
    final r = c.read(creditoSeguroProvider);
    expect(r.modo, ModoParcelados.parcela);
    expect(r.comprometidoCartao, 25000);
    expect(r.podeGastar, -25000);
    // as parcelas seguintes aparecem só como informação
    expect(r.comprometidoProximasFaturas, 50000);
  });

  test('com R\$ 500 em conta, a mesma compra deixa +R\$ 250 (não −R\$ 250)', () async {
    await conta(50000);
    await comprar(75000, 3);
    await carregar();
    expect(c.read(creditoSeguroProvider).podeGastar, 25000);
  });

  test('quem prefere o modo rígido ainda pode escolher (−R\$ 750)', () async {
    await conta(0);
    await comprar(75000, 3);
    await c.read(definirAjusteProvider)('modo_parcelados', 'rigido');
    await carregar();
    expect(c.read(creditoSeguroProvider).podeGastar, -75000);
  });

  test('saldo inicial é dinheiro em conta: não vira ganho, gasto nem poupança', () async {
    await conta(500000); // R$ 5.000,00 que já existiam
    await carregar();

    final t = c.read(totaisDoMesProvider);
    expect((t.ganhos, t.gastos, t.investido, t.saldo), (0, 0, 0, 0));
    expect(t.taxaPoupanca, 0);
    expect(c.read(saldoTotalProvider), 500000);
    final r = c.read(creditoSeguroProvider);
    expect(r.saldoContas, 500000);
    expect(r.podeGastar, 500000);
    expect(c.read(projecaoDoMesProvider)!.ganhos, 0);
    expect(c.read(gastosPorCategoriaProvider), isEmpty);
  });

  test('mudar o saldo inicial atualiza saldo e crédito na hora, sem mexer nos totais',
      () async {
    final id = await conta(100000);
    await comprar(30000, 1);
    await carregar();
    expect(c.read(creditoSeguroProvider).podeGastar, 70000);

    final conta0 = (await db.contasDao.obter(id))!;
    await db.contasDao.atualizar(conta0.copyWith(saldoInicial: 400000));
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(c.read(saldoTotalProvider), 400000);
    expect(c.read(creditoSeguroProvider).podeGastar, 370000);
    final t = c.read(totaisDoMesProvider);
    expect(t.ganhos, 0);
    expect(t.gastos, 30000); // a compra no crédito é gasto do mês
  });

  test('ajustar o saldo (ajuste) também não conta como ganho', () async {
    final id = await conta(100000);
    await db.lancamentosDao.inserir(LancamentosCompanion.insert(
      tipo: TipoLancamento.ajusteSaldo,
      valor: 250000,
      data: DateTime(hoje.year, hoje.month, hoje.day),
      contaId: Value(id),
    ));
    await carregar();
    expect(c.read(saldoTotalProvider), 350000);
    expect(c.read(totaisDoMesProvider).ganhos, 0);
  });
}
