// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contas_dao.dart';

// ignore_for_file: type=lint
mixin _$ContasDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContasTable get contas => attachedDatabase.contas;
  $CategoriasTable get categorias => attachedDatabase.categorias;
  $CartoesTable get cartoes => attachedDatabase.cartoes;
  $FaturasTable get faturas => attachedDatabase.faturas;
  $ComprasParceladasTable get comprasParceladas =>
      attachedDatabase.comprasParceladas;
  $InvestimentosTable get investimentos => attachedDatabase.investimentos;
  $LancamentosTable get lancamentos => attachedDatabase.lancamentos;
  ContasDaoManager get managers => ContasDaoManager(this);
}

class ContasDaoManager {
  final _$ContasDaoMixin _db;
  ContasDaoManager(this._db);
  $$ContasTableTableManager get contas =>
      $$ContasTableTableManager(_db.attachedDatabase, _db.contas);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db.attachedDatabase, _db.categorias);
  $$CartoesTableTableManager get cartoes =>
      $$CartoesTableTableManager(_db.attachedDatabase, _db.cartoes);
  $$FaturasTableTableManager get faturas =>
      $$FaturasTableTableManager(_db.attachedDatabase, _db.faturas);
  $$ComprasParceladasTableTableManager get comprasParceladas =>
      $$ComprasParceladasTableTableManager(
        _db.attachedDatabase,
        _db.comprasParceladas,
      );
  $$InvestimentosTableTableManager get investimentos =>
      $$InvestimentosTableTableManager(_db.attachedDatabase, _db.investimentos);
  $$LancamentosTableTableManager get lancamentos =>
      $$LancamentosTableTableManager(_db.attachedDatabase, _db.lancamentos);
}
