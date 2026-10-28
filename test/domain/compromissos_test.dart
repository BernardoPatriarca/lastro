import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/compromissos.dart';
import 'package:lastro/domain/enums.dart';

void main() {
  group('ocorrências de compromissos (CLAUDE.md 5.5)', () {
    test('recorrente gera uma por mês até a competência pedida', () {
      final o = gerarOcorrencias(
        tipo: TipoCompromisso.recorrente,
        valor: 10000,
        diaVencimento: 5,
        dataInicio: DateTime(2026, 1, 5),
        ate: const Competencia(2026, 4),
      );
      expect(o.map((e) => e.competencia.chave),
          ['2026-01', '2026-02', '2026-03', '2026-04']);
      expect(o.every((e) => e.numeroParcela == null), isTrue);
      expect(o.map((e) => e.dataVencimento.day).toSet(), {5});
    });

    test('parcelado numera e termina sozinho após a última parcela', () {
      final o = gerarOcorrencias(
        tipo: TipoCompromisso.parcelado,
        valor: 25000,
        diaVencimento: 10,
        dataInicio: DateTime(2026, 1, 10),
        numeroParcelas: 3,
        ate: const Competencia(2027, 12), // muito além do fim
      );
      expect(o.length, 3);
      expect(o.map((e) => e.numeroParcela), [1, 2, 3]);
      expect(o.last.competencia, const Competencia(2026, 3));
    });

    test('primeira vence na data de início; as seguintes no dia combinado', () {
      final o = gerarOcorrencias(
        tipo: TipoCompromisso.recorrente,
        valor: 1,
        diaVencimento: 20,
        dataInicio: DateTime(2026, 1, 15),
        ate: const Competencia(2026, 2),
      );
      expect(o[0].dataVencimento, DateTime(2026, 1, 15));
      expect(o[1].dataVencimento, DateTime(2026, 2, 20));
    });

    test('dia 31 cai no último dia dos meses curtos', () {
      final o = gerarOcorrencias(
        tipo: TipoCompromisso.recorrente,
        valor: 1,
        diaVencimento: 31,
        dataInicio: DateTime(2026, 1, 31),
        ate: const Competencia(2026, 4),
      );
      expect(o.map((e) => e.dataVencimento), [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 30),
      ]);
    });

    test('atravessa a virada de ano', () {
      final o = gerarOcorrencias(
        tipo: TipoCompromisso.parcelado,
        valor: 1,
        diaVencimento: 15,
        dataInicio: DateTime(2026, 11, 15),
        numeroParcelas: 4,
        ate: const Competencia(2027, 6),
      );
      expect(o.map((e) => e.competencia.chave),
          ['2026-11', '2026-12', '2027-01', '2027-02']);
    });

    test('início depois do limite não gera nada', () {
      final o = gerarOcorrencias(
        tipo: TipoCompromisso.recorrente,
        valor: 1,
        diaVencimento: 1,
        dataInicio: DateTime(2026, 8, 1),
        ate: const Competencia(2026, 6),
      );
      expect(o, isEmpty);
    });

    test('só as faltantes são devolvidas', () {
      final todas = gerarOcorrencias(
        tipo: TipoCompromisso.recorrente,
        valor: 1,
        diaVencimento: 1,
        dataInicio: DateTime(2026, 1, 1),
        ate: const Competencia(2026, 3),
      );
      final f = ocorrenciasFaltantes(todas, {const Competencia(2026, 1), const Competencia(2026, 2)});
      expect(f.map((e) => e.competencia.chave), ['2026-03']);
    });

    test('data de término do parcelado', () {
      expect(dataDeTermino(DateTime(2026, 1, 31), 3), DateTime(2026, 3, 31));
      expect(dataDeTermino(DateTime(2026, 1, 15), 1), DateTime(2026, 1, 15));
    });
  });

  group('receitas recorrentes (CLAUDE.md 5.6)', () {
    ReceitaBase r(int id, DateTime inicio, {bool ativa = true}) =>
        ReceitaBase(id: id, dataInicio: inicio, ativa: ativa, diaPrevisto: 5);

    test('pendente até ser confirmada no mês', () {
      final receitas = [r(1, DateTime(2026, 1, 5)), r(2, DateTime(2026, 1, 5))];
      final p = receitasPendentesDoMes(
        receitas: receitas,
        confirmadasNoMes: {1},
        mes: const Competencia(2026, 3),
      );
      expect(p.map((e) => e.id), [2]);
    });

    test('inativa ou que ainda não começou não é pendente', () {
      final p = receitasPendentesDoMes(
        receitas: [
          r(1, DateTime(2026, 1, 5), ativa: false),
          r(2, DateTime(2026, 6, 1)),
        ],
        confirmadasNoMes: {},
        mes: const Competencia(2026, 3),
      );
      expect(p, isEmpty);
    });
  });

  group('projeção de comprometimento', () {
    test('agrupa por mês e preenche meses vazios com zero', () {
      final m = projetarComprometido([
        ItemComprometido(DateTime(2026, 3, 10), 1000),
        ItemComprometido(DateTime(2026, 3, 20), 500),
        ItemComprometido(DateTime(2026, 5, 1), 700),
        ItemComprometido(DateTime(2027, 12, 1), 999), // fora da janela
      ], inicio: const Competencia(2026, 3), meses: 4);
      expect(m.length, 4);
      expect(m[const Competencia(2026, 3)], 1500);
      expect(m[const Competencia(2026, 4)], 0);
      expect(m[const Competencia(2026, 5)], 700);
      expect(m[const Competencia(2026, 6)], 0);
    });

    test('janela padrão é de 12 meses', () {
      final m = projetarComprometido([], inicio: const Competencia(2026, 10));
      expect(m.length, 12);
      expect(m.keys.last, const Competencia(2027, 9));
    });
  });
}
