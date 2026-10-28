import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/banco.dart';
import '../../data/servicos/servico_cartao.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/enums.dart';
import 'lancamento_tile.dart';

void mostrarAviso(BuildContext context, String texto) {
  final m = ScaffoldMessenger.maybeOf(context);
  m?.hideCurrentSnackBar();
  m?.showSnackBar(SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating));
}

/// Pergunta em quais parcelas aplicar a ação: "só esta" ou "esta e as próximas"
/// (e, para exclusão, também "todas"). Devolve `null` se cancelar.
Future<EscopoParcelas?> perguntarEscopo(
  BuildContext context, {
  required String titulo,
  bool permitirTodas = false,
}) {
  return showModalBottomSheet<EscopoParcelas>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(titulo,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Icon(Icons.looks_one_rounded),
              title: const Text('Só esta parcela'),
              onTap: () => Navigator.pop(ctx, EscopoParcelas.soEsta),
            ),
            ListTile(
              leading: const Icon(Icons.last_page_rounded),
              title: const Text('Esta e as próximas'),
              onTap: () => Navigator.pop(ctx, EscopoParcelas.estaEProximas),
            ),
            if (permitirTodas)
              ListTile(
                leading: const Icon(Icons.layers_rounded),
                title: const Text('Todas as parcelas'),
                onTap: () => Navigator.pop(ctx, EscopoParcelas.todas),
              ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Pede confirmação e exclui. Devolve `true` se algo foi excluído.
///
/// - Compra parcelada: pergunta o escopo.
/// - Pagamento de fatura: avisa que a fatura será reaberta.
/// - Fatura já paga: mostra o motivo em vez de excluir.
Future<bool> confirmarExclusao(
  BuildContext context,
  WidgetRef ref,
  Lancamento l,
) async {
  final cartao = ref.read(servicoCartaoProvider);
  try {
    if (l.compraParceladaId != null) {
      final escopo = await perguntarEscopo(
        context,
        titulo: 'Excluir qual parte da compra parcelada?',
        permitirTodas: true,
      );
      if (escopo == null) return false;
      await cartao.excluirCompra(l, escopo);
      return true;
    }

    final pagamento = l.tipo == TipoLancamento.pagamentoFatura;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir lançamento?'),
        content: Text(
          pagamento
              ? 'A fatura voltará a ficar em aberto e o valor volta para a conta.'
              : l.descricao.isNotEmpty
                  ? '"${l.descricao}" será removido.'
                  : 'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    if (l.formaPagamento == FormaPagamento.credito) {
      await cartao.excluirCompra(l, EscopoParcelas.soEsta);
    } else {
      await ref.read(servicoLancamentosProvider).excluir(l.id);
    }
    return true;
  } on OperacaoInvalida catch (e) {
    if (context.mounted) mostrarAviso(context, e.mensagem);
    return false;
  }
}

/// Linha de lançamento que se arrasta para excluir (com confirmação).
class LinhaLancamentoDispensavel extends ConsumerWidget {
  const LinhaLancamentoDispensavel({super.key, required this.lancamento});
  final Lancamento lancamento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    return Dismissible(
      key: ValueKey('d${lancamento.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: tema.colorScheme.error.withValues(alpha: 0.9),
        child: Icon(Icons.delete_rounded, color: tema.colorScheme.onError),
      ),
      confirmDismiss: (_) => confirmarExclusao(context, ref, lancamento),
      child: LancamentoTile(
        lancamento: lancamento,
        onTap: () => context.push(Rotas.editarLancamento(lancamento.id)),
      ),
    );
  }
}
