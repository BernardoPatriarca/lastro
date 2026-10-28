import 'competencia.dart';
import 'enums.dart';

/// Movimento de um investimento reduzido ao que o cálculo precisa.
class MovimentoInv {
  const MovimentoInv({
    required this.id,
    required this.investimentoId,
    required this.tipo,
    required this.valor,
    required this.data,
  });

  final int id;
  final int investimentoId;
  final TipoMovimentoInvestimento tipo;

  /// Centavos, positivo. Em `atualizacaoSaldo` é o saldo total informado.
  final int valor;
  final DateTime data;
}

/// Ordena por data e, no mesmo dia, pela ordem de criação.
List<MovimentoInv> _ordenados(Iterable<MovimentoInv> movs) =>
    movs.toList()
      ..sort((a, b) {
        final c = a.data.compareTo(b.data);
        return c != 0 ? c : a.id.compareTo(b.id);
      });

/// Saldo de um investimento (CLAUDE.md 4.6): o último "atualizar saldo"
/// ajustado pelos aportes e resgates **posteriores** a ele. Sem nenhuma
/// atualização, é aportes − resgates. Considera só movimentos até [ate].
int saldoDoInvestimento(Iterable<MovimentoInv> movimentos, {DateTime? ate}) {
  var saldo = 0;
  for (final m in _ordenados(movimentos)) {
    if (ate != null && m.data.isAfter(ate)) continue;
    switch (m.tipo) {
      case TipoMovimentoInvestimento.atualizacaoSaldo:
        saldo = m.valor;
      case TipoMovimentoInvestimento.aporte:
        saldo += m.valor;
      case TipoMovimentoInvestimento.resgate:
        saldo -= m.valor;
    }
  }
  return saldo;
}

/// Saldo de cada investimento (id → centavos).
Map<int, int> saldosPorInvestimento(Iterable<MovimentoInv> movimentos, {DateTime? ate}) {
  final porId = <int, List<MovimentoInv>>{};
  for (final m in movimentos) {
    porId.putIfAbsent(m.investimentoId, () => []).add(m);
  }
  return {
    for (final e in porId.entries) e.key: saldoDoInvestimento(e.value, ate: ate),
  };
}

/// Patrimônio (soma dos saldos) no fim de cada um dos últimos [meses] meses,
/// terminando em [fim]. Serve ao gráfico de evolução mensal.
Map<Competencia, int> patrimonioMensal(
  Iterable<MovimentoInv> movimentos, {
  required Competencia fim,
  int meses = 12,
}) {
  final lista = movimentos.toList();
  final resultado = <Competencia, int>{};
  for (var i = meses - 1; i >= 0; i--) {
    final c = fim.somarMeses(-i);
    final saldos = saldosPorInvestimento(lista, ate: c.ultimoDia);
    resultado[c] = saldos.values.fold(0, (s, v) => s + v);
  }
  return resultado;
}

/// Situação de uma meta.
enum SituacaoMeta { atingida, noRitmo, atrasada }

class ProgressoMeta {
  const ProgressoMeta({
    required this.atual,
    required this.alvo,
    required this.mesesRestantes,
    required this.aporteMensalNecessario,
    required this.situacao,
  });

  final int atual;
  final int alvo;
  final int mesesRestantes;

  /// (alvo − atual) ÷ meses restantes, arredondado para cima.
  final int aporteMensalNecessario;
  final SituacaoMeta situacao;

  double get percentual => alvo <= 0 ? 0 : (atual / alvo).clamp(0, 1).toDouble();
  int get falta => (alvo - atual) < 0 ? 0 : alvo - atual;
}

/// Meses que faltam até o [prazo] (mínimo 1; prazo vencido conta como 1).
int mesesAte(DateTime hoje, DateTime prazo) {
  final dias = prazo.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
  if (dias <= 0) return 1;
  return (dias + 29) ~/ 30;
}

/// Calcula o andamento de uma meta (CLAUDE.md 4.6).
///
/// - aporte mensal necessário = (alvo − atual) ÷ meses restantes;
/// - "no ritmo" quando o ritmo médio atual de aportes líquidos
///   ([ritmoMensalAtual], ex.: média dos últimos 3 meses) cobre o necessário;
///   "atrasada" quando não cobre ou o prazo já passou sem atingir o alvo.
ProgressoMeta calcularProgressoMeta({
  required int atual,
  required int alvo,
  required DateTime prazo,
  required DateTime hoje,
  required int ritmoMensalAtual,
}) {
  final meses = mesesAte(hoje, prazo);
  final falta = alvo - atual;
  final necessario = falta <= 0 ? 0 : (falta + meses - 1) ~/ meses;
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  final SituacaoMeta situacao;
  if (atual >= alvo) {
    situacao = SituacaoMeta.atingida;
  } else if (prazo.isBefore(dia)) {
    situacao = SituacaoMeta.atrasada;
  } else if (ritmoMensalAtual >= necessario) {
    situacao = SituacaoMeta.noRitmo;
  } else {
    situacao = SituacaoMeta.atrasada;
  }
  return ProgressoMeta(
    atual: atual,
    alvo: alvo,
    mesesRestantes: meses,
    aporteMensalNecessario: necessario,
    situacao: situacao,
  );
}

/// Média mensal de aportes líquidos (aportes − resgates) nos últimos [meses]
/// meses completos antes de [hoje] mais o mês corrente. Divide por [meses].
int ritmoMensal(
  Iterable<MovimentoInv> movimentos, {
  required DateTime hoje,
  int meses = 3,
}) {
  final fim = Competencia.deData(hoje);
  final inicio = fim.somarMeses(-(meses - 1)).primeiroDia;
  var liquido = 0;
  for (final m in movimentos) {
    if (m.data.isBefore(inicio) || m.data.isAfter(fim.ultimoDia)) continue;
    if (m.tipo == TipoMovimentoInvestimento.aporte) liquido += m.valor;
    if (m.tipo == TipoMovimentoInvestimento.resgate) liquido -= m.valor;
  }
  return liquido ~/ meses;
}
