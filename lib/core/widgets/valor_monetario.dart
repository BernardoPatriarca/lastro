import 'package:flutter/material.dart';

import '../formatadores/moeda.dart';
import '../theme/cores_lastro.dart';

/// Exibe um valor em R$ com algarismos tabulares (colunas alinhadas).
///
/// Com [colorirPorSinal], positivo fica verde (com `+`) e negativo vermelho
/// (com `-`): o sinal impresso garante que a cor não é a única informação.
class ValorMonetario extends StatelessWidget {
  const ValorMonetario(
    this.centavos, {
    super.key,
    this.estilo,
    this.colorirPorSinal = false,
    this.mostrarMais = false,
    this.ocultar = false,
    this.textAlign,
  });

  final int centavos;
  final TextStyle? estilo;
  final bool colorirPorSinal;
  final bool mostrarMais;
  final bool ocultar;
  final TextAlign? textAlign;

  /// Estilo com números tabulares, para usar também fora deste widget.
  static TextStyle tabular(TextStyle? base) => (base ?? const TextStyle())
      .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
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
