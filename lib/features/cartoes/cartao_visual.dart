import 'package:flutter/material.dart';

import '../../core/formatadores/data.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/derivados.dart';

/// Cartão "de verdade": gradiente na cor do cartão, fatura atual, limite usado.
class CartaoVisual extends StatelessWidget {
  const CartaoVisual({super.key, required this.resumo, this.onTap});

  final ResumoCartao resumo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final base = Color(resumo.cartao.cor);
    final escuro = Color.lerp(base, Colors.black, 0.45)!;
    const texto = Colors.white;
    final suave = Colors.white.withValues(alpha: 0.78);

    return Opacity(
      opacity: resumo.cartao.ativo ? 1 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [base, escuro],
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, color: texto),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            resumo.cartao.nome,
                            style: tema.textTheme.titleMedium?.copyWith(
                              color: texto,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!resumo.cartao.ativo)
                          Text('inativo', style: TextStyle(color: suave)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Fatura atual',
                      style: TextStyle(color: suave, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    ValorMonetario(
                      resumo.totalFaturaAtual,
                      estilo: tema.textTheme.headlineMedium?.copyWith(
                        color: texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vence em ${FormatoData.dia(resumo.ciclo.dataVencimento)}',
                      style: TextStyle(color: suave, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: resumo.percentualUsado,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        color: resumo.percentualUsado > 0.9
                            ? const Color(0xFFFCA5A5)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Duplo('Usado', resumo.usado, suave),
                        _Duplo(
                          'Disponível',
                          resumo.disponivel,
                          suave,
                          alinhaDireita: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Duplo extends StatelessWidget {
  const _Duplo(this.rotulo, this.valor, this.cor, {this.alinhaDireita = false});
  final String rotulo;
  final int valor;
  final Color cor;
  final bool alinhaDireita;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alinhaDireita
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: TextStyle(color: cor, fontSize: 11)),
        ValorMonetario(
          valor,
          estilo: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
