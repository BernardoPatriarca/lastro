// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapeamentos_dao.dart';

// ignore_for_file: type=lint
mixin _$MapeamentosDaoMixin on DatabaseAccessor<AppDatabase> {
  $MapeamentosCsvTable get mapeamentosCsv => attachedDatabase.mapeamentosCsv;
  MapeamentosDaoManager get managers => MapeamentosDaoManager(this);
}

class MapeamentosDaoManager {
  final _$MapeamentosDaoMixin _db;
  MapeamentosDaoManager(this._db);
  $$MapeamentosCsvTableTableManager get mapeamentosCsv =>
      $$MapeamentosCsvTableTableManager(
        _db.attachedDatabase,
        _db.mapeamentosCsv,
      );
}
