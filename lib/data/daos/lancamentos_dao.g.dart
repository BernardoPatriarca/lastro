// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lancamentos_dao.dart';

// ignore_for_file: type=lint
mixin _$LancamentosDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriasTable get categorias => attachedDatabase.categorias;
  $ContasTable get contas => attachedDatabase.contas;
  $CartoesTable get cartoes => attachedDatabase.cartoes;
  $FaturasTable get faturas => attachedDatabase.faturas;
  $ComprasParceladasTable get comprasParceladas =>
      attachedDatabase.comprasParceladas;
  $InvestimentosTable get investimentos => attachedDatabase.investimentos;
  $LancamentosTable get lancamentos => attachedDatabase.lancamentos;
  LancamentosDaoManager get managers => LancamentosDaoManager(this);
}

class LancamentosDaoManager {
  final _$LancamentosDaoMixin _db;
  LancamentosDaoManager(this._db);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db.attachedDatabase, _db.categorias);
  $$ContasTableTableManager get contas =>
      $$ContasTableTableManager(_db.attachedDatabase, _db.contas);
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
