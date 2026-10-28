import 'package:drift/drift.dart';

import '../domain/competencia.dart';
import '../domain/datas.dart';
import '../domain/enums.dart';
import 'banco.dart';
import 'servicos/servico_cartao.dart';
import 'servicos/servico_compromisso.dart';
import 'servicos/servico_lancamentos.dart';

/// Dados **fictícios** para testar o app visualmente (só acionável em debug).
/// Nada aqui vem de extratos reais. Use num app vazio e apague depois com
/// [apagarTodosOsDados].
Future<void> popularDadosFicticios(AppDatabase db, {DateTime? hoje}) async {
  final agora = soData(hoje ?? DateTime.now());
  final inicio = Competencia.deData(agora).somarMeses(-3);
  final lanc = ServicoLancamentos(db);
  final cartaoServ = ServicoCartao(db);
  final compServ = ServicoCompromisso(db);

  final categorias = {for (final c in await db.categoriasDao.todas()) c.nome: c.id};
  int? cat(String nome) => categorias[nome];

  final corrente = await db.contasDao.inserir(ContasCompanion.insert(
    nome: 'Conta Corrente (demo)',
    tipo: TipoConta.corrente,
    dataSaldoInicial: inicio.primeiroDia,
    saldoInicial: const Value(200000),
  ));
  final poupanca = await db.contasDao.inserir(ContasCompanion.insert(
    nome: 'Poupança (demo)',
    tipo: TipoConta.poupanca,
    dataSaldoInicial: inicio.primeiroDia,
    saldoInicial: const Value(800000),
    considerarNoCreditoSeguro: const Value(false),
  ));

  final cartaoId = await db.cartoesDao.inserir(CartoesCompanion.insert(
    nome: 'Cartão Demo',
    diaFechamento: 10,
    diaVencimento: 17,
    limite: const Value(600000),
    contaPagamentoId: Value(corrente),
    cor: const Value(0xFF6366F1),
  ));
  final cartao = (await db.cartoesDao.obter(cartaoId))!;

  Future<void> gasto(
    int mesesAtras,
    int dia,
    int valor,
    String categoria,
    String descricao, {
    FormaPagamento forma = FormaPagamento.pix,
  }) async {
    final data = DateTime(
      Competencia.deData(agora).somarMeses(-mesesAtras).ano,
      Competencia.deData(agora).somarMeses(-mesesAtras).mes,
      dia,
    );
    if (data.isAfter(agora)) return;
    await lanc.registrar(
      tipo: TipoLancamento.gasto,
      valor: valor,
      data: data,
      descricao: descricao,
      categoriaId: cat(categoria),
      forma: forma,
      contaId: corrente,
    );
  }

  for (var m = 3; m >= 0; m--) {
    final base = Competencia.deData(agora).somarMeses(-m);
    DateTime dia(int d) => DateTime(base.ano, base.mes, d);

    if (!dia(5).isAfter(agora)) {
      await lanc.registrar(
        tipo: TipoLancamento.ganho,
        valor: 450000,
        data: dia(5),
        descricao: 'Salário',
        categoriaId: cat('Salário'),
        contaId: corrente,
      );
    }
    if (m == 2 && !dia(18).isAfter(agora)) {
      await lanc.registrar(
        tipo: TipoLancamento.ganho,
        valor: 80000,
        data: dia(18),
        descricao: 'Trabalho extra',
        categoriaId: cat('Extra'),
        contaId: corrente,
      );
    }
    await gasto(m, 3, 38990, 'Mercado', 'Mercado do mês');
    await gasto(m, 9, 12480, 'Mercado', 'Feira');
    await gasto(m, 12, 21050, 'Combustível', 'Posto');
    await gasto(m, 14, 7890, 'Restaurante', 'Almoço de domingo');
    await gasto(m, 20, 5490, 'Delivery', 'Pizza');
    await gasto(m, 22, 35000, 'Saúde', 'Consulta', forma: FormaPagamento.debito);
    await gasto(m, 25, 9990, 'Assinaturas', 'Streaming', forma: FormaPagamento.debito);
    if (!dia(8).isAfter(agora)) {
      await lanc.registrar(
        tipo: TipoLancamento.aporte,
        valor: 50000,
        data: dia(8),
        descricao: 'Aporte mensal',
        contaId: corrente,
      );
    }
  }

  // Uma transferência para a poupança no mês passado.
  final mesPassado = Competencia.deData(agora).somarMeses(-1);
  await lanc.registrar(
    tipo: TipoLancamento.transferencia,
    valor: 100000,
    data: DateTime(mesPassado.ano, mesPassado.mes, 7),
    descricao: 'Reserva do mês',
    contaId: corrente,
    contaDestinoId: poupanca,
  );

  // Compras no crédito (algumas parceladas) para gerar faturas e comprometido.
  Future<void> credito(int mesesAtras, int dia, int valor, int parcelas, String descricao,
      String categoria) async {
    final c = Competencia.deData(agora).somarMeses(-mesesAtras);
    final data = DateTime(c.ano, c.mes, dia);
    if (data.isAfter(agora)) return;
    await cartaoServ.registrarCompra(
      cartao: cartao,
      valorTotal: valor,
      parcelas: parcelas,
      data: data,
      descricao: descricao,
      categoriaId: cat(categoria),
    );
  }

  await credito(3, 6, 18990, 1, 'Roupas', 'Compras');
  await credito(2, 15, 240000, 6, 'Notebook', 'Compras');
  await credito(1, 4, 9500, 1, 'Livros', 'Educação');
  await credito(1, 19, 36000, 3, 'Tênis', 'Compras');
  await credito(0, 2, 15990, 1, 'Material de escritório', 'Compras');

  // Faturas já vencidas ficam pagas; a atual e as futuras seguem abertas.
  for (final f in await db.cartoesDao.todasFaturas()) {
    if (f.dataVencimento.isBefore(agora.subtract(const Duration(days: 1)))) {
      final total = await cartaoServ.totalDaFatura(f.id);
      if (total > 0) {
        await cartaoServ.pagarFatura(fatura: f, contaId: corrente, data: f.dataVencimento);
      }
    }
  }

  // Contas fixas e receita recorrente.
  await compServ.criarCompromisso(
    descricao: 'Aluguel',
    valor: 120000,
    tipo: TipoCompromisso.recorrente,
    dataInicio: DateTime(inicio.ano, inicio.mes, 5),
    forma: FormaPagamento.boleto,
    categoriaId: cat('Moradia'),
    contaId: corrente,
  );
  await compServ.criarCompromisso(
    descricao: 'Internet',
    valor: 9990,
    tipo: TipoCompromisso.recorrente,
    dataInicio: DateTime(inicio.ano, inicio.mes, 10),
    forma: FormaPagamento.boleto,
    categoriaId: cat('Internet'),
    contaId: corrente,
  );
  await compServ.criarCompromisso(
    descricao: 'Financiamento do carro',
    valor: 62000,
    tipo: TipoCompromisso.parcelado,
    numeroParcelas: 12,
    dataInicio: DateTime(Competencia.deData(agora).somarMeses(-1).ano,
        Competencia.deData(agora).somarMeses(-1).mes, 20),
    forma: FormaPagamento.boleto,
    categoriaId: cat('Transporte/Carro'),
    contaId: corrente,
  );
  // Contas de meses anteriores ao atual já foram pagas (só o mês atual fica
  // pendente), como numa vida financeira em dia.
  final inicioDoMes = Competencia.deData(agora).primeiroDia;
  for (final o in await db.compromissosDao.todasOcorrencias()) {
    if (o.dataVencimento.isBefore(inicioDoMes)) {
      await compServ.pagarOcorrencia(o, data: o.dataVencimento);
    }
  }

  await compServ.criarReceita(
    descricao: 'Salário',
    valorPrevisto: 450000,
    contaId: corrente,
    dataInicio: Competencia.deData(agora).somarMeses(1).primeiroDia,
    diaPrevisto: 5,
    categoriaId: cat('Salário'),
  );

}
