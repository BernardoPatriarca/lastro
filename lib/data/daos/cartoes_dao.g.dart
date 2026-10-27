// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cartoes_dao.dart';

// ignore_for_file: type=lint
mixin _$CartoesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContasTable get contas => attachedDatabase.contas;
  $CartoesTable get cartoes => attachedDatabase.cartoes;
  $FaturasTable get faturas => attachedDatabase.faturas;
  CartoesDaoManager get managers => CartoesDaoManager(this);
}

class CartoesDaoManager {
  final _$CartoesDaoMixin _db;
  CartoesDaoManager(this._db);
  $$ContasTableTableManager get contas =>
      $$ContasTableTableManager(_db.attachedDatabase, _db.contas);
  $$CartoesTableTableManager get cartoes =>
      $$CartoesTableTableManager(_db.attachedDatabase, _db.cartoes);
  $$FaturasTableTableManager get faturas =>
      $$FaturasTableTableManager(_db.attachedDatabase, _db.faturas);
}
