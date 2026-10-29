import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/derivados.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/data/servicos/servico_compromisso.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/importacao/importacao_controller.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer c;
  late Cartao cartao;
  final hoje = DateTime.now();
  final dia = DateTime(hoje.year, hoje.month, hoje.day);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    c = ProviderContainer(overrides: [bancoProvider.overrideWithValue(db)]);
    await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta',
      tipo: TipoConta.corrente,
      dataSaldoInicial: DateTime(2020),
      saldoInicial: const Value(100000),
    ));
    final id = await db.cartoesDao.inserir(CartoesCompanion.insert(
      nome: 'Cartão', diaFechamento: 10, diaVencimento: 17,
    ));
    cartao = (await db.cartoesDao.obter(id))!;
    await ServicoCompromisso(db).criarCompromisso(
      descricao: 'Streaming',
      valor: 4000,
      tipo: TipoCompromisso.recorrente,
      dataInicio: dia,
      forma: FormaPagamento.credito,
      cartaoId: cartao.id,
    );
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<void> carregar() async {
    for (final p in [
      contasProvider, cartoesProvider, faturasProvider, lancamentosProvider,
      compromissosProvider, ocorrenciasProvider, receitasProvider,
      categoriasProvider, orcamentosProvider, investimentosProvider,
      movimentosInvestimentoProvider, metasProvider,
    ]) {
      c.listen(p, (_, _) {});
      await c.read((p as dynamic).future);
    }
    c.listen(ajustesProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 40));
  }

  test('a cobrança entra na fatura e pesa no crédito seguro (fatura do mês)', () async {
    await carregar();
    final r = c.read(creditoSeguroProvider);
    expect(r.comprometidoCartao, 4000); // a cobrança de hoje, na fatura atual
    expect(r.fixosDescontados, 0); // não é conta pendente para pagar
    expect(r.podeGastar, 96000);
    expect(r.comprometidoProximasFaturas, 4000); // a do mês que vem, só informação
  });

  test('não aparece como pendente, nem em alertas de conta, nem em Contas do mês',
      () async {
    await carregar();
    expect(c.read(ocorrenciasPendentesProvider), isEmpty);
    expect(c.read(vencimentosPendentesProvider).where((v) => !v.ehFatura), isEmpty);

    final linhas = c.read(contasDoMesProvider);
    expect(linhas.any((l) => l.descricao == 'Streaming'), isFalse);
    // mas a fatura do cartão (que contém a cobrança) está lá, com o total
    final faturas = linhas.where((l) => l.ehFatura).toList();
    expect(faturas.fold<int>(0, (s, l) => s + l.valor), greaterThanOrEqualTo(0));
  });

  test('é gasto fixo nos relatórios (paga um compromisso)', () async {
    await carregar();
    final rel = c.read(lancamentosRelatorioProvider);
    expect(rel.where((l) => l.fixo && l.valor == 4000), isNotEmpty);
  });

  group('importar a fatura do cartão', () {
    Uint8List csv(String linhas) =>
        Uint8List.fromList(utf8.encode('Data;Descrição;Valor\n$linhas\n'));

    String dataBr(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    test('a assinatura já lançada vem desmarcada, o resto normal', () async {
      await carregar();
      final ctl = c.read(importacaoProvider.notifier);
      ctl.definirDestino(TipoDestino.cartao, cartao.id);
      final formato = await ctl.carregar(ArquivoEscolhido(
        'fatura.csv',
        csv('${dataBr(dia)};NETFLIX.COM;40,00\n${dataBr(dia)};MERCADO CENTRAL;120,00'),
      ));
      expect(formato, FormatoArquivo.csv);
      await ctl.aplicarMapeamento();

      final linhas = c.read(importacaoProvider).linhas;
      expect(linhas.length, 2);
      final netflix = linhas.firstWhere((l) => l.transacao.descricao.contains('NETFLIX'));
      final mercado = linhas.firstWhere((l) => l.transacao.descricao.contains('MERCADO'));
      expect(netflix.porGastoFixo, isTrue);
      expect(netflix.duplicada, isTrue);
      expect(netflix.selecionada, isFalse);
      expect(mercado.porGastoFixo, isFalse);
      expect(mercado.selecionada, isTrue);
    });

    test('valor diferente ou data longe não é confundido com a assinatura', () async {
      await carregar();
      final ctl = c.read(importacaoProvider.notifier);
      ctl.definirDestino(TipoDestino.cartao, cartao.id);
      await ctl.carregar(ArquivoEscolhido(
        'fatura.csv',
        csv('${dataBr(dia)};OUTRA COISA;41,00\n${dataBr(dia.subtract(const Duration(days: 20)))};NETFLIX;40,00'),
      ));
      await ctl.aplicarMapeamento();
      expect(c.read(importacaoProvider).linhas.any((l) => l.porGastoFixo), isFalse);
    });
  });
}
