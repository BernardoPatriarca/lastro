import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/parcelas.dart';

void main() {
  group('divisão em parcelas (CLAUDE.md 5.4)', () {
    test('R\$ 100,00 em 3x → 33,34 + 33,33 + 33,33', () {
      expect(dividirEmParcelas(10000, 3), [3334, 3333, 3333]);
    });

    test('divisão exata não tem resto', () {
      expect(dividirEmParcelas(9000, 3), [3000, 3000, 3000]);
    });

    test('a soma sempre fecha o total', () {
      for (final total in [1, 99, 10001, 123457]) {
        for (var n = 1; n <= 12; n++) {
          final p = dividirEmParcelas(total, n);
          expect(p.length, n);
          expect(p.reduce((a, b) => a + b), total);
          // só a primeira pode ser maior, no máximo n-1 centavos
          expect(p.first - p.last, lessThan(n));
        }
      }
    });

    test('à vista devolve o total', () {
      expect(dividirEmParcelas(5555, 1), [5555]);
    });
  });

  group('descrição da parcela', () {
    test('formata (N/total) e à vista sem sufixo', () {
      expect(descricaoDaParcela('Geladeira', 2, 10), 'Geladeira (2/10)');
      expect(descricaoDaParcela('Café', 1, 1), 'Café');
    });

    test('descricaoBase tira o sufixo', () {
      expect(descricaoBase('Geladeira (2/10)'), 'Geladeira');
      expect(descricaoBase('Sem sufixo'), 'Sem sufixo');
      expect(descricaoBase('Loja (promo) (3/12)'), 'Loja (promo)');
    });
  });

  group('geração de parcelas no cartão', () {
    test('parcela N vai para a fatura N-1 ciclos depois', () {
      final p = gerarParcelas(
        descricao: 'Notebook',
        valorTotal: 10000,
        numeroParcelas: 3,
        dataCompra: DateTime(2026, 3, 5),
        diaFechamento: 10,
        diaVencimento: 17,
      );
      expect(p.map((e) => e.valor), [3334, 3333, 3333]);
      expect(p.map((e) => e.ciclo.competencia), [
        const Competencia(2026, 3),
        const Competencia(2026, 4),
        const Competencia(2026, 5),
      ]);
      expect(p.map((e) => e.descricao),
          ['Notebook (1/3)', 'Notebook (2/3)', 'Notebook (3/3)']);
      expect(p.map((e) => e.data), [
        DateTime(2026, 3, 5),
        DateTime(2026, 4, 5),
        DateTime(2026, 5, 5),
      ]);
      expect(p[2].ciclo.dataVencimento, DateTime(2026, 5, 17));
    });

    test('compra depois do fechamento começa na fatura seguinte', () {
      final p = gerarParcelas(
        descricao: 'TV',
        valorTotal: 6000,
        numeroParcelas: 2,
        dataCompra: DateTime(2026, 3, 20),
        diaFechamento: 10,
        diaVencimento: 17,
      );
      expect(p.first.ciclo.competencia, const Competencia(2026, 4));
      expect(p.last.ciclo.competencia, const Competencia(2026, 5));
    });

    test('atravessa a virada de ano e meses curtos', () {
      final p = gerarParcelas(
        descricao: 'Sofá',
        valorTotal: 12000,
        numeroParcelas: 4,
        dataCompra: DateTime(2026, 11, 30),
        diaFechamento: 31,
        diaVencimento: 10,
      );
      // datas: 30/11, 30/12, 30/01, 28/02
      expect(p.map((e) => e.data), [
        DateTime(2026, 11, 30),
        DateTime(2026, 12, 30),
        DateTime(2027, 1, 30),
        DateTime(2027, 2, 28),
      ]);
      // Em novembro o fechamento "31" vira dia 30: a compra de 30/11 já cai
      // na fatura que fecha em dezembro.
      expect(p.map((e) => e.ciclo.competencia), [
        const Competencia(2026, 12),
        const Competencia(2027, 1),
        const Competencia(2027, 2),
        const Competencia(2027, 3),
      ]);
      expect(p[2].ciclo.dataFechamento, DateTime(2027, 2, 28));
      expect(p.last.ciclo.dataFechamento, DateTime(2027, 3, 31));
    });

    test('à vista tem uma parcela sem sufixo', () {
      final p = gerarParcelas(
        descricao: 'Almoço',
        valorTotal: 4590,
        numeroParcelas: 1,
        dataCompra: DateTime(2026, 3, 5),
        diaFechamento: 10,
        diaVencimento: 17,
      );
      expect(p.length, 1);
      expect(p.single.descricao, 'Almoço');
      expect(p.single.valor, 4590);
    });
  });
}
