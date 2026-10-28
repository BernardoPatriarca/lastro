/// Gravidade de um alerta.
enum NivelAlerta { critico, atencao, info }

/// Para onde o alerta leva ao ser tocado (a tela decide a rota).
enum DestinoAlerta { credito, orcamento, cartoes, lancamentos, investimentos, configuracoes }

class Alerta {
  const Alerta({
    required this.nivel,
    required this.titulo,
    required this.detalhe,
    required this.destino,
  });

  final NivelAlerta nivel;
  final String titulo;
  final String detalhe;
  final DestinoAlerta destino;
}

/// Algo que vence (fatura de cartão ou conta fixa) para o cálculo de alertas.
class VencimentoAlerta {
  const VencimentoAlerta({
    required this.descricao,
    required this.vencimento,
    required this.valor,
    this.ehFatura = false,
  });
  final String descricao;
  final DateTime vencimento;
  final int valor;
  final bool ehFatura;
}

/// Uma categoria com orçamento no limite ou acima, para os alertas.
class OrcamentoEmAlerta {
  const OrcamentoEmAlerta({required this.nome, required this.estourou});
  final String nome;

  /// `true` = passou de 100%; `false` = entre 80% e 100%.
  final bool estourou;
}

/// Projeção do gasto do mês no ritmo atual: `gasto ÷ dia atual × dias do mês`
/// (só inteiros). No último dia do mês é o próprio gasto.
int projetarGastoDoMes({
  required int gastoAteAgora,
  required int diaAtual,
  required int diasNoMes,
}) {
  if (diaAtual <= 0) return gastoAteAgora;
  if (diaAtual >= diasNoMes) return gastoAteAgora;
  return gastoAteAgora * diasNoMes ~/ diaAtual;
}

/// Reúne os alertas do momento, dos mais graves para os menos.
///
/// - crédito seguro negativo → crítico;
/// - conta/fatura vencida e não paga → crítico; vencendo em até
///   [diasAviso] dias → atenção;
/// - orçamento estourado → crítico; entre 80% e 100% → atenção;
/// - metas atrasadas → atenção; backup atrasado → informação.
List<Alerta> gerarAlertas({
  required DateTime hoje,
  required int creditoPodeGastar,
  required Iterable<VencimentoAlerta> vencimentos,
  required Iterable<OrcamentoEmAlerta> orcamentos,
  required Iterable<String> metasAtrasadas,
  required bool backupAtrasado,
  int diasAviso = 3,
}) {
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  final alertas = <Alerta>[];

  if (creditoPodeGastar < 0) {
    alertas.add(const Alerta(
      nivel: NivelAlerta.critico,
      titulo: 'Crédito acima do seu saldo',
      detalhe: 'O que você deve no cartão e nas contas passa do dinheiro em conta. '
          'Evite novas compras no crédito.',
      destino: DestinoAlerta.credito,
    ));
  }

  final ordenados = vencimentos.toList()
    ..sort((a, b) => a.vencimento.compareTo(b.vencimento));
  for (final v in ordenados) {
    final dias = DateTime(v.vencimento.year, v.vencimento.month, v.vencimento.day)
        .difference(dia)
        .inDays;
    final destino = v.ehFatura ? DestinoAlerta.cartoes : DestinoAlerta.lancamentos;
    if (dias < 0) {
      alertas.add(Alerta(
        nivel: NivelAlerta.critico,
        titulo: '${v.descricao} atrasada',
        detalhe: 'Venceu há ${-dias} ${-dias == 1 ? 'dia' : 'dias'}.',
        destino: destino,
      ));
    } else if (dias <= diasAviso) {
      alertas.add(Alerta(
        nivel: NivelAlerta.atencao,
        titulo: '${v.descricao} vence ${dias == 0 ? 'hoje' : dias == 1 ? 'amanhã' : 'em $dias dias'}',
        detalhe: 'Deixe o dinheiro em conta para pagar.',
        destino: destino,
      ));
    }
  }

  for (final o in orcamentos) {
    alertas.add(Alerta(
      nivel: o.estourou ? NivelAlerta.critico : NivelAlerta.atencao,
      titulo: o.estourou
          ? 'Orçamento de ${o.nome} estourado'
          : 'Orçamento de ${o.nome} quase no limite',
      detalhe: o.estourou
          ? 'Você já passou do limite deste mês.'
          : 'Você já usou mais de 80% do limite.',
      destino: DestinoAlerta.orcamento,
    ));
  }

  for (final m in metasAtrasadas) {
    alertas.add(Alerta(
      nivel: NivelAlerta.atencao,
      titulo: 'Meta "$m" atrasada',
      detalhe: 'No ritmo atual você não chega lá a tempo. Veja o aporte necessário.',
      destino: DestinoAlerta.investimentos,
    ));
  }

  if (backupAtrasado) {
    alertas.add(const Alerta(
      nivel: NivelAlerta.info,
      titulo: 'Faça um backup',
      detalhe: 'Seus dados só existem neste celular.',
      destino: DestinoAlerta.configuracoes,
    ));
  }

  // Mais graves primeiro; dentro do mesmo nível, mantém a ordem de geração.
  final indice = {for (var i = 0; i < alertas.length; i++) alertas[i]: i};
  alertas.sort((a, b) {
    final c = a.nivel.index.compareTo(b.nivel.index);
    return c != 0 ? c : indice[a]!.compareTo(indice[b]!);
  });
  return alertas;
}
