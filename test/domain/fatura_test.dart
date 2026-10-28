import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/fatura.dart';

CicloFatura compra(DateTime d, {int fecha = 10, int vence = 17}) =>
    cicloDaCompra(d, diaFechamento: fecha, diaVencimento: vence);

void main() {
  group('fatura da compra (CLAUDE.md 5.3)', () {
    test('antes do fechamento entra na fatura do mês', () {
      final c = compra(DateTime(2026, 3, 9));
      expect(c.competencia, const Competencia(2026, 3));
      expect(c.dataFechamento, DateTime(2026, 3, 10));
      expect(c.dataVencimento, DateTime(2026, 3, 17));
    });

    test('no dia do fechamento já entra na fatura seguinte', () {
      final c = compra(DateTime(2026, 3, 10));
      expect(c.competencia, const Competencia(2026, 4));
      expect(c.dataFechamento, DateTime(2026, 4, 10));
    });

    test('depois do fechamento entra na fatura seguinte', () {
      final c = compra(DateTime(2026, 3, 25));
      expect(c.competencia, const Competencia(2026, 4));
    });

    test('virada de ano', () {
      final c = compra(DateTime(2026, 12, 20));
      expect(c.competencia, const Competencia(2027, 1));
      expect(c.dataFechamento, DateTime(2027, 1, 10));
    });

    test('vencimento menor que o fechamento cai no mês seguinte', () {
      final c = compra(DateTime(2026, 3, 5), fecha: 25, vence: 5);
      expect(c.competencia, const Competencia(2026, 3));
      expect(c.dataFechamento, DateTime(2026, 3, 25));
      expect(c.dataVencimento, DateTime(2026, 4, 5));
    });

    test('vencimento menor que o fechamento na virada de ano', () {
      final c = compra(DateTime(2026, 12, 1), fecha: 25, vence: 5);
      expect(c.dataVencimento, DateTime(2027, 1, 5));
    });

    test('fechamento dia 31 em fevereiro vai para o último dia do mês', () {
      final c = compra(DateTime(2026, 2, 10), fecha: 31, vence: 31);
      expect(c.competencia, const Competencia(2026, 2));
      expect(c.dataFechamento, DateTime(2026, 2, 28));
      expect(c.dataVencimento, DateTime(2026, 2, 28));
    });

    test('fechamento dia 31 em fevereiro de ano bissexto', () {
      final c = compra(DateTime(2028, 2, 10), fecha: 31, vence: 31);
      expect(c.dataFechamento, DateTime(2028, 2, 29));
    });

    test('compra no último dia de fevereiro com fechamento 31 já é da próxima', () {
      // o fechamento "31" vira 28 em fevereiro; compra no dia 28 = fechamento
      final c = compra(DateTime(2026, 2, 28), fecha: 31, vence: 10);
      expect(c.competencia, const Competencia(2026, 3));
      expect(c.dataFechamento, DateTime(2026, 3, 31));
    });
  });

  group('status da fatura', () {
    test('aberta antes do fechamento, fechada a partir dele', () {
      final fecha = DateTime(2026, 3, 10);
      expect(statusEfetivo(StatusFatura.aberta, fecha, DateTime(2026, 3, 9)),
          StatusFatura.aberta);
      expect(statusEfetivo(StatusFatura.aberta, fecha, DateTime(2026, 3, 10)),
          StatusFatura.fechada);
      expect(statusEfetivo(StatusFatura.aberta, fecha, DateTime(2026, 5, 1)),
          StatusFatura.fechada);
    });

    test('paga continua paga', () {
      expect(
        statusEfetivo(StatusFatura.paga, DateTime(2026, 3, 10), DateTime(2026, 1, 1)),
        StatusFatura.paga,
      );
    });
  });
}
