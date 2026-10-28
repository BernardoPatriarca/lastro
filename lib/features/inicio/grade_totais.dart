import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/moeda.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/derivados.dart';

/// Saldo atual total das contas, em destaque discreto.
class CardSaldoContas extends ConsumerWidget {
  const CardSaldoContas({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saldo = ref.watch(saldoTotalProvider);
    final tema = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tema.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.account_balance_wallet_rounded,
                    color: tema.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo nas contas',
                        style: tema.textTheme.labelLarge
                            ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                    ValorMonetario(
                      saldo,
                      colorirPorSinal: saldo < 0,
                      estilo: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ganhos, Gastos, Investido e Saldo do mês (mês selecionado).
class GradeTotais extends ConsumerWidget {
  const GradeTotais({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(totaisDoMesProvider);
    final cores = context.coresLastro;
    final tema = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                rotulo: 'Ganhos',
                icone: Icons.south_west_rounded,
                cor: cores.positivo,
                valor: t.ganhos,
                mostrarMais: true,
                colorir: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniCard(
                rotulo: 'Gastos',
                icone: Icons.north_east_rounded,
                cor: cores.negativo,
                valor: -t.gastos,
                mostrarMais: true,
                colorir: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                rotulo: 'Investido',
                icone: Icons.savings_rounded,
                cor: tema.colorScheme.secondary,
                valor: t.investido,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniCard(
                rotulo: 'Saldo do mês',
                icone: Icons.balance_rounded,
                cor: t.saldo >= 0 ? cores.positivo : cores.negativo,
                valor: t.saldo,
                mostrarMais: true,
                colorir: true,
                dica: 'ganhos − gastos',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.rotulo,
    required this.icone,
    required this.cor,
    required this.valor,
    this.mostrarMais = false,
    this.colorir = false,
    this.dica,
  });
  final String rotulo;
  final IconData icone;
  final Color cor;
  final int valor;
  final bool mostrarMais;
  final bool colorir;
  final String? dica;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icone, size: 18, color: cor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(rotulo,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.labelLarge
                          ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: ValorMonetario(
                valor,
                colorirPorSinal: colorir,
                mostrarMais: mostrarMais,
                estilo: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (dica != null)
              Text(dica!,
                  style: tema.textTheme.labelSmall
                      ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Taxa de poupança do mês: investido ÷ ganhos.
class CardTaxaPoupanca extends ConsumerWidget {
  const CardTaxaPoupanca({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(totaisDoMesProvider);
    final tema = Theme.of(context);
    final pct = (t.taxaPoupanca * 100);
    final texto = t.ganhos <= 0
        ? 'Sem ganhos neste mês'
        : '${Moeda.formatar(t.investido)} de ${Moeda.formatar(t.ganhos)} ganhos';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Taxa de poupança',
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(
                  '${pct.toStringAsFixed(pct == pct.roundToDouble() ? 0 : 1).replaceAll('.', ',')}%',
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tema.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: t.taxaPoupanca.clamp(0, 1).toDouble()),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 8),
              ),
            ),
            const SizedBox(height: 8),
            Text(texto,
                style: tema.textTheme.bodySmall
                    ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
