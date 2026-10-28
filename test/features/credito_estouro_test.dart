import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<(ProviderContainer, Ambiente)> abrir(WidgetTester tester) async {
    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      await amb.db.contasDao.inserir(ContasCompanion.insert(
        nome: 'Corrente',
        tipo: TipoConta.corrente,
        dataSaldoInicial: DateTime(2020, 1, 1),
        saldoInicial: const Value(10000), // R$ 100,00
      ));
      await amb.db.cartoesDao.inserir(CartoesCompanion.insert(
        nome: 'Cartão', diaFechamento: 10, diaVencimento: 17,
      ));
    });
    await tester.pumpWidget(
        ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();
    return (c, amb);
  }

  /// Preenche R$ 200,00 no crédito (passa dos R$ 100,00 em conta).
  Future<void> preencherCompraGrande(WidgetTester tester) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '20000');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Crédito'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('acima do seu saldo'), 150,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Fica R\$ 100,00 acima do seu saldo'), findsOneWidget);
  }

  Future<int> totalDeLancamentos(WidgetTester tester, Ambiente amb) async =>
      (await tester.runAsync(() => amb.db.lancamentosDao.todos()))!.length;

  testWidgets('confirmar (padrão): pede confirmação e respeita o "cancelar"',
      (tester) async {
    final (_, amb) = await abrir(tester);
    await preencherCompraGrande(tester);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Passou do seu saldo'), findsOneWidget);
    expect(find.textContaining('Lançar mesmo assim?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await totalDeLancamentos(tester, amb), 0);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lançar mesmo assim'));
    await tester.pumpAndSettle();
    expect(await totalDeLancamentos(tester, amb), 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });

  testWidgets('bloquear: não deixa lançar', (tester) async {
    final (c, amb) = await abrir(tester);
    await c.read(definirAjusteProvider)('comportamento_estouro', 'bloquear');
    await tester.pumpAndSettle();
    await preencherCompraGrande(tester);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Compra bloqueada'), findsOneWidget);
    expect(await totalDeLancamentos(tester, amb), 0);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });

  testWidgets('avisar: lança direto, só mostrando o aviso', (tester) async {
    final (c, amb) = await abrir(tester);
    await c.read(definirAjusteProvider)('comportamento_estouro', 'avisar');
    await tester.pumpAndSettle();
    await preencherCompraGrande(tester);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Passou do seu saldo'), findsNothing);
    expect(await totalDeLancamentos(tester, amb), 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });

  testWidgets('card no Início mostra o pode gastar e fica negativo ao estourar',
      (tester) async {
    final (c, amb) = await abrir(tester);
    expect(find.text('Pode gastar no crédito'), findsOneWidget);
    expect(find.textContaining('100,00'), findsWidgets);

    await c.read(definirAjusteProvider)('comportamento_estouro', 'avisar');
    await tester.pumpAndSettle();
    await preencherCompraGrande(tester);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('-R\$ 100,00'), findsWidgets);
    expect(find.textContaining('já passou do que tem em conta'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });
}
