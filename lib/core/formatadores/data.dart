import 'package:intl/intl.dart';

/// Datas no padrão brasileiro. Requer `initializeDateFormatting('pt_BR')`.
abstract final class FormatoData {
  static final _dia = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _mesAno = DateFormat("MMMM 'de' yyyy", 'pt_BR');

  /// `2026-03-05` → `05/03/2026`
  static String dia(DateTime data) => _dia.format(data);

  /// `2026-03-05` → `Março de 2026`
  static String mesAno(DateTime data) {
    final texto = _mesAno.format(data);
    return texto[0].toUpperCase() + texto.substring(1);
  }
}
