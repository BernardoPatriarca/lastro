import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/notificacoes/agendador.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<(ProviderContainer, Ambiente)> abrir(
    WidgetTester tester, {
    required AgendadorFalso agendador,
  }) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final amb = Ambiente(comSenha: true, agendador: agendador);
    await tester.runAsync(amb.preparar);
    await tester.pumpWidget(ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();
    return (c, amb);
  }

  Future<void> encerrar(WidgetTester tester, Ambiente amb) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.runAsync(amb.fechar);
  }

  testWidgets('ligar pede a permissão; com permissão liga e mostra a antecedência',
      (tester) async {
    final (c, amb) = await abrir(tester, agendador: AgendadorFalso());
    expect(c.read(ajustesProvider).notificacoes, isFalse);
    expect(find.text('Avisar com antecedência de'), findsNothing);

    await tester.tap(find.text('Avisar vencimentos'));
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).notificacoes, isTrue);
    expect(find.text('Avisar com antecedência de'), findsOneWidget);

    await tester.tap(find.text('1 dia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 dias').last);
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).notificacoesDias, 3);

    await tester.tap(find.text('Avisar vencimentos'));
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).notificacoes, isFalse);
    await encerrar(tester, amb);
  });

  testWidgets('permissão negada: continua desligado e explica', (tester) async {
    final (c, amb) = await abrir(tester, agendador: AgendadorFalso(concede: false));
    await tester.tap(find.text('Avisar vencimentos'));
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).notificacoes, isFalse);
    expect(find.textContaining('Sem permissão de notificações'), findsOneWidget);
    await encerrar(tester, amb);
  });
}
