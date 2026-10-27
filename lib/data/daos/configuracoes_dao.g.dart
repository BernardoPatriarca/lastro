// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuracoes_dao.dart';

// ignore_for_file: type=lint
mixin _$ConfiguracoesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConfiguracoesTable get configuracoes => attachedDatabase.configuracoes;
  ConfiguracoesDaoManager get managers => ConfiguracoesDaoManager(this);
}

class ConfiguracoesDaoManager {
  final _$ConfiguracoesDaoMixin _db;
  ConfiguracoesDaoManager(this._db);
  $$ConfiguracoesTableTableManager get configuracoes =>
      $$ConfiguracoesTableTableManager(_db.attachedDatabase, _db.configuracoes);
}
