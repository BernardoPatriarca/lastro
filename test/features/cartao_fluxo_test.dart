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

  testWidgets('compra parcelada no crédito, fatura e pagamento', (tester) async {
    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      final conta = await amb.db.contasDao.inserir(ContasCompanion.insert(
        nome: 'Corrente',
        tipo: TipoConta.corrente,
        dataSaldoInicial: DateTime(2020, 1, 1),
        saldoInicial: const Value(100000),
      ));
      await amb.db.cartoesDao.inserir(CartoesCompanion.insert(
        nome: 'Meu Cartão',
        diaFechamento: 10,
        diaVencimento: 17,
        limite: const Value(500000),
        contaPagamentoId: Value(conta),
      ));
    });
    await tester.pumpWidget(
        ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    // + → Gasto → Crédito, R$ 100,00 em 3x
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '10000');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Crédito'));
    await tester.pumpAndSettle();
    final rolagem = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.widgetWithText(ChoiceChip, '3x'), 150,
        scrollable: rolagem);
    await tester.tap(find.widgetWithText(ChoiceChip, '3x'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('1ª de'), 150,
        scrollable: rolagem);
    expect(find.textContaining('3x de R\$ 33,33 (1ª de R\$ 33,34)'), findsOneWidget);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // o crédito não mexe no saldo da conta
    expect(c.read(saldoTotalProvider), 100000);

    // Cartões: usado = R$ 100,00 comprometido; fatura atual = 1ª parcela
    await tester.tap(find.widgetWithText(NavigationDestination, 'Cartões'));
    await tester.pumpAndSettle();
    expect(find.text('Meu Cartão'), findsOneWidget);
    final r = c.read(resumosCartaoProvider).single;
    expect(r.usado, 10000);
    expect(r.disponivel, 490000);
    expect(r.totalFaturaAtual, 3334);

    // Detalhe e pagamento da fatura atual
    await tester.tap(find.text('Meu Cartão'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fatura de'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Pagar fatura'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pagar fatura'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Pagar'));
    await tester.pumpAndSettle();

    expect(c.read(saldoTotalProvider), 100000 - 3334);
    expect(c.read(resumosCartaoProvider).single.usado, 10000 - 3334);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(amb.fechar);
  });
}
