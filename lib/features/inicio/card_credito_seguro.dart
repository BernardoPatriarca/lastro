import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatadores/moeda.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/derivados.dart';
import '../../domain/credito_seguro.dart';
import '../../domain/enums.dart';

/// Card de destaque "Pode gastar no crédito" (regra 5.1): valor, barra do
/// quanto do saldo já está comprometido e aviso quando fica negativo.
class CardCreditoSeguro extends ConsumerWidget {
  const CardCreditoSeguro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(creditoSeguroProvider);
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final negativo = r.negativo;

    final cores = negativo
        ? const [Color(0xFFB91C1C), Color(0xFF7F1D1D)]
        : [esquema.primary, esquema.primaryContainer];
    const texto = Colors.white;
    final suave = Colors.white.withValues(alpha: 0.82);

    final raio = BorderRadius.circular(28);
    return Container(
      decoration: BoxDecoration(
        borderRadius: raio,
        boxShadow: [
          BoxShadow(
            color: cores.first.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: raio,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: cores,
            ),
          ),
          child: InkWell(
            onTap: () => _detalhes(context, r),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        negativo
                            ? Icons.warning_amber_rounded
                            : Icons.shield_outlined,
                        size: 20,
                        color: texto,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pode gastar no crédito',
                          style: tema.textTheme.titleSmall?.copyWith(
                            color: texto,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.info_outline_rounded, size: 18, color: suave),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: r.podeGastar, end: r.podeGastar),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, valor, _) => ValorMonetario(
                      valor,
                      estilo: tema.textTheme.displaySmall?.copyWith(
                        color: texto,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (negativo) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Você já passou do que tem em conta. Evite novas compras no crédito.',
                      style: tema.textTheme.bodySmall?.copyWith(color: texto),
                    ),
                  ],
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: r.percentualComprometido),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        color: negativo
                            ? const Color(0xFFFCA5A5)
                            : esquema.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.saldoContas <= 0 &&
                            (r.comprometidoCartao + r.fixosDescontados) == 0
                        ? 'Cadastre uma conta e informe o saldo para calcular.'
                        : '${(r.percentualComprometido * 100).round()}% do saldo já comprometido',
                    style: tema.textTheme.bodySmall?.copyWith(color: suave),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Mini('Em conta', r.saldoContas, suave),
                      _Mini('No cartão', r.comprometidoCartao, suave),
                      _Mini('Contas fixas', r.fixosDescontados, suave),
                    ],
                  ),
                  if (r.modo == ModoParcelados.parcela &&
                      r.comprometidoProximasFaturas > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Comprometido nas próximas faturas: ${Moeda.formatar(r.comprometidoProximasFaturas)}',
                      style: tema.textTheme.bodySmall?.copyWith(color: suave),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _detalhes(BuildContext context, ResultadoCreditoSeguro r) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _DetalhesCredito(resultado: r),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini(this.rotulo, this.valor, this.cor);
  final String rotulo;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: TextStyle(color: cor, fontSize: 11)),
          const SizedBox(height: 2),
          ValorMonetario(
            valor,
            estilo: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetalhesCredito extends StatelessWidget {
  const _DetalhesCredito({required this.resultado});
  final ResultadoCreditoSeguro resultado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final r = resultado;
    Widget linha(
      String rotulo,
      int valor, {
      bool menos = false,
      bool forte = false,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              menos ? '− $rotulo' : rotulo,
              style: forte
                  ? tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )
                  : tema.textTheme.bodyMedium,
            ),
          ),
          ValorMonetario(
            valor,
            colorirPorSinal: forte,
            estilo: forte
                ? tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  )
                : tema.textTheme.bodyMedium,
          ),
        ],
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como é calculado',
              style: tema.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Toda compra no crédito precisa já ter o dinheiro em conta para '
              'pagá-la, nunca o salário que ainda vai entrar.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            linha('Saldo das contas no crédito seguro', r.saldoContas),
            linha(
              r.modo == ModoParcelados.rigido
                  ? 'Tudo que falta pagar no cartão (inclui parcelas futuras)'
                  : 'Faturas abertas e fechadas não pagas',
              r.comprometidoCartao,
              menos: true,
            ),
            linha('Contas fixas pendentes', r.fixosDescontados, menos: true),
            const Divider(height: 20),
            linha('Pode gastar no crédito', r.podeGastar, forte: true),
            if (r.modo == ModoParcelados.parcela) ...[
              const SizedBox(height: 8),
              Text(
                'Comprometido nas próximas faturas (não descontado): '
                '${Moeda.formatar(r.comprometidoProximasFaturas)}',
                style: tema.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Ajuste o modo em Mais › Configurações › Crédito seguro.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
