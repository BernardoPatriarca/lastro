import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/dados_ficticios.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<(ProviderContainer, Ambiente)> abrir(WidgetTester tester, {bool demo = true}) async {
    tester.view.physicalSize = const Size(780, 3000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      if (demo) await popularDadosFicticios(amb.db);
    });
    await tester.pumpWidget(ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Relatórios'));
    await tester.pumpAndSettle();
    return (c, amb);
  }

  Future<void> encerrar(WidgetTester tester, Ambiente amb) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(amb.fechar);
  }

  testWidgets('relatórios com dados: todas as seções, 6 e 12 meses, sem erros', (tester) async {
    final (_, amb) = await abrir(tester);
    for (final t in [
      'Ganhos × gastos × investido',
      'Gastos fixos × variáveis',
      'Média mensal por categoria',
      'Comparativo por categoria',
    ]) {
      expect(find.text(t), findsOneWidget);
    }
    expect(find.textContaining('Fixos ·'), findsOneWidget);
    expect(find.textContaining('Variáveis ·'), findsOneWidget);
    expect(find.textContaining('Mês anterior:'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Últimos 12 meses'));
    await tester.pumpAndSettle();
    expect(find.text('Ganhos × gastos × investido'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // mês anterior no comparativo
    await tester.tap(find.byTooltip('Mês anterior'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await encerrar(tester, amb);
  });

  testWidgets('relatórios sem dados mostram estados vazios', (tester) async {
    final (_, amb) = await abrir(tester, demo: false);
    expect(find.text('Sem movimentos neste período.'), findsOneWidget);
    expect(find.text('Sem gastos neste período.'), findsWidgets);
    expect(find.text('Sem gastos neste mês nem no anterior.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await encerrar(tester, amb);
  });
}
