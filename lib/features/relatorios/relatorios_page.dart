import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/seletor_mes.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/derivados.dart';
import '../../domain/competencia.dart';
import '../../domain/relatorios.dart';
import '../categorias/seletor_categoria.dart';

/// Relatórios (V3): evolução mensal, comparativo por categoria, média mensal
/// por categoria e gastos fixos × variáveis.
class RelatoriosPage extends ConsumerStatefulWidget {
  const RelatoriosPage({super.key});

  @override
  ConsumerState<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends ConsumerState<RelatoriosPage> {
  int _meses = 6;

  @override
  Widget build(BuildContext context) {
    final lancs = ref.watch(lancamentosRelatorioProvider);
    final mesRef = ref.watch(mesSelecionadoProvider);
    final fim = Competencia.deData(DateTime.now());
    final pontos = evolucaoMensal(lancs, fim: fim, meses: _meses);
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 6, label: Text('Últimos 6 meses')),
              ButtonSegment(value: 12, label: Text('Últimos 12 meses')),
            ],
            selected: {_meses},
            onSelectionChanged: (s) => setState(() => _meses = s.first),
          ),
          const SizedBox(height: 14),
          _Evolucao(pontos: pontos),
          const SizedBox(height: 14),
          _FixosVariaveisCard(lancs: lancs, fim: fim, meses: _meses),
          const SizedBox(height: 14),
          _MediaPorCategoria(lancs: lancs, fim: fim, meses: _meses),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: Column(
                children: [
                  Text('Comparativo por categoria',
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SeletorMes(),
                  _Comparativo(lancs: lancs, mes: mesRef),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _mesCurto(Competencia c) {
  const n = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
  return n[c.mes - 1];
}

class _Evolucao extends StatelessWidget {
  const _Evolucao({required this.pontos});
  final List<PontoMensal> pontos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final maximo = pontos.fold<int>(
      0,
      (m, p) => [m, p.ganhos, p.gastos, p.investido].reduce((a, b) => a > b ? a : b),
    );
    final n = pontos.length;
    final largura = (n * 62.0).clamp(300.0, 900.0);
    final temDados = maximo > 0;
    int media(int Function(PontoMensal) f) => pontos.fold<int>(0, (s, p) => s + f(p)) ~/ n;

    Widget legenda(String texto, Color cor, int valor) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Flexible(child: Text(texto, overflow: TextOverflow.ellipsis, style: tema.textTheme.labelMedium)),
              ]),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ValorMonetario(valor,
                    estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Text('média/mês', style: tema.textTheme.labelSmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ganhos × gastos × investido',
                style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(children: [
              legenda('Ganhos', cores.positivo, media((p) => p.ganhos)),
              legenda('Gastos', cores.negativo, media((p) => p.gastos)),
              legenda('Investido', tema.colorScheme.secondary, media((p) => p.investido)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: !temDados
                  ? Center(
                      child: Text('Sem movimentos neste período.',
                          style: tema.textTheme.bodyMedium
                              ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // abre mostrando os meses mais recentes
                      child: SizedBox(
                        width: largura,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maximo * 1.15,
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
                                  getTitlesWidget: (v, _) => Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(_mesCurto(pontos[v.toInt()].competencia),
                                        style: tema.textTheme.labelSmall),
                                  ),
                                ),
                              ),
                            ),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => tema.colorScheme.inverseSurface,
                                getTooltipItem: (g, _, rod, rodIndex) {
                                  final p = pontos[g.x];
                                  final nome = ['Ganhos', 'Gastos', 'Investido'][rodIndex];
                                  final valor = [p.ganhos, p.gastos, p.investido][rodIndex];
                                  return BarTooltipItem(
                                    '${FormatoData.mesAno(p.competencia.primeiroDia)}\n$nome: ${Moeda.formatar(valor)}',
                                    TextStyle(
                                      color: tema.colorScheme.onInverseSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ),
                            barGroups: [
                              for (var i = 0; i < n; i++)
                                BarChartGroupData(
                                  x: i,
                                  barsSpace: 3,
                                  barRods: [
                                    _barra(pontos[i].ganhos, cores.positivo),
                                    _barra(pontos[i].gastos, cores.negativo),
                                    _barra(pontos[i].investido, tema.colorScheme.secondary),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartRodData _barra(int valor, Color cor) => BarChartRodData(
        toY: valor.toDouble(),
        width: 12,
        color: cor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      );
}

class _FixosVariaveisCard extends StatelessWidget {
  const _FixosVariaveisCard({required this.lancs, required this.fim, required this.meses});
  final List<LancRelatorio> lancs;
  final Competencia fim;
  final int meses;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final r = fixosVariaveis(lancs, fim: fim, meses: meses);
    final corFixo = tema.colorScheme.primary;
    final corVar = tema.colorScheme.tertiary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gastos fixos × variáveis',
                style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Fixos: contas fixas e parcelas do cartão.',
                style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 14),
            if (r.total == 0)
              Text('Sem gastos neste período.',
                  style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant))
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 18,
                  child: Row(
                    children: [
                      if (r.fixos > 0) Expanded(flex: r.fixos, child: Container(color: corFixo)),
                      if (r.variaveis > 0)
                        Expanded(flex: r.variaveis, child: Container(color: corVar)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Parte('Fixos', r.fixos, r.percentualFixos, corFixo),
                  _Parte('Variáveis', r.variaveis, 100 - r.percentualFixos, corVar),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Parte extends StatelessWidget {
  const _Parte(this.rotulo, this.valor, this.percentual, this.cor);
  final String rotulo;
  final int valor;
  final int percentual;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Flexible(
              child: Text('$rotulo · $percentual%',
                  overflow: TextOverflow.ellipsis, style: tema.textTheme.labelMedium),
            ),
          ]),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ValorMonetario(valor,
                estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MediaPorCategoria extends ConsumerWidget {
  const _MediaPorCategoria({required this.lancs, required this.fim, required this.meses});
  final List<LancRelatorio> lancs;
  final Competencia fim;
  final int meses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final categorias = ref.watch(categoriasPorIdProvider);
    final media = mediaMensalPorCategoria(lancs, fim: fim, meses: meses).take(8).toList();
    final maior = media.isEmpty ? 1 : media.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Média mensal por categoria',
                style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (media.isEmpty)
              Text('Sem gastos neste período.',
                  style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
            for (final e in media)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key == null ? 'Sem categoria' : (categorias[e.key]?.nome ?? 'Categoria'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ValorMonetario(e.value,
                            estilo: tema.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(' /mês', style: tema.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: maior == 0 ? 0 : e.value / maior,
                        minHeight: 6,
                        color: e.key == null
                            ? tema.colorScheme.outline
                            : Color(categorias[e.key]?.cor ?? 0xFF14B8A6),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Comparativo extends ConsumerWidget {
  const _Comparativo({required this.lancs, required this.mes});
  final List<LancRelatorio> lancs;
  final Competencia mes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final categorias = ref.watch(categoriasPorIdProvider);
    final lista = comparativoPorCategoria(
      atual: gastosPorCategoriaNoMes(lancs, mes),
      anterior: gastosPorCategoriaNoMes(lancs, mes.somarMeses(-1)),
    ).take(10).toList();

    if (lista.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Sem gastos neste mês nem no anterior.',
            style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
      );
    }
    return Column(
      children: [
        for (final c in lista)
          ListTile(
            dense: true,
            leading: IconeCategoria(categoria: categorias[c.categoriaId], tamanho: 36),
            title: Text(
              c.categoriaId == null ? 'Sem categoria' : (categorias[c.categoriaId]?.nome ?? 'Categoria'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Mês anterior: ${Moeda.formatar(c.anterior)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ValorMonetario(c.atual,
                    estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                _Variacao(c: c, positivo: cores.positivo, negativo: cores.negativo),
              ],
            ),
          ),
      ],
    );
  }
}

class _Variacao extends StatelessWidget {
  const _Variacao({required this.c, required this.positivo, required this.negativo});
  final ComparativoCategoria c;
  final Color positivo;
  final Color negativo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    if (c.ehNova) {
      return Text('novo', style: tema.textTheme.labelSmall?.copyWith(color: negativo, fontWeight: FontWeight.w700));
    }
    final v = c.variacaoPercentual;
    if (v == null || v == 0) {
      return Text('igual', style: tema.textTheme.labelSmall);
    }
    // Gastar mais é "ruim" (vermelho); gastar menos é "bom" (verde). O sinal e a
    // seta impressos garantem que a cor não é a única informação.
    final subiu = v > 0;
    return Text(
      '${subiu ? '▲' : '▼'} ${v.abs()}%',
      style: tema.textTheme.labelSmall?.copyWith(
        color: subiu ? negativo : positivo,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
