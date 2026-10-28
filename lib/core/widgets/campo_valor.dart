import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatadores/moeda.dart';

/// Formata a digitação como centavos: digitar `1234` mostra `12,34`.
class FormatadorCentavos extends TextInputFormatter {
  const FormatadorCentavos({this.maxDigitos = 11});
  final int maxDigitos;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue antigo, TextEditingValue novo) {
    var digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > maxDigitos) digitos = digitos.substring(0, maxDigitos);
    final centavos = int.tryParse(digitos) ?? 0;
    final texto = digitos.isEmpty ? '' : _formatar(centavos);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  static String _formatar(int centavos) =>
      Moeda.formatar(centavos).replaceFirst('R\$ ', '');
}

/// Controlador que expõe o valor digitado em centavos.
class ControladorValor extends TextEditingController {
  ControladorValor({int centavos = 0})
      : super(text: centavos == 0 ? '' : _inicial(centavos));

  static String _inicial(int c) => Moeda.formatar(c).replaceFirst('R\$ ', '');

  int get centavos => Moeda.interpretar(text) ?? 0;

  set centavos(int v) => text = v == 0 ? '' : _inicial(v);
}

/// Campo de valor em R$, com teclado numérico e entrada em centavos.
class CampoValor extends StatelessWidget {
  const CampoValor({
    super.key,
    required this.controller,
    this.rotulo = 'Valor',
    this.autofocus = false,
    this.grande = false,
    this.validator,
    this.onChanged,
    this.cor,
  });

  final ControladorValor controller;
  final String rotulo;
  final bool autofocus;
  final bool grande;
  final String? Function(String?)? validator;
  final ValueChanged<int>? onChanged;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estilo = grande
        ? tema.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cor,
            fontFeatures: const [FontFeature.tabularFigures()],
          )
        : tema.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          );
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: const [FormatadorCentavos()],
      textAlign: grande ? TextAlign.center : TextAlign.start,
      style: estilo,
      validator: validator,
      onChanged: onChanged == null ? null : (_) => onChanged!(controller.centavos),
      decoration: InputDecoration(
        labelText: grande ? null : rotulo,
        hintText: '0,00',
        prefixText: 'R\$ ',
        prefixStyle: estilo?.copyWith(
          color: cor ?? tema.colorScheme.onSurfaceVariant,
        ),
        filled: !grande,
        border: grande ? InputBorder.none : null,
        enabledBorder: grande ? InputBorder.none : null,
        focusedBorder: grande ? InputBorder.none : null,
      ),
    );
  }
}
