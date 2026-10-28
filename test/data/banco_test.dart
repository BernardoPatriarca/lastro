import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/domain/enums.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('seed cria categorias padrão de gasto e de ganho', () async {
    final todas = await db.categoriasDao.todas();
    final nomes = todas.map((c) => c.nome).toSet();
    for (final n in [
      'Moradia', 'Alimentação', 'Mercado', 'Delivery', 'Restaurante',
      'Transporte/Carro', 'Combustível', 'Manutenção', 'Peças', 'Saúde',
      'Lazer', 'Assinaturas', 'Educação', 'Compras', 'Contas', 'Luz', 'Água',
      'Internet', 'Celular', 'Outros', 'Salário', 'Extra', 'Rendimentos',
    ]) {
      expect(nomes, contains(n));
    }
    final mercado = todas.firstWhere((c) => c.nome == 'Mercado');
    final alimentacao = todas.firstWhere((c) => c.nome == 'Alimentação');
    expect(mercado.categoriaPaiId, alimentacao.id);
    expect(todas.where((c) => c.tipo == TipoCategoria.ganho), isNotEmpty);
  });

  test('seed grava as configurações padrão', () async {
    final cfg = await db.configuracoesDao.todas();
    expect(cfg['modo_parcelados'], 'parcela');
    expect(cfg['comportamento_estouro'], 'confirmar');
    expect(cfg['bloqueio_minutos'], '2');
  });

  test('não semeia dados pessoais: sem contas, cartões ou lançamentos', () async {
    expect(await db.select(db.contas).get(), isEmpty);
    expect(await db.select(db.cartoes).get(), isEmpty);
    expect(await db.lancamentosDao.todos(), isEmpty);
  });

  test('conta e lançamento: ida e volta preserva centavos e datas', () async {
    final contaId = await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta teste',
      tipo: TipoConta.corrente,
      dataSaldoInicial: DateTime(2026, 1, 31),
      saldoInicial: const Value(123456),
    ));
    final conta = (await db.contasDao.obter(contaId))!;
    expect(conta.saldoInicial, 123456);
    expect(conta.dataSaldoInicial, DateTime(2026, 1, 31));
    expect(conta.considerarNoCreditoSeguro, isTrue);

    final id = await db.lancamentosDao.inserir(LancamentosCompanion.insert(
      tipo: TipoLancamento.gasto,
      valor: 3333,
      data: DateTime(2026, 2, 28),
      contaId: Value(contaId),
      formaPagamento: const Value(FormaPagamento.pix),
    ));
    final l = (await db.lancamentosDao.obter(id))!;
    expect(l.valor, 3333);
    expect(l.data, DateTime(2026, 2, 28));
    expect(l.tipo, TipoLancamento.gasto);
    expect(l.formaPagamento, FormaPagamento.pix);
    expect(l.origem, OrigemLancamento.manual);
  });

  test('chave estrangeira impede lançamento de conta inexistente', () async {
    expect(
      () => db.lancamentosDao.inserir(LancamentosCompanion.insert(
        tipo: TipoLancamento.ganho,
        valor: 1,
        data: DateTime(2026, 1, 1),
        contaId: const Value(999),
      )),
      throwsA(isA<Exception>()),
    );
  });

  test('configuração é gravada e atualizada', () async {
    await db.configuracoesDao.definir('tema', 'light');
    expect(await db.configuracoesDao.obter('tema'), 'light');
    await db.configuracoesDao.definir('tema', 'dark');
    expect(await db.configuracoesDao.obter('tema'), 'dark');
  });

  test('fatura é única por cartão e competência', () async {
    final cartaoId = await db.cartoesDao.inserir(CartoesCompanion.insert(
      nome: 'Cartão', diaFechamento: 10, diaVencimento: 17,
    ));
    final f = FaturasCompanion.insert(
      cartaoId: cartaoId,
      competencia: '2026-03',
      dataFechamento: DateTime(2026, 3, 10),
      dataVencimento: DateTime(2026, 3, 17),
    );
    await db.cartoesDao.inserirFatura(f);
    expect(() => db.cartoesDao.inserirFatura(f), throwsA(isA<Exception>()));
  });
}
