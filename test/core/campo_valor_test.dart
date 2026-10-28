import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/core/widgets/campo_valor.dart';

void main() {
  const f = FormatadorCentavos();
  String digitar(String texto) => f
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: texto))
      .text;

  test('digitar números preenche da direita para a esquerda (centavos)', () {
    expect(digitar('1'), '0,01');
    expect(digitar('12'), '0,12');
    expect(digitar('123'), '1,23');
    expect(digitar('123456'), '1.234,56');
    expect(digitar(''), '');
  });

  test('ignora caracteres que não são dígitos', () {
    expect(digitar('1a2b'), '0,12');
  });

  test('controlador devolve centavos', () {
    final c = ControladorValor(centavos: 123456);
    expect(c.text, '1.234,56');
    expect(c.centavos, 123456);
    c.centavos = 0;
    expect(c.text, '');
    expect(c.centavos, 0);
  });
}
