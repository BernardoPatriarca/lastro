import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('configurações: crédito seguro, ocultar valores e tema', (tester) async {
    // Tela alta: a página de configurações cabe inteira, sem rolar.
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final amb = Ambiente(comSenha: true);
    await tester.runAsync(amb.preparar);
    await tester.pumpWidget(
        ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    // valores aparecem normalmente
    expect(find.textContaining('R\$ 0,00'), findsWidgets);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();

    // padrão: fatura do mês; dá para escolher o modo rígido
    expect(c.read(ajustesProvider).modoParcelados, ModoParcelados.parcela);
    await tester.tap(find.text('Tudo de uma vez (rígido)'));
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).modoParcelados, ModoParcelados.rigido);

    // bloquear ao estourar
    await tester.tap(find.text('Bloquear'));
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).comportamentoEstouro, ComportamentoEstouro.bloquear);

    // descontar contas fixas desligado
    await tester.tap(find.text('Descontar contas fixas'));
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).descontarFixos, isFalse);

    // ocultar valores
    await tester.tap(find.text('Ocultar valores'));
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).ocultarValores, isTrue);

    // tema claro
    await tester.tap(find.text('Claro'));
    await tester.pumpAndSettle();
    expect(c.read(ajustesProvider).tema, 'light');
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.light);

    // voltando ao Início: nenhum valor em R$ aparece, só a máscara
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Início'));
    await tester.pumpAndSettle();
    expect(find.textContaining('R\$ 0,00'), findsNothing);
    expect(find.text('R\$ •••'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });
}
