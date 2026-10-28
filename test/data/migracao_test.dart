import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastro/data/banco.dart';

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
}
