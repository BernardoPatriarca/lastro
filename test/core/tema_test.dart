import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/core/theme/cores_lastro.dart';
import 'package:lastro/core/theme/tema.dart';

void main() {
  test('tema claro usa as cores da marca', () {
    final tema = TemaLastro.claro;
    expect(tema.useMaterial3, isTrue);
    expect(tema.colorScheme.primary, PaletaLastro.primaria);
    expect(tema.colorScheme.secondary, PaletaLastro.secundariaClaro);
    expect(tema.scaffoldBackgroundColor, PaletaLastro.fundoClaro);
    expect(tema.extension<CoresLastro>(), isNotNull);
  });

  test('tema escuro usa as cores da marca', () {
    final tema = TemaLastro.escuro;
    expect(tema.colorScheme.primary, PaletaLastro.primaria);
    expect(tema.colorScheme.secondary, PaletaLastro.secundariaEscuro);
    expect(tema.scaffoldBackgroundColor, PaletaLastro.fundoEscuro);
    expect(tema.colorScheme.brightness, Brightness.dark);
  });

  test('a fonte do app é a Inter embutida', () {
    expect(TemaLastro.claro.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(TemaLastro.escuro.textTheme.bodyMedium?.fontFamily, 'Inter');
  });
}
