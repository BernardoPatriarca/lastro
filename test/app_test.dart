import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/core/theme/tema_provider.dart';

Future<void> _abrirApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: LastroApp()));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('abre no login e entra no Início com as 5 abas', (tester) async {
    await _abrirApp(tester);

    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Pode gastar no crédito'), findsOneWidget);
    for (final aba in [
      'Início',
      'Lançamentos',
      'Cartões',
      'Investimentos',
      'Mais',
    ]) {
      expect(find.widgetWithText(NavigationDestination, aba), findsOneWidget);
    }
  });

  testWidgets('navega pelas abas e cada uma tem estado vazio', (tester) async {
    await _abrirApp(tester);
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Lançamentos'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum lançamento neste mês'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Cartões'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum cartão cadastrado'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(NavigationDestination, 'Investimentos'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nenhum investimento cadastrado'), findsOneWidget);
  });

  testWidgets('botão + aparece nas abas principais e some em Mais', (
    tester,
  ) async {
    await _abrirApp(tester);
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('tema padrão é escuro e pode virar claro', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LastroApp()));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(LastroApp)),
    );
    expect(container.read(temaModoProvider), ThemeMode.dark);

    container.read(temaModoProvider.notifier).definir(ThemeMode.light);
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
  });
}
