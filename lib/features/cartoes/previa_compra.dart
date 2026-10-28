import 'package:flutter/material.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../data/banco.dart';
import '../../domain/fatura.dart';
import '../../domain/parcelas.dart';

/// Mostra como a compra no crédito será dividida e em que fatura cai.
class PreviaCompra extends StatelessWidget {
  const PreviaCompra({
    super.key,
    required this.cartao,
    required this.valorTotal,
    required this.parcelas,
    required this.data,
  });

  final Cartao cartao;
  final int valorTotal;
  final int parcelas;
  final DateTime data;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ciclo = cicloDaCompra(
      data,
      diaFechamento: cartao.diaFechamento,
      diaVencimento: cartao.diaVencimento,
    );
    final valores = dividirEmParcelas(valorTotal, parcelas);
    final linhaParcelas = parcelas <= 1
        ? 'À vista: ${Moeda.formatar(valorTotal)}'
        : valores.first == valores.last
            ? '${parcelas}x de ${Moeda.formatar(valores.last)}'
            : '${parcelas}x de ${Moeda.formatar(valores.last)} '
                '(1ª de ${Moeda.formatar(valores.first)})';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (valorTotal > 0)
            Text(linhaParcelas,
                style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            'Entra na fatura de ${FormatoData.mesAno(ciclo.competencia.primeiroDia)} '
            '· fecha em ${FormatoData.dia(ciclo.dataFechamento)} '
            'e vence em ${FormatoData.dia(ciclo.dataVencimento)}',
            style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Escolha do número de parcelas: atalhos mais comuns e botões − / +.
class SeletorParcelas extends StatelessWidget {
  const SeletorParcelas({super.key, required this.parcelas, required this.onChanged});

  final int parcelas;
  final ValueChanged<int> onChanged;

  static const maximo = 48;
  static const atalhos = [1, 2, 3, 4, 6, 10, 12];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: 'Menos uma parcela',
              onPressed: parcelas > 1 ? () => onChanged(parcelas - 1) : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: Text(
                parcelas == 1 ? 'À vista' : '${parcelas}x',
                textAlign: TextAlign.center,
                style: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Mais uma parcela',
              onPressed: parcelas < maximo ? () => onChanged(parcelas + 1) : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in atalhos)
              ChoiceChip(
                label: Text(n == 1 ? 'À vista' : '${n}x'),
                selected: parcelas == n,
                showCheckmark: false,
                onSelected: (_) => onChanged(n),
              ),
          ],
        ),
      ],
    );
  }
}
