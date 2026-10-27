import 'package:flutter/material.dart';

import '../../core/formatadores/moeda.dart';
import '../../core/widgets/valor_monetario.dart';

/// Card de destaque "Pode gastar no crédito" (regra 5.1 do CLAUDE.md).
///
/// Placeholder visual: o cálculo real (função pura em `domain/`) entra na
/// Etapa 6. Fica sempre no topo do Início.
class CardCreditoSeguro extends StatelessWidget {
  const CardCreditoSeguro({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cores.primary, cores.primaryContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: cores.onPrimary),
              const SizedBox(width: 8),
              Text(
                'Pode gastar no crédito',
                style: tema.textTheme.titleSmall?.copyWith(
                  color: cores.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValorMonetario(
            0,
            estilo: tema.textTheme.displaySmall?.copyWith(
              color: cores.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 8,
              backgroundColor: cores.onPrimary.withValues(alpha: 0.2),
              color: cores.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Cadastre uma conta para calcular quanto sobra no crédito '
            'sem passar do saldo (${Moeda.formatar(0)} comprometidos).',
            style: tema.textTheme.bodySmall?.copyWith(
              color: cores.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
