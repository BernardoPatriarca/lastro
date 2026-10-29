import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'conversores.dart';

// Todo valor em dinheiro é INTEGER em centavos. Datas sem hora usam
// [ConversorData] (aaaammdd); competências são texto `aaaa-mm`.

@DataClassName('Conta')
class Contas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 80)();
  TextColumn get tipo => textEnum<TipoConta>()();
  IntColumn get saldoInicial => integer().withDefault(const Constant(0))();
  IntColumn get dataSaldoInicial => integer().map(const ConversorData())();
  BoolColumn get considerarNoCreditoSeguro =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();
}

@DataClassName('Cartao')
class Cartoes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 80)();
  IntColumn get limite => integer().withDefault(const Constant(0))();
  IntColumn get diaFechamento => integer()();
  IntColumn get diaVencimento => integer()();
  IntColumn get contaPagamentoId =>
      integer().nullable().references(Contas, #id)();
  IntColumn get cor => integer().withDefault(const Constant(0xFF0F766E))();
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();
}

@DataClassName('Fatura')
class Faturas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cartaoId => integer().references(Cartoes, #id)();

  /// Mês em que a fatura **fecha** (`aaaa-mm`).
  TextColumn get competencia => text()();
  IntColumn get dataFechamento => integer().map(const ConversorData())();
  IntColumn get dataVencimento => integer().map(const ConversorData())();
  TextColumn get status =>
      textEnum<StatusFatura>().withDefault(const Constant('aberta'))();
  IntColumn get dataPagamento =>
      integer().map(const ConversorData()).nullable()();
  IntColumn get lancamentoPagamentoId => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {cartaoId, competencia},
      ];
}

@DataClassName('Categoria')
class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 80)();

  /// Chave do ícone (ver `core/icones.dart`).
  TextColumn get icone => text().withDefault(const Constant('category'))();
  IntColumn get cor => integer().withDefault(const Constant(0xFF14B8A6))();
  TextColumn get tipo => textEnum<TipoCategoria>()();
  IntColumn get categoriaPaiId =>
      integer().nullable().references(Categorias, #id)();
  IntColumn get ordem => integer().withDefault(const Constant(0))();
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();
}

@DataClassName('Lancamento')
@TableIndex(name: 'idx_lancamentos_data', columns: {#data})
@TableIndex(name: 'idx_lancamentos_conta', columns: {#contaId})
@TableIndex(name: 'idx_lancamentos_fatura', columns: {#faturaId})
@TableIndex(name: 'idx_lancamentos_chave', columns: {#chaveImportacao})
class Lancamentos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => textEnum<TipoLancamento>()();

  /// Centavos, sempre positivo (o [tipo] define o sentido).
  /// Exceção: em `ajusteSaldo` o sinal define o sentido do ajuste.
  IntColumn get valor => integer()();
  IntColumn get data => integer().map(const ConversorData())();
  TextColumn get descricao => text().withDefault(const Constant(''))();
  IntColumn get categoriaId => integer().nullable().references(Categorias, #id)();
  TextColumn get formaPagamento => textEnum<FormaPagamento>().nullable()();

  /// Conta afetada. Nulo nas compras no crédito (que pertencem a um cartão).
  IntColumn get contaId => integer().nullable().references(Contas, #id)();
  @ReferenceName('lancamentosDestino')
  IntColumn get contaDestinoId => integer().nullable().references(Contas, #id)();
  IntColumn get cartaoId => integer().nullable().references(Cartoes, #id)();
  IntColumn get faturaId => integer().nullable().references(Faturas, #id)();
  IntColumn get compraParceladaId =>
      integer().nullable().references(ComprasParceladas, #id)();
  IntColumn get parcelaNumero => integer().nullable()();
  IntColumn get ocorrenciaCompromissoId => integer().nullable()();
  IntColumn get investimentoId =>
      integer().nullable().references(Investimentos, #id)();
  IntColumn get receitaRecorrenteId => integer().nullable()();
  TextColumn get origem =>
      textEnum<OrigemLancamento>().withDefault(const Constant('manual'))();

  /// FITID do OFX, ou data|valor|descrição normalizada. Serve para deduplicar.
  TextColumn get chaveImportacao => text().nullable()();
  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get atualizadoEm => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('CompraParcelada')
class ComprasParceladas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cartaoId => integer().references(Cartoes, #id)();
  TextColumn get descricao => text()();
  IntColumn get categoriaId => integer().nullable().references(Categorias, #id)();
  IntColumn get valorTotal => integer()();
  IntColumn get numeroParcelas => integer()();
  IntColumn get dataCompra => integer().map(const ConversorData())();
}

@DataClassName('Compromisso')
class Compromissos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get descricao => text()();
  IntColumn get categoriaId => integer().nullable().references(Categorias, #id)();
  TextColumn get formaPagamento =>
      textEnum<FormaPagamento>().withDefault(const Constant('boleto'))();
  IntColumn get contaId => integer().nullable().references(Contas, #id)();

  /// Gasto fixo **no crédito**: cartão em que a cobrança cai todo mês.
  IntColumn get cartaoId => integer().nullable().references(Cartoes, #id)();
  IntColumn get valor => integer()();
  IntColumn get diaVencimento => integer()();
  IntColumn get dataInicio => integer().map(const ConversorData())();
  TextColumn get tipo => textEnum<TipoCompromisso>()();
  IntColumn get numeroParcelas => integer().nullable()();
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();
}

@DataClassName('OcorrenciaCompromisso')
class OcorrenciasCompromisso extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get compromissoId => integer().references(Compromissos, #id)();
  TextColumn get competencia => text()();
  IntColumn get numeroParcela => integer().nullable()();
  IntColumn get valor => integer()();
  IntColumn get dataVencimento => integer().map(const ConversorData())();
  TextColumn get status =>
      textEnum<StatusOcorrencia>().withDefault(const Constant('pendente'))();
  IntColumn get lancamentoId => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {compromissoId, competencia},
      ];
}

@DataClassName('ReceitaRecorrente')
class ReceitasRecorrentes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get descricao => text()();
  IntColumn get categoriaId => integer().nullable().references(Categorias, #id)();
  IntColumn get contaId => integer().references(Contas, #id)();
  IntColumn get valorPrevisto => integer()();
  IntColumn get diaPrevisto => integer()();
  IntColumn get dataInicio => integer().map(const ConversorData())();
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();
}

@DataClassName('Investimento')
class Investimentos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  TextColumn get tipo => textEnum<TipoInvestimento>()();
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();
}

@DataClassName('MovimentoInvestimento')
class MovimentosInvestimento extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get investimentoId => integer().references(Investimentos, #id)();
  TextColumn get tipo => textEnum<TipoMovimentoInvestimento>()();
  IntColumn get valor => integer()();
  IntColumn get data => integer().map(const ConversorData())();
  IntColumn get lancamentoId => integer().nullable()();
}

@DataClassName('Meta')
class Metas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  IntColumn get valorAlvo => integer()();
  IntColumn get prazo => integer().map(const ConversorData())();
  IntColumn get investimentoId =>
      integer().nullable().references(Investimentos, #id)();
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();
}

@DataClassName('Orcamento')
class Orcamentos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoriaId => integer().references(Categorias, #id)();
  TextColumn get competencia => text()();
  IntColumn get limite => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoriaId, competencia},
      ];
}

@DataClassName('RegraCategorizacao')
class RegrasCategorizacao extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Texto procurado na descrição (sem acento, sem diferenciar maiúsculas).
  TextColumn get padrao => text()();
  IntColumn get categoriaId => integer().references(Categorias, #id)();
  IntColumn get prioridade => integer().withDefault(const Constant(0))();
}

@DataClassName('Configuracao')
class Configuracoes extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {chave};
}

/// Mapeamento de colunas de CSV salvo por banco (Etapa 9).
@DataClassName('MapeamentoCsvSalvo')
class MapeamentosCsv extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().unique()();
  TextColumn get separador => text().withDefault(const Constant(';'))();
  BoolColumn get temCabecalho => boolean().withDefault(const Constant(true))();
  IntColumn get colunaData => integer()();
  IntColumn get colunaDescricao => integer()();
  IntColumn get colunaValor => integer()();
  IntColumn get colunaTipo => integer().nullable()();
  TextColumn get formatoData => text().withDefault(const Constant('dd/MM/yyyy'))();

  /// Faturas de cartão costumam trazer compras como valor positivo.
  BoolColumn get positivoEhGasto => boolean().withDefault(const Constant(false))();
}
