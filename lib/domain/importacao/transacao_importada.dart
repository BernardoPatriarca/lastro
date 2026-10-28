import '../enums.dart';
import '../texto.dart';

/// Uma transação lida de um extrato (OFX ou CSV), antes de virar lançamento.
///
/// [valor] tem sinal em centavos: **negativo = saída/gasto**, positivo =
/// entrada/ganho.
class TransacaoImportada {
  const TransacaoImportada({
    required this.data,
    required this.descricao,
    required this.valor,
    this.fitid,
    this.chave = '',
  });

  final DateTime data;
  final String descricao;
  final int valor;

  /// Identificador único da transação no banco (OFX), quando existe.
  final String? fitid;

  /// Chave de deduplicação (preenchida por [atribuirChaves]).
  final String chave;

  bool get ehSaida => valor < 0;

  TransacaoImportada comChave(String nova) => TransacaoImportada(
        data: data,
        descricao: descricao,
        valor: valor,
        fitid: fitid,
        chave: nova,
      );

  @override
  String toString() => 'Transacao($data, $descricao, $valor)';
}

String _ymd(DateTime d) =>
    '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

/// Chave de importação: FITID do OFX; sem FITID, `data|valor|descrição
/// normalizada`. [prefixo] separa contas/cartões (ex.: `c3`). Transações
/// idênticas no mesmo arquivo ganham `#2`, `#3`… (dois cafés iguais no mesmo
/// dia não podem virar "duplicada" um do outro) e a numeração é estável: ao
/// importar o mesmo arquivo de novo, as chaves coincidem.
List<TransacaoImportada> atribuirChaves(
  Iterable<TransacaoImportada> transacoes, {
  required String prefixo,
}) {
  final vistas = <String, int>{};
  final saida = <TransacaoImportada>[];
  for (final t in transacoes) {
    final base = (t.fitid != null && t.fitid!.trim().isNotEmpty)
        ? '$prefixo:f:${t.fitid!.trim()}'
        : '$prefixo:h:${_ymd(t.data)}|${t.valor}|${normalizarTexto(t.descricao)}';
    final n = (vistas[base] ?? 0) + 1;
    vistas[base] = n;
    saida.add(t.comChave(n == 1 ? base : '$base#$n'));
  }
  return saida;
}

/// Quais [transacoes] já foram importadas antes (chave presente em [existentes]).
Set<String> chavesDuplicadas(
  Iterable<TransacaoImportada> transacoes,
  Set<String> existentes,
) =>
    {
      for (final t in transacoes)
        if (existentes.contains(t.chave)) t.chave,
    };

/// Forma de pagamento provável pelo texto da descrição.
FormaPagamento inferirForma(String descricao) {
  final d = normalizarTexto(descricao);
  if (d.contains('pix')) return FormaPagamento.pix;
  if (d.contains('boleto')) return FormaPagamento.boleto;
  if (d.contains('saque')) return FormaPagamento.dinheiro;
  return FormaPagamento.debito;
}

/// Ocorrência de compromisso pendente, reduzida ao que o casamento precisa.
class OcorrenciaPendenteSimples {
  const OcorrenciaPendenteSimples({
    required this.id,
    required this.valor,
    required this.vencimento,
  });
  final int id;
  final int valor;
  final DateTime vencimento;
}

/// Liga transações de saída a ocorrências pendentes de mesmo valor com
/// vencimento até ±[toleranciaDias] da data (CLAUDE.md 7). Devolve
/// índice da transação → id da ocorrência. Cada ocorrência é usada uma vez,
/// escolhendo sempre a mais próxima da data.
Map<int, int> casarComOcorrencias(
  List<TransacaoImportada> transacoes,
  Iterable<OcorrenciaPendenteSimples> ocorrencias, {
  int toleranciaDias = 5,
}) {
  final livres = ocorrencias.toList();
  final resultado = <int, int>{};
  final ordem = [for (var i = 0; i < transacoes.length; i++) i]
    ..sort((a, b) => transacoes[a].data.compareTo(transacoes[b].data));
  for (final i in ordem) {
    final t = transacoes[i];
    if (!t.ehSaida) continue;
    OcorrenciaPendenteSimples? melhor;
    var melhorDif = toleranciaDias + 1;
    for (final o in livres) {
      if (o.valor != -t.valor) continue;
      final dif = t.data.difference(o.vencimento).inDays.abs();
      if (dif <= toleranciaDias && dif < melhorDif) {
        melhor = o;
        melhorDif = dif;
      }
    }
    if (melhor != null) {
      resultado[i] = melhor.id;
      livres.remove(melhor);
    }
  }
  return resultado;
}
