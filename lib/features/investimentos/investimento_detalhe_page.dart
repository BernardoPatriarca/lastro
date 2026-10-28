import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/estado_vazio.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/enums.dart';
import 'movimento_dialog.dart';

/// Detalhe do investimento: saldo, histórico de movimentos e as ações
/// Aporte, Resgate e Atualizar saldo.
class InvestimentoDetalhePage extends ConsumerWidget {
  const InvestimentoDetalhePage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = ref.watch(investimentosProvider).ou.where((i) => i.id == id).firstOrNull;
    final tema = Theme.of(context);
    if (inv == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EstadoVazio(
          icone: Icons.search_off_rounded,
          titulo: 'Investimento não encontrado',
        ),
      );
    }
    final saldo = ref.watch(saldosInvestimentosProvider)[id] ?? 0;
    final movs = [
      for (final m in ref.watch(movimentosInvestimentoProvider).ou)
        if (m.investimentoId == id) m,
    ]..sort((a, b) {
        final c = b.data.compareTo(a.data);
        return c != 0 ? c : b.id.compareTo(a.id);
      });

    Widget acao(IconData icone, String rotulo, AcaoInvestimento a) => Expanded(
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 64),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            onPressed: () => abrirMovimentoInvestimento(context, ref, inv, a, saldoAtual: saldo),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icone),
                const SizedBox(height: 2),
                Text(rotulo, style: const TextStyle(fontSize: 12), maxLines: 1),
              ],
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(inv.nome),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(Rotas.editarInvestimento(id)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inv.tipo.rotulo,
                      style: tema.textTheme.labelLarge
                          ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  ValorMonetario(saldo,
                      estilo: tema.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              acao(Icons.add_circle_outline_rounded, 'Aporte', AcaoInvestimento.aporte),
              const SizedBox(width: 8),
              acao(Icons.remove_circle_outline_rounded, 'Resgate', AcaoInvestimento.resgate),
              const SizedBox(width: 8),
              acao(Icons.published_with_changes_rounded, 'Atualizar saldo',
                  AcaoInvestimento.atualizarSaldo),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text('Histórico',
                style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (movs.isEmpty)
            const SizedBox(
              height: 240,
              child: EstadoVazio(
                icone: Icons.history_rounded,
                titulo: 'Nenhum movimento ainda',
                mensagem: 'Faça um aporte ou atualize o saldo para começar.',
              ),
            )
          else
            for (final m in movs) _LinhaMovimento(movimento: m),
        ],
      ),
    );
  }
}

class _LinhaMovimento extends ConsumerWidget {
  const _LinhaMovimento({required this.movimento});
  final MovimentoInvestimento movimento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final m = movimento;
    final (titulo, icone, cor, sinal) = switch (m.tipo) {
      TipoMovimentoInvestimento.aporte =>
        ('Aporte', Icons.south_west_rounded, tema.colorScheme.secondary, 1),
      TipoMovimentoInvestimento.resgate =>
        ('Resgate', Icons.north_east_rounded, tema.colorScheme.error, -1),
      TipoMovimentoInvestimento.atualizacaoSaldo =>
        ('Saldo atualizado para', Icons.published_with_changes_rounded, tema.colorScheme.tertiary, 0),
    };
    return Dismissible(
      key: ValueKey('m${m.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: tema.colorScheme.error.withValues(alpha: 0.9),
        child: Icon(Icons.delete_rounded, color: tema.colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir movimento?'),
            content: Text(m.lancamentoId != null
                ? 'O lançamento na conta também será excluído.'
                : 'O saldo será recalculado sem esta atualização.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(80, 44)),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
        if (ok != true) return false;
        await ref.read(servicoInvestimentoProvider).excluirMovimento(m);
        return true;
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icone, color: cor, size: 20),
        ),
        title: Text(titulo),
        subtitle: Text(FormatoData.dia(m.data)),
        trailing: ValorMonetario(
          m.valor,
          mostrarMais: sinal != 0,
          estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
