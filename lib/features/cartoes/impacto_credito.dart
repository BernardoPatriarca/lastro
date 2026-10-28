import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/moeda.dart';
import '../../core/theme/cores_lastro.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../domain/credito_seguro.dart';
import '../../domain/datas.dart';
import '../../domain/enums.dart';
import '../../domain/fatura.dart';
import '../../domain/parcelas.dart';

/// Impacto de uma compra no crédito sobre o "pode gastar" (regra 5.1).
ImpactoCompra impactoDaCompra(
  WidgetRef ref, {
  required Cartao cartao,
  required int valor,
  required int parcelas,
  required DateTime data,
}) {
  final atual = ref.read(creditoSeguroProvider);
  final modo = ref.read(ajustesProvider).modoParcelados;
  final cicloHoje = cicloDaCompra(
    soData(DateTime.now()),
    diaFechamento: cartao.diaFechamento,
    diaVencimento: cartao.diaVencimento,
  );
  final geradas = gerarParcelas(
    descricao: '',
    valorTotal: valor,
    numeroParcelas: parcelas,
    dataCompra: soData(data),
    diaFechamento: cartao.diaFechamento,
    diaVencimento: cartao.diaVencimento,
  );
  final peso = valorQuePesaDaCompra(parcelas: geradas, cicloAtual: cicloHoje, modo: modo);
  return calcularImpactoCompra(atual: atual, valorQuePesa: peso);
}

/// "Depois dessa compra sobra R$ X" (vermelho se estourar), em tempo real.
class ImpactoCredito extends ConsumerWidget {
  const ImpactoCredito({
    super.key,
    required this.cartao,
    required this.valor,
    required this.parcelas,
    required this.data,
  });

  final Cartao cartao;
  final int valor;
  final int parcelas;
  final DateTime data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa para reconstruir quando saldo/faturas/ajustes mudarem.
    ref.watch(creditoSeguroProvider);
    final comportamento = ref.watch(ajustesProvider.select((a) => a.comportamentoEstouro));
    if (valor <= 0) return const SizedBox.shrink();

    final impacto = impactoDaCompra(
      ref,
      cartao: cartao,
      valor: valor,
      parcelas: parcelas,
      data: data,
    );
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final cor = impacto.estoura ? cores.negativo : cores.positivo;

    final aviso = switch (comportamento) {
      ComportamentoEstouro.bloquear => 'O lançamento será bloqueado (veja Configurações).',
      ComportamentoEstouro.confirmar => 'Vou pedir sua confirmação antes de lançar.',
      ComportamentoEstouro.avisar => 'Você não terá dinheiro para pagar essa fatura.',
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(impacto.estoura ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
              color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  impacto.estoura
                      ? 'Fica ${Moeda.formatar(impacto.acimaDoSaldo)} acima do seu saldo'
                      : 'Depois dessa compra sobra ${Moeda.formatar(impacto.sobra)}',
                  style: tema.textTheme.titleSmall?.copyWith(
                    color: cor,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (impacto.estoura)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(aviso, style: tema.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
