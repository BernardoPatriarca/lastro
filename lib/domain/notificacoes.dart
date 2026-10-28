import 'alertas.dart';

/// Uma notificação já planejada (data, texto e id estável).
class NotificacaoPlanejada {
  const NotificacaoPlanejada({
    required this.id,
    required this.quando,
    required this.titulo,
    required this.corpo,
  });

  final int id;
  final DateTime quando;
  final String titulo;
  final String corpo;

  @override
  String toString() => 'Notificacao($id, $quando, $titulo)';
}

/// Id inteiro estável (FNV-1a de 31 bits) a partir de um texto: a mesma conta
/// sempre recebe o mesmo id, então reagendar substitui em vez de duplicar.
int idEstavel(String chave) {
  var h = 0x811c9dc5;
  for (final u in chave.codeUnits) {
    h ^= u;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h & 0x7fffffff;
}

String _quando(int dias) => dias <= 0
    ? 'vence hoje'
    : dias == 1
        ? 'vence amanhã'
        : 'vence em $dias dias';

/// Planeja avisos de vencimento (faturas e contas fixas).
///
/// Cada conta gera um aviso [diasAntes] dias antes do vencimento (0 = no dia),
/// às [hora]h. Só entram horários **futuros** dentro de [horizonteDias] e, no
/// máximo, os [limite] mais próximos (o Android limita alarmes agendados).
/// [formatarValor] converte centavos em texto (ex.: `R$ 1.234,56`).
List<NotificacaoPlanejada> planejarNotificacoes({
  required DateTime agora,
  required Iterable<VencimentoAlerta> vencimentos,
  required int diasAntes,
  required String Function(int centavos) formatarValor,
  int hora = 9,
  int horizonteDias = 45,
  int limite = 60,
}) {
  final fim = agora.add(Duration(days: horizonteDias));
  final saida = <NotificacaoPlanejada>[];
  for (final v in vencimentos) {
    final dia = DateTime(v.vencimento.year, v.vencimento.month, v.vencimento.day);
    final quando = DateTime(dia.year, dia.month, dia.day - diasAntes, hora);
    if (!quando.isAfter(agora) || quando.isAfter(fim)) continue;
    saida.add(NotificacaoPlanejada(
      id: idEstavel(v.chave.isEmpty ? '${v.descricao}|${dia.toIso8601String()}' : v.chave),
      quando: quando,
      titulo: '${v.descricao} ${_quando(diasAntes)}',
      corpo: v.ehFatura
          ? '${formatarValor(v.valor)} · deixe o saldo em conta para pagar.'
          : formatarValor(v.valor),
    ));
  }
  saida.sort((a, b) => a.quando.compareTo(b.quando));
  return saida.take(limite).toList();
}

/// Valores aceitos para a antecedência (dias).
const antecedenciasDeAviso = [0, 1, 2, 3];
