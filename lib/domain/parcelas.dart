import 'datas.dart';
import 'fatura.dart';

/// Divide [total] (centavos) em [n] parcelas. A diferença de arredondamento
/// vai na **primeira** (R$ 100,00 em 3x → 33,34 + 33,33 + 33,33).
List<int> dividirEmParcelas(int total, int n) {
  assert(n >= 1, 'número de parcelas deve ser >= 1');
  final base = total ~/ n;
  final resto = total - base * n;
  return [for (var i = 0; i < n; i++) i == 0 ? base + resto : base];
}

/// "Descrição (2/10)". Compra à vista (1 parcela) fica sem sufixo.
String descricaoDaParcela(String base, int numero, int total) =>
    total <= 1 ? base : '$base ($numero/$total)';

final _sufixoParcela = RegExp(r'\s*\(\d+/\d+\)\s*$');

/// Tira o sufixo " (2/10)" de uma descrição de parcela.
String descricaoBase(String descricao) =>
    descricao.replaceFirst(_sufixoParcela, '').trim();

/// Uma parcela já posicionada: valor, data e fatura de destino.
class ParcelaGerada {
  const ParcelaGerada({
    required this.numero,
    required this.valor,
    required this.data,
    required this.ciclo,
    required this.descricao,
  });

  final int numero;
  final int valor;

  /// Data do lançamento: a da compra + (N−1) meses, para a parcela aparecer
  /// no mês em que pesa.
  final DateTime data;

  /// Fatura em que a parcela cai.
  final CicloFatura ciclo;
  final String descricao;
}

/// Gera as parcelas de uma compra no cartão (CLAUDE.md 5.4): a parcela N vai
/// para a fatura N−1 ciclos depois da fatura da compra.
List<ParcelaGerada> gerarParcelas({
  required String descricao,
  required int valorTotal,
  required int numeroParcelas,
  required DateTime dataCompra,
  required int diaFechamento,
  required int diaVencimento,
}) {
  final valores = dividirEmParcelas(valorTotal, numeroParcelas);
  final primeira = cicloDaCompra(
    dataCompra,
    diaFechamento: diaFechamento,
    diaVencimento: diaVencimento,
  );
  return [
    for (var i = 0; i < numeroParcelas; i++)
      ParcelaGerada(
        numero: i + 1,
        valor: valores[i],
        data: somarMeses(dataCompra, i),
        ciclo: cicloDaCompetencia(
          primeira.competencia.somarMeses(i),
          diaFechamento: diaFechamento,
          diaVencimento: diaVencimento,
        ),
        descricao: descricaoDaParcela(descricao, i + 1, numeroParcelas),
      ),
  ];
}
