import 'package:flutter/material.dart';

/// Paleta oficial do Lastro (ver lastro-brand/LEIAME.md).
abstract final class PaletaLastro {
  static const primaria = Color(0xFF0F766E);
  static const primariaEscura = Color(0xFF0A4F4A);
  static const secundariaClaro = Color(0xFF14B8A6);
  static const secundariaEscuro = Color(0xFF5EEAD4);

  static const alerta = Color(0xFFF59E0B);
  static const positivo = Color(0xFF16A34A);
  static const negativo = Color(0xFFDC2626);

  static const fundoEscuro = Color(0xFF0B1215);
  static const fundoClaro = Color(0xFFF6F8F8);
}

/// Cores semânticas de dinheiro, acessíveis via `Theme.of(context).extension`.
///
/// No tema escuro o vermelho/verde são levemente mais claros que o da paleta
/// para manter contraste de texto sobre o fundo `#0B1215`.
/// Valores nunca dependem só da cor: sempre vêm com sinal ou texto.
@immutable
class CoresLastro extends ThemeExtension<CoresLastro> {
  const CoresLastro({
    required this.positivo,
    required this.negativo,
    required this.alerta,
  });

  final Color positivo;
  final Color negativo;
  final Color alerta;

  static const claro = CoresLastro(
    positivo: PaletaLastro.positivo,
    negativo: PaletaLastro.negativo,
    alerta: Color(0xFFB45309), // âmbar escuro: F59E0B não tem contraste sobre claro
  );

  static const escuro = CoresLastro(
    positivo: Color(0xFF22C55E),
    negativo: Color(0xFFF87171),
    alerta: PaletaLastro.alerta,
  );

  @override
  CoresLastro copyWith({Color? positivo, Color? negativo, Color? alerta}) =>
      CoresLastro(
        positivo: positivo ?? this.positivo,
        negativo: negativo ?? this.negativo,
        alerta: alerta ?? this.alerta,
      );

  @override
  CoresLastro lerp(ThemeExtension<CoresLastro>? other, double t) {
    if (other is! CoresLastro) return this;
    return CoresLastro(
      positivo: Color.lerp(positivo, other.positivo, t)!,
      negativo: Color.lerp(negativo, other.negativo, t)!,
      alerta: Color.lerp(alerta, other.alerta, t)!,
    );
  }
}

extension CoresLastroContexto on BuildContext {
  CoresLastro get coresLastro => Theme.of(this).extension<CoresLastro>()!;
}
