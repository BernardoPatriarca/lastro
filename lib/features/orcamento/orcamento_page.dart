import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/moeda.dart';
import '../../core/widgets/campo_valor.dart';
import '../../core/widgets/seletor_mes.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/orcamento.dart';
import '../categorias/seletor_categoria.dart';
import '../lancamentos/lancamento_acoes.dart';
import 'barra_orcamento.dart';

/// Orçamento por categoria: limite mensal, barra verde/amarela/vermelha e
/// "copiar do mês anterior".
class OrcamentoPage extends ConsumerWidget {
  const OrcamentoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linhas = ref.watch(linhasOrcamentoProvider);
    final categorias = ref.watch(categoriasPorIdProvider);
    final mes = ref.watch(mesSelecionadoProvider);
    final tema = Theme.of(context);

    final comLimite = linhas.where((l) => l.temLimite).toList();
    final estourados = comLimite.where((l) => l.nivel == NivelOrcamento.vermelho).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamento'),
        actions: [
          IconButton(
            tooltip: 'Copiar do mês anterior',
            icon: const Icon(Icons.content_copy_rounded),
            onPressed: () async {
              final n = await ref.read(servicoOrcamentoProvider).copiarDoMesAnterior(mes);
              if (context.mounted) {
                mostrarAviso(context, n == 0
                    ? 'Nada novo para copiar do mês anterior.'
                    : '$n ${n == 1 ? 'limite copiado' : 'limites copiados'} do mês anterior.');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
        children: [
          const SeletorMes(),
          if (comLimite.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tema.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      estourados == 0 ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                      color: corDoNivel(context,
                          estourados == 0 ? NivelOrcamento.verde : NivelOrcamento.vermelho),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        estourados == 0
                            ? 'Todas as ${comLimite.length} categorias com limite estão dentro dele.'
                            : '$estourados de ${comLimite.length} categorias passaram do limite.',
                        style: tema.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (comLimite.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
              child: Text(
                'Toque em uma categoria para definir o limite do mês. '
                'Limite numa categoria principal já inclui as subcategorias.',
                style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
              ),
            ),
          for (final l in linhas)
            if (categorias[l.categoriaId] != null)
              _LinhaCategoria(linha: l, categoria: categorias[l.categoriaId]!),
        ],
      ),
    );
  }
}

class _LinhaCategoria extends ConsumerWidget {
  const _LinhaCategoria({required this.linha, required this.categoria});
  final LinhaOrcamento linha;
  final Categoria categoria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final categorias = ref.watch(categoriasPorIdProvider);
    final pai = categoria.categoriaPaiId == null ? null : categorias[categoria.categoriaPaiId];
    final nome = pai == null ? categoria.nome : '${pai.nome} › ${categoria.nome}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _definir(context, ref),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconeCategoria(categoria: categoria, tamanho: 38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(nome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    if (!linha.temLimite)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(linha.gasto > 0 ? Moeda.formatar(linha.gasto) : 'Definir limite',
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.labelLarge?.copyWith(
                                color: tema.colorScheme.onSurfaceVariant)),
                      ),
                  ],
                ),
                if (linha.temLimite) ...[
                  const SizedBox(height: 10),
                  BarraOrcamento(gasto: linha.gasto, limite: linha.limite!),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${Moeda.formatar(linha.gasto)} de ${Moeda.formatar(linha.limite!)} '
                          '(${(linha.percentual * 100).round()}%)',
                          style: tema.textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        linha.restante >= 0
                            ? 'Resta ${Moeda.formatar(linha.restante)}'
                            : 'Passou ${Moeda.formatar(-linha.restante)}',
                        style: tema.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: corDoNivel(context, linha.nivel!),
                        ),
                      ),
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

  Future<void> _definir(BuildContext context, WidgetRef ref) async {
    final valor = ControladorValor(centavos: linha.limite ?? 0);
    final r = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Limite de ${categoria.nome}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoValor(controller: valor, rotulo: 'Limite do mês', autofocus: true),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Gasto até agora: '),
                ValorMonetario(linha.gasto, estilo: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        actions: [
          if (linha.temLimite)
            TextButton(
              onPressed: () => Navigator.pop(ctx, 0),
              child: const Text('Remover limite'),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
            onPressed: () => Navigator.pop(ctx, valor.centavos),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    descartarDepoisDoDialogo([valor]);
    if (r == null) return;
    await ref.read(servicoOrcamentoProvider).definirLimite(categoria.id, ref.read(mesSelecionadoProvider), r);
  }
}
