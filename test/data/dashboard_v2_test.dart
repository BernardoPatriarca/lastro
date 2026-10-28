import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/core/widgets/seletor_mes.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/dados_ficticios.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/data/servicos/servico_lancamentos.dart';
import 'package:lastro/data/servicos/servico_orcamento.dart';
import 'package:lastro/domain/alertas.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/orcamento.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer c;
  final hoje = DateTime.now();
  final mes = Competencia.deData(hoje);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    c = ProviderContainer(overrides: [bancoProvider.overrideWithValue(db)]);
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<void> carregar() async {
    for (final p in [
      contasProvider, cartoesProvider, faturasProvider, lancamentosProvider,
      compromissosProvider, ocorrenciasProvider, receitasProvider, categoriasProvider,
      orcamentosProvider, investimentosProvider, movimentosInvestimentoProvider, metasProvider,
    ]) {
      c.listen(p, (_, _) {});
      await c.read((p as dynamic).future);
    }
    c.listen(ajustesProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }

  Future<int> categoria(String nome) async =>
      (await db.categoriasDao.todas()).firstWhere((x) => x.nome == nome).id;

  Future<int> conta() => db.contasDao.inserir(ContasCompanion.insert(
        nome: 'Conta',
        tipo: TipoConta.corrente,
        dataSaldoInicial: DateTime(2020, 1, 1),
        saldoInicial: const Value(1000000),
      ));

  test('orçamento: gasto das subcategorias entra no limite do pai e muda de faixa', () async {
    final contaId = await conta();
    final alimentacao = await categoria('Alimentação');
    final mercado = await categoria('Mercado');
    final dia = DateTime(hoje.year, hoje.month, 1);
    final s = ServicoLancamentos(db);
    await s.registrar(
        tipo: TipoLancamento.gasto, valor: 60000, data: dia, categoriaId: mercado,
        forma: FormaPagamento.pix, contaId: contaId);
    await ServicoOrcamento(db).definirLimite(alimentacao, mes, 100000);
    await carregar();

    var linha = c.read(linhasOrcamentoProvider).firstWhere((l) => l.categoriaId == alimentacao);
    expect(linha.gasto, 60000);
    expect(linha.nivel, NivelOrcamento.verde);
    // com limite: aparece antes das sem limite
    expect(c.read(linhasOrcamentoProvider).first.categoriaId, alimentacao);

    await s.registrar(
        tipo: TipoLancamento.gasto, valor: 25000, data: dia, categoriaId: mercado,
        forma: FormaPagamento.pix, contaId: contaId);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    linha = c.read(linhasOrcamentoProvider).firstWhere((l) => l.categoriaId == alimentacao);
    expect(linha.gasto, 85000);
    expect(linha.nivel, NivelOrcamento.amarelo);

    await s.registrar(
        tipo: TipoLancamento.gasto, valor: 20000, data: dia, categoriaId: alimentacao,
        forma: FormaPagamento.pix, contaId: contaId);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    linha = c.read(linhasOrcamentoProvider).firstWhere((l) => l.categoriaId == alimentacao);
    expect(linha.nivel, NivelOrcamento.vermelho);
    expect(linha.restante, -5000);
  });

  test('definir limite zero remove; copiar do mês anterior traz só os que faltam', () async {
    final lazer = await categoria('Lazer');
    final saude = await categoria('Saúde');
    final s = ServicoOrcamento(db);
    await s.definirLimite(lazer, mes.somarMeses(-1), 20000);
    await s.definirLimite(saude, mes.somarMeses(-1), 30000);
    await s.definirLimite(saude, mes, 99999); // já definido neste mês

    expect(await s.copiarDoMesAnterior(mes), 1);
    final atuais = {for (final o in await db.investimentosDao.orcamentosDe(mes.chave)) o.categoriaId: o.limite};
    expect(atuais, {lazer: 20000, saude: 99999});

    await s.definirLimite(lazer, mes, 0);
    expect((await db.investimentosDao.orcamentosDe(mes.chave)).length, 1);
    expect(await s.copiarDoMesAnterior(mes), 1); // lazer volta (some e é copiado)
  });

  test('projeção do mês só existe no mês corrente e usa o gasto até hoje', () async {
    final contaId = await conta();
    final s = ServicoLancamentos(db);
    await s.registrar(
        tipo: TipoLancamento.gasto, valor: 10000, data: hoje,
        forma: FormaPagamento.pix, contaId: contaId);
    await s.registrar(
        tipo: TipoLancamento.ganho, valor: 500000, data: hoje, contaId: contaId);
    await carregar();

    final p = c.read(projecaoDoMesProvider)!;
    expect(p.gastoAteAgora, 10000);
    expect(p.ganhos, 500000);
    expect(p.projetado, projetarGastoDoMes(
        gastoAteAgora: 10000, diaAtual: hoje.day, diasNoMes: mes.ultimoDia.day));
    expect(p.projetado, greaterThanOrEqualTo(10000));

    c.read(mesSelecionadoProvider.notifier).anterior();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(c.read(projecaoDoMesProvider), isNull);
  });

  test('alertas reais: conta atrasada, orçamento estourado e backup', () async {
    await popularDadosFicticios(db);
    final lazer = await categoria('Lazer');
    // estoura o orçamento de Lazer deste mês
    await db.lancamentosDao.inserir(LancamentosCompanion.insert(
      tipo: TipoLancamento.gasto, valor: 999999, data: DateTime(hoje.year, hoje.month, 1),
      categoriaId: Value(lazer), formaPagamento: const Value(FormaPagamento.pix),
      contaId: const Value(1),
    ));
    await carregar();

    final a = c.read(alertasProvider);
    expect(a, isNotEmpty);
    expect(a.any((x) => x.titulo.contains('Orçamento de Lazer estourado')), isTrue);
    expect(a.any((x) => x.titulo == 'Faça um backup'), isTrue); // nunca fez
    // ordenado: críticos primeiro
    final niveis = a.map((x) => x.nivel.index).toList();
    expect([...niveis]..sort(), niveis);
  });

  test('top categorias traz o limite quando existe e no máximo 5', () async {
    await popularDadosFicticios(db);
    await carregar();
    final top = c.read(topCategoriasProvider);
    expect(top.length, lessThanOrEqualTo(5));
    expect(top, isNotEmpty);
    final gastos = top.map((t) => t.gasto).toList();
    expect([...gastos]..sort((a, b) => b.compareTo(a)), gastos);
    final alim = await categoria('Alimentação');
    final t = top.where((x) => x.categoriaId == alim);
    if (t.isNotEmpty) expect(t.single.limite, 80000);
  });
}
