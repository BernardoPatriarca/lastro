import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/estado_vazio.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import 'cartao_visual.dart';

/// Lista de cartões: limite, usado, disponível e fatura atual.
class CartoesPage extends ConsumerWidget {
  const CartoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carregado = ref.watch(cartoesProvider).hasValue;
    final resumos = ref.watch(resumosCartaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões'),
        actions: [
          IconButton(
            tooltip: 'Novo cartão',
            icon: const Icon(Icons.add_card_rounded),
            onPressed: () => context.push(Rotas.novoCartao),
          ),
        ],
      ),
      body: !carregado
          ? const SizedBox.shrink()
          : resumos.isEmpty
              ? EstadoVazio(
                  icone: Icons.credit_card_rounded,
                  titulo: 'Nenhum cartão cadastrado',
                  mensagem: 'Cadastre um cartão para acompanhar faturas, '
                      'parcelas e quanto ainda dá para gastar.',
                  acao: 'Cadastrar cartão',
                  onAcao: () => context.push(Rotas.novoCartao),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: resumos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final r = resumos[i];
                    return CartaoVisual(
                      resumo: r,
                      onTap: () => context.push(Rotas.cartao(r.cartao.id)),
                    );
                  },
                ),
    );
  }
}
