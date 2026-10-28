import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../formatadores/moeda.dart';
import '../theme/cores_lastro.dart';

/// Exibe um valor em R$ com algarismos tabulares (colunas alinhadas).
///
/// Respeita a configuração "ocultar valores" (`R$ •••`) sozinho.
/// Com [colorirPorSinal], positivo fica verde e negativo vermelho; o sinal
/// impresso garante que a cor não é a única informação.
class ValorMonetario extends ConsumerWidget {
  const ValorMonetario(
    this.centavos, {
    super.key,
    this.estilo,
    this.colorirPorSinal = false,
    this.mostrarMais = false,
    this.textAlign,
  });

  final int centavos;
  final TextStyle? estilo;
  final bool colorirPorSinal;
  final bool mostrarMais;
  final TextAlign? textAlign;

  /// Estilo com números tabulares, para usar também fora deste widget.
  static TextStyle tabular(TextStyle? base) => (base ?? const TextStyle())
      .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocultar = ref.watch(ajustesProvider.select((a) => a.ocultarValores));
    var estiloFinal = tabular(estilo ?? Theme.of(context).textTheme.bodyLarge);
    if (colorirPorSinal && !ocultar && centavos != 0) {
      final cores = context.coresLastro;
      estiloFinal = estiloFinal.copyWith(
        color: centavos > 0 ? cores.positivo : cores.negativo,
      );
    }
    final texto = mostrarMais
        ? Moeda.comSinal(centavos, ocultar: ocultar)
        : Moeda.formatar(centavos, ocultar: ocultar);
    return Text(texto, style: estiloFinal, textAlign: textAlign);
  }
}
