import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/relatorios.dart';

LancRelatorio gasto(int valor, DateTime d, {int? cat, bool fixo = false}) =>
    LancRelatorio(data: d, tipo: TipoLancamento.gasto, valor: valor, categoriaId: cat, fixo: fixo);
LancRelatorio ganho(int valor, DateTime d) =>
    LancRelatorio(data: d, tipo: TipoLancamento.ganho, valor: valor);
LancRelatorio aporte(int valor, DateTime d) =>
    LancRelatorio(data: d, tipo: TipoLancamento.aporte, valor: valor);

void main() {
  const fim = Competencia(2026, 3);

  group('evolução mensal', () {
    test('ganhos, gastos e investido por mês, com meses vazios zerados', () {
      final p = evolucaoMensal([
        ganho(500000, DateTime(2026, 3, 5)),
        gasto(120000, DateTime(2026, 3, 6)),
        aporte(50000, DateTime(2026, 3, 7)),
        gasto(80000, DateTime(2026, 1, 10)),
        ganho(450000, DateTime(2026, 1, 5)),
        LancRelatorio(data: DateTime(2026, 3, 8), tipo: TipoLancamento.transferencia, valor: 99999),
        gasto(1, DateTime(2025, 1, 1)), // fora da janela
      ], fim: fim, meses: 4);
      expect(p.map((e) => e.competencia.chave), ['2025-12', '2026-01', '2026-02', '2026-03']);
      expect(p[0].gastos, 0);
      expect(p[1].ganhos, 450000);
      expect(p[1].gastos, 80000);
      expect(p[2].ganhos + p[2].gastos + p[2].investido, 0);
      expect(p[3].ganhos, 500000);
      expect(p[3].gastos, 120000);
      expect(p[3].investido, 50000);
      expect(p[3].saldo, 380000); // transferência não entra
    });
  });

  group('comparativo por categoria', () {
    test('compara com o mês anterior, incluindo categorias novas e sumidas', () {
      final lancs = [
        gasto(60000, DateTime(2026, 3, 5), cat: 1),
        gasto(30000, DateTime(2026, 3, 6), cat: 2),
        gasto(10000, DateTime(2026, 3, 7), cat: 3), // nova
        gasto(40000, DateTime(2026, 2, 5), cat: 1),
        gasto(30000, DateTime(2026, 2, 6), cat: 2),
        gasto(20000, DateTime(2026, 2, 7), cat: 4), // sumiu
      ];
      final r = comparativoPorCategoria(
        atual: gastosPorCategoriaNoMes(lancs, const Competencia(2026, 3)),
        anterior: gastosPorCategoriaNoMes(lancs, const Competencia(2026, 2)),
      );
      expect(r.map((c) => c.categoriaId), [1, 2, 3, 4]);
      expect(r[0].variacaoPercentual, 50); // 40k -> 60k
      expect(r[0].diferenca, 20000);
      expect(r[1].variacaoPercentual, 0);
      expect(r[2].variacaoPercentual, isNull);
      expect(r[2].ehNova, isTrue);
      expect(r[3].atual, 0);
      expect(r[3].variacaoPercentual, -100);
    });

    test('só considera gastos do mês pedido', () {
      final m = gastosPorCategoriaNoMes([
        gasto(100, DateTime(2026, 3, 1), cat: 1),
        gasto(200, DateTime(2026, 4, 1), cat: 1),
        ganho(999, DateTime(2026, 3, 1)),
        gasto(50, DateTime(2026, 3, 9)),
      ], const Competencia(2026, 3));
      expect(m, {1: 100, null: 50});
    });
  });

  group('média mensal por categoria', () {
    test('divide pelo número de meses da janela (meses sem gasto contam zero)', () {
      final r = mediaMensalPorCategoria([
        gasto(60000, DateTime(2026, 1, 5), cat: 1),
        gasto(30000, DateTime(2026, 3, 5), cat: 1),
        gasto(12000, DateTime(2026, 2, 5), cat: 2),
        gasto(999999, DateTime(2025, 6, 5), cat: 2), // fora da janela
      ], fim: fim, meses: 3);
      expect(r.map((e) => (e.key, e.value)), [(1, 30000), (2, 4000)]);
    });
  });

  group('fixos × variáveis', () {
    test('separa o gasto fixo do variável no período', () {
      final r = fixosVariaveis([
        gasto(120000, DateTime(2026, 3, 5), fixo: true),
        gasto(30000, DateTime(2026, 2, 5), fixo: true),
        gasto(50000, DateTime(2026, 3, 8)),
        ganho(500000, DateTime(2026, 3, 5)),
        gasto(77777, DateTime(2025, 1, 1)),
      ], fim: fim, meses: 3);
      expect(r.fixos, 150000);
      expect(r.variaveis, 50000);
      expect(r.total, 200000);
      expect(r.percentualFixos, 75);
    });

    test('sem gastos: 0%', () {
      final r = fixosVariaveis(const [], fim: fim);
      expect(r.total, 0);
      expect(r.percentualFixos, 0);
    });
  });
}
