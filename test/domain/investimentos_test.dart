import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/investimentos.dart';

int _id = 0;
MovimentoInv mov(TipoMovimentoInvestimento t, int valor, DateTime d, {int inv = 1}) =>
    MovimentoInv(id: ++_id, investimentoId: inv, tipo: t, valor: valor, data: d);

void main() {
  const aporte = TipoMovimentoInvestimento.aporte;
  const resgate = TipoMovimentoInvestimento.resgate;
  const atualiza = TipoMovimentoInvestimento.atualizacaoSaldo;

  group('saldo do investimento (CLAUDE.md 4.6)', () {
    test('sem atualização: aportes − resgates', () {
      expect(
        saldoDoInvestimento([
          mov(aporte, 100000, DateTime(2026, 1, 5)),
          mov(aporte, 50000, DateTime(2026, 2, 5)),
          mov(resgate, 30000, DateTime(2026, 3, 1)),
        ]),
        120000,
      );
    });

    test('último "atualizar saldo" vira a base; só o que vem depois ajusta', () {
      expect(
        saldoDoInvestimento([
          mov(aporte, 100000, DateTime(2026, 1, 5)),
          mov(atualiza, 108000, DateTime(2026, 2, 1)), // rendeu 8%
          mov(aporte, 20000, DateTime(2026, 2, 10)), // depois: soma
          mov(resgate, 5000, DateTime(2026, 2, 20)), // depois: subtrai
        ]),
        123000,
      );
    });

    test('vale a atualização mais recente, ignorando as antigas', () {
      expect(
        saldoDoInvestimento([
          mov(atualiza, 100000, DateTime(2026, 1, 1)),
          mov(atualiza, 90000, DateTime(2026, 3, 1)),
          mov(atualiza, 95000, DateTime(2026, 2, 1)),
        ]),
        90000,
      );
    });

    test('no mesmo dia vale a ordem de criação', () {
      final d = DateTime(2026, 2, 1);
      expect(
        saldoDoInvestimento([
          mov(atualiza, 50000, d),
          mov(aporte, 1000, d), // criado depois da atualização
        ]),
        51000,
      );
    });

    test('até uma data: ignora movimentos futuros', () {
      final movs = [
        mov(aporte, 100000, DateTime(2026, 1, 5)),
        mov(aporte, 100000, DateTime(2026, 3, 5)),
      ];
      expect(saldoDoInvestimento(movs, ate: DateTime(2026, 2, 28)), 100000);
      expect(saldoDoInvestimento(movs), 200000);
    });

    test('sem movimentos é zero; saldo por investimento separa os ids', () {
      expect(saldoDoInvestimento(const []), 0);
      final s = saldosPorInvestimento([
        mov(aporte, 100, DateTime(2026, 1, 1), inv: 1),
        mov(aporte, 300, DateTime(2026, 1, 1), inv: 2),
        mov(aporte, 50, DateTime(2026, 1, 2), inv: 1),
      ]);
      expect(s, {1: 150, 2: 300});
    });
  });

  group('patrimônio mensal', () {
    test('saldo no fim de cada mês, soma dos investimentos', () {
      final movs = [
        mov(aporte, 100000, DateTime(2026, 1, 15), inv: 1),
        mov(aporte, 50000, DateTime(2026, 2, 10), inv: 2),
        mov(atualiza, 160000, DateTime(2026, 3, 31), inv: 1),
      ];
      final p = patrimonioMensal(movs, fim: const Competencia(2026, 3), meses: 4);
      expect(p.length, 4);
      expect(p[const Competencia(2025, 12)], 0);
      expect(p[const Competencia(2026, 1)], 100000);
      expect(p[const Competencia(2026, 2)], 150000);
      expect(p[const Competencia(2026, 3)], 210000); // 160000 + 50000
    });
  });

  group('metas', () {
    final hoje = DateTime(2026, 3, 1);

    test('meses restantes: arredonda para cima e nunca menos que 1', () {
      expect(mesesAte(hoje, DateTime(2026, 4, 1)), 2); // 31 dias
      expect(mesesAte(hoje, DateTime(2026, 3, 20)), 1);
      expect(mesesAte(hoje, DateTime(2026, 2, 1)), 1); // vencido
      expect(mesesAte(hoje, DateTime(2027, 3, 1)), 13); // 365 dias
    });

    test('aporte mensal necessário = (alvo − atual) ÷ meses, para cima', () {
      final p = calcularProgressoMeta(
        atual: 100000,
        alvo: 400000,
        prazo: DateTime(2026, 8, 28), // 180 dias = 6 meses
        hoje: hoje,
        ritmoMensalAtual: 0,
      );
      expect(p.mesesRestantes, 6);
      expect(p.aporteMensalNecessario, 50000);
      expect(p.falta, 300000);
      expect(p.percentual, closeTo(0.25, 1e-9));
    });

    test('arredondamento para cima nos centavos', () {
      final p = calcularProgressoMeta(
        atual: 0,
        alvo: 100000,
        prazo: DateTime(2026, 6, 29), // 120 dias = 4 meses
        hoje: hoje,
        ritmoMensalAtual: 0,
      );
      expect(p.aporteMensalNecessario, 25000);
      final q = calcularProgressoMeta(
        atual: 0,
        alvo: 100001,
        prazo: DateTime(2026, 6, 29),
        hoje: hoje,
        ritmoMensalAtual: 0,
      );
      expect(q.aporteMensalNecessario, 25001);
    });

    test('no ritmo quando o ritmo atual cobre o necessário', () {
      final p = calcularProgressoMeta(
        atual: 100000, alvo: 400000, prazo: DateTime(2026, 8, 28),
        hoje: hoje, ritmoMensalAtual: 50000,
      );
      expect(p.situacao, SituacaoMeta.noRitmo);
    });

    test('atrasada quando o ritmo não cobre', () {
      final p = calcularProgressoMeta(
        atual: 100000, alvo: 400000, prazo: DateTime(2026, 8, 28),
        hoje: hoje, ritmoMensalAtual: 49999,
      );
      expect(p.situacao, SituacaoMeta.atrasada);
    });

    test('atingida quando atual >= alvo (e nada falta)', () {
      final p = calcularProgressoMeta(
        atual: 500000, alvo: 400000, prazo: DateTime(2026, 8, 28),
        hoje: hoje, ritmoMensalAtual: 0,
      );
      expect(p.situacao, SituacaoMeta.atingida);
      expect(p.aporteMensalNecessario, 0);
      expect(p.falta, 0);
      expect(p.percentual, 1);
    });

    test('prazo vencido sem atingir é atrasada', () {
      final p = calcularProgressoMeta(
        atual: 100, alvo: 1000, prazo: DateTime(2026, 2, 1),
        hoje: hoje, ritmoMensalAtual: 999999,
      );
      expect(p.situacao, SituacaoMeta.atrasada);
    });

    test('ritmo mensal: média dos últimos 3 meses de aportes líquidos', () {
      final r = ritmoMensal([
        mov(aporte, 90000, DateTime(2026, 1, 10)),
        mov(aporte, 60000, DateTime(2026, 2, 10)),
        mov(resgate, 30000, DateTime(2026, 3, 1)),
        mov(aporte, 99999, DateTime(2025, 10, 1)), // fora da janela
      ], hoje: DateTime(2026, 3, 15));
      expect(r, (90000 + 60000 - 30000) ~/ 3);
    });
  });
}
