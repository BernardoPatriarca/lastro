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

  testWidgets('Início com dados fictícios: todos os cards, sem erros de layout',
      (tester) async {
    // Tamanho de um celular (390 x 844 dp).
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      await popularDadosFicticios(amb.db);
    });
    await tester.pumpWidget(
        ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    final rolagem = find.byType(Scrollable).first;
    expect(find.text('Pode gastar no crédito'), findsOneWidget);
    // alertas (nunca fez backup) e projeção do mês corrente
    expect(find.text('Alertas'), findsOneWidget);
    for (final titulo in [
      'Projeção do mês',
      'Saldo nas contas',
      'Ganhos',
      'Gastos',
      'Investido',
      'Taxa de poupança',
      'Contas do mês',
      'Gastos por categoria',
      'Top categorias do mês',
      'Maiores gastos do mês',
      'Metas',
    ]) {
      await tester.scrollUntilVisible(find.text(titulo), 200, scrollable: rolagem);
      expect(find.text(titulo), findsWidgets);
    }
    expect(tester.takeException(), isNull);

    // mês anterior: continua sem erro e mostra os dados daquele mês
    await tester.scrollUntilVisible(find.byTooltip('Mês anterior'), -400, scrollable: rolagem);
    await tester.tap(find.byTooltip('Mês anterior'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Gastos por categoria'), 200, scrollable: rolagem);
    expect(find.text('Gastos por categoria'), findsOneWidget);

    // olhinho: oculta os valores
    await tester.scrollUntilVisible(find.byTooltip('Ocultar valores'), -2000, scrollable: rolagem);
    await tester.tap(find.byTooltip('Ocultar valores'));
    await tester.pumpAndSettle();
    expect(find.text('R\$ •••'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });

  testWidgets('Início vazio mostra estados vazios amigáveis', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final amb = Ambiente(comSenha: true);
    await tester.runAsync(amb.preparar);
    await tester.pumpWidget(
        ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.textContaining('Nenhuma conta ou fatura'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.scrollUntilVisible(find.textContaining('Nenhum gasto neste mês — toque'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });
}
