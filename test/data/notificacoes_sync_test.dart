import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/notificacoes/agendador.dart';
import 'package:lastro/data/providers.dart';
import 'package:lastro/data/servicos/servico_compromisso.dart';
import 'package:lastro/domain/enums.dart';
import 'package:lastro/features/notificacoes/sincronizador.dart';

void main() {
  late AppDatabase db;
  late AgendadorFalso agendador;
  late ProviderContainer c;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    agendador = AgendadorFalso();
    c = ProviderContainer(overrides: [
      bancoProvider.overrideWithValue(db),
      agendadorProvider.overrideWithValue(agendador),
    ]);
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<void> ativarSincronizador() async {
    for (final p in [
      faturasProvider, ocorrenciasProvider, compromissosProvider, cartoesProvider,
    ]) {
      c.listen(p, (_, _) {});
      await c.read((p as dynamic).future);
    }
    c.listen(ajustesProvider, (_, _) {});
    c.listen(sincronizadorNotificacoesProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  Future<void> esperar() => Future<void>.delayed(const Duration(milliseconds: 900));

  Future<void> contaVencendoEm(int dias) => ServicoCompromisso(db).criarCompromisso(
        descricao: 'Aluguel',
        valor: 120000,
        tipo: TipoCompromisso.recorrente,
        dataInicio: DateTime.now().add(Duration(days: dias)),
        forma: FormaPagamento.boleto,
      );

  test('desligado (padrão): nada é agendado', () async {
    await contaVencendoEm(5);
    await ativarSincronizador();
    await esperar();
    expect(agendador.agendadas, isEmpty);
  });

  test('ligado com permissão: agenda o aviso da conta pendente', () async {
    await contaVencendoEm(5);
    await agendador.pedirPermissao();
    await c.read(definirAjusteProvider)('notificacoes', 'true');
    await ativarSincronizador();
    await esperar();

    expect(agendador.agendadas, isNotEmpty);
    final n = agendador.agendadas.first;
    expect(n.titulo, startsWith('Aluguel vence amanhã'));
    expect(n.corpo, 'R\$ 1.200,00');
    expect(n.quando.hour, 9);
  });

  test('sem permissão do sistema, não agenda', () async {
    await contaVencendoEm(5);
    // permissão nunca concedida
    await c.read(definirAjusteProvider)('notificacoes', 'true');
    await ativarSincronizador();
    await esperar();
    expect(agendador.agendadas, isEmpty);
  });

  test('mudar a antecedência reagenda; desligar cancela tudo', () async {
    await contaVencendoEm(10);
    await agendador.pedirPermissao();
    await c.read(definirAjusteProvider)('notificacoes', 'true');
    await ativarSincronizador();
    await esperar();
    final umDiaAntes = agendador.agendadas.first.quando;

    await c.read(definirAjusteProvider)('notificacoes_dias', '3');
    await esperar();
    final tresDiasAntes = agendador.agendadas.first.quando;
    expect(umDiaAntes.difference(tresDiasAntes).inDays, 2);

    await c.read(definirAjusteProvider)('notificacoes', 'false');
    await esperar();
    expect(agendador.agendadas, isEmpty);
  });

  test('pagar a conta tira o aviso', () async {
    await contaVencendoEm(5);
    final conta = await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'C', tipo: TipoConta.corrente, dataSaldoInicial: DateTime(2020),
    ));
    await agendador.pedirPermissao();
    await c.read(definirAjusteProvider)('notificacoes', 'true');
    await ativarSincronizador();
    await esperar();
    expect(agendador.agendadas, isNotEmpty);

    final oc = (await db.compromissosDao.todasOcorrencias())
        .where((o) => o.status == StatusOcorrencia.pendente)
        .toList();
    for (final o in oc) {
      await ServicoCompromisso(db).pagarOcorrencia(o, contaId: conta);
    }
    await esperar();
    // os meses seguintes continuam; mas o aviso daquela conta já não está lá
    expect(agendador.agendadas.where((n) => n.titulo.contains('Aluguel')).length,
        lessThan(oc.length + 1));
  });
}
