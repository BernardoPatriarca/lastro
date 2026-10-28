import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/resumo_mes.dart';

void main() {
  group('gastos por categoria', () {
    // 1 = Alimentação (pai) com filhas 2 = Mercado e 3 = Delivery; 4 = Lazer
    const pai = <int, int?>{1: null, 2: 1, 3: 1, 4: null};

    test('agrupa subcategorias no pai e ordena do maior para o menor', () {
      final r = gastosPorCategoria(
        const [
          GastoSimples(2, 10000),
          GastoSimples(3, 5000),
          GastoSimples(4, 12000),
          GastoSimples(1, 1000),
        ],
        categoriaPai: pai,
      );
      expect(r.map((f) => (f.categoriaId, f.valor)), [(1, 16000), (4, 12000)]);
    });

    test('sem agrupar, mantém cada subcategoria', () {
      final r = gastosPorCategoria(
        const [GastoSimples(2, 10000), GastoSimples(3, 5000)],
        categoriaPai: pai,
        agruparNoPai: false,
      );
      expect(r.map((f) => f.categoriaId), [2, 3]);
    });

    test('gasto sem categoria vira uma fatia de id nulo', () {
      final r = gastosPorCategoria(
        const [GastoSimples(null, 700), GastoSimples(null, 300), GastoSimples(4, 100)],
        categoriaPai: pai,
      );
      expect(r.first.categoriaId, isNull);
      expect(r.first.valor, 1000);
    });

    test('lista vazia gera nada', () {
      expect(gastosPorCategoria(const []), isEmpty);
    });

    test('limitarFatias junta o resto em "Outras" sem perder valor', () {
      final fatias = [
        for (var i = 1; i <= 8; i++) FatiaCategoria(i, (9 - i) * 100),
      ];
      final r = limitarFatias(fatias, 5);
      expect(r.length, 6);
      expect(r.last.categoriaId, idOutras);
      expect(r.last.valor, 300 + 200 + 100);
      expect(r.fold<int>(0, (s, f) => s + f.valor),
          fatias.fold<int>(0, (s, f) => s + f.valor));
    });

    test('limitarFatias não mexe quando cabe', () {
      final f = [const FatiaCategoria(1, 1), const FatiaCategoria(2, 2)];
      expect(limitarFatias(f, 5), f);
    });
  });

  group('contas do mês', () {
    ContaDoMes c(int valor, {required bool paga, bool fatura = false}) => ContaDoMes(
          descricao: 'x',
          valor: valor,
          vencimento: DateTime(2026, 3, 10),
          paga: paga,
          ehFatura: fatura,
        );

    test('separa pago e falta pagar', () {
      final r = resumirContasDoMes([
        c(30000, paga: true),
        c(20000, paga: false, fatura: true),
        c(10000, paga: false),
      ]);
      expect(r.pago, 30000);
      expect(r.falta, 30000);
      expect(r.total, 60000);
      expect(r.percentualPago, closeTo(0.5, 1e-9));
    });

    test('mês sem contas', () {
      final r = resumirContasDoMes(const []);
      expect(r.total, 0);
      expect(r.percentualPago, 0);
    });
  });
}
