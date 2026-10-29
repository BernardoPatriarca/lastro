import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/servicos/servico_cartao.dart';
import 'package:lastro/data/servicos/servico_compromisso.dart';
import 'package:lastro/domain/enums.dart';

void main() {
  late AppDatabase db;
  late ServicoCompromisso s;
  late Cartao cartao;
  late int contaId;
  final hoje = DateTime(2026, 3, 15);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    s = ServicoCompromisso(db);
    contaId = await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta', tipo: TipoConta.corrente, dataSaldoInicial: DateTime(2020),
    ));
    final id = await db.cartoesDao.inserir(CartoesCompanion.insert(
      nome: 'Cartão', diaFechamento: 10, diaVencimento: 17,
    ));
    cartao = (await db.cartoesDao.obter(id))!;
  });
  tearDown(() => db.close());

  Future<int> criar({DateTime? inicio, int valor = 4000}) => s.criarCompromisso(
        descricao: 'Streaming',
        valor: valor,
        tipo: TipoCompromisso.recorrente,
        dataInicio: inicio ?? DateTime(2026, 3, 20),
        forma: FormaPagamento.credito,
        cartaoId: cartao.id,
        hoje: hoje,
      );

  Future<List<Lancamento>> cobrancas() async => (await db.lancamentosDao.todos())
    ..sort((a, b) => a.data.compareTo(b.data));

  test('a cobrança entra sozinha na fatura do cartão, sem conta pendente', () async {
    final id = await criar();
    final lancs = await cobrancas();
    expect(lancs.length, 2); // março e abril (janela: mês atual + 1)
    expect(lancs.map((l) => l.data), [DateTime(2026, 3, 20), DateTime(2026, 4, 20)]);
    for (final l in lancs) {
      expect(l.tipo, TipoLancamento.gasto);
      expect(l.formaPagamento, FormaPagamento.credito);
      expect(l.cartaoId, cartao.id);
      expect(l.contaId, isNull); // não mexe em nenhuma conta
      expect(l.valor, 4000);
      expect(l.descricao, 'Streaming');
      expect(l.ocorrenciaCompromissoId, isNotNull);
    }
    // 20/03 já passou do fechamento (dia 10): cai na fatura que fecha em abril
    final faturas = {for (final f in await db.cartoesDao.todasFaturas()) f.id: f.competencia};
    expect(lancs.map((l) => faturas[l.faturaId]), ['2026-04', '2026-05']);

    final ocs = await db.compromissosDao.todasOcorrencias();
    expect(ocs.length, 2);
    expect(ocs.every((o) => o.status == StatusOcorrencia.paga && o.lancamentoId != null), isTrue);
    expect(ocs.any((o) => o.status == StatusOcorrencia.pendente), isFalse);
    expect((await db.compromissosDao.compromisso(id))!.cartaoId, cartao.id);
  });

  test('gerar de novo não duplica; o mês seguinte entra quando chega a hora', () async {
    await criar();
    await s.gerarOcorrencias(hoje: hoje);
    expect((await cobrancas()).length, 2);
    await s.gerarOcorrencias(hoje: DateTime(2026, 4, 2));
    final lancs = await cobrancas();
    expect(lancs.length, 3);
    expect(lancs.last.data, DateTime(2026, 5, 20));
  });

  test('exige cartão e só aceita recorrente', () async {
    expect(
      () => s.criarCompromisso(
        descricao: 'x', valor: 1, tipo: TipoCompromisso.recorrente,
        dataInicio: hoje, forma: FormaPagamento.credito, hoje: hoje,
      ),
      throwsA(isA<OperacaoInvalida>()),
    );
    expect(
      () => s.criarCompromisso(
        descricao: 'x', valor: 1, tipo: TipoCompromisso.parcelado, numeroParcelas: 3,
        dataInicio: hoje, forma: FormaPagamento.credito, cartaoId: cartao.id, hoje: hoje,
      ),
      throwsA(isA<OperacaoInvalida>()),
    );
  });

  test('editar o valor refaz só as cobranças futuras', () async {
    final id = await criar(inicio: DateTime(2026, 3, 12));
    final c = (await db.compromissosDao.compromisso(id))!;
    // "hoje" = 25/03: a de 12/03 já passou; a de 12/04 é futura
    await s.atualizarCompromisso(c, valor: 5500, hoje: DateTime(2026, 3, 25));
    final lancs = await cobrancas();
    expect(lancs.map((l) => (l.data, l.valor)), [
      (DateTime(2026, 3, 12), 4000), // passado: fica como estava
      (DateTime(2026, 4, 12), 5500), // futuro: refeito
    ]);
  });

  test('excluir o gasto fixo remove as cobranças futuras e mantém as passadas', () async {
    final id = await criar(inicio: DateTime(2026, 3, 12));
    await s.excluirCompromisso(id);
    final lancs = await cobrancas();
    // a de 12/03 já passou (hoje real é bem depois de março/2026): tudo é "passado"
    expect(lancs.length, lessThanOrEqualTo(2));
    expect(await db.compromissosDao.todosCompromissos(), isEmpty);
    expect(await db.compromissosDao.todasOcorrencias(), isEmpty);
  });

  test('pausar o gasto fixo tira as cobranças futuras', () async {
    final id = await criar(inicio: DateTime(2026, 3, 12));
    final c = (await db.compromissosDao.compromisso(id))!;
    await s.atualizarCompromisso(c, ativo: false, hoje: DateTime(2026, 3, 25));
    final lancs = await cobrancas();
    expect(lancs.map((l) => l.data), [DateTime(2026, 3, 12)]);
  });

  test('apagar a cobrança de um mês a dispensa: não é gerada de novo', () async {
    await criar();
    final primeira = (await cobrancas()).first;
    await ServicoCartao(db).excluirCompra(primeira, EscopoParcelas.soEsta);
    await s.gerarOcorrencias(hoje: hoje);
    await s.gerarOcorrencias(hoje: hoje);

    final lancs = await cobrancas();
    expect(lancs.length, 1); // só a de abril
    final ocs = await db.compromissosDao.todasOcorrencias();
    expect(ocs.length, 2);
    final dispensada = ocs.firstWhere((o) => o.lancamentoId == null);
    expect(dispensada.status, StatusOcorrencia.paga); // nunca vira "pendente para pagar"
  });

  test('fatura já paga não é mexida: a cobrança cai no ciclo seguinte', () async {
    final cartaoServ = ServicoCartao(db);
    // fatura que fecha em abril (compra de 12/03) paga antes
    await cartaoServ.registrarCompra(
      cartao: cartao, valorTotal: 10000, parcelas: 1,
      data: DateTime(2026, 3, 12), descricao: 'Compra',
    );
    final abril = (await db.cartoesDao.todasFaturas()).single;
    expect(abril.competencia, '2026-04');
    await cartaoServ.pagarFatura(fatura: abril, contaId: contaId, data: DateTime(2026, 4, 17));
    final totalAntes = await cartaoServ.totalDaFatura(abril.id);

    await criar(inicio: DateTime(2026, 3, 20)); // cairia na fatura de abril (paga)

    expect(await cartaoServ.totalDaFatura(abril.id), totalAntes);
    final faturas = {for (final f in await db.cartoesDao.todasFaturas()) f.id: f};
    final cobranca = (await cobrancas()).firstWhere((l) => l.descricao == 'Streaming');
    expect(faturas[cobranca.faturaId]!.competencia, '2026-05');
  });

  test('não conta como "conta fixa pendente" nem tem o que pagar', () async {
    await criar();
    final ocs = await db.compromissosDao.todasOcorrencias();
    expect(ocs.where((o) => o.status == StatusOcorrencia.pendente), isEmpty);
    expect(
      () => s.pagarOcorrencia(ocs.first, contaId: contaId),
      throwsA(isA<OperacaoInvalida>()), // já está resolvida
    );
  });
}
