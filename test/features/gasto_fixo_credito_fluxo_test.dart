import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<(ProviderContainer, Ambiente)> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      await amb.db.contasDao.inserir(ContasCompanion.insert(
        nome: 'Corrente',
        tipo: TipoConta.corrente,
        dataSaldoInicial: DateTime(2020),
        saldoInicial: const Value(100000),
      ));
      await amb.db.cartoesDao.inserir(CartoesCompanion.insert(
        nome: 'Meu Cartão', diaFechamento: 10, diaVencimento: 17,
      ));
    });
    await tester.pumpWidget(ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();
    return (c, amb);
  }

  Future<void> encerrar(WidgetTester tester, Ambiente amb) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.runAsync(amb.fechar);
  }

  testWidgets('lançamento rápido: gasto fixo no crédito cria a cobrança mensal no cartão',
      (tester) async {
    final (_, amb) = await abrir(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '4000'); // R$ 40,00
    await tester.tap(find.widgetWithText(ChoiceChip, 'Crédito'));
    await tester.pumpAndSettle();
    expect(find.text('Parcelas'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Descrição (opcional)'), 'Streaming');
    await tester.tap(find.text('Gasto fixo'));
    await tester.pumpAndSettle();
    // no crédito o fixo é sem fim: não há "parcelas" nem o seletor Sem fim/Parcelado
    expect(find.text('Parcelas'), findsNothing);
    expect(find.text('Parcelado'), findsNothing);
    expect(find.textContaining('primeira cobrança'), findsOneWidget);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('a cobrança entra na fatura do cartão todo mês'), findsOneWidget);

    final r = await tester.runAsync(() async => (
          await amb.db.compromissosDao.todosCompromissos(),
          await amb.db.lancamentosDao.todos(),
          await amb.db.compromissosDao.todasOcorrencias(),
        ));
    final (comps, lancs, ocs) = r!;
    expect(comps.length, 1);
    expect(comps.single.formaPagamento, FormaPagamento.credito);
    expect(comps.single.cartaoId, isNotNull);
    expect(comps.single.contaId, isNull);
    expect(lancs.length, 2); // este mês e o seguinte
    expect(lancs.every((l) => l.formaPagamento == FormaPagamento.credito && l.valor == 4000), isTrue);
    expect(ocs.any((o) => o.status == StatusOcorrencia.pendente), isFalse);

    await encerrar(tester, amb);
  });

  testWidgets('formulário de compromissos: crédito pede o cartão e trava em recorrente',
      (tester) async {
    final (_, amb) = await abrir(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compromissos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gasto fixo ou parcelado'));
    await tester.pumpAndSettle();

    expect(find.text('Conta que paga'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Crédito'));
    await tester.pumpAndSettle();
    expect(find.text('Cartão da cobrança'), findsOneWidget);
    expect(find.text('Conta que paga'), findsNothing);
    expect(find.textContaining('No crédito o gasto fixo é recorrente'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Descrição'), 'Academia');
    await tester.enterText(find.widgetWithText(TextFormField, 'Valor mensal'), '9990');
    await tester.tap(find.text('Criar'));
    await tester.pumpAndSettle();

    final comps = (await tester.runAsync(() => amb.db.compromissosDao.todosCompromissos()))!;
    expect(comps.single.descricao, 'Academia');
    expect(comps.single.formaPagamento, FormaPagamento.credito);
    expect(comps.single.valor, 9990);
    // a lista mostra em qual cartão a cobrança cai
    expect(find.textContaining('No cartão Meu Cartão'), findsOneWidget);

    await encerrar(tester, amb);
  });
}
