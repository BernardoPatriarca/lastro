import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/servicos/servico_compromisso.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/importacao/importacao_controller.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

Uint8List bytesDe(String fixture) => File('test/fixtures/$fixture').readAsBytesSync();

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<(ProviderContainer, Ambiente)> abrir(
    WidgetTester tester,
    String fixture, {
    Future<void> Function(Ambiente)? preparar,
  }) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      await amb.db.contasDao.inserir(ContasCompanion.insert(
        nome: 'Corrente',
        tipo: TipoConta.corrente,
        dataSaldoInicial: DateTime(2026, 1, 1),
        saldoInicial: const Value(100000),
      ));
      await amb.db.cartoesDao.inserir(CartoesCompanion.insert(
        nome: 'Cartão',
        diaFechamento: 20,
        diaVencimento: 27,
      ));
      if (preparar != null) await preparar(amb);
    });
    await tester.pumpWidget(ProviderScope(
      overrides: [
        ...amb.overrides,
        seletorDeArquivoProvider.overrideWithValue(
          () async => ArquivoEscolhido(fixture, bytesDe(fixture)),
        ),
      ],
      child: const LastroApp(),
    ));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Importar extrato'));
    await tester.pumpAndSettle();
    return (c, amb);
  }

  Future<void> encerrar(WidgetTester tester, Ambiente amb) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1)); // descarte atrasado dos diálogos
    await tester.runAsync(amb.fechar);
  }

  testWidgets('OFX de conta: revisa, marca conta fixa como paga, importa e ajusta saldo',
      (tester) async {
    final (_, amb) = await abrir(tester, 'extrato_conta_sgml.ofx', preparar: (a) async {
      final categorias = {for (final c in await a.db.categoriasDao.todas()) c.nome: c.id};
      await a.db.categoriasDao.inserirRegra(RegrasCategorizacaoCompanion.insert(
        padrao: 'supermercado',
        categoriaId: categorias['Mercado']!,
      ));
      final conta = (await a.db.contasDao.obter(1))!;
      await ServicoCompromisso(a.db).criarCompromisso(
        descricao: 'Aluguel',
        valor: 120000,
        tipo: TipoCompromisso.recorrente,
        dataInicio: DateTime(2026, 3, 5),
        forma: FormaPagamento.boleto,
        contaId: conta.id,
        hoje: DateTime(2026, 3, 5),
      );
    });

    await tester.tap(find.text('Escolher arquivo (OFX ou CSV)'));
    await tester.pumpAndSettle();

    // revisão
    expect(find.text('Revisar importação'), findsOneWidget);
    expect(find.text('5 de 5 selecionadas'), findsOneWidget);
    expect(find.text('Mercado'), findsOneWidget); // sugerida pela regra "supermercado"
    expect(find.textContaining('Marcar "Aluguel" como paga'), findsOneWidget);

    await tester.tap(find.text('Importar 5 lançamentos'));
    await tester.pumpAndSettle();

    // primeira importação: oferece ajustar o saldo inicial (saldo do OFX: 3.731,60)
    expect(find.text('Ajustar saldo inicial?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Ajustar'));
    await tester.pumpAndSettle();

    final r = await tester.runAsync(() async {
      final lancs = await amb.db.lancamentosDao.todos();
      final ocs = await amb.db.compromissosDao.todasOcorrencias();
      final conta = (await amb.db.contasDao.obter(1))!;
      return (lancs, ocs, conta);
    });
    final (lancs, ocs, conta) = r!;
    expect(lancs.length, 5);
    expect(lancs.every((l) => l.origem == OrigemLancamento.importado), isTrue);
    final marco = ocs.firstWhere((o) => o.competencia == '2026-03');
    expect(marco.status, StatusOcorrencia.paga);
    // 1.000,00 inicial -> ajustado para o saldo ficar 3.731,60 como no banco
    expect(conta.saldoInicial, 100000 + (373160 - 403160));
    final mercado = lancs.firstWhere((l) => l.descricao.contains('SUPERMERCADO'));
    expect(mercado.categoriaId, isNotNull);

    await encerrar(tester, amb);
  });

  testWidgets('reimportar o mesmo arquivo: tudo já importado e desmarcado', (tester) async {
    final (_, amb) = await abrir(tester, 'extrato_conta_sgml.ofx');
    await tester.tap(find.text('Escolher arquivo (OFX ou CSV)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Importar 5 lançamentos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agora não'));
    await tester.pumpAndSettle();

    // de novo
    await tester.tap(find.text('Importar extrato'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo (OFX ou CSV)'));
    await tester.pumpAndSettle();
    expect(find.text('0 de 5 selecionadas · 5 já importadas'), findsOneWidget);
    expect(find.text('Já importada'), findsNWidgets(5));
    expect(tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed, isNull);

    await encerrar(tester, amb);
  });

  testWidgets('CSV: mapeia colunas, ignora linha inválida e importa', (tester) async {
    final (_, amb) = await abrir(tester, 'extrato_conta.csv');
    await tester.tap(find.text('Escolher arquivo (OFX ou CSV)'));
    await tester.pumpAndSettle();

    expect(find.text('Mapear colunas do CSV'), findsOneWidget);
    expect(find.textContaining('5 transações lidas · 1 linhas ignoradas'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Salvar este mapeamento como (nome do banco)'), 'Banco Teste');
    await tester.tap(find.text('Continuar para a revisão'));
    await tester.pumpAndSettle();

    // as duas "PADARIA, SAO JOAO" iguais no mesmo dia não são duplicadas entre si
    expect(find.text('5 de 5 selecionadas'), findsOneWidget);
    await tester.tap(find.text('Importar 5 lançamentos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agora não'));
    await tester.pumpAndSettle();

    final r = await tester.runAsync(() async => (
          await amb.db.lancamentosDao.todos(),
          await amb.db.select(amb.db.mapeamentosCsv).get(),
        ));
    expect(r!.$1.length, 5);
    expect(r.$2.single.nome, 'Banco Teste');
    expect(r.$2.single.colunaTipo, 3);

    await encerrar(tester, amb);
  });

  testWidgets('fatura de cartão em OFX: compras no crédito; entrada começa desmarcada',
      (tester) async {
    final (_, amb) = await abrir(tester, 'fatura_cartao_xml.ofx');
    await tester.tap(find.text('Fatura de cartão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo (OFX ou CSV)'));
    await tester.pumpAndSettle();

    expect(find.text('2 de 3 selecionadas'), findsOneWidget);
    await tester.tap(find.text('Importar 2 lançamentos'));
    await tester.pumpAndSettle();

    final lancs = (await tester.runAsync(() => amb.db.lancamentosDao.todos()))!;
    expect(lancs.length, 2);
    expect(lancs.every((l) => l.formaPagamento == FormaPagamento.credito), isTrue);
    expect(lancs.fold<int>(0, (a, l) => a + l.valor), 13490);

    await encerrar(tester, amb);
  });

  testWidgets('corrigir a categoria oferece criar regra e reaplica nas outras linhas',
      (tester) async {
    final (_, amb) = await abrir(tester, 'extrato_conta_sgml.ofx');
    await tester.tap(find.text('Escolher arquivo (OFX ou CSV)'));
    await tester.pumpAndSettle();

    // primeira linha de saída: "COMPRA DEBITO - SUPERMERCADO BOM PRECO"
    final chipsSem = find.widgetWithText(ActionChip, 'Sem categoria');
    expect(chipsSem, findsNWidgets(5));
    await tester.tap(chipsSem.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mercado').last);
    await tester.pumpAndSettle();

    expect(find.text('Criar regra?'), findsOneWidget);
    await tester.tap(find.text('Criar regra'));
    await tester.pumpAndSettle();

    final regras = (await tester.runAsync(() => amb.db.categoriasDao.todasRegras()))!;
    expect(regras.length, 1);
    expect(regras.single.padrao, contains('supermercado'));

    await encerrar(tester, amb);
  });
}
