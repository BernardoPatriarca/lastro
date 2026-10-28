import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/estado_vazio.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../domain/competencia.dart';
import '../../domain/enums.dart';
import '../../domain/investimentos.dart';

/// Investimentos (V2): patrimônio e evolução mensal, lista por tipo e metas.
class InvestimentosPage extends ConsumerWidget {
  const InvestimentosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carregado = ref.watch(investimentosProvider).hasValue;
    final investimentos = [for (final i in ref.watch(investimentosProvider).ou) if (i.ativo) i];
    final saldos = ref.watch(saldosInvestimentosProvider);
    final patrimonio = ref.watch(patrimonioProvider);
    final metas = [for (final m in ref.watch(metasProvider).ou) if (m.ativa) m];
    final progresso = ref.watch(progressoMetasProvider);
    final tema = Theme.of(context);

    final porTipo = <TipoInvestimento, List<Investimento>>{};
    for (final i in investimentos) {
      porTipo.putIfAbsent(i.tipo, () => []).add(i);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investimentos'),
        actions: [
          IconButton(
            tooltip: 'Novo investimento',
            icon: const Icon(Icons.add_chart_rounded),
            onPressed: () => context.push(Rotas.novoInvestimento),
          ),
        ],
      ),
      body: !carregado
          ? const SizedBox.shrink()
          : investimentos.isEmpty && metas.isEmpty
              ? EstadoVazio(
                  icone: Icons.trending_up_rounded,
                  titulo: 'Nenhum investimento cadastrado',
                  mensagem: 'Cadastre sua reserva, CDB, tesouro ou ações para '
                      'acompanhar o patrimônio e as metas.',
                  acao: 'Novo investimento',
                  onAcao: () => context.push(Rotas.novoInvestimento),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
                  children: [
                    _CardPatrimonio(total: patrimonio),
                    const SizedBox(height: 20),
                    for (final e in porTipo.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(e.key.rotulo,
                                  style: tema.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                            ),
                            ValorMonetario(
                              e.value.fold<int>(0, (s, i) => s + (saldos[i.id] ?? 0)),
                              estilo: tema.textTheme.labelLarge
                                  ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      for (final i in e.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: tema.colorScheme.secondary.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.savings_rounded, color: tema.colorScheme.secondary),
                              ),
                              title: Text(i.nome),
                              subtitle: patrimonio > 0
                                  ? Text('${((saldos[i.id] ?? 0) * 100 / patrimonio).round()}% do patrimônio')
                                  : null,
                              trailing: ValorMonetario(saldos[i.id] ?? 0,
                                  estilo: tema.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              onTap: () => context.push(Rotas.investimento(i.id)),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text('Metas',
                                style: tema.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push(Rotas.novaMeta),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Nova meta'),
                        ),
                      ],
                    ),
                    if (metas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Nenhuma meta ainda. Crie uma para saber quanto aportar por mês.',
                          style: tema.textTheme.bodyMedium
                              ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    for (final m in metas)
                      if (progresso[m.id] != null)
                        _CartaoMeta(meta: m, progresso: progresso[m.id]!),
                  ],
                ),
    );
  }
}

class _CardPatrimonio extends ConsumerWidget {
  const _CardPatrimonio({required this.total});
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mensal = ref.watch(patrimonioMensalProvider);
    final tema = Theme.of(context);
    final entradas = mensal.entries.toList();
    final temHistorico = entradas.any((e) => e.value != 0);
    final maximo = entradas.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final cor = tema.colorScheme.secondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patrimônio em investimentos',
                style: tema.textTheme.labelLarge?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            ValorMonetario(total,
                estilo: tema.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            SizedBox(
              height: 150,
              child: !temHistorico
                  ? Center(
                      child: Text('A evolução mensal aparece depois do primeiro aporte.',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodySmall
                              ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                    )
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maximo * 1.2,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          topTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              interval: 2,
                              getTitlesWidget: (v, _) => Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(_mes(entradas[v.toInt()].key),
                                    style: tema.textTheme.labelSmall),
                              ),
                            ),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => tema.colorScheme.inverseSurface,
                            getTooltipItems: (spots) => [
                              for (final s in spots)
                                LineTooltipItem(
                                  '${FormatoData.mesAno(entradas[s.x.toInt()].key.primeiroDia)}\n'
                                  '${Moeda.formatar(entradas[s.x.toInt()].value)}',
                                  TextStyle(
                                    color: tema.colorScheme.onInverseSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < entradas.length; i++)
                                FlSpot(i.toDouble(), entradas[i].value.toDouble()),
                            ],
                            isCurved: true,
                            curveSmoothness: 0.25,
                            color: cor,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [cor.withValues(alpha: 0.28), cor.withValues(alpha: 0)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static String _mes(Competencia c) {
    const n = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return n[c.mes - 1];
  }
}

class _CartaoMeta extends StatelessWidget {
  const _CartaoMeta({required this.meta, required this.progresso});
  final Meta meta;
  final ProgressoMeta progresso;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final (rotulo, cor, icone) = switch (progresso.situacao) {
      SituacaoMeta.atingida => ('Atingida', cores.positivo, Icons.emoji_events_rounded),
      SituacaoMeta.noRitmo => ('No ritmo', cores.positivo, Icons.trending_up_rounded),
      SituacaoMeta.atrasada => ('Atrasada', cores.alerta, Icons.schedule_rounded),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(Rotas.editarMeta(meta.id)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(meta.nome,
                          style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icone, size: 14, color: cor),
                          const SizedBox(width: 4),
                          Text(rotulo,
                              style: TextStyle(color: cor, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progresso.percentual),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 10, color: cor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${Moeda.formatar(progresso.atual)} de ${Moeda.formatar(progresso.alvo)}',
                        style: tema.textTheme.bodySmall,
                      ),
                    ),
                    Text('${(progresso.percentual * 100).round()}%',
                        style: tema.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  progresso.situacao == SituacaoMeta.atingida
                      ? 'Meta alcançada. Parabéns!'
                      : 'Prazo ${FormatoData.dia(meta.prazo)} · aportar '
                          '${Moeda.formatar(progresso.aporteMensalNecessario)} por mês '
                          '(${progresso.mesesRestantes} ${progresso.mesesRestantes == 1 ? 'mês' : 'meses'})',
                  style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
