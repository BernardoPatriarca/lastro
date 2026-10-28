import 'package:flutter/material.dart';

import '../../core/theme/cores_lastro.dart';
import '../../domain/orcamento.dart';

/// Cor da faixa do orçamento: verde, amarelo ou vermelho.
Color corDoNivel(BuildContext context, NivelOrcamento nivel) {
  final cores = context.coresLastro;
  return switch (nivel) {
    NivelOrcamento.verde => cores.positivo,
    NivelOrcamento.amarelo => cores.alerta,
    NivelOrcamento.vermelho => cores.negativo,
  };
}

/// Barra de progresso do orçamento, animada e colorida pela faixa.
class BarraOrcamento extends StatelessWidget {
  const BarraOrcamento({super.key, required this.gasto, required this.limite, this.altura = 8});
  final int gasto;
  final int limite;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final cor = corDoNivel(context, nivelOrcamento(gasto, limite));
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percentualUsado(gasto, limite).clamp(0, 1).toDouble()),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: altura,
          color: cor,
          backgroundColor: cor.withValues(alpha: 0.16),
        ),
      ),
    );
  }
}
