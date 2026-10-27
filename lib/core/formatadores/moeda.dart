import 'package:intl/intl.dart';

/// Formatação de dinheiro. Todo valor no app é `int` em centavos (nunca double).
abstract final class Moeda {
  static const mascara = 'R\$ •••';

  /// Só formata a parte inteira (reais) com separador de milhar; os centavos
  /// são montados à mão para nunca passar por `double`. Os símbolos numéricos
  /// do pt_BR já vêm no intl, sem precisar de `initializeDateFormatting`.
  static final _inteiros = NumberFormat.decimalPattern('pt_BR');

  /// `123456` → `R$ 1.234,56`; negativo → `-R$ 1.234,56`.
  /// Com [ocultar] devolve `R$ •••` (modo "ocultar valores").
  static String formatar(int centavos, {bool ocultar = false}) {
    if (ocultar) return mascara;
    final negativo = centavos < 0;
    final abs = centavos.abs();
    final reais = _inteiros.format(abs ~/ 100);
    final resto = (abs % 100).toString().padLeft(2, '0');
    return '${negativo ? '-' : ''}R\$ $reais,$resto';
  }

  /// Igual a [formatar], mas com `+` explícito nos positivos (ganhos).
  static String comSinal(int centavos, {bool ocultar = false}) {
    final texto = formatar(centavos, ocultar: ocultar);
    return centavos > 0 && !ocultar ? '+$texto' : texto;
  }

  /// Lê o que o usuário digitou (`1.234,56`, `12,5`, `12`) como centavos.
  /// Devolve `null` se não for um valor válido. Sem passar por double.
  static int? interpretar(String texto) {
    final limpo = texto.replaceAll(RegExp(r'[R\$\s.]'), '');
    if (limpo.isEmpty) return null;
    final partes = limpo.split(',');
    if (partes.length > 2) return null;
    final reais = partes[0];
    var centavos = partes.length == 2 ? partes[1] : '';
    if (centavos.length > 2) return null;
    centavos = centavos.padRight(2, '0');
    if (!RegExp(r'^\d+$').hasMatch(reais.isEmpty ? '0' : reais) ||
        !RegExp(r'^\d{2}$').hasMatch(centavos)) {
      return null;
    }
    return int.parse(reais.isEmpty ? '0' : reais) * 100 + int.parse(centavos);
  }
}
