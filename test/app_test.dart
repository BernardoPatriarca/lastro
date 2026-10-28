import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/features/login/auth_controller.dart';

import 'helpers/ambiente.dart';

Future<ProviderContainer> abrir(WidgetTester tester, Ambiente amb) async {
  await tester.runAsync(amb.preparar);
  await tester.pumpWidget(
    ProviderScope(overrides: amb.overrides, child: const LastroApp()),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
}

Future<void> fechar(WidgetTester tester, Ambiente amb) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
  await tester.runAsync(amb.fechar);
}

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('primeira abertura pede para criar a senha e entra no Início',
      (tester) async {
    final amb = Ambiente();
    final c = await abrir(tester, amb);

    expect(find.text('Crie sua senha'), findsOneWidget);
    expect(c.read(authProvider), EstadoAuth.semSenha);

    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'abc');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirme a senha'), 'abc');
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('pelo menos 6'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'), 'segredo123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirme a senha'), 'outra123');
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    expect(find.text('As senhas não conferem'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirme a senha'), 'segredo123');
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(c.read(authProvider), EstadoAuth.liberado);
    expect(find.text('Pode gastar no crédito'), findsOneWidget);
    await fechar(tester, amb);
  });

  testWidgets('login: senha errada avisa, certa entra', (tester) async {
    final amb = Ambiente(comSenha: true);
    final c = await abrir(tester, amb);

    expect(find.text('Entrar'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'errada');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Restam 4 tentativas'), findsOneWidget);
    expect(c.read(authProvider), EstadoAuth.bloqueado);

    await tester.enterText(find.byType(TextField), 'segredo123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(c.read(authProvider), EstadoAuth.liberado);
    expect(find.text('Pode gastar no crédito'), findsOneWidget);
    await fechar(tester, amb);
  });

  testWidgets('5 senhas erradas bloqueiam o campo por 30 s', (tester) async {
    final amb = Ambiente(comSenha: true);
    await abrir(tester, amb);

    for (var i = 0; i < 5; i++) {
      await tester.enterText(find.byType(TextField), 'errada$i');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('Muitas tentativas'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);

    await tester.pump(const Duration(seconds: 31));
    expect(find.textContaining('Muitas tentativas'), findsNothing);
    await fechar(tester, amb);
  });

  testWidgets('bloqueia ao voltar do segundo plano após o tempo', (tester) async {
    final amb = Ambiente(comSenha: true);
    final c = await abrir(tester, amb);
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();
    expect(c.read(authProvider), EstadoAuth.liberado);

    // volta rápido: continua liberado
    c.read(authProvider.notifier).foiParaSegundoPlano();
    c.read(authProvider.notifier).voltouDoSegundoPlano();
    expect(c.read(authProvider), EstadoAuth.liberado);

    // tempo zero: sempre bloqueia
    await c.read(definirAjusteProvider)('bloqueio_minutos', '0');
    await tester.pumpAndSettle();
    c.read(authProvider.notifier).foiParaSegundoPlano();
    c.read(authProvider.notifier).voltouDoSegundoPlano();
    await tester.pumpAndSettle();
    expect(c.read(authProvider), EstadoAuth.bloqueado);
    expect(find.text('Entrar'), findsOneWidget);
    await fechar(tester, amb);
  });

  testWidgets('abas e botão + depois de entrar', (tester) async {
    final amb = Ambiente(comSenha: true);
    final c = await abrir(tester, amb);
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    for (final aba in ['Início', 'Lançamentos', 'Cartões', 'Investimentos', 'Mais']) {
      expect(find.widgetWithText(NavigationDestination, aba), findsOneWidget);
    }
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsNothing);
    await fechar(tester, amb);
  });
}
