import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/competencia.dart';
import 'package:lastro/domain/credito_seguro.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/domain/fatura.dart';
import 'package:lastro/domain/parcelas.dart';

ResultadoCreditoSeguro calc({
  int saldo = 70000,
  List<ComprometimentoFatura> faturas = const [],
  int fixos = 0,
  ModoParcelados modo = ModoParcelados.rigido,
  bool descontar = true,
}) =>
    calcularCreditoSeguro(
      saldoContas: saldo,
      faturasNaoPagas: faturas,
      fixosPendentes: fixos,
      modo: modo,
      descontarFixos: descontar,
    );

void main() {
  group('crédito seguro (CLAUDE.md 5.1)', () {
    test('exemplo da spec: saldo R\$ 700, fatura R\$ 500, sem fixos → R\$ 200', () {
      final r = calc(faturas: [const ComprometimentoFatura(50000, futura: false)]);
      expect(r.podeGastar, 20000);
      expect(r.negativo, isFalse);
    });

    test('exemplo da spec: boleto pendente de R\$ 250 com fixos ligados → −R\$ 50', () {
      final r = calc(
        faturas: [const ComprometimentoFatura(50000, futura: false)],
        fixos: 25000,
      );
      expect(r.podeGastar, -5000);
      expect(r.negativo, isTrue);
    });

    test('com "descontar contas fixas" desligado o boleto não conta', () {
      final r = calc(
        faturas: [const ComprometimentoFatura(50000, futura: false)],
        fixos: 25000,
        descontar: false,
      );
      expect(r.podeGastar, 20000);
      expect(r.fixosDescontados, 0);
    });

    test('sem dívidas, pode gastar todo o saldo', () {
      expect(calc().podeGastar, 70000);
      expect(calc().percentualComprometido, 0);
    });

    test('modo rígido desconta também as parcelas futuras', () {
      final r = calc(
        modo: ModoParcelados.rigido,
        faturas: [
          const ComprometimentoFatura(30000, futura: false),
          const ComprometimentoFatura(20000, futura: true),
          const ComprometimentoFatura(10000, futura: true),
        ],
      );
      expect(r.comprometidoCartao, 60000);
      expect(r.podeGastar, 10000);
      expect(r.comprometidoProximasFaturas, 30000);
    });

    test('modo parcela só desconta faturas abertas/fechadas; futuras são informação',
        () {
      final r = calc(
        modo: ModoParcelados.parcela,
        faturas: [
          const ComprometimentoFatura(30000, futura: false),
          const ComprometimentoFatura(20000, futura: true),
          const ComprometimentoFatura(10000, futura: true),
        ],
      );
      expect(r.comprometidoCartao, 30000);
      expect(r.podeGastar, 40000);
      expect(r.comprometidoProximasFaturas, 30000);
    });

    test('várias faturas atuais (cartões diferentes) somam', () {
      final r = calc(faturas: [
        const ComprometimentoFatura(10000, futura: false),
        const ComprometimentoFatura(15000, futura: false),
      ]);
      expect(r.comprometidoCartao, 25000);
    });

    test('saldo negativo e dívida: percentual comprometido satura em 1', () {
      final r = calc(
        saldo: -1000,
        faturas: [const ComprometimentoFatura(5000, futura: false)],
      );
      expect(r.podeGastar, -6000);
      expect(r.percentualComprometido, 1);
    });

    test('percentual comprometido é proporcional ao saldo', () {
      final r = calc(
        faturas: [const ComprometimentoFatura(35000, futura: false)],
      );
      expect(r.percentualComprometido, closeTo(0.5, 1e-9));
    });
  });

  group('fatura futura e horizonte das contas fixas', () {
    final atual = cicloDaCompra(DateTime(2026, 3, 5), diaFechamento: 10, diaVencimento: 17);

    test('só é futura a fatura de ciclo posterior ao atual', () {
      expect(faturaEhFutura(const Competencia(2026, 3), atual), isFalse);
      expect(faturaEhFutura(const Competencia(2026, 2), atual), isFalse);
      expect(faturaEhFutura(const Competencia(2026, 4), atual), isTrue);
    });

    test('horizonte = maior vencimento da fatura atual entre os cartões', () {
      final h = horizonteContasFixas(
        vencimentosFaturaAtual: [DateTime(2026, 3, 17), DateTime(2026, 3, 28)],
        hoje: DateTime(2026, 3, 5),
      );
      expect(h, DateTime(2026, 3, 28));
    });

    test('sem cartões, vale o fim do mês', () {
      expect(
        horizonteContasFixas(vencimentosFaturaAtual: [], hoje: DateTime(2026, 2, 10)),
        DateTime(2026, 2, 28),
      );
    });
  });

  group('impacto de uma compra nova', () {
    final atual = cicloDaCompra(DateTime(2026, 3, 5), diaFechamento: 10, diaVencimento: 17);
    List<ParcelaGerada> compra(int total, int n) => gerarParcelas(
          descricao: 'x',
          valorTotal: total,
          numeroParcelas: n,
          dataCompra: DateTime(2026, 3, 5),
          diaFechamento: 10,
          diaVencimento: 17,
        );

    test('rígido: a compra inteira pesa', () {
      final peso = valorQuePesaDaCompra(
        parcelas: compra(30000, 3),
        cicloAtual: atual,
        modo: ModoParcelados.rigido,
      );
      expect(peso, 30000);
    });

    test('parcela: só a primeira parcela pesa (as outras caem em faturas futuras)', () {
      final peso = valorQuePesaDaCompra(
        parcelas: compra(30000, 3),
        cicloAtual: atual,
        modo: ModoParcelados.parcela,
      );
      expect(peso, 10000);
    });

    test('à vista pesa igual nos dois modos', () {
      for (final modo in ModoParcelados.values) {
        expect(
          valorQuePesaDaCompra(parcelas: compra(8000, 1), cicloAtual: atual, modo: modo),
          8000,
        );
      }
    });

    test('depois dessa compra sobra… e estoura quando negativo', () {
      final r = calc(faturas: [const ComprometimentoFatura(50000, futura: false)]); // pode 200
      final cabe = calcularImpactoCompra(atual: r, valorQuePesa: 15000);
      expect(cabe.sobra, 5000);
      expect(cabe.estoura, isFalse);

      final estoura = calcularImpactoCompra(atual: r, valorQuePesa: 27000);
      expect(estoura.sobra, -7000);
      expect(estoura.estoura, isTrue);
      expect(estoura.acimaDoSaldo, 7000);
    });

    test('exatamente zero não estoura', () {
      final r = calc(faturas: [const ComprometimentoFatura(50000, futura: false)]);
      expect(calcularImpactoCompra(atual: r, valorQuePesa: 20000).estoura, isFalse);
    });
  });
}
