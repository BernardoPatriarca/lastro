import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lastro/app.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/dados_ficticios.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/configuracoes/backup_secao.dart';
import 'package:lastro/features/importacao/importacao_controller.dart';
import 'package:lastro/features/login/auth_controller.dart';

import '../helpers/ambiente.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('lembrete: atrasado quando nunca fez ou passou de 30 dias', () {
    final agora = DateTime(2026, 6, 30);
    expect(backupAtrasado(null, agora), isTrue);
    expect(backupAtrasado(DateTime(2026, 6, 20), agora), isFalse);
    expect(backupAtrasado(DateTime(2026, 5, 20), agora), isTrue);
    expect(diasDesdeUltimoBackup(DateTime(2026, 6, 20), agora), 10);
    expect(diasDesdeUltimoBackup(null, agora), isNull);
  });

  testWidgets('exportar gera o arquivo, registra a data e some o lembrete; '
      'restaurar volta ao estado do backup', (tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final amb = Ambiente(comSenha: true);
    await tester.runAsync(() async {
      await amb.preparar();
      await popularDadosFicticios(amb.db);
    });

    String? nomeGerado;
    String? conteudoGerado;
    Uint8List? arquivoParaRestaurar;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        ...amb.overrides,
        salvarECompartilharProvider.overrideWithValue((nome, conteudo) async {
          nomeGerado = nome;
          conteudoGerado = conteudo;
        }),
        seletorDeArquivoProvider.overrideWithValue(
          () async => arquivoParaRestaurar == null
              ? null
              : ArquivoEscolhido('backup.json', arquivoParaRestaurar),
        ),
      ],
      child: const LastroApp(),
    ));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(LastroApp)));
    await c.read(authProvider.notifier).entrarComSenha('segredo123');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();

    // nunca fez backup: lembrete visível
    expect(find.textContaining('Você ainda não fez backup'), findsOneWidget);
    expect(find.text('Nenhum backup feito ainda'), findsOneWidget);

    await tester.tap(find.text('Exportar backup'));
    await tester.pumpAndSettle();
    expect(nomeGerado, startsWith('lastro-backup-'));
    expect(nomeGerado, endsWith('.json'));
    final json = jsonDecode(conteudoGerado!) as Map<String, dynamic>;
    expect(json['formato'], 'lastro-backup');
    expect(json['versaoSchema'], AppDatabase.versaoSchema);
    expect((json['tabelas'] as Map)['lancamentos'], isNotEmpty);
    // a senha nunca vai no backup
    expect(conteudoGerado, isNot(contains('senha')));

    expect(c.read(ajustesProvider).ultimoBackup, isNotNull);
    expect(find.textContaining('Você ainda não fez backup'), findsNothing);
    expect(find.textContaining('Último backup:'), findsOneWidget);

    // altera os dados depois do backup...
    final antes = (await tester.runAsync(() => amb.db.lancamentosDao.todos()))!.length;
    await tester.runAsync(() => amb.db.contasDao.inserir(ContasCompanion.insert(
          nome: 'Conta extra',
          tipo: TipoConta.carteira,
          dataSaldoInicial: DateTime(2026, 1, 1),
        )));

    // ...e restaura: mostra resumo, pede confirmação e volta ao estado do backup
    arquivoParaRestaurar = Uint8List.fromList(utf8.encode(conteudoGerado!));
    await tester.tap(find.text('Restaurar backup'));
    await tester.pumpAndSettle();
    expect(find.text('Restaurar este backup?'), findsOneWidget);
    expect(find.textContaining('$antes lançamentos'), findsOneWidget);
    expect(find.textContaining('SUBSTITUÍDO'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Restaurar'));
    await tester.pumpAndSettle();

    final contas = (await tester.runAsync(() => amb.db.select(amb.db.contas).get()))!;
    expect(contas.length, 2); // sem a "Conta extra"
    final depois = (await tester.runAsync(() => amb.db.lancamentosDao.todos()))!.length;
    expect(depois, antes);

    // arquivo que não é backup: recusado sem mexer em nada
    arquivoParaRestaurar = Uint8List.fromList(utf8.encode('isto não é um backup'));
    await tester.tap(find.text('Restaurar backup'));
    await tester.pumpAndSettle();
    expect(find.textContaining('não é um backup'), findsOneWidget);
    expect(find.text('Restaurar este backup?'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(amb.fechar);
  });
}
