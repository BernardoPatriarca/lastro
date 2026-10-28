import 'package:flutter/material.dart';

import '../../data/banco.dart';
import '../../domain/enums.dart';

/// Quanto o lançamento "pesa" para o dono, com sinal, para exibição:
/// ganhos/resgates positivos; gastos/aportes/pagamentos negativos.
/// Transferências são neutras (0 na cor, valor cheio no texto).
int valorExibido(Lancamento l) => switch (l.tipo) {
      TipoLancamento.ganho || TipoLancamento.resgate => l.valor,
      TipoLancamento.gasto ||
      TipoLancamento.aporte ||
      TipoLancamento.pagamentoFatura =>
        -l.valor,
      TipoLancamento.ajusteSaldo => l.valor,
      TipoLancamento.transferencia => l.valor,
    };

bool ehNeutro(Lancamento l) => l.tipo == TipoLancamento.transferencia;

IconData iconeDoTipo(TipoLancamento t) => switch (t) {
      TipoLancamento.gasto => Icons.arrow_downward_rounded,
      TipoLancamento.ganho => Icons.arrow_upward_rounded,
      TipoLancamento.transferencia => Icons.swap_horiz_rounded,
      TipoLancamento.aporte => Icons.savings_rounded,
      TipoLancamento.resgate => Icons.account_balance_wallet_rounded,
      TipoLancamento.pagamentoFatura => Icons.credit_score_rounded,
      TipoLancamento.ajusteSaldo => Icons.tune_rounded,
    };

/// Contribuição do lançamento ao "total do dia" (ganhos − gastos).
int contribuicaoDoDia(Lancamento l) => switch (l.tipo) {
      TipoLancamento.ganho => l.valor,
      TipoLancamento.gasto => -l.valor,
      _ => 0,
    };
