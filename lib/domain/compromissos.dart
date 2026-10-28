import 'competencia.dart';
import 'datas.dart';
import 'enums.dart';

/// Uma ocorrência (mensalidade) de um compromisso, ainda não gravada.
class OcorrenciaPrevista {
  const OcorrenciaPrevista({
    required this.competencia,
    required this.valor,
    required this.dataVencimento,
    this.numeroParcela,
  });

  final Competencia competencia;
  final int valor;
  final DateTime dataVencimento;

  /// Nulo nos compromissos recorrentes (sem fim).
  final int? numeroParcela;

  @override
  String toString() =>
      'Ocorrencia($competencia, $valor, $dataVencimento, parcela=$numeroParcela)';
}

/// Ocorrências de um compromisso do mês da primeira até [ate] (inclusive).
///
/// - A primeira vence em [dataInicio]; as seguintes, no [diaVencimento] de
///   cada mês (limitado ao último dia: dia 31 em fevereiro → 28/29).
/// - `parcelado` termina sozinho após [numeroParcelas]; `recorrente` não tem fim.
List<OcorrenciaPrevista> gerarOcorrencias({
  required TipoCompromisso tipo,
  required int valor,
  required int diaVencimento,
  required DateTime dataInicio,
  required Competencia ate,
  int? numeroParcelas,
}) {
  assert(tipo == TipoCompromisso.recorrente || (numeroParcelas ?? 0) >= 1,
      'compromisso parcelado precisa de numeroParcelas');
  final inicio = Competencia.deData(dataInicio);
  final saida = <OcorrenciaPrevista>[];
  for (var k = 0;; k++) {
    final comp = inicio.somarMeses(k);
    if (comp > ate) break;
    if (tipo == TipoCompromisso.parcelado && k >= numeroParcelas!) break;
    saida.add(OcorrenciaPrevista(
      competencia: comp,
      valor: valor,
      dataVencimento: k == 0 ? soData(dataInicio) : comp.dia(diaVencimento),
      numeroParcela: tipo == TipoCompromisso.parcelado ? k + 1 : null,
    ));
  }
  return saida;
}

/// Só as ocorrências cuja competência ainda não existe em [existentes].
List<OcorrenciaPrevista> ocorrenciasFaltantes(
  List<OcorrenciaPrevista> geradas,
  Set<Competencia> existentes,
) =>
    [for (final o in geradas) if (!existentes.contains(o.competencia)) o];

/// Data em que o último pagamento de um parcelado vence.
DateTime dataDeTermino(DateTime dataInicio, int numeroParcelas) =>
    somarMeses(dataInicio, numeroParcelas - 1);

/// Receita recorrente reduzida ao que o cálculo de pendência precisa.
class ReceitaBase {
  const ReceitaBase({
    required this.id,
    required this.dataInicio,
    required this.ativa,
    required this.diaPrevisto,
  });
  final int id;
  final DateTime dataInicio;
  final bool ativa;
  final int diaPrevisto;
}

/// Receitas recorrentes ativas, já iniciadas em [mes], que ainda **não foram
/// confirmadas** nesse mês (CLAUDE.md 5.6). [confirmadasNoMes] traz os ids das
/// receitas com lançamento real no mês.
List<ReceitaBase> receitasPendentesDoMes({
  required Iterable<ReceitaBase> receitas,
  required Set<int> confirmadasNoMes,
  required Competencia mes,
}) =>
    [
      for (final r in receitas)
        if (r.ativa &&
            Competencia.deData(r.dataInicio) <= mes &&
            !confirmadasNoMes.contains(r.id))
          r,
    ];

/// Item que pesa no bolso em uma data (parcela de fatura, boleto etc.).
class ItemComprometido {
  const ItemComprometido(this.data, this.valor, {this.origem = ''});
  final DateTime data;
  final int valor;
  final String origem;
}

/// Soma [itens] por mês, de [inicio] por [meses] meses (meses sem itens = 0).
Map<Competencia, int> projetarComprometido(
  Iterable<ItemComprometido> itens, {
  required Competencia inicio,
  int meses = 12,
}) {
  final mapa = {for (var i = 0; i < meses; i++) inicio.somarMeses(i): 0};
  for (final item in itens) {
    final c = Competencia.deData(item.data);
    if (mapa.containsKey(c)) mapa[c] = mapa[c]! + item.valor;
  }
  return mapa;
}
