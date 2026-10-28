import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('criar conta, lançar um gasto e vê-lo na lista', (tester) async {
    final amb = Ambiente(comSenha: true);
    await tester.runAsync(amb.preparar);
    await tester.pumpWidget(
        ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    // + abre o lançamento rápido; sem conta, avisa e oferece criar
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Novo lançamento'), findsOneWidget);
    expect(find.textContaining('ainda não tem uma conta'), findsOneWidget);

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome da conta'), 'Minha conta');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Saldo inicial'), '100000');
    await tester.tap(find.text('Criar conta').last);
    await tester.pumpAndSettle();

    // de volta ao lançamento: valor 25,50 e categoria
    expect(find.text('Novo lançamento'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '2550');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Moradia'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // lista de lançamentos
    await tester.tap(find.widgetWithText(NavigationDestination, 'Lançamentos'));
    await tester.pumpAndSettle();
    expect(find.text('Moradia'), findsWidgets);
    expect(find.textContaining('25,50'), findsWidgets);

    // saldo da conta: 1.000,00 - 25,50 = 974,50
    expect(c.read(saldoTotalProvider), 97450);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });
}
