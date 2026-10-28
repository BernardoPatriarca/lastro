import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/servicos/servico_compromisso.dart';
import 'package:lastro/data/servicos/servico_importacao.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/importacao/ofx.dart';
import 'package:lastro/domain/importacao/transacao_importada.dart';

void main() {
  late AppDatabase db;
  late ServicoImportacao s;
  late int contaId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    s = ServicoImportacao(db);
    contaId = await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta',
      tipo: TipoConta.corrente,
      dataSaldoInicial: DateTime(2026, 1, 1),
      saldoInicial: const Value(100000),
    ));
  });
  tearDown(() => db.close());

  List<LinhaParaImportar> linhasDoOfx() {
    final ofx = lerOfx(File('test/fixtures/extrato_conta_sgml.ofx').readAsStringSync());
    return [
      for (final t in atribuirChaves(ofx.transacoes, prefixo: 'c$contaId'))
        LinhaParaImportar(transacao: t),
    ];
  }

  test('importar para conta: saídas viram gasto, entradas ganho, com chave', () async {
    final r = await s.importarParaConta(contaId, linhasDoOfx());
    expect(r.importadas, 5);

    final lancs = await db.lancamentosDao.todos();
    expect(lancs.length, 5);
    expect(lancs.every((l) => l.origem == OrigemLancamento.importado), isTrue);
    expect(lancs.every((l) => (l.chaveImportacao ?? '').isNotEmpty), isTrue);

    final salario = lancs.firstWhere((l) => l.descricao.contains('SALARIO'));
    expect(salario.tipo, TipoLancamento.ganho);
    expect(salario.valor, 450000);
    expect(salario.contaId, contaId);

    final boleto = lancs.firstWhere((l) => l.descricao.contains('ALUGUEL'));
    expect(boleto.tipo, TipoLancamento.gasto);
    expect(boleto.valor, 120000);
    expect(boleto.formaPagamento, FormaPagamento.boleto);

    final pix = lancs.firstWhere((l) => l.descricao.contains('PADARIA'));
    expect(pix.formaPagamento, FormaPagamento.pix);
  });

  test('reimportar: as chaves existentes marcam tudo como duplicada', () async {
    await s.importarParaConta(contaId, linhasDoOfx());
    final existentes = await s.chavesExistentes();
    expect(existentes.length, 5);
    final dup = linhasDoOfx().where((l) => existentes.contains(l.transacao.chave));
    expect(dup.length, 5);
  });

  test('primeira importação e saldo atual da conta', () async {
    expect(await s.importadosDaConta(contaId), 0);
    await s.importarParaConta(contaId, linhasDoOfx());
    expect(await s.importadosDaConta(contaId), 5);

    // 1.000,00 + 4.500,00 - 389,90 - 1.200,00 - 28,50 + 150,00 = 4.031,60
    final conta = (await db.contasDao.obter(contaId))!;
    expect(await s.saldoAtual(conta), 403160);
    // o OFX diz que o saldo real é 3.731,60: ajusta o saldo inicial para bater
    await ServicoImportacaoAjuste.ajustar(db, conta, 373160, 403160);
    final nova = (await db.contasDao.obter(contaId))!;
    expect(await s.saldoAtual(nova), 373160);
  });

  test('linha casada com conta fixa pendente marca a parcela como paga', () async {
    final compId = await ServicoCompromisso(db).criarCompromisso(
      descricao: 'Aluguel',
      valor: 120000,
      tipo: TipoCompromisso.recorrente,
      dataInicio: DateTime(2026, 3, 5),
      forma: FormaPagamento.boleto,
      contaId: contaId,
      hoje: DateTime(2026, 3, 5),
    );
    final oc = (await db.compromissosDao.todasOcorrencias())
        .firstWhere((o) => o.competencia == '2026-03');
    final linhas = [
      for (final l in linhasDoOfx())
        LinhaParaImportar(
          transacao: l.transacao,
          ocorrenciaId: l.transacao.descricao.contains('ALUGUEL') ? oc.id : null,
        ),
    ];
    final r = await s.importarParaConta(contaId, linhas);
    expect(r.vinculadas, 1);
    final paga = (await db.compromissosDao.ocorrencia(oc.id))!;
    expect(paga.status, StatusOcorrencia.paga);
    expect(paga.lancamentoId, isNotNull);
    final l = (await db.lancamentosDao.obter(paga.lancamentoId!))!;
    expect(l.ocorrenciaCompromissoId, oc.id);
    expect(l.origem, OrigemLancamento.importado);
    expect(compId, isPositive);
    // sem lançamento duplicado: um gasto de aluguel só
    final alugueis = (await db.lancamentosDao.todos()).where((x) => x.descricao.contains('ALUGUEL'));
    expect(alugueis.length, 1);
  });

  test('importar fatura de cartão: compras à vista na fatura certa; entradas ignoradas',
      () async {
    final cartaoId = await db.cartoesDao.inserir(CartoesCompanion.insert(
      nome: 'Cartão', diaFechamento: 20, diaVencimento: 27,
    ));
    final cartao = (await db.cartoesDao.obter(cartaoId))!;
    final ofx = lerOfx(File('test/fixtures/fatura_cartao_xml.ofx').readAsStringSync());
    final linhas = [
      for (final t in atribuirChaves(ofx.transacoes, prefixo: 'k$cartaoId'))
        LinhaParaImportar(transacao: t),
    ];
    final r = await s.importarParaCartao(cartao, linhas);
    expect(r.importadas, 2);
    expect(r.ignoradas, 1); // "pagamento recebido"

    final lancs = await db.lancamentosDao.todos();
    expect(lancs.length, 2);
    expect(lancs.every((l) => l.formaPagamento == FormaPagamento.credito), isTrue);
    expect(lancs.every((l) => l.contaId == null && l.cartaoId == cartaoId), isTrue);
    // 12/03 e 18/03 (antes do fechamento no dia 20) → mesma fatura de março
    final faturas = await db.cartoesDao.todasFaturas();
    expect(faturas.length, 1);
    expect(faturas.single.competencia, '2026-03');
    expect(lancs.fold<int>(0, (a, l) => a + l.valor), 13490);
  });

  test('mapeamento de CSV é salvo e atualizado pelo nome do banco', () async {
    await s.salvarMapeamento(
      nome: 'Banco X', separador: ';', temCabecalho: true, colunaData: 0,
      colunaDescricao: 1, colunaValor: 2, formatoData: 'dd/MM/yyyy', positivoEhGasto: false,
    );
    await s.salvarMapeamento(
      nome: 'Banco X', separador: ',', temCabecalho: false, colunaData: 3,
      colunaDescricao: 4, colunaValor: 5, colunaTipo: 6, formatoData: 'yyyy-MM-dd',
      positivoEhGasto: true,
    );
    final todos = await db.select(db.mapeamentosCsv).get();
    expect(todos.length, 1);
    expect(todos.single.colunaData, 3);
    expect(todos.single.colunaTipo, 6);
    expect(todos.single.positivoEhGasto, isTrue);
  });
}

/// Mesma conta de [ServicoImportacao.saldoAtual], usada pela tela de revisão.
abstract final class ServicoImportacaoAjuste {
  static Future<void> ajustar(AppDatabase db, Conta conta, int real, int atual) async {
    await db.contasDao.atualizar(
      conta.copyWith(saldoInicial: conta.saldoInicial + (real - atual)),
    );
  }
}
