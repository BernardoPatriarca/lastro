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

  testWidgets('criar investimento, aportar, atualizar saldo e criar meta', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      await amb.db.contasDao.inserir(ContasCompanion.insert(
        nome: 'Corrente',
        tipo: TipoConta.corrente,
        dataSaldoInicial: DateTime(2020, 1, 1),
        saldoInicial: const Value(500000),
      ));
    });
    await tester.pumpWidget(
        ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Investimentos'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum investimento cadastrado'), findsOneWidget);

    // novo investimento
    await tester.tap(find.text('Novo investimento').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Reserva');
    await tester.tap(find.text('Criar'));
    await tester.pumpAndSettle();
    expect(find.text('Reserva'), findsOneWidget);

    // detalhe → aporte de R$ 1.000,00
    await tester.tap(find.text('Reserva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aporte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '100000');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(c.read(patrimonioProvider), 100000);
    // o dinheiro saiu da conta (abre o Início para retomar o provider pausado)
    await tester.tap(find.widgetWithText(NavigationDestination, 'Início'));
    await tester.pumpAndSettle();
    expect(c.read(saldoTotalProvider), 400000);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Investimentos'));
    await tester.pumpAndSettle();

    // atualizar saldo para R$ 1.080,00 (rendimento): não mexe na conta
    await tester.tap(find.text('Atualizar saldo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '108000');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(c.read(patrimonioProvider), 108000);
    expect(find.text('Saldo atualizado para'), findsOneWidget);

    // volta e cria uma meta
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova meta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome da meta'), 'Viagem');
    await tester.enterText(find.widgetWithText(TextFormField, 'Valor-alvo'), '300000');
    await tester.tap(find.text('Criar meta'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Viagem'), findsOneWidget);
    final progresso = c.read(progressoMetasProvider).values.single;
    expect(progresso.atual, 108000); // sem vínculo: patrimônio total
    expect(progresso.alvo, 300000);
    expect(find.textContaining('por mês'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(amb.fechar);
  });
}
