import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/saldo.dart';

MovimentoSaldo mov(
  TipoLancamento tipo,
  int valor, {
  FormaPagamento? forma,
  int? conta = 1,
  int? destino,
  DateTime? data,
}) =>
    MovimentoSaldo(
      tipo: tipo,
      valor: valor,
      forma: forma,
      contaId: conta,
      contaDestinoId: destino,
      data: data ?? DateTime(2026, 3, 10),
    );

int saldo(List<MovimentoSaldo> movs, {int inicial = 0, int conta = 1}) =>
    calcularSaldoConta(
      contaId: conta,
      saldoInicial: inicial,
      dataSaldoInicial: DateTime(2026, 1, 1),
      movimentos: movs,
    );

void main() {
  group('saldo da conta (CLAUDE.md 5.2)', () {
    test('sem movimentos é o saldo inicial', () {
      expect(saldo([], inicial: 150000), 150000);
    });

    test('ganhos e resgates somam', () {
      expect(
        saldo([
          mov(TipoLancamento.ganho, 500000),
          mov(TipoLancamento.resgate, 20000),
        ]),
        520000,
      );
    });

    test('gastos não-crédito, aportes e pagamento de fatura subtraem', () {
      expect(
        saldo([
          mov(TipoLancamento.gasto, 1000, forma: FormaPagamento.debito),
          mov(TipoLancamento.gasto, 2000, forma: FormaPagamento.pix),
          mov(TipoLancamento.gasto, 3000, forma: FormaPagamento.dinheiro),
          mov(TipoLancamento.gasto, 4000, forma: FormaPagamento.boleto),
          mov(TipoLancamento.aporte, 5000),
          mov(TipoLancamento.pagamentoFatura, 6000),
        ], inicial: 100000),
        100000 - 1000 - 2000 - 3000 - 4000 - 5000 - 6000,
      );
    });

    test('compra no crédito NÃO mexe no saldo da conta', () {
      expect(
        saldo([
          mov(TipoLancamento.gasto, 99999,
              forma: FormaPagamento.credito, conta: null),
        ], inicial: 70000),
        70000,
      );
    });

    test('só o pagamento da fatura tira o dinheiro da conta', () {
      expect(
        saldo([
          mov(TipoLancamento.gasto, 50000,
              forma: FormaPagamento.credito, conta: null),
          mov(TipoLancamento.pagamentoFatura, 50000),
        ], inicial: 70000),
        20000,
      );
    });

    test('transferência sai da origem e entra no destino', () {
      final movs = [mov(TipoLancamento.transferencia, 30000, destino: 2)];
      expect(saldo(movs, inicial: 100000, conta: 1), 70000);
      expect(saldo(movs, inicial: 10000, conta: 2), 40000);
      expect(saldo(movs, inicial: 5000, conta: 3), 5000);
    });

    test('ajuste de saldo tem sinal próprio', () {
      expect(saldo([mov(TipoLancamento.ajusteSaldo, 2500)], inicial: 1000), 3500);
      expect(saldo([mov(TipoLancamento.ajusteSaldo, -400)], inicial: 1000), 600);
    });

    test('lançamentos de outra conta são ignorados', () {
      expect(
        saldo([mov(TipoLancamento.ganho, 9999, conta: 2)], inicial: 100),
        100,
      );
    });

    test('lançamentos anteriores à data do saldo inicial são ignorados', () {
      final antigo = mov(TipoLancamento.ganho, 5000, data: DateTime(2025, 12, 31));
      final novo = mov(TipoLancamento.ganho, 700, data: DateTime(2026, 1, 1));
      expect(saldo([antigo, novo], inicial: 100), 800);
    });
  });
}
