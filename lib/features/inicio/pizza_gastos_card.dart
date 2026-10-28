import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icones.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/derivados.dart';
import '../../domain/resumo_mes.dart';

/// Gráfico de pizza dos gastos do mês por categoria (+ legenda acessível).
class PizzaGastosCard extends ConsumerStatefulWidget {
  const PizzaGastosCard({super.key});

  @override
  ConsumerState<PizzaGastosCard> createState() => _PizzaGastosCardState();
}

class _PizzaGastosCardState extends ConsumerState<PizzaGastosCard> {
  int _tocada = -1;

  static const _paleta = [
    0xFF14B8A6, 0xFF3B82F6, 0xFFF59E0B, 0xFF8B5CF6, 0xFFEC4899, 0xFFEF4444,
  ];

  @override
  Widget build(BuildContext context) {
    final fatias = limitarFatias(ref.watch(gastosPorCategoriaProvider), 6);
    final categorias = ref.watch(categoriasPorIdProvider);
    final tema = Theme.of(context);
    final total = fatias.fold<int>(0, (s, f) => s + f.valor);

    String nome(FatiaCategoria f) => f.categoriaId == idOutras
        ? 'Outras'
        : f.categoriaId == null
            ? 'Sem categoria'
            : categorias[f.categoriaId]?.nome ?? 'Categoria';
    Color cor(int i, FatiaCategoria f) {
      if (f.categoriaId == idOutras || f.categoriaId == null) return tema.colorScheme.outline;
      final c = categorias[f.categoriaId];
      return c != null ? Color(c.cor) : Color(_paleta[i % _paleta.length]);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gastos por categoria',
                style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (fatias.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Nenhum gasto neste mês — toque em + para adicionar.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium
                          ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                ),
              )
            else ...[
              SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 58,
                        pieTouchData: PieTouchData(
                          touchCallback: (evento, resposta) {
                            final i = resposta?.touchedSection?.touchedSectionIndex ?? -1;
                            if (i != _tocada && evento.isInterestedForInteractions) {
                              setState(() => _tocada = i);
                            } else if (!evento.isInterestedForInteractions && _tocada != -1) {
                              setState(() => _tocada = -1);
                            }
                          },
                        ),
                        sections: [
                          for (var i = 0; i < fatias.length; i++)
                            PieChartSectionData(
                              value: fatias[i].valor.toDouble(),
                              color: cor(i, fatias[i]),
                              radius: i == _tocada ? 38 : 30,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tocada >= 0 && _tocada < fatias.length
                              ? nome(fatias[_tocada])
                              : 'Total',
                          style: tema.textTheme.labelMedium
                              ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                        ),
                        ValorMonetario(
                          _tocada >= 0 && _tocada < fatias.length
                              ? fatias[_tocada].valor
                              : total,
                          estilo: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < fatias.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: cor(i, fatias[i]).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          fatias[i].categoriaId == null || fatias[i].categoriaId == idOutras
                              ? Icons.category_rounded
                              : iconeDe(categorias[fatias[i].categoriaId]?.icone),
                          size: 16,
                          color: cor(i, fatias[i]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(nome(fatias[i]), overflow: TextOverflow.ellipsis)),
                      Text(
                        '${(fatias[i].valor * 100 / total).round()}%',
                        style: tema.textTheme.labelMedium
                            ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 104,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ValorMonetario(fatias[i].valor,
                              estilo: tema.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

