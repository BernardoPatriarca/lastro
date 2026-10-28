import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/seletor_mes.dart';
import '../domain/competencia.dart';
import '../domain/enums.dart';
import '../domain/fatura.dart';
import '../domain/saldo.dart';
import 'banco.dart';
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
