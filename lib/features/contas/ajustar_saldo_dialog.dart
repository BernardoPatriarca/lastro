import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/moeda.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/servicos/servicos.dart';

/// "Ajustar saldo": o dono informa o saldo real do banco e o app cria um
/// lançamento `ajusteSaldo` com a diferença.
Future<void> ajustarSaldoDialog(
  BuildContext context,
  WidgetRef ref,
  Conta conta,
  int saldoAtual,
) async {
  final valor = ControladorValor();
  var negativo = false;
  final resultado = await showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final real = negativo ? -valor.centavos : valor.centavos;
        final dif = real - saldoAtual;
        return AlertDialog(
          title: const Text('Ajustar saldo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo no app: ${Moeda.formatar(saldoAtual)}'),
              const SizedBox(height: 12),
              CampoValor(
                controller: valor,
                rotulo: 'Saldo real no banco',
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: negativo,
                onChanged: (v) => setState(() => negativo = v ?? false),
                title: const Text('Saldo negativo'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (valor.text.isNotEmpty)
                Text(
                  dif == 0
                      ? 'Já está batendo.'
                      : 'Será lançado um ajuste de ${Moeda.comSinal(dif)}.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
              onPressed: valor.text.isEmpty ? null : () => Navigator.pop(ctx, real),
              child: const Text('Ajustar'),
            ),
          ],
        );
      },
    ),
  );
  valor.dispose();
  if (resultado == null) return;
  final dif = await ref.read(servicoLancamentosProvider).ajustarSaldo(
        contaId: conta.id,
        saldoReal: resultado,
        saldoAtual: saldoAtual,
      );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(dif == 0
          ? 'Saldo já estava correto'
          : 'Saldo ajustado (${Moeda.comSinal(dif)})'),
    ));
  }
}
