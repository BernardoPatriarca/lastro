import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/core/router/app_router.dart';
import 'package:lastro/data/dados_ficticios.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

/// Percorre todas as telas com dados fictícios em tela pequena (320 dp) e com
/// fonte ampliada (1,3x): qualquer overflow de layout vira falha do teste.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('nenhuma tela estoura o layout em 320 dp com fonte 1,3x', (tester) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearAllTestValues();
    });

    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      await popularDadosFicticios(amb.db);
    });
    await tester.pumpWidget(ProviderScope(overrides: amb.overrides, child: const LastroApp()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);

    // Captura os erros com detalhes (qual widget estourou e onde) e só falha
    // no final, com o relatório completo.
    final relatorio = <String>[];
    final original = FlutterError.onError;
    var atual = '';
    final vistos = <String>{};
    FlutterError.onError = (d) {
      final t = d.toString();
      final px = RegExp(r'overflowed by (\d+)').firstMatch(t)?.group(1);
      final onde = RegExp(r'lib/([\w/]+\.dart:\d+)').firstMatch(t)?.group(1);
      final resumo = px != null
          ? '[$atual] overflow de ${px}px em $onde'
          : '[$atual] ${t.length > 500 ? t.substring(0, 500) : t}';
      if (vistos.add(resumo)) relatorio.add(resumo);
    };
    addTearDown(() => FlutterError.onError = original);
    void conferir(String onde) => atual = onde;

    final rotas = <String>[
      Rotas.inicio,
      Rotas.lancamentos,
      Rotas.cartoes,
      Rotas.cartao(1),
      Rotas.investimentos,
      Rotas.investimento(1),
      Rotas.mais,
      Rotas.contas,
      Rotas.compromissos,
      Rotas.orcamento,
      Rotas.relatorios,
      Rotas.categorias,
      Rotas.regras,
      Rotas.importar,
      Rotas.configuracoes,
    ];
    for (final rota in rotas) {
      conferir(rota);
      router.go(rota);
      await tester.pumpAndSettle();
      // rola a página até o fim para construir tudo
      final rolaveis = find.byType(Scrollable);
      if (rolaveis.evaluate().isNotEmpty) {
        for (var i = 0; i < 6; i++) {
          await tester.drag(rolaveis.first, const Offset(0, -700));
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();
      }
    }

    // formulários em tela cheia
    for (final rota in [
      Rotas.novoLancamento,
      Rotas.editarLancamento(1),
      Rotas.novaConta,
      Rotas.novoCartao,
      Rotas.novoCompromisso,
      Rotas.novaReceita,
      Rotas.novoInvestimento,
      Rotas.novaMeta,
      Rotas.novaCategoria,
    ]) {
      router.go(Rotas.inicio);
      await tester.pumpAndSettle();
      conferir(rota);
      router.push(rota);
      await tester.pumpAndSettle();
    }

    FlutterError.onError = original;
    expect(relatorio, isEmpty, reason: '\n${relatorio.join('\n')}');

    router.go(Rotas.inicio);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.runAsync(amb.fechar);
  });
}
