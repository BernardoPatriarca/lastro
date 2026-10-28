import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/estado_vazio.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../domain/enums.dart';
import 'ajustar_saldo_dialog.dart';

/// CRUD de contas: saldo atual calculado, ajuste de saldo e transferência.
class ContasPage extends ConsumerWidget {
  const ContasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contas = ref.watch(contasProvider);
    final saldos = ref.watch(saldosPorContaProvider);
    final total = ref.watch(saldoTotalProvider);
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Rotas.novaConta),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova conta'),
      ),
      body: contas.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (lista) {
          if (lista.isEmpty) {
            return const EstadoVazio(
              icone: Icons.account_balance_wallet_rounded,
              titulo: 'Nenhuma conta cadastrada',
              mensagem: 'Cadastre sua conta corrente, poupança ou carteira '
                  'para começar a lançar.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: lista.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo total das contas ativas',
                          style: tema.textTheme.labelLarge?.copyWith(
                              color: tema.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      ValorMonetario(
                        total,
                        colorirPorSinal: total < 0,
                        estilo: tema.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }
              final c = lista[i - 1];
              return _CartaoConta(conta: c, saldo: saldos[c.id] ?? 0);
            },
          );
        },
      ),
    );
  }
}

class _CartaoConta extends ConsumerWidget {
  const _CartaoConta({required this.conta, required this.saldo});
  final Conta conta;
  final int saldo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final icone = switch (conta.tipo) {
      TipoConta.corrente => Icons.account_balance_rounded,
      TipoConta.poupanca => Icons.savings_rounded,
      TipoConta.carteira => Icons.account_balance_wallet_rounded,
    };
    return Opacity(
      opacity: conta.ativa ? 1 : 0.55,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(Rotas.editarConta(conta.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tema.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icone, color: tema.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(conta.nome,
                          style: tema.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        [
                          conta.tipo.rotulo,
                          if (!conta.ativa) 'arquivada',
                          if (!conta.considerarNoCreditoSeguro) 'fora do crédito seguro',
                        ].join(' · '),
                        style: tema.textTheme.bodySmall?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  flex: 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: ValorMonetario(
                        saldo,
                        colorirPorSinal: saldo < 0,
                        estilo: tema.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (acao) {
                    switch (acao) {
                      case 'editar':
                        context.push(Rotas.editarConta(conta.id));
                      case 'ajustar':
                        ajustarSaldoDialog(context, ref, conta, saldo);
                      case 'transferir':
                        context.push(
                            '${Rotas.novoLancamento}?tipo=mov&conta=${conta.id}');
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'ajustar', child: Text('Ajustar saldo')),
                    PopupMenuItem(value: 'transferir', child: Text('Transferir')),
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
