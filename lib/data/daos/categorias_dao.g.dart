// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorias_dao.dart';

// ignore_for_file: type=lint
mixin _$CategoriasDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriasTable get categorias => attachedDatabase.categorias;
  $RegrasCategorizacaoTable get regrasCategorizacao =>
      attachedDatabase.regrasCategorizacao;
  $ContasTable get contas => attachedDatabase.contas;
  $CartoesTable get cartoes => attachedDatabase.cartoes;
  $FaturasTable get faturas => attachedDatabase.faturas;
  $ComprasParceladasTable get comprasParceladas =>
      attachedDatabase.comprasParceladas;
  $InvestimentosTable get investimentos => attachedDatabase.investimentos;
  $LancamentosTable get lancamentos => attachedDatabase.lancamentos;
  CategoriasDaoManager get managers => CategoriasDaoManager(this);
}

class CategoriasDaoManager {
  final _$CategoriasDaoMixin _db;
  CategoriasDaoManager(this._db);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db.attachedDatabase, _db.categorias);
  $$RegrasCategorizacaoTableTableManager get regrasCategorizacao =>
      $$RegrasCategorizacaoTableTableManager(
        _db.attachedDatabase,
        _db.regrasCategorizacao,
      );
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
