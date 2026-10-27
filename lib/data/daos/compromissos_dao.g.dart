// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compromissos_dao.dart';

// ignore_for_file: type=lint
mixin _$CompromissosDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriasTable get categorias => attachedDatabase.categorias;
  $ContasTable get contas => attachedDatabase.contas;
  $CompromissosTable get compromissos => attachedDatabase.compromissos;
  $OcorrenciasCompromissoTable get ocorrenciasCompromisso =>
      attachedDatabase.ocorrenciasCompromisso;
  $ReceitasRecorrentesTable get receitasRecorrentes =>
      attachedDatabase.receitasRecorrentes;
  CompromissosDaoManager get managers => CompromissosDaoManager(this);
}

class CompromissosDaoManager {
  final _$CompromissosDaoMixin _db;
  CompromissosDaoManager(this._db);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db.attachedDatabase, _db.categorias);
  $$ContasTableTableManager get contas =>
      $$ContasTableTableManager(_db.attachedDatabase, _db.contas);
  $$CompromissosTableTableManager get compromissos =>
      $$CompromissosTableTableManager(_db.attachedDatabase, _db.compromissos);
  $$OcorrenciasCompromissoTableTableManager get ocorrenciasCompromisso =>
      $$OcorrenciasCompromissoTableTableManager(
        _db.attachedDatabase,
        _db.ocorrenciasCompromisso,
      );
  $$ReceitasRecorrentesTableTableManager get receitasRecorrentes =>
      $$ReceitasRecorrentesTableTableManager(
        _db.attachedDatabase,
        _db.receitasRecorrentes,
      );
}
