import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/orcamento.dart';
import 'package:lastro/domain/resumo_mes.dart';

void main() {
  group('nível do orçamento (CLAUDE.md 4.7)', () {
    test('verde abaixo de 80%', () {
      expect(nivelOrcamento(0, 100000), NivelOrcamento.verde);
      expect(nivelOrcamento(79999, 100000), NivelOrcamento.verde);
    });

    test('amarelo de 80% a 100% (inclusive os dois extremos)', () {
      expect(nivelOrcamento(80000, 100000), NivelOrcamento.amarelo);
      expect(nivelOrcamento(95000, 100000), NivelOrcamento.amarelo);
      expect(nivelOrcamento(100000, 100000), NivelOrcamento.amarelo);
    });

    test('vermelho acima de 100%', () {
      expect(nivelOrcamento(100001, 100000), NivelOrcamento.vermelho);
      expect(nivelOrcamento(250000, 100000), NivelOrcamento.vermelho);
    });

    test('limite zero: qualquer gasto estoura', () {
      expect(nivelOrcamento(0, 0), NivelOrcamento.verde);
      expect(nivelOrcamento(1, 0), NivelOrcamento.vermelho);
    });

    test('percentual usado', () {
      expect(percentualUsado(50000, 100000), 0.5);
      expect(percentualUsado(150000, 100000), 1.5);
      expect(percentualUsado(0, 0), 0);
    });
  });

  group('gastos acumulados com subcategorias', () {
    // 1 = Alimentação (pai), 2 = Mercado, 3 = Delivery (filhas), 4 = Lazer
    const pai = <int, int?>{1: null, 2: 1, 3: 1, 4: null};

    test('filhas também contam no pai', () {
      final m = gastosAcumulados(const [
        GastoSimples(2, 10000),
        GastoSimples(3, 5000),
        GastoSimples(1, 2000),
        GastoSimples(4, 700),
        GastoSimples(null, 999), // sem categoria: fora
      ], categoriaPai: pai);
      expect(m[2], 10000);
      expect(m[3], 5000);
      expect(m[1], 17000);
      expect(m[4], 700);
      expect(m.containsKey(0), isFalse);
    });
  });

  group('montar orçamento', () {
    test('com limite primeiro (mais estourada no topo), depois por gasto', () {
      final l = montarOrcamento(
        categorias: [1, 2, 3, 4],
        limites: {1: 100000, 3: 50000},
        gastos: {1: 80000, 2: 300, 3: 60000, 4: 900},
      );
      expect(l.map((e) => e.categoriaId), [3, 1, 4, 2]);
      expect(l[0].nivel, NivelOrcamento.vermelho);
      expect(l[1].nivel, NivelOrcamento.amarelo);
      expect(l[2].nivel, isNull);
      expect(l[0].restante, -10000);
      expect(l[1].restante, 20000);
    });

    test('categoria sem gasto aparece com zero', () {
      final l = montarOrcamento(categorias: [1], limites: {1: 100}, gastos: {});
      expect(l.single.gasto, 0);
      expect(l.single.nivel, NivelOrcamento.verde);
    });
  });

  test('copiar do mês anterior não sobrescreve o que já existe', () {
    final r = limitesACopiar(
      mesAnterior: {1: 100, 2: 200, 3: 300},
      mesAtual: {2: 999},
    );
    expect(r, {1: 100, 3: 300});
  });
}
