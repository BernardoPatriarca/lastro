import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/core/formatadores/moeda.dart';

void main() {
  group('Moeda.formatar', () {
    test('formata centavos no padrão brasileiro', () {
      expect(Moeda.formatar(123456), 'R\$ 1.234,56');
      expect(Moeda.formatar(5), 'R\$ 0,05');
      expect(Moeda.formatar(0), 'R\$ 0,00');
      expect(Moeda.formatar(100000000), 'R\$ 1.000.000,00');
    });

    test('negativos levam o sinal antes do símbolo', () {
      expect(Moeda.formatar(-5000), '-R\$ 50,00');
      expect(Moeda.formatar(-5), '-R\$ 0,05');
    });

    test('ocultar esconde o valor', () {
      expect(Moeda.formatar(123456, ocultar: true), 'R\$ •••');
      expect(Moeda.comSinal(123456, ocultar: true), 'R\$ •••');
    });

    test('comSinal põe + só nos positivos', () {
      expect(Moeda.comSinal(1000), '+R\$ 10,00');
      expect(Moeda.comSinal(-1000), '-R\$ 10,00');
      expect(Moeda.comSinal(0), 'R\$ 0,00');
    });
  });

  group('Moeda.interpretar', () {
    test('lê o que o usuário digita', () {
      expect(Moeda.interpretar('1.234,56'), 123456);
      expect(Moeda.interpretar('R\$ 12,5'), 1250);
      expect(Moeda.interpretar('12'), 1200);
      expect(Moeda.interpretar(',99'), 99);
    });

    test('rejeita entradas inválidas', () {
      expect(Moeda.interpretar(''), isNull);
      expect(Moeda.interpretar('abc'), isNull);
      expect(Moeda.interpretar('1,234'), isNull);
      expect(Moeda.interpretar('1,2,3'), isNull);
    });

    test('ida e volta não perde centavos', () {
      for (final v in [1, 99, 100, 101, 123456789]) {
        final texto = Moeda.formatar(v).replaceFirst('R\$ ', '');
        expect(Moeda.interpretar(texto), v);
      }
    });
  });
}
