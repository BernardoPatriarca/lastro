import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/seletor_mes.dart';
import '../../data/providers.dart';
import 'card_credito_seguro.dart';
import 'cards_v2.dart';
import 'contas_do_mes_card.dart';
import 'grade_totais.dart';
import 'maiores_gastos_card.dart';
import 'pizza_gastos_card.dart';

/// Dashboard: crédito seguro em destaque, alertas, totais do mês, projeção,
/// contas do mês, gastos por categoria, top categorias com orçamento,
/// maiores gastos e metas.
class InicioPage extends ConsumerWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocultar = ref.watch(ajustesProvider.select((a) => a.ocultarValores));
    final espaco = const SizedBox(height: 14);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        actions: [
          IconButton(
            tooltip: ocultar ? 'Mostrar valores' : 'Ocultar valores',
            icon: Icon(ocultar ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            onPressed: () =>
                ref.read(definirAjusteProvider)('ocultar_valores', '${!ocultar}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
        children: [
          const SeletorMes(),
          const CardCreditoSeguro(),
          const AlertasCard(),
          espaco,
          CardSaldoContas(onTap: () => context.push(Rotas.contas)),
          espaco,
          const GradeTotais(),
          espaco,
          const CardTaxaPoupanca(),
          const ProjecaoCard(),
          espaco,
          const ContasDoMesCard(),
          espaco,
          const PizzaGastosCard(),
          const TopCategoriasCard(),
          espaco,
          const MaioresGastosCard(),
          const MetasCard(),
        ],
      ),
    );
  }
}
