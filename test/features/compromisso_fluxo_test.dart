import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('gasto fixo vira pendente, é pago em um toque e aparece em Compromissos',
      (tester) async {
    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      await amb.db.contasDao.inserir(ContasCompanion.insert(
        nome: 'Corrente',
        tipo: TipoConta.corrente,
        dataSaldoInicial: DateTime(2020, 1, 1),
        saldoInicial: const Value(100000),
      ));
    });
    await tester.pumpWidget(
        ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    // + → R$ 250,00, "Aluguel", Boleto, gasto fixo
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '25000');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Boleto'));
    await tester.pump();
    final rolagem = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.widgetWithText(TextFormField, 'Descrição (opcional)'), 150,
        scrollable: rolagem);
    await tester.enterText(find.widgetWithText(TextFormField, 'Descrição (opcional)'), 'Aluguel');
    await tester.scrollUntilVisible(find.text('Gasto fixo'), 150, scrollable: rolagem);
    await tester.tap(find.text('Gasto fixo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // nada foi lançado ainda; a conta fica pendente
    expect(c.read(saldoTotalProvider), 100000);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Lançamentos'));
    await tester.pumpAndSettle();
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.text('Aluguel'), findsOneWidget);

    // um toque em "Pagar"
    await tester.tap(find.widgetWithText(FilledButton, 'Pagar'));
    await tester.pumpAndSettle();
    expect(c.read(saldoTotalProvider), 100000 - 25000);
    expect(find.text('Pendentes'), findsNothing);

    // Mais → Compromissos
    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compromissos'));
    await tester.pumpAndSettle();
    expect(find.text('Comprometido nos próximos 12 meses'), findsOneWidget);
    expect(find.text('Aluguel'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });
}
