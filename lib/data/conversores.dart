import 'package:drift/drift.dart';

/// Grava datas sem hora como inteiro `aaaammdd` (ex.: 20260305).
///
/// Vantagens: não sofre com fuso/horário, ordena e filtra por intervalo
/// direto no SQL, e é legível ao inspecionar o banco.
class ConversorData extends TypeConverter<DateTime, int> {
  const ConversorData();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime(fromDb ~/ 10000, (fromDb ~/ 100) % 100, fromDb % 100);

  @override
  int toSql(DateTime value) => value.year * 10000 + value.month * 100 + value.day;
}
