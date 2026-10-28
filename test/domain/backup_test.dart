import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/domain/backup.dart';

void main() {
  Backup exemplo({int versao = 1}) => Backup(
        versaoSchema: versao,
        exportadoEm: DateTime(2026, 3, 31, 10, 30),
        tabelas: {
          'contas': [
            {'id': 1, 'nome': 'Conta', 'saldo_inicial': 1000, 'ativa': 1},
          ],
          'lancamentos': [
            {'id': 1, 'data': 20260305, 'valor': 500, 'descricao': 'a', 'categoria_id': null},
            {'id': 2, 'data': 20260110, 'valor': 700, 'descricao': 'b', 'categoria_id': null},
            {'id': 3, 'data': 20260220, 'valor': 900, 'descricao': 'ç "aspas"', 'categoria_id': 4},
          ],
          'cartoes': <Map<String, Object?>>[],
        },
      );

  test('ida e volta em JSON preserva tudo (inclusive nulos e acentos)', () {
    final json = exemplo().paraJson();
    final volta = Backup.lerJson(json, versaoAtual: 1);
    expect(volta.versaoSchema, 1);
    expect(volta.exportadoEm, DateTime(2026, 3, 31, 10, 30));
    expect(volta.tabelas['contas']!.single['nome'], 'Conta');
    expect(volta.tabelas['lancamentos']![0]['categoria_id'], isNull);
    expect(volta.tabelas['lancamentos']![2]['descricao'], 'ç "aspas"');
    expect(volta.tabelas['cartoes'], isEmpty);
  });

  test('resumo: contagens e período dos lançamentos', () {
    final r = exemplo().resumir();
    expect(r.lancamentos, 3);
    expect(r.contas, 1);
    expect(r.cartoes, 0);
    expect(r.primeiroLancamento, DateTime(2026, 1, 10));
    expect(r.ultimoLancamento, DateTime(2026, 3, 5));
  });

  test('resumo de backup sem lançamentos', () {
    final r = Backup(
      versaoSchema: 1,
      exportadoEm: DateTime(2026),
      tabelas: const {},
    ).resumir();
    expect(r.lancamentos, 0);
    expect(r.primeiroLancamento, isNull);
  });

  test('recusa arquivo que não é JSON, que não é do Lastro ou corrompido', () {
    expect(() => Backup.lerJson('isso nao e json', versaoAtual: 1),
        throwsA(isA<BackupInvalido>()));
    expect(() => Backup.lerJson('{"formato":"outro"}', versaoAtual: 1),
        throwsA(isA<BackupInvalido>()));
    expect(() => Backup.lerJson('[1,2,3]', versaoAtual: 1), throwsA(isA<BackupInvalido>()));
    expect(
      () => Backup.lerJson(
          '{"formato":"lastro-backup","versaoSchema":1,"tabelas":{"contas":5}}',
          versaoAtual: 1),
      throwsA(isA<BackupInvalido>()),
    );
    expect(
      () => Backup.lerJson('{"formato":"lastro-backup","tabelas":{}}', versaoAtual: 1),
      throwsA(isA<BackupInvalido>()),
    );
  });

  test('valida a versão: mais nova é recusada, mais antiga é aceita', () {
    final futuro = exemplo(versao: 5).paraJson();
    expect(() => Backup.lerJson(futuro, versaoAtual: 2), throwsA(isA<BackupInvalido>()));
    expect(Backup.lerJson(exemplo(versao: 1).paraJson(), versaoAtual: 3).versaoSchema, 1);
  });
}
