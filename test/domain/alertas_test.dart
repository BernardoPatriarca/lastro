import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/alertas.dart';

void main() {
  final hoje = DateTime(2026, 3, 10);

  List<Alerta> gerar({
    int credito = 1000,
    List<VencimentoAlerta> venc = const [],
    List<OrcamentoEmAlerta> orc = const [],
    List<String> metas = const [],
    bool backup = false,
  }) =>
      gerarAlertas(
        hoje: hoje,
        creditoPodeGastar: credito,
        vencimentos: venc,
        orcamentos: orc,
        metasAtrasadas: metas,
        backupAtrasado: backup,
      );

  group('projeção do gasto do mês', () {
    test('ritmo atual: gasto ÷ dia × dias do mês', () {
      expect(projetarGastoDoMes(gastoAteAgora: 30000, diaAtual: 10, diasNoMes: 30), 90000);
      expect(projetarGastoDoMes(gastoAteAgora: 10000, diaAtual: 15, diasNoMes: 31), 20666);
    });

    test('no último dia do mês é o próprio gasto; dia inválido não quebra', () {
      expect(projetarGastoDoMes(gastoAteAgora: 5000, diaAtual: 30, diasNoMes: 30), 5000);
      expect(projetarGastoDoMes(gastoAteAgora: 5000, diaAtual: 0, diasNoMes: 30), 5000);
    });

    test('sem gasto, projeção zero', () {
      expect(projetarGastoDoMes(gastoAteAgora: 0, diaAtual: 7, diasNoMes: 31), 0);
    });
  });

  group('alertas', () {
    test('tudo em ordem: nenhum alerta', () {
      expect(gerar(), isEmpty);
    });

    test('crédito negativo é crítico', () {
      final a = gerar(credito: -1);
      expect(a.single.nivel, NivelAlerta.critico);
      expect(a.single.destino, DestinoAlerta.credito);
    });

    test('vencimentos: atrasado crítico, hoje/amanhã/em 3 dias atenção, longe nada', () {
      final a = gerar(venc: [
        VencimentoAlerta(descricao: 'Aluguel', vencimento: DateTime(2026, 3, 5), valor: 1),
        VencimentoAlerta(descricao: 'Luz', vencimento: DateTime(2026, 3, 10), valor: 1),
        VencimentoAlerta(descricao: 'Água', vencimento: DateTime(2026, 3, 11), valor: 1),
        VencimentoAlerta(
            descricao: 'Fatura X', vencimento: DateTime(2026, 3, 13), valor: 1, ehFatura: true),
        VencimentoAlerta(descricao: 'Internet', vencimento: DateTime(2026, 3, 14), valor: 1),
      ]);
      expect(a.map((e) => e.titulo), [
        'Aluguel atrasada',
        'Luz vence hoje',
        'Água vence amanhã',
        'Fatura X vence em 3 dias',
      ]);
      expect(a.first.nivel, NivelAlerta.critico);
      expect(a.first.detalhe, 'Venceu há 5 dias.');
      expect(a.last.destino, DestinoAlerta.cartoes);
      expect(a[1].destino, DestinoAlerta.lancamentos);
    });

    test('orçamento: estourado crítico, quase no limite atenção', () {
      final a = gerar(orc: const [
        OrcamentoEmAlerta(nome: 'Lazer', estourou: false),
        OrcamentoEmAlerta(nome: 'Mercado', estourou: true),
      ]);
      expect(a.first.titulo, 'Orçamento de Mercado estourado');
      expect(a.first.nivel, NivelAlerta.critico);
      expect(a.last.nivel, NivelAlerta.atencao);
    });

    test('metas atrasadas e backup entram com os níveis certos', () {
      final a = gerar(metas: ['Viagem'], backup: true);
      expect(a.map((e) => e.nivel), [NivelAlerta.atencao, NivelAlerta.info]);
      expect(a.first.titulo, 'Meta "Viagem" atrasada');
    });

    test('ordena dos mais graves para os menos, estável dentro do nível', () {
      final a = gerar(
        credito: -5,
        backup: true,
        metas: ['M'],
        orc: const [OrcamentoEmAlerta(nome: 'X', estourou: true)],
        venc: [VencimentoAlerta(descricao: 'Boleto', vencimento: DateTime(2026, 3, 1), valor: 1)],
      );
      expect(a.map((e) => e.nivel).toList(), [
        NivelAlerta.critico,
        NivelAlerta.critico,
        NivelAlerta.critico,
        NivelAlerta.atencao,
        NivelAlerta.info,
      ]);
      expect(a.first.titulo, 'Crédito acima do seu saldo');
    });
  });
}
