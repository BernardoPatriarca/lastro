import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/estado_vazio.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../domain/competencia.dart';
import '../../domain/compromissos.dart';
import '../../domain/enums.dart';

/// Compromissos ativos (progresso, restante, término), receitas recorrentes e
/// total comprometido por mês nos próximos 12 meses.
class CompromissosPage extends ConsumerWidget {
  const CompromissosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compromissos = ref.watch(compromissosProvider).ou;
    final receitas = ref.watch(receitasProvider).ou;
    final ocorrencias = ref.watch(ocorrenciasProvider).ou;
    final projecao = ref.watch(projecaoComprometidoProvider);
    final ativos = [for (final c in compromissos) if (c.ativo) c];
    final encerrados = [for (final c in compromissos) if (!c.ativo) c];
    final vazio = compromissos.isEmpty && receitas.isEmpty;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Compromissos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _novo(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          _Projecao(projecao: projecao),
          const SizedBox(height: 20),
          if (vazio)
            const SizedBox(
              height: 320,
              child: EstadoVazio(
                icone: Icons.event_repeat_rounded,
                titulo: 'Nenhum compromisso cadastrado',
                mensagem: 'Cadastre aluguel, internet, financiamentos e outros '
                    'gastos fixos — e receitas que se repetem todo mês.',
              ),
            ),
          if (ativos.isNotEmpty) ...[
            _Titulo('Gastos fixos e parcelados'),
            for (final c in ativos)
              _CartaoCompromisso(compromisso: c, ocorrencias: ocorrencias),
          ],
          if (receitas.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Titulo('Receitas recorrentes'),
            for (final r in receitas) _CartaoReceita(receita: r),
          ],
          if (encerrados.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Titulo('Encerrados'),
            Opacity(
              opacity: 0.6,
              child: Column(children: [
                for (final c in encerrados)
                  _CartaoCompromisso(compromisso: c, ocorrencias: ocorrencias),
              ]),
            ),
          ],
          if (!vazio) SizedBox(height: tema.useMaterial3 ? 8 : 0),
        ],
      ),
    );
  }

  void _novo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded),
              title: const Text('Gasto fixo ou parcelado'),
              subtitle: const Text('Aluguel, internet, financiamento…'),
              onTap: () {
                Navigator.pop(ctx);
                context.push(Rotas.novoCompromisso);
              },
            ),
            ListTile(
              leading: const Icon(Icons.south_west_rounded),
              title: const Text('Receita recorrente'),
              subtitle: const Text('Salário e outras entradas mensais'),
              onTap: () {
                Navigator.pop(ctx);
                context.push(Rotas.novaReceita);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(texto,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      );
}

String _mesCurto(Competencia c) {
  const nomes = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
  return nomes[c.mes - 1];
}

class _Projecao extends StatelessWidget {
  const _Projecao({required this.projecao});
  final Map<Competencia, int> projecao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final entradas = projecao.entries.toList();
    final maximo = entradas.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final total = entradas.fold<int>(0, (s, e) => s + e.value);
    final cor = tema.colorScheme.secondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comprometido nos próximos 12 meses',
                style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Faturas de cartão a vencer + contas fixas',
                style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            ValorMonetario(total,
                estilo: tema.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SizedBox(
              height: 170,
              child: maximo == 0
                  ? Center(
                      child: Text('Nada comprometido nos próximos meses.',
                          style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                    )
                  : BarChart(
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
                                child: Text(_mesCurto(entradas[v.toInt()].key),
                                    style: tema.textTheme.labelSmall),
                              ),
                            ),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => tema.colorScheme.inverseSurface,
                            getTooltipItem: (g, _, rod, _) => BarTooltipItem(
                              '${FormatoData.mesAno(entradas[g.x].key.primeiroDia)}\n'
                              '${Moeda.formatar(entradas[g.x].value)}',
                              TextStyle(
                                color: tema.colorScheme.onInverseSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < entradas.length; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                toY: entradas[i].value.toDouble(),
                                width: 14,
                                color: cor,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ]),
                        ],
                      ),
                    ),
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text('Ver mês a mês', style: tema.textTheme.labelLarge),
              children: [
                for (final e in entradas)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(FormatoData.mesAno(e.key.primeiroDia))),
                        ValorMonetario(e.value),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoCompromisso extends ConsumerWidget {
  const _CartaoCompromisso({required this.compromisso, required this.ocorrencias});
  final Compromisso compromisso;
  final List<OcorrenciaCompromisso> ocorrencias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = compromisso;
    final tema = Theme.of(context);
    final parcelado = c.tipo == TipoCompromisso.parcelado && c.numeroParcelas != null;
    final pagas = [
      for (final o in ocorrencias)
        if (o.compromissoId == c.id && o.status == StatusOcorrencia.paga) o,
    ];
    // Progresso = última parcela paga (vale também se começou no meio).
    final feitas = pagas.fold<int>(0, (m, o) => (o.numeroParcela ?? 0) > m ? o.numeroParcela! : m);
    final restante = parcelado ? (c.numeroParcelas! - feitas) * c.valor : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(Rotas.editarCompromisso(c.id)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c.descricao,
                          style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    ValorMonetario(c.valor,
                        estilo: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(' /mês', style: tema.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  parcelado
                      ? 'Parcelado · vence dia ${c.diaVencimento}'
                      : 'Recorrente, sem fim · vence dia ${c.diaVencimento}',
                  style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
                if (parcelado) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('$feitas/${c.numeroParcelas}',
                          style: tema.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: feitas / c.numeroParcelas!,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Restante: ${Moeda.formatar(restante!)}',
                            style: tema.textTheme.bodySmall),
                      ),
                      Text('Termina em ${FormatoData.mesAno(dataDeTermino(c.dataInicio, c.numeroParcelas!))}',
                          style: tema.textTheme.bodySmall),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartaoReceita extends StatelessWidget {
  const _CartaoReceita({required this.receita});
  final ReceitaRecorrente receita;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: receita.ativa ? 1 : 0.55,
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(receita.descricao,
                style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('Prevista todo dia ${receita.diaPrevisto}${receita.ativa ? '' : ' · pausada'}'),
            trailing: ValorMonetario(receita.valorPrevisto,
                colorirPorSinal: true,
                estilo: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            onTap: () => context.push(Rotas.editarReceita(receita.id)),
          ),
        ),
      ),
    );
  }
}
