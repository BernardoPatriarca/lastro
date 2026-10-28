import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/dados_ficticios.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('orçamento: limites do mês com barras, definir e remover limite',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
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

    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orçamento'));
    await tester.pumpAndSettle();

    // seed de demonstração: Alimentação, Transporte/Carro e Lazer têm limite
    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.textContaining('de R\$ 800,00'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // define limite para Saúde
    await tester.tap(find.text('Saúde'));
    await tester.pumpAndSettle();
    expect(find.text('Limite de Saúde'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '50000');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    final mes = Competencia.deData(DateTime.now()).chave;
    final limites = c.read(orcamentosProvider).value!
        .where((o) => o.competencia == mes)
        .map((o) => o.limite);
    expect(limites, contains(50000));
    expect(find.textContaining('de R\$ 500,00'), findsOneWidget);

    // remove o limite de Saúde
    await tester.tap(find.textContaining('de R\$ 500,00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover limite'));
    await tester.pumpAndSettle();
    expect(find.textContaining('de R\$ 500,00'), findsNothing);

    // mês seguinte está sem limites; copiar traz os do mês anterior
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pumpAndSettle();
    expect(find.textContaining('de R\$ 800,00'), findsNothing);
    await tester.tap(find.byTooltip('Copiar do mês anterior'));
    await tester.pumpAndSettle();
    expect(find.textContaining('limites copiados'), findsOneWidget);
    expect(find.textContaining('de R\$ 800,00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(amb.fechar);
  });
}
