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

  testWidgets('criar subcategoria, regra de categorização e testar descrição',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
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

    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Categorias'));
    await tester.pumpAndSettle();

    // padrão do seed aparece
    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.text('Mercado'), findsOneWidget);

    // nova subcategoria "Padaria" dentro de Alimentação
    await tester.tap(find.text('Nova categoria'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Padaria');
    await tester.tap(find.byType(DropdownButtonFormField<int?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alimentação').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar categoria'));
    await tester.pumpAndSettle();

    final cats = c.read(categoriasProvider).value!;
    final padaria = cats.firstWhere((x) => x.nome == 'Padaria');
    final alimentacao = cats.firstWhere((x) => x.nome == 'Alimentação');
    expect(padaria.categoriaPaiId, alimentacao.id);
    expect(padaria.tipo, TipoCategoria.gasto);
    expect(find.text('Padaria'), findsOneWidget);

    // regra "padaria" → Padaria
    await tester.tap(find.byTooltip('Regras de categorização'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma regra ainda'), findsOneWidget);
    await tester.tap(find.text('Nova regra'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Descrições que contêm'), 'padaria');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Padaria').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar regra'));
    await tester.pumpAndSettle();
    expect(find.text('"padaria"'), findsOneWidget);
    expect(c.read(regrasProvider).value!.single.categoriaId, padaria.id);

    // testar descrição (sem acento / caixa alta)
    await tester.enterText(find.widgetWithText(TextField, 'Testar uma descrição'), 'PADARIA SAO JOAO');
    await tester.pump();
    expect(find.textContaining('Seria categorizada como: Padaria'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Testar uma descrição'), 'outro lugar');
    await tester.pump();
    expect(find.textContaining('Nenhuma regra casa'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });
}
