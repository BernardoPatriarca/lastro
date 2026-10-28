import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatadores/moeda.dart';
import '../core/widgets/seletor_mes.dart';
import '../domain/alertas.dart';
import '../domain/competencia.dart';
import '../domain/compromissos.dart';
import '../domain/credito_seguro.dart';
import '../domain/enums.dart';
import '../domain/fatura.dart';
import '../domain/investimentos.dart';
import '../domain/notificacoes.dart';
import '../domain/orcamento.dart';
import '../domain/relatorios.dart';
import '../domain/resumo_mes.dart';
import '../domain/saldo.dart';
import 'banco.dart';
import 'compromisso_calculo.dart';
import 'providers.dart';

/// Converte um [Lancamento] na visão usada pelo cálculo de saldo.
MovimentoSaldo paraMovimento(Lancamento l) => MovimentoSaldo(
      tipo: l.tipo,
      valor: l.valor,
      data: l.data,
      forma: l.formaPagamento,
      contaId: l.contaId,
      contaDestinoId: l.contaDestinoId,
    );

/// Saldo atual de cada conta (id → centavos). Recalculado quando contas ou
/// lançamentos mudam; lançamentos futuros não entram no saldo "de hoje".
final saldosPorContaProvider = Provider<Map<int, int>>((ref) {
  final contas = ref.watch(contasProvider).ou;
  final lancs = ref.watch(lancamentosProvider).ou;
  final hoje = DateTime.now();
  final fim = DateTime(hoje.year, hoje.month, hoje.day);

  final movimentos = [
    for (final l in lancs)
      if (!l.data.isAfter(fim)) paraMovimento(l),
  ];
  return {
    for (final c in contas)
      c.id: calcularSaldoConta(
        contaId: c.id,
        saldoInicial: c.saldoInicial,
        dataSaldoInicial: c.dataSaldoInicial,
        movimentos: movimentos,
      ),
  };
});

/// Soma dos saldos das contas ativas.
final saldoTotalProvider = Provider<int>((ref) {
  final contas = ref.watch(contasProvider).ou;
  final saldos = ref.watch(saldosPorContaProvider);
  var total = 0;
  for (final c in contas) {
    if (c.ativa) total += saldos[c.id] ?? 0;
  }
  return total;
});

final contasAtivasProvider = Provider<List<Conta>>(
  (ref) => [for (final c in ref.watch(contasProvider).ou) if (c.ativa) c],
);

final categoriasPorIdProvider = Provider<Map<int, Categoria>>(
  (ref) => {for (final c in ref.watch(categoriasProvider).ou) c.id: c},
);

final contasPorIdProvider = Provider<Map<int, Conta>>(
  (ref) => {for (final c in ref.watch(contasProvider).ou) c.id: c},
);

final cartoesPorIdProvider = Provider<Map<int, Cartao>>(
  (ref) => {for (final c in ref.watch(cartoesProvider).ou) c.id: c},
);

/// Lançamentos do mês selecionado.
final lancamentosDoMesProvider = Provider<List<Lancamento>>((ref) {
  final mes = ref.watch(mesSelecionadoProvider);
  return [
    for (final l in ref.watch(lancamentosProvider).ou)
      if (mes.contem(l.data)) l,
  ];
});

/// Quantas vezes cada categoria foi usada (para listar as mais usadas primeiro).
final usoCategoriasProvider = Provider<Map<int, int>>((ref) {
  final uso = <int, int>{};
  for (final l in ref.watch(lancamentosProvider).ou) {
    final c = l.categoriaId;
    if (c != null) uso[c] = (uso[c] ?? 0) + 1;
  }
  return uso;
});

/// Totais de um mês (ganhos, gastos, investido).
class TotaisMes {
  const TotaisMes({this.ganhos = 0, this.gastos = 0, this.investido = 0});
  final int ganhos;
  final int gastos;
  final int investido;

  /// Sobra do mês antes de investir.
  int get saldo => ganhos - gastos;

  /// Investido ÷ ganhos (0 quando não há ganhos).
  double get taxaPoupanca => ganhos <= 0 ? 0 : investido / ganhos;
}

/// Soma os lançamentos de [mes]. Transferências, ajustes e pagamentos de
/// fatura não são ganho nem gasto (a compra já foi contada no crédito).
TotaisMes calcularTotaisMes(Iterable<Lancamento> lancs, Competencia mes) {
  var ganhos = 0, gastos = 0, investido = 0;
  for (final l in lancs) {
    if (!mes.contem(l.data)) continue;
    switch (l.tipo) {
      case TipoLancamento.ganho:
        ganhos += l.valor;
      case TipoLancamento.gasto:
        gastos += l.valor;
      case TipoLancamento.aporte:
        investido += l.valor;
      default:
        break;
    }
  }
  return TotaisMes(ganhos: ganhos, gastos: gastos, investido: investido);
}

final totaisDoMesProvider = Provider<TotaisMes>((ref) {
  final mes = ref.watch(mesSelecionadoProvider);
  return calcularTotaisMes(ref.watch(lancamentosProvider).ou, mes);
});

// ---------------------------------------------------------------------------
// Cartões e faturas
// ---------------------------------------------------------------------------

/// Total de cada fatura (id → centavos), somando as compras no crédito.
final totaisFaturasProvider = Provider<Map<int, int>>((ref) {
  final totais = <int, int>{};
  for (final l in ref.watch(lancamentosProvider).ou) {
    final f = l.faturaId;
    if (f != null && l.tipo == TipoLancamento.gasto) {
      totais[f] = (totais[f] ?? 0) + l.valor;
    }
  }
  return totais;
});

/// Visão de um cartão: limite, usado, disponível e fatura corrente.
class ResumoCartao {
  const ResumoCartao({
    required this.cartao,
    required this.usado,
    required this.ciclo,
    required this.faturaAtual,
    required this.totalFaturaAtual,
  });

  final Cartao cartao;

  /// Tudo que ainda não foi pago (faturas abertas, fechadas e futuras).
  final int usado;
  final CicloFatura ciclo;

  /// Fatura do ciclo de hoje (nula se ainda não há compras nela).
  final Fatura? faturaAtual;
  final int totalFaturaAtual;

  int get disponivel => cartao.limite - usado;
  double get percentualUsado =>
      cartao.limite <= 0 ? 0 : (usado / cartao.limite).clamp(0, 1).toDouble();
}

final resumosCartaoProvider = Provider<List<ResumoCartao>>((ref) {
  final cartoes = ref.watch(cartoesProvider).ou;
  final faturas = ref.watch(faturasProvider).ou;
  final totais = ref.watch(totaisFaturasProvider);
  final hoje = DateTime.now();
  final dia = DateTime(hoje.year, hoje.month, hoje.day);

  final pagas = {
    for (final f in faturas) if (f.status == StatusFatura.paga) f.id,
  };
  final naoPagoPorCartao = <int, int>{};
  for (final f in faturas) {
    if (pagas.contains(f.id)) continue;
    naoPagoPorCartao[f.cartaoId] =
        (naoPagoPorCartao[f.cartaoId] ?? 0) + (totais[f.id] ?? 0);
  }

  return [
    for (final c in cartoes)
      () {
        final ciclo = cicloDaCompra(
          dia,
          diaFechamento: c.diaFechamento,
          diaVencimento: c.diaVencimento,
        );
        final atual = faturas
            .where((f) =>
                f.cartaoId == c.id && f.competencia == ciclo.competencia.chave)
            .firstOrNull;
        return ResumoCartao(
          cartao: c,
          usado: naoPagoPorCartao[c.id] ?? 0,
          ciclo: ciclo,
          faturaAtual: atual,
          totalFaturaAtual: atual == null ? 0 : (totais[atual.id] ?? 0),
        );
      }(),
  ];
});

// ---------------------------------------------------------------------------
// Compromissos, receitas e pendentes
// ---------------------------------------------------------------------------

final compromissosPorIdProvider = Provider<Map<int, Compromisso>>(
  (ref) => {for (final c in ref.watch(compromissosProvider).ou) c.id: c},
);

/// Ocorrências de compromissos pendentes com vencimento até o fim do mês
/// atual (inclui as atrasadas), da mais antiga para a mais nova.
final ocorrenciasPendentesProvider = Provider<List<OcorrenciaCompromisso>>((ref) {
  final fim = Competencia.deData(DateTime.now()).ultimoDia;
  final lista = [
    for (final o in ref.watch(ocorrenciasProvider).ou)
      if (o.status == StatusOcorrencia.pendente && !o.dataVencimento.isAfter(fim)) o,
  ]..sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
  return lista;
});

/// Receitas recorrentes previstas e ainda não confirmadas no mês atual.
final receitasPendentesProvider = Provider<List<ReceitaRecorrente>>((ref) {
  final mes = Competencia.deData(DateTime.now());
  final receitas = ref.watch(receitasProvider).ou;
  final confirmadas = <int>{
    for (final l in ref.watch(lancamentosProvider).ou)
      if (l.receitaRecorrenteId != null && mes.contem(l.data)) l.receitaRecorrenteId!,
  };
  final pendentes = receitasPendentesDoMes(
    receitas: [
      for (final r in receitas)
        ReceitaBase(
          id: r.id,
          dataInicio: r.dataInicio,
          ativa: r.ativa,
          diaPrevisto: r.diaPrevisto,
        ),
    ],
    confirmadasNoMes: confirmadas,
    mes: mes,
  ).map((r) => r.id).toSet();
  return [for (final r in receitas) if (pendentes.contains(r.id)) r];
});

/// Total comprometido por mês nos próximos 12 meses: faturas de cartão ainda
/// não pagas (no mês do vencimento) + compromissos (pendentes já gravados e
/// ocorrências futuras apenas calculadas, sem gravar).
final projecaoComprometidoProvider = Provider<Map<Competencia, int>>((ref) {
  final inicio = Competencia.deData(DateTime.now());
  final fim = inicio.somarMeses(11);
  final itens = <ItemComprometido>[];

  final totais = ref.watch(totaisFaturasProvider);
  for (final f in ref.watch(faturasProvider).ou) {
    if (f.status == StatusFatura.paga) continue;
    final total = totais[f.id] ?? 0;
    if (total > 0) itens.add(ItemComprometido(f.dataVencimento, total, origem: 'cartao'));
  }

  final ocorrencias = ref.watch(ocorrenciasProvider).ou;
  for (final o in ocorrencias) {
    if (o.status == StatusOcorrencia.pendente) {
      itens.add(ItemComprometido(o.dataVencimento, o.valor, origem: 'compromisso'));
    }
  }
  for (final c in ref.watch(compromissosProvider).ou) {
    if (!c.ativo) continue;
    final gravadas = {
      for (final o in ocorrencias)
        if (o.compromissoId == c.id) Competencia.parse(o.competencia),
    };
    final previstas = ocorrenciasFaltantes(
      ocorrenciasDe(c, fim),
      gravadas,
    );
    for (final o in previstas) {
      // Antes do mês atual = já resolvido fora do app.
      if (o.competencia >= inicio) {
        itens.add(ItemComprometido(o.dataVencimento, o.valor, origem: 'compromisso'));
      }
    }
  }
  return projetarComprometido(itens, inicio: inicio);
});

// ---------------------------------------------------------------------------
// Crédito seguro (CLAUDE.md 5.1)
// ---------------------------------------------------------------------------

/// "Pode gastar no crédito", recalculado sempre que saldo, faturas,
/// compromissos ou configurações mudam.
final creditoSeguroProvider = Provider<ResultadoCreditoSeguro>((ref) {
  final ajustes = ref.watch(ajustesProvider);
  final contas = ref.watch(contasAtivasProvider);
  final saldos = ref.watch(saldosPorContaProvider);
  final cartoes = ref.watch(cartoesPorIdProvider);
  final faturas = ref.watch(faturasProvider).ou;
  final totais = ref.watch(totaisFaturasProvider);
  final hoje = DateTime.now();
  final dia = DateTime(hoje.year, hoje.month, hoje.day);

  var saldoContas = 0;
  for (final c in contas) {
    if (c.considerarNoCreditoSeguro) saldoContas += saldos[c.id] ?? 0;
  }

  CicloFatura cicloAtual(Cartao c) => cicloDaCompra(
        dia,
        diaFechamento: c.diaFechamento,
        diaVencimento: c.diaVencimento,
      );

  final naoPagas = <ComprometimentoFatura>[];
  for (final f in faturas) {
    if (f.status == StatusFatura.paga) continue;
    final total = totais[f.id] ?? 0;
    final cartao = cartoes[f.cartaoId];
    if (total <= 0 || cartao == null) continue;
    naoPagas.add(ComprometimentoFatura(
      total,
      futura: faturaEhFutura(Competencia.parse(f.competencia), cicloAtual(cartao)),
    ));
  }

  final horizonte = horizonteContasFixas(
    vencimentosFaturaAtual: [
      for (final c in cartoes.values)
        if (c.ativo) cicloAtual(c).dataVencimento,
    ],
    hoje: dia,
  );
  final compromissos = ref.watch(compromissosPorIdProvider);
  var fixos = 0;
  for (final o in ref.watch(ocorrenciasProvider).ou) {
    if (o.status != StatusOcorrencia.pendente) continue;
    if (compromissos[o.compromissoId]?.ativo != true) continue;
    if (!o.dataVencimento.isAfter(horizonte)) fixos += o.valor;
  }

  return calcularCreditoSeguro(
    saldoContas: saldoContas,
    faturasNaoPagas: naoPagas,
    fixosPendentes: fixos,
    modo: ajustes.modoParcelados,
    descontarFixos: ajustes.descontarFixos,
  );
});

// ---------------------------------------------------------------------------
// Início: gastos por categoria, maiores gastos e contas do mês
// ---------------------------------------------------------------------------

/// Gastos do mês por categoria (subcategorias somadas na categoria-pai).
final gastosPorCategoriaProvider = Provider<List<FatiaCategoria>>((ref) {
  final categorias = ref.watch(categoriasPorIdProvider);
  return gastosPorCategoria(
    [
      for (final l in ref.watch(lancamentosDoMesProvider))
        if (l.tipo == TipoLancamento.gasto) GastoSimples(l.categoriaId, l.valor),
    ],
    categoriaPai: {for (final c in categorias.values) c.id: c.categoriaPaiId},
  );
});

/// Os 5 maiores gastos do mês.
final maioresGastosProvider = Provider<List<Lancamento>>((ref) {
  final gastos = [
    for (final l in ref.watch(lancamentosDoMesProvider))
      if (l.tipo == TipoLancamento.gasto) l,
  ]..sort((a, b) => b.valor.compareTo(a.valor));
  return gastos.take(5).toList();
});

/// Compromissos e faturas que vencem no mês selecionado.
final contasDoMesProvider = Provider<List<ContaDoMes>>((ref) {
  final mes = ref.watch(mesSelecionadoProvider);
  final cartoes = ref.watch(cartoesPorIdProvider);
  final compromissos = ref.watch(compromissosPorIdProvider);
  final totais = ref.watch(totaisFaturasProvider);
  final ocorrencias = ref.watch(ocorrenciasProvider).ou;
  final itens = <ContaDoMes>[];

  for (final f in ref.watch(faturasProvider).ou) {
    if (!mes.contem(f.dataVencimento)) continue;
    final total = totais[f.id] ?? 0;
    if (total <= 0) continue;
    itens.add(ContaDoMes(
      descricao: 'Fatura ${cartoes[f.cartaoId]?.nome ?? 'cartão'}',
      valor: total,
      vencimento: f.dataVencimento,
      paga: f.status == StatusFatura.paga,
      ehFatura: true,
      referenciaId: f.id,
    ));
  }

  final geradas = <int, Set<Competencia>>{};
  for (final o in ocorrencias) {
    geradas
        .putIfAbsent(o.compromissoId, () => {})
        .add(Competencia.parse(o.competencia));
    if (!mes.contem(o.dataVencimento)) continue;
    final c = compromissos[o.compromissoId];
    if (c == null) continue;
    itens.add(ContaDoMes(
      descricao: o.numeroParcela == null
          ? c.descricao
          : '${c.descricao} (${o.numeroParcela}/${c.numeroParcelas})',
      valor: o.valor,
      vencimento: o.dataVencimento,
      paga: o.status == StatusOcorrencia.paga,
      ehFatura: false,
      referenciaId: o.id,
    ));
  }

  // Meses futuros: contas fixas ainda não geradas, só para enxergar o peso.
  for (final c in compromissos.values) {
    if (!c.ativo) continue;
    final ja = geradas[c.id] ?? const <Competencia>{};
    for (final o in ocorrenciasDe(c, mes)) {
      if (o.competencia != mes || ja.contains(o.competencia)) continue;
      itens.add(ContaDoMes(
        descricao: o.numeroParcela == null
            ? c.descricao
            : '${c.descricao} (${o.numeroParcela}/${c.numeroParcelas})',
        valor: o.valor,
        vencimento: o.dataVencimento,
        paga: false,
        ehFatura: false,
        podePagar: false,
      ));
    }
  }

  itens.sort((a, b) => a.vencimento.compareTo(b.vencimento));
  return itens;
});

// ---------------------------------------------------------------------------
// Investimentos e metas (V2)
// ---------------------------------------------------------------------------

final movimentosInvProvider = Provider<List<MovimentoInv>>((ref) => [
      for (final m in ref.watch(movimentosInvestimentoProvider).ou)
        MovimentoInv(
          id: m.id,
          investimentoId: m.investimentoId,
          tipo: m.tipo,
          valor: m.valor,
          data: m.data,
        ),
    ]);

/// Saldo atual de cada investimento (id → centavos).
final saldosInvestimentosProvider = Provider<Map<int, int>>(
  (ref) => saldosPorInvestimento(ref.watch(movimentosInvProvider)),
);

/// Patrimônio total em investimentos ativos.
final patrimonioProvider = Provider<int>((ref) {
  final saldos = ref.watch(saldosInvestimentosProvider);
  var total = 0;
  for (final i in ref.watch(investimentosProvider).ou) {
    if (i.ativo) total += saldos[i.id] ?? 0;
  }
  return total;
});

/// Evolução do patrimônio nos últimos 12 meses.
final patrimonioMensalProvider = Provider<Map<Competencia, int>>((ref) {
  final ativos = {
    for (final i in ref.watch(investimentosProvider).ou)
      if (i.ativo) i.id,
  };
  return patrimonioMensal(
    [for (final m in ref.watch(movimentosInvProvider)) if (ativos.contains(m.investimentoId)) m],
    fim: Competencia.deData(DateTime.now()),
  );
});

/// Andamento de cada meta ativa (id → progresso). Meta ligada a um
/// investimento usa o saldo dele; meta sem vínculo usa o patrimônio total.
final progressoMetasProvider = Provider<Map<int, ProgressoMeta>>((ref) {
  final saldos = ref.watch(saldosInvestimentosProvider);
  final patrimonio = ref.watch(patrimonioProvider);
  final movs = ref.watch(movimentosInvProvider);
  final hoje = DateTime.now();
  return {
    for (final m in ref.watch(metasProvider).ou)
      if (m.ativa)
        m.id: calcularProgressoMeta(
          atual: m.investimentoId == null ? patrimonio : (saldos[m.investimentoId] ?? 0),
          alvo: m.valorAlvo,
          prazo: m.prazo,
          hoje: hoje,
          ritmoMensalAtual: ritmoMensal(
            m.investimentoId == null
                ? movs
                : [for (final x in movs) if (x.investimentoId == m.investimentoId) x],
            hoje: hoje,
          ),
        ),
  };
});

// ---------------------------------------------------------------------------
// Orçamento por categoria (V2)
// ---------------------------------------------------------------------------

/// Limites do mês selecionado (categoria → centavos).
final limitesDoMesProvider = Provider<Map<int, int>>((ref) {
  final mes = ref.watch(mesSelecionadoProvider).chave;
  return {
    for (final o in ref.watch(orcamentosProvider).ou)
      if (o.competencia == mes) o.categoriaId: o.limite,
  };
});

/// Gasto do mês por categoria, contando as subcategorias também no pai.
final gastosAcumuladosDoMesProvider = Provider<Map<int, int>>((ref) {
  final categorias = ref.watch(categoriasPorIdProvider);
  return gastosAcumulados(
    [
      for (final l in ref.watch(lancamentosDoMesProvider))
        if (l.tipo == TipoLancamento.gasto) GastoSimples(l.categoriaId, l.valor),
    ],
    categoriaPai: {for (final c in categorias.values) c.id: c.categoriaPaiId},
  );
});

/// Linhas da tela de orçamento (categorias de gasto ativas).
final linhasOrcamentoProvider = Provider<List<LinhaOrcamento>>((ref) {
  final ativas = [
    for (final c in ref.watch(categoriasProvider).ou)
      if (c.ativa && c.tipo == TipoCategoria.gasto) c.id,
  ];
  return montarOrcamento(
    categorias: ativas,
    limites: ref.watch(limitesDoMesProvider),
    gastos: ref.watch(gastosAcumuladosDoMesProvider),
  );
});

// ---------------------------------------------------------------------------
// Dashboard V2: projeção, top categorias, metas e alertas
// ---------------------------------------------------------------------------

/// Projeção do gasto do mês no ritmo atual (só vale para o mês corrente).
class ProjecaoMes {
  const ProjecaoMes({required this.projetado, required this.gastoAteAgora, required this.ganhos});
  final int projetado;
  final int gastoAteAgora;
  final int ganhos;

  /// Projeção passa dos ganhos do mês.
  bool get passaDosGanhos => ganhos > 0 && projetado > ganhos;
}

final projecaoDoMesProvider = Provider<ProjecaoMes?>((ref) {
  final hoje = DateTime.now();
  final mes = ref.watch(mesSelecionadoProvider);
  if (mes != Competencia.deData(hoje)) return null;
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  var gasto = 0;
  for (final l in ref.watch(lancamentosDoMesProvider)) {
    if (l.tipo == TipoLancamento.gasto && !l.data.isAfter(dia)) gasto += l.valor;
  }
  return ProjecaoMes(
    projetado: projetarGastoDoMes(
      gastoAteAgora: gasto,
      diaAtual: hoje.day,
      diasNoMes: mes.ultimoDia.day,
    ),
    gastoAteAgora: gasto,
    ganhos: ref.watch(totaisDoMesProvider).ganhos,
  );
});

/// Categoria entre as que mais gastaram, com o limite (se houver).
class TopCategoria {
  const TopCategoria({required this.categoriaId, required this.gasto, this.limite});
  final int categoriaId;
  final int gasto;
  final int? limite;
}

/// As 5 categorias que mais gastaram no mês (subcategorias no pai), com a
/// barra de orçamento quando há limite.
final topCategoriasProvider = Provider<List<TopCategoria>>((ref) {
  final limites = ref.watch(limitesDoMesProvider);
  return [
    for (final f in ref.watch(gastosPorCategoriaProvider))
      if (f.categoriaId != null)
        TopCategoria(categoriaId: f.categoriaId!, gasto: f.valor, limite: limites[f.categoriaId]),
  ].take(5).toList();
});

/// Faturas não pagas e contas fixas pendentes, como vencimentos (base dos
/// alertas e das notificações).
final vencimentosPendentesProvider = Provider<List<VencimentoAlerta>>((ref) {
  final cartoes = ref.watch(cartoesPorIdProvider);
  final compromissos = ref.watch(compromissosPorIdProvider);
  final totais = ref.watch(totaisFaturasProvider);
  final vencimentos = <VencimentoAlerta>[];
  for (final f in ref.watch(faturasProvider).ou) {
    final total = totais[f.id] ?? 0;
    if (f.status == StatusFatura.paga || total <= 0) continue;
    vencimentos.add(VencimentoAlerta(
      descricao: 'Fatura ${cartoes[f.cartaoId]?.nome ?? 'do cartão'}',
      vencimento: f.dataVencimento,
      valor: total,
      ehFatura: true,
      chave: 'f${f.id}',
    ));
  }
  for (final o in ref.watch(ocorrenciasProvider).ou) {
    final c = compromissos[o.compromissoId];
    if (o.status != StatusOcorrencia.pendente || c == null || !c.ativo) continue;
    vencimentos.add(VencimentoAlerta(
      descricao: o.numeroParcela == null
          ? c.descricao
          : '${c.descricao} (${o.numeroParcela}/${c.numeroParcelas})',
      vencimento: o.dataVencimento,
      valor: o.valor,
      chave: 'o${o.id}',
    ));
  }
  return vencimentos;
});

/// Avisos de vencimento planejados (vazio com as notificações desligadas).
final notificacoesPlanejadasProvider = Provider<List<NotificacaoPlanejada>>((ref) {
  final ajustes = ref.watch(ajustesProvider);
  if (!ajustes.notificacoes) return const [];
  return planejarNotificacoes(
    agora: DateTime.now(),
    vencimentos: ref.watch(vencimentosPendentesProvider),
    diasAntes: ajustes.notificacoesDias,
    formatarValor: Moeda.formatar,
  );
});

/// Alertas do momento (crédito, vencimentos, orçamento do mês atual, metas
/// atrasadas e backup).
final alertasProvider = Provider<List<Alerta>>((ref) {
  final hoje = DateTime.now();
  final categorias = ref.watch(categoriasPorIdProvider);
  final ajustes = ref.watch(ajustesProvider);
  final vencimentos = ref.watch(vencimentosPendentesProvider);

  // Orçamento do mês ATUAL (independe do mês que está na tela).
  final mesAtual = Competencia.deData(hoje);
  final paiDe = {for (final c in categorias.values) c.id: c.categoriaPaiId};
  final gastos = gastosAcumulados(
    [
      for (final l in ref.watch(lancamentosProvider).ou)
        if (l.tipo == TipoLancamento.gasto && mesAtual.contem(l.data))
          GastoSimples(l.categoriaId, l.valor),
    ],
    categoriaPai: paiDe,
  );
  final emAlerta = <OrcamentoEmAlerta>[];
  for (final o in ref.watch(orcamentosProvider).ou) {
    if (o.competencia != mesAtual.chave) continue;
    final nivel = nivelOrcamento(gastos[o.categoriaId] ?? 0, o.limite);
    if (nivel == NivelOrcamento.verde) continue;
    emAlerta.add(OrcamentoEmAlerta(
      nome: categorias[o.categoriaId]?.nome ?? 'categoria',
      estourou: nivel == NivelOrcamento.vermelho,
    ));
  }

  final progresso = ref.watch(progressoMetasProvider);
  final metasAtrasadas = [
    for (final m in ref.watch(metasProvider).ou)
      if (m.ativa && progresso[m.id]?.situacao == SituacaoMeta.atrasada) m.nome,
  ];

  final ultimo = ajustes.ultimoBackup;
  final backupAtrasado = ultimo == null || hoje.difference(ultimo).inDays >= 30;

  return gerarAlertas(
    hoje: hoje,
    creditoPodeGastar: ref.watch(creditoSeguroProvider).podeGastar,
    vencimentos: vencimentos,
    orcamentos: emAlerta,
    metasAtrasadas: metasAtrasadas,
    backupAtrasado: backupAtrasado,
  );
});

// ---------------------------------------------------------------------------
// Relatórios (V3)
// ---------------------------------------------------------------------------

/// Lançamentos na forma que os relatórios usam. "Fixo" = paga um compromisso
/// ou é parcela de compra parcelada no cartão.
final lancamentosRelatorioProvider = Provider<List<LancRelatorio>>((ref) => [
      for (final l in ref.watch(lancamentosProvider).ou)
        LancRelatorio(
          data: l.data,
          tipo: l.tipo,
          valor: l.valor,
          categoriaId: l.categoriaId,
          fixo: l.ocorrenciaCompromissoId != null || l.compraParceladaId != null,
        ),
    ]);
