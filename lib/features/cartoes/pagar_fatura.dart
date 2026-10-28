import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/moeda.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/servicos/servico_cartao.dart';
import '../../data/servicos/servicos.dart';
import '../lancamentos/lancamento_acoes.dart';

/// "Pagar fatura": escolhe a conta (padrão: a do cartão), avisa se o saldo não
/// cobre e gera o lançamento de pagamento.
Future<void> pagarFaturaDialog(
  BuildContext context,
  WidgetRef ref,
  Cartao cartao,
  Fatura fatura,
  int total,
) async {
  final contas = ref.read(contasAtivasProvider);
  if (contas.isEmpty) {
    mostrarAviso(context, 'Cadastre uma conta para pagar a fatura.');
    return;
  }
  final saldos = ref.read(saldosPorContaProvider);
  var contaId = contas.any((c) => c.id == cartao.contaPagamentoId)
      ? cartao.contaPagamentoId!
      : contas.first.id;

  final escolhida = await showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) {
        final saldo = saldos[contaId] ?? 0;
        final insuficiente = saldo < total;
        return AlertDialog(
          title: const Text('Pagar fatura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${cartao.nome} · ${Moeda.formatar(total)}',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: contaId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Pagar com a conta'),
                items: [
                  for (final c in contas) DropdownMenuItem(value: c.id, child: Text(c.nome)),
                ],
                onChanged: (v) => setSt(() => contaId = v!),
              ),
              const SizedBox(height: 10),
              Text('Saldo da conta: ${Moeda.formatar(saldo)}',
                  style: Theme.of(ctx).textTheme.bodySmall),
              if (insuficiente)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Saldo insuficiente: a conta ficará negativa.',
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
              onPressed: () => Navigator.pop(ctx, contaId),
              child: const Text('Pagar'),
            ),
          ],
        );
      },
    ),
  );
  if (escolhida == null) return;
  try {
    await ref.read(servicoCartaoProvider).pagarFatura(fatura: fatura, contaId: escolhida);
    if (context.mounted) mostrarAviso(context, 'Fatura paga');
  } on OperacaoInvalida catch (e) {
    if (context.mounted) mostrarAviso(context, e.mensagem);
  }
}
