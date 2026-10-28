import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/derivados.dart';
import '../lancamentos/lancamento_tile.dart';

/// Os 5 maiores gastos do mês.
class MaioresGastosCard extends ConsumerWidget {
  const MaioresGastosCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastos = ref.watch(maioresGastosProvider);
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Maiores gastos do mês',
                  style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 4),
            if (gastos.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text('Nenhum gasto neste mês.',
                    style: tema.textTheme.bodyMedium
                        ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
              )
            else
              for (final l in gastos)
                LancamentoTile(
                  lancamento: l,
                  onTap: () => context.push(Rotas.editarLancamento(l.id)),
                ),
          ],
        ),
      ),
    );
  }
}
