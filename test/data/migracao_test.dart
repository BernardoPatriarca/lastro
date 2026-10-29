import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';
import 'package:lastro/domain/enums.dart';

/// Simula quem já tinha o app instalado (schema v1): atualizar o app mantém os
/// dados e migra o padrão antigo do crédito seguro.
void main() {
  late Directory dir;
  late File arquivo;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('lastro_migracao');
    arquivo = File('${dir.path}/lastro.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  /// Cria o banco, grava [modo] e volta a versão para 1 (como o app antigo).
  Future<void> prepararBancoAntigo(String modo) async {
    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    await db.configuracoesDao.definir('modo_parcelados', modo);
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();
  }

  test('quem estava no padrão antigo (rígido) passa para a fatura do mês', () async {
    await prepararBancoAntigo('rigido');
    final db = AppDatabase.forTesting(NativeDatabase(arquivo)); // abre e migra
    addTearDown(db.close);
    expect(await db.configuracoesDao.obter('modo_parcelados'), 'parcela');
  });

  test('quem já usava "parcela" continua; os dados são preservados', () async {
    final antes = AppDatabase.forTesting(NativeDatabase(arquivo));
    final categorias = (await antes.categoriasDao.todas()).length;
    await antes.configuracoesDao.definir('modo_parcelados', 'parcela');
    await antes.configuracoesDao.definir('tema', 'light');
    await antes.customStatement('PRAGMA user_version = 1');
    await antes.close();

    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);
    expect(await db.configuracoesDao.obter('modo_parcelados'), 'parcela');
    expect(await db.configuracoesDao.obter('tema'), 'light');
    expect((await db.categoriasDao.todas()).length, categorias);
  });

  test('banco novo já nasce no padrão por fatura do mês', () async {
    final db = AppDatabase.forTesting(NativeDatabase(arquivo));
    addTearDown(db.close);
    expect(await db.configuracoesDao.obter('modo_parcelados'), 'parcela');
  });

  test('v2 -> v3: gasto fixo no crédito ganha o campo do cartão, sem perder dados', () async {
    // banco "antigo": compromissos sem a coluna cartao_id
    final novo = AppDatabase.forTesting(NativeDatabase(arquivo));
    await novo.compromissosDao.inserirCompromisso(CompromissosCompanion.insert(
      descricao: 'Aluguel',
      valor: 120000,
      diaVencimento: 5,
      dataInicio: DateTime(2026, 3, 5),
      tipo: TipoCompromisso.recorrente,
    ));
    await novo.customStatement('PRAGMA foreign_keys = OFF');
    await novo.customStatement(
      'CREATE TABLE compromissos_v2 AS SELECT id, descricao, categoria_id, '
      'forma_pagamento, conta_id, valor, dia_vencimento, data_inicio, tipo, '
      'numero_parcelas, ativo FROM compromissos',
    );
    await novo.customStatement('DROP TABLE compromissos');
    await novo.customStatement('ALTER TABLE compromissos_v2 RENAME TO compromissos');
    await novo.customStatement('PRAGMA user_version = 2');
    await novo.close();

    final db = AppDatabase.forTesting(NativeDatabase(arquivo)); // abre e migra
    addTearDown(db.close);
    final todos = await db.compromissosDao.todosCompromissos();
    expect(todos.length, 1);
    expect(todos.single.descricao, 'Aluguel');
    expect(todos.single.valor, 120000);
    expect(todos.single.cartaoId, isNull);
    // a coluna nova existe e aceita valor
    final colunas = await db.customSelect('PRAGMA table_info(compromissos)').get();
    expect(colunas.map((c) => c.read<String>('name')), contains('cartao_id'));
  });
}
