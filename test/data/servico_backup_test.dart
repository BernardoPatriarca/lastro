import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/data/dados_ficticios.dart';
import 'package:lastro/data/manutencao.dart';
import 'package:lastro/data/servicos/servico_backup.dart';
import 'package:lastro/domain/backup.dart';
import 'package:lastro/domain/enums.dart';

void main() {
  late AppDatabase db;
  late ServicoBackup s;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    s = ServicoBackup(db);
  });
  tearDown(() => db.close());

  Future<Map<String, int>> contagens() async => {
        for (final t in tabelasDoApp)
          t: (await db.customSelect('SELECT COUNT(*) AS n FROM $t').getSingle())
              .read<int>('n'),
      };

  Future<List<Map<String, Object?>>> linhas(String t) async => [
        for (final l in await db.customSelect('SELECT * FROM $t ORDER BY id').get())
          Map<String, Object?>.from(l.data),
      ];

  test('exportar e restaurar reproduz o banco exatamente', () async {
    await popularDadosFicticios(db);
    final antes = await contagens();
    final lancAntes = await linhas('lancamentos');
    final fatAntes = await linhas('faturas');
    expect(antes['lancamentos'], greaterThan(30));

    // passa pelo JSON de verdade (como no arquivo)
    final json = (await s.exportar()).paraJson();

    await apagarTodosOsDados(db);
    expect((await contagens())['lancamentos'], 0);

    await s.restaurar(s.ler(json));

    expect(await contagens(), antes);
    expect(await linhas('lancamentos'), lancAntes);
    expect(await linhas('faturas'), fatAntes);
    // as configurações voltaram e o app continua funcional
    expect((await db.configuracoesDao.todas())['modo_parcelados'], 'rigido');
    await db.lancamentosDao.inserir(LancamentosCompanion.insert(
      tipo: TipoLancamento.ganho, valor: 1, data: DateTime(2026, 1, 1),
    ));
  });

  test('restaurar substitui o que existia (não mistura)', () async {
    await popularDadosFicticios(db);
    final json = (await s.exportar()).paraJson();

    // dados extras depois do backup
    await db.contasDao.inserir(ContasCompanion.insert(
      nome: 'Conta extra', tipo: TipoConta.carteira, dataSaldoInicial: DateTime(2026, 1, 1),
    ));
    expect((await db.select(db.contas).get()).length, 3);

    await s.restaurar(s.ler(json));
    expect((await db.select(db.contas).get()).length, 2);
  });

  test('backup com referência quebrada falha e NÃO altera os dados atuais', () async {
    await popularDadosFicticios(db);
    final antes = await contagens();

    final bom = await s.exportar();
    final tabelas = {
      for (final e in bom.tabelas.entries) e.key: [...e.value],
    };
    tabelas['lancamentos']!.add({
      'id': 99999,
      'tipo': 'gasto',
      'valor': 1,
      'data': 20260101,
      'descricao': '',
      'conta_id': 424242, // conta que não existe
      'origem': 'manual',
      'criado_em': 0,
      'atualizado_em': 0,
    });
    final quebrado = Backup(
      versaoSchema: bom.versaoSchema,
      exportadoEm: bom.exportadoEm,
      tabelas: tabelas,
    );

    await expectLater(s.restaurar(quebrado), throwsA(anything));
    expect(await contagens(), antes); // tudo como estava
  });

  test('tabela desconhecida e coluna maliciosa são recusadas antes de gravar', () async {
    await popularDadosFicticios(db);
    final antes = await contagens();
    final base = await s.exportar();

    final comTabela = Backup(
      versaoSchema: 1,
      exportadoEm: base.exportadoEm,
      tabelas: {
        ...base.tabelas,
        'tabela_inventada': [
          {'id': 1}
        ],
      },
    );
    await expectLater(s.restaurar(comTabela), throwsA(isA<BackupInvalido>()));

    final comColuna = Backup(
      versaoSchema: 1,
      exportadoEm: base.exportadoEm,
      tabelas: {
        ...base.tabelas,
        'contas': [
          {'id': 9, 'nome); DROP TABLE contas; --': 'x'},
        ],
      },
    );
    await expectLater(s.restaurar(comColuna), throwsA(isA<BackupInvalido>()));
    expect(await contagens(), antes);
  });

  test('ler recusa lixo e versão futura', () {
    expect(() => s.ler('lixo'), throwsA(isA<BackupInvalido>()));
    expect(
      () => s.ler('{"formato":"lastro-backup","versaoSchema":99,"tabelas":{}}'),
      throwsA(isA<BackupInvalido>()),
    );
  });

  test('o valor de valor/ids sobrevive (saldo calculado igual antes e depois)', () async {
    await popularDadosFicticios(db);
    Future<int> somaValores() async =>
        (await db.customSelect('SELECT SUM(valor) AS s FROM lancamentos').getSingle())
            .read<int>('s');
    final antes = await somaValores();
    final json = (await s.exportar()).paraJson();
    await apagarTodosOsDados(db);
    await s.restaurar(s.ler(json));
    expect(await somaValores(), antes);
  });
}
