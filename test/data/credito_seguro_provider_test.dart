import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/data/servicos/servico_cartao.dart';
import 'package:lastro/data/servicos/servico_compromisso.dart';
import 'package:lastro/domain/enums.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer c;
  late int contaId;
  late Cartao cartao;
  final hoje = DateTime.now();

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    c = ProviderContainer(overrides: [bancoProvider.overrideWithValue(db)]);
    contaId = await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta',
      tipo: TipoConta.corrente,
      dataSaldoInicial: DateTime(2020, 1, 1),
      saldoInicial: const Value(70000), // R$ 700,00
    ));
    final id = await db.cartoesDao.inserir(CartoesCompanion.insert(
      nome: 'Cartão', diaFechamento: 10, diaVencimento: 17,
    ));
    cartao = (await db.cartoesDao.obter(id))!;
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  /// Mantém os streams vivos e espera o primeiro valor de cada um.
  Future<void> carregar() async {
    for (final p in [
      contasProvider, cartoesProvider, faturasProvider, lancamentosProvider,
      compromissosProvider, ocorrenciasProvider,
    ]) {
      c.listen(p, (_, _) {});
      await c.read((p as dynamic).future);
    }
    c.listen(ajustesProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  Future<void> definir(String k, String v) async {
    await c.read(definirAjusteProvider)(k, v);
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }

  Future<void> compraNoCartao(int valor, {int parcelas = 1}) =>
      ServicoCartao(db).registrarCompra(
        cartao: cartao, valorTotal: valor, parcelas: parcelas,
        data: hoje, descricao: 'x',
      );

  test('sem nada, pode gastar todo o saldo da conta', () async {
    await carregar();
    expect(c.read(creditoSeguroProvider).podeGastar, 70000);
  });

  test('spec: saldo R\$ 700, fatura aberta R\$ 500, sem fixos → R\$ 200', () async {
    await compraNoCartao(50000);
    await carregar();
    final r = c.read(creditoSeguroProvider);
    expect(r.saldoContas, 70000);
    expect(r.comprometidoCartao, 50000);
    expect(r.podeGastar, 20000);
  });

  test('spec: com boleto pendente de R\$ 250 e fixos ligados → R\$ −50', () async {
    await compraNoCartao(50000);
    await ServicoCompromisso(db).criarCompromisso(
      descricao: 'Boleto', valor: 25000, tipo: TipoCompromisso.recorrente,
      dataInicio: hoje, forma: FormaPagamento.boleto, contaId: contaId,
    );
    await carregar();
    await definir('descontar_fixos', 'true');
    expect(c.read(creditoSeguroProvider).podeGastar, -5000);

    await definir('descontar_fixos', 'false');
    expect(c.read(creditoSeguroProvider).podeGastar, 20000);
  });

  test('pagar a fatura devolve o crédito (saldo e dívida caem juntos)', () async {
    await compraNoCartao(50000);
    await carregar();
    final f = (await db.cartoesDao.todasFaturas()).single;
    await ServicoCartao(db).pagarFatura(fatura: f, contaId: contaId);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final r = c.read(creditoSeguroProvider);
    expect(r.saldoContas, 20000);
    expect(r.comprometidoCartao, 0);
    expect(r.podeGastar, 20000); // o mesmo: o dinheiro só trocou de lugar
  });

  test('modo rígido x por parcela numa compra parcelada', () async {
    await compraNoCartao(30000, parcelas: 3); // 3 x R$ 100,00
    await carregar();

    await definir('modo_parcelados', 'rigido');
    var r = c.read(creditoSeguroProvider);
    expect(r.comprometidoCartao, 30000);
    expect(r.podeGastar, 40000);

    await definir('modo_parcelados', 'parcela');
    r = c.read(creditoSeguroProvider);
    expect(r.comprometidoCartao, 10000); // só a 1ª parcela (fatura atual)
    expect(r.comprometidoProximasFaturas, 20000);
    expect(r.podeGastar, 60000);
  });

  test('conta fora do crédito seguro não entra no saldo', () async {
    await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Reserva',
      tipo: TipoConta.poupanca,
      dataSaldoInicial: DateTime(2020, 1, 1),
      saldoInicial: const Value(1000000),
      considerarNoCreditoSeguro: const Value(false),
    ));
    await carregar();
    expect(c.read(creditoSeguroProvider).saldoContas, 70000);
  });

  test('conta arquivada não entra no saldo', () async {
    final conta = (await db.contasDao.obter(contaId))!;
    await db.contasDao.atualizar(conta.copyWith(ativa: false));
    await carregar();
    expect(c.read(creditoSeguroProvider).saldoContas, 0);
  });

  test('compromisso pausado não é descontado', () async {
    final id = await ServicoCompromisso(db).criarCompromisso(
      descricao: 'Boleto', valor: 25000, tipo: TipoCompromisso.recorrente,
      dataInicio: hoje, forma: FormaPagamento.boleto, contaId: contaId,
    );
    final comp = (await db.compromissosDao.compromisso(id))!;
    await db.compromissosDao.atualizarCompromisso(comp.copyWith(ativo: false));
    await carregar();
    expect(c.read(creditoSeguroProvider).fixosDescontados, 0);
  });
}
