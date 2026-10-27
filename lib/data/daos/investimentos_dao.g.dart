// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investimentos_dao.dart';

// ignore_for_file: type=lint
mixin _$InvestimentosDaoMixin on DatabaseAccessor<AppDatabase> {
  $InvestimentosTable get investimentos => attachedDatabase.investimentos;
  $MovimentosInvestimentoTable get movimentosInvestimento =>
      attachedDatabase.movimentosInvestimento;
  $MetasTable get metas => attachedDatabase.metas;
  $CategoriasTable get categorias => attachedDatabase.categorias;
  $OrcamentosTable get orcamentos => attachedDatabase.orcamentos;
  InvestimentosDaoManager get managers => InvestimentosDaoManager(this);
}

class InvestimentosDaoManager {
  final _$InvestimentosDaoMixin _db;
  InvestimentosDaoManager(this._db);
  $$InvestimentosTableTableManager get investimentos =>
      $$InvestimentosTableTableManager(_db.attachedDatabase, _db.investimentos);
  $$MovimentosInvestimentoTableTableManager get movimentosInvestimento =>
      $$MovimentosInvestimentoTableTableManager(
        _db.attachedDatabase,
        _db.movimentosInvestimento,
      );
  $$MetasTableTableManager get metas =>
      $$MetasTableTableManager(_db.attachedDatabase, _db.metas);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db.attachedDatabase, _db.categorias);
  $$OrcamentosTableTableManager get orcamentos =>
      $$OrcamentosTableTableManager(_db.attachedDatabase, _db.orcamentos);
}
