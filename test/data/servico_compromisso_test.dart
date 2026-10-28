import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/data/servicos/servico_cartao.dart';
import 'package:lastro/data/servicos/servico_compromisso.dart';
import 'package:lastro/data/servicos/servico_lancamentos.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/enums.dart';

void main() {
  late AppDatabase db;
  late ServicoCompromisso s;
  late int contaId;
  final hoje = DateTime(2026, 3, 15);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    s = ServicoCompromisso(db);
    contaId = await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta',
      tipo: TipoConta.corrente,
      dataSaldoInicial: DateTime(2020, 1, 1),
      saldoInicial: const Value(100000),
    ));
  });
  tearDown(() => db.close());

  Future<List<OcorrenciaCompromisso>> ocorrencias() =>
      db.compromissosDao.todasOcorrencias();

  test('recorrente criada no mês atual gera mês atual e o próximo', () async {
    await s.criarCompromisso(
      descricao: 'Internet',
      valor: 9990,
      tipo: TipoCompromisso.recorrente,
      dataInicio: DateTime(2026, 3, 20),
      forma: FormaPagamento.boleto,
      contaId: contaId,
      hoje: hoje,
    );
    final o = await ocorrencias();
    expect(o.map((e) => e.competencia).toSet(), {'2026-03', '2026-04'});
    expect(o.every((e) => e.status == StatusOcorrencia.pendente), isTrue);
  });

  test('gerar de novo não duplica (competência única)', () async {
    await s.criarCompromisso(
      descricao: 'Internet', valor: 100, tipo: TipoCompromisso.recorrente,
      dataInicio: DateTime(2026, 3, 20), forma: FormaPagamento.boleto,
      contaId: contaId, hoje: hoje,
    );
    await s.gerarOcorrencias(hoje: hoje);
    await s.gerarOcorrencias(hoje: hoje);
    expect((await ocorrencias()).length, 2);
    // o app aberto no mês seguinte gera o novo mês
    await s.gerarOcorrencias(hoje: DateTime(2026, 4, 2));
    expect((await ocorrencias()).length, 3);
  });

  test('compromisso antigo só gera a partir do mês anterior', () async {
    await s.criarCompromisso(
      descricao: 'Academia', valor: 100, tipo: TipoCompromisso.recorrente,
      dataInicio: DateTime(2025, 1, 10), forma: FormaPagamento.pix,
      contaId: contaId, hoje: hoje,
    );
    expect((await ocorrencias()).map((e) => e.competencia).toSet(),
        {'2026-02', '2026-03', '2026-04'});
  });

  test('pagar cria o gasto na conta e marca como paga', () async {
    await s.criarCompromisso(
      descricao: 'Luz', valor: 25000, tipo: TipoCompromisso.recorrente,
      dataInicio: DateTime(2026, 3, 10), forma: FormaPagamento.boleto,
      contaId: contaId, hoje: hoje,
    );
    final o = (await ocorrencias()).firstWhere((e) => e.competencia == '2026-03');
    final id = await s.pagarOcorrencia(o, data: DateTime(2026, 3, 12));

    final l = (await db.lancamentosDao.obter(id))!;
    expect(l.tipo, TipoLancamento.gasto);
    expect(l.valor, 25000);
    expect(l.formaPagamento, FormaPagamento.boleto);
    expect(l.contaId, contaId);
    expect(l.ocorrenciaCompromissoId, o.id);
    final paga = (await db.compromissosDao.ocorrencia(o.id))!;
    expect(paga.status, StatusOcorrencia.paga);
    expect(paga.lancamentoId, id);
    expect(() => s.pagarOcorrencia(paga), throwsA(isA<OperacaoInvalida>()));
  });

  test('pagar com valor diferente do previsto', () async {
    await s.criarCompromisso(
      descricao: 'Luz', valor: 25000, tipo: TipoCompromisso.recorrente,
      dataInicio: DateTime(2026, 3, 10), forma: FormaPagamento.boleto,
      contaId: contaId, hoje: hoje,
    );
    final o = (await ocorrencias()).first;
    final id = await s.pagarOcorrencia(o, valor: 27345);
    expect((await db.lancamentosDao.obter(id))!.valor, 27345);
  });

  test('sem conta definida pede a conta', () async {
    await s.criarCompromisso(
      descricao: 'Luz', valor: 100, tipo: TipoCompromisso.recorrente,
      dataInicio: DateTime(2026, 3, 10), forma: FormaPagamento.boleto, hoje: hoje,
    );
    final o = (await ocorrencias()).first;
    expect(() => s.pagarOcorrencia(o), throwsA(isA<OperacaoInvalida>()));
    await s.pagarOcorrencia(o, contaId: contaId); // informando a conta, vai
  });

  test('parcelado encerra após pagar a última parcela', () async {
    final id = await s.criarCompromisso(
      descricao: 'Empréstimo', valor: 50000, tipo: TipoCompromisso.parcelado,
      numeroParcelas: 2, dataInicio: DateTime(2026, 3, 5),
      forma: FormaPagamento.boleto, contaId: contaId, hoje: hoje,
    );
    final o = await ocorrencias()
      ..sort((a, b) => a.numeroParcela!.compareTo(b.numeroParcela!));
    expect(o.map((e) => e.numeroParcela), [1, 2]);
    await s.pagarOcorrencia(o[0]);
    expect((await db.compromissosDao.compromisso(id))!.ativo, isTrue);
    await s.pagarOcorrencia(o[1]);
    expect((await db.compromissosDao.compromisso(id))!.ativo, isFalse);
    final desc = (await db.lancamentosDao.todos()).map((l) => l.descricao).toSet();
    expect(desc, {'Empréstimo (1/2)', 'Empréstimo (2/2)'});
  });

  test('excluir o lançamento reabre a ocorrência (e reativa o parcelado)', () async {
    final id = await s.criarCompromisso(
      descricao: 'Empréstimo', valor: 100, tipo: TipoCompromisso.parcelado,
      numeroParcelas: 1, dataInicio: DateTime(2026, 3, 5),
      forma: FormaPagamento.boleto, contaId: contaId, hoje: hoje,
    );
    final o = (await ocorrencias()).first;
    final lancId = await s.pagarOcorrencia(o);
    expect((await db.compromissosDao.compromisso(id))!.ativo, isFalse);

    await ServicoLancamentos(db).excluir(lancId);

    final reaberta = (await db.compromissosDao.ocorrencia(o.id))!;
    expect(reaberta.status, StatusOcorrencia.pendente);
    expect(reaberta.lancamentoId, isNull);
    expect((await db.compromissosDao.compromisso(id))!.ativo, isTrue);
  });

  test('editar refaz só as pendentes com o novo valor', () async {
    final id = await s.criarCompromisso(
      descricao: 'Internet', valor: 10000, tipo: TipoCompromisso.recorrente,
      dataInicio: DateTime(2026, 3, 10), forma: FormaPagamento.boleto,
      contaId: contaId, hoje: hoje,
    );
    final marco = (await ocorrencias()).firstWhere((e) => e.competencia == '2026-03');
    await s.pagarOcorrencia(marco);

    final c = (await db.compromissosDao.compromisso(id))!;
    await s.atualizarCompromisso(c, valor: 12000, hoje: hoje);

    final o = await ocorrencias();
    expect(o.firstWhere((e) => e.competencia == '2026-03').valor, 10000); // paga
    expect(o.firstWhere((e) => e.competencia == '2026-04').valor, 12000);
  });

  test('receita recorrente: confirmar cria o ganho com o vínculo', () async {
    final id = await s.criarReceita(
      descricao: 'Salário', valorPrevisto: 500000, contaId: contaId,
      dataInicio: DateTime(2026, 1, 5),
    );
    final r = (await db.compromissosDao.receita(id))!;
    final lancId = await s.confirmarReceita(r, valor: 510000, data: DateTime(2026, 3, 5));
    final l = (await db.lancamentosDao.obter(lancId))!;
    expect(l.tipo, TipoLancamento.ganho);
    expect(l.valor, 510000);
    expect(l.receitaRecorrenteId, id);
    expect(l.contaId, contaId);
  });

  group('providers (com data real)', () {
    late ProviderContainer c;
    setUp(() => c = ProviderContainer(overrides: [bancoProvider.overrideWithValue(db)]));
    tearDown(() => c.dispose());

    Future<void> carregar() async {
      for (final p in [
        compromissosProvider, ocorrenciasProvider, receitasProvider,
        lancamentosProvider, faturasProvider,
      ]) {
        c.listen(p, (_, _) {});
        await c.read((p as dynamic).future);
      }
    }

    test('receita pendente some depois de confirmada no mês', () async {
      final agora = DateTime.now();
      final id = await s.criarReceita(
        descricao: 'Salário', valorPrevisto: 100, contaId: contaId,
        dataInicio: DateTime(agora.year, agora.month, 1),
      );
      await carregar();
      expect(c.read(receitasPendentesProvider).map((r) => r.id), [id]);

      await s.confirmarReceita((await db.compromissosDao.receita(id))!);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.read(receitasPendentesProvider), isEmpty);
    });

    test('projeção de 12 meses soma fixos e fatura não paga', () async {
      final agora = DateTime.now();
      await s.criarCompromisso(
        descricao: 'Aluguel', valor: 100000, tipo: TipoCompromisso.recorrente,
        dataInicio: DateTime(agora.year, agora.month, 1),
        forma: FormaPagamento.boleto, contaId: contaId,
      );
      final cartaoId = await db.cartoesDao.inserir(CartoesCompanion.insert(
        nome: 'C', diaFechamento: 10, diaVencimento: 17,
      ));
      await ServicoCartao(db).registrarCompra(
        cartao: (await db.cartoesDao.obter(cartaoId))!,
        valorTotal: 30000, parcelas: 3, data: agora, descricao: 'TV',
      );
      await carregar();
      final p = c.read(projecaoComprometidoProvider);
      expect(p.length, 12);
      final inicio = Competencia.deData(agora);
      // aluguel em todos os 12 meses (os 2 primeiros gravados + 10 calculados)
      final soAluguel = p.values.where((v) => v == 100000).length;
      final comTv = p.values.where((v) => v == 110000).length;
      expect(soAluguel + comTv, 12);
      expect(comTv, 3); // 3 parcelas de R$ 100,00 em 3 faturas distintas
      expect(p[inicio.somarMeses(11)], 100000);
    });
  });
}
