import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/moeda.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../domain/alertas.dart';
import '../../domain/investimentos.dart';
import '../../domain/orcamento.dart';
import '../categorias/seletor_categoria.dart';
import '../orcamento/barra_orcamento.dart';

/// Alertas do momento (crédito, vencimentos, orçamento, metas, backup).
class AlertasCard extends ConsumerStatefulWidget {
  const AlertasCard({super.key});

  @override
  ConsumerState<AlertasCard> createState() => _AlertasCardState();
}

class _AlertasCardState extends ConsumerState<AlertasCard> {
  bool _todos = false;
  static const _visiveis = 3;

  void _abrir(Alerta a) {
    switch (a.destino) {
      case DestinoAlerta.credito:
      case DestinoAlerta.cartoes:
        context.go(Rotas.cartoes);
      case DestinoAlerta.lancamentos:
        context.go(Rotas.lancamentos);
      case DestinoAlerta.investimentos:
        context.go(Rotas.investimentos);
      case DestinoAlerta.orcamento:
        context.push(Rotas.orcamento);
      case DestinoAlerta.configuracoes:
        context.push(Rotas.configuracoes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertas = ref.watch(alertasProvider);
    if (alertas.isEmpty) return const SizedBox.shrink();
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final mostrados = _todos ? alertas : alertas.take(_visiveis).toList();

    Color cor(NivelAlerta n) => switch (n) {
          NivelAlerta.critico => cores.negativo,
          NivelAlerta.atencao => cores.alerta,
          NivelAlerta.info => tema.colorScheme.secondary,
        };
    IconData icone(NivelAlerta n) => switch (n) {
          NivelAlerta.critico => Icons.error_rounded,
          NivelAlerta.atencao => Icons.warning_amber_rounded,
          NivelAlerta.info => Icons.info_rounded,
        };

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
              child: Row(
                children: [
                  Text('Alertas',
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Badge(label: Text('${alertas.length}')),
                ],
              ),
            ),
            for (final a in mostrados)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                leading: Icon(icone(a.nivel), color: cor(a.nivel)),
                title: Text(a.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(a.detalhe),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _abrir(a),
              ),
            if (alertas.length > _visiveis)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _todos = !_todos),
                  icon: Icon(_todos ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  label: Text(_todos ? 'Mostrar menos' : 'Ver todos (${alertas.length - _visiveis} a mais)'),
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

/// "Projeção do mês": quanto o mês fecha no ritmo atual de gastos.
class ProjecaoCard extends ConsumerWidget {
  const ProjecaoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(projecaoDoMesProvider);
    if (p == null) return const SizedBox.shrink();
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final cor = p.passaDosGanhos ? cores.negativo : tema.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: tema.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text('Projeção do mês',
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              ValorMonetario(
                p.projetado,
                estilo: tema.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: cor),
              ),
              const SizedBox(height: 4),
              Text(
                p.gastoAteAgora == 0
                    ? 'Sem gastos até agora neste mês.'
                    : 'No ritmo atual você termina o mês gastando isso '
                        '(até hoje: ${Moeda.formatar(p.gastoAteAgora)}).',
                style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
              ),
              if (p.passaDosGanhos)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Isso passa dos ganhos do mês (${Moeda.formatar(p.ganhos)}).',
                    style: tema.textTheme.bodySmall?.copyWith(color: cores.negativo, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top 5 categorias do mês, com barra de orçamento quando há limite.
class TopCategoriasCard extends ConsumerWidget {
  const TopCategoriasCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = ref.watch(topCategoriasProvider);
    final categorias = ref.watch(categoriasPorIdProvider);
    if (top.isEmpty) return const SizedBox.shrink();
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Top categorias do mês',
                        style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: () => context.push(Rotas.orcamento),
                    child: const Text('Orçamento'),
                  ),
                ],
              ),
              for (final t in top)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconeCategoria(categoria: categorias[t.categoriaId], tamanho: 32),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(categorias[t.categoriaId]?.nome ?? 'Categoria',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          ValorMonetario(t.gasto,
                              estilo: tema.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      if (t.limite != null) ...[
                        const SizedBox(height: 8),
                        BarraOrcamento(gasto: t.gasto, limite: t.limite!, altura: 6),
                        const SizedBox(height: 4),
                        Text(
                          '${(percentualUsado(t.gasto, t.limite!) * 100).round()}% de ${Moeda.formatar(t.limite!)}',
                          style: tema.textTheme.labelSmall?.copyWith(
                            color: corDoNivel(context, nivelOrcamento(t.gasto, t.limite!)),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Progresso das metas ativas.
class MetasCard extends ConsumerWidget {
  const MetasCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progresso = ref.watch(progressoMetasProvider);
    final metas = [for (final m in ref.watch(metasProvider).ou) if (m.ativa) m];
    if (metas.isEmpty) return const SizedBox.shrink();
    final tema = Theme.of(context);
    final cores = context.coresLastro;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go(Rotas.investimentos),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Metas',
                    style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                for (final m in metas.take(3))
                  if (progresso[m.id] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(m.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Text('${(progresso[m.id]!.percentual * 100).round()}%',
                                  style: tema.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progresso[m.id]!.percentual,
                              minHeight: 8,
                              color: progresso[m.id]!.situacao == SituacaoMeta.atrasada
                                  ? cores.alerta
                                  : cores.positivo,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
