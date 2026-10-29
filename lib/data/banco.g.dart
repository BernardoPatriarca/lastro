// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco.dart';

// ignore_for_file: type=lint
class $ContasTable extends Contas with TableInfo<$ContasTable, Conta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoConta, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoConta>($ContasTable.$convertertipo);
  static const VerificationMeta _saldoInicialMeta = const VerificationMeta(
    'saldoInicial',
  );
  @override
  late final GeneratedColumn<int> saldoInicial = GeneratedColumn<int>(
    'saldo_inicial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dataSaldoInicial =
      GeneratedColumn<int>(
        'data_saldo_inicial',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ContasTable.$converterdataSaldoInicial);
  static const VerificationMeta _considerarNoCreditoSeguroMeta =
      const VerificationMeta('considerarNoCreditoSeguro');
  @override
  late final GeneratedColumn<bool> considerarNoCreditoSeguro =
      GeneratedColumn<bool>(
        'considerar_no_credito_seguro',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("considerar_no_credito_seguro" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    tipo,
    saldoInicial,
    dataSaldoInicial,
    considerarNoCreditoSeguro,
    ativa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('saldo_inicial')) {
      context.handle(
        _saldoInicialMeta,
        saldoInicial.isAcceptableOrUnknown(
          data['saldo_inicial']!,
          _saldoInicialMeta,
        ),
      );
    }
    if (data.containsKey('considerar_no_credito_seguro')) {
      context.handle(
        _considerarNoCreditoSeguroMeta,
        considerarNoCreditoSeguro.isAcceptableOrUnknown(
          data['considerar_no_credito_seguro']!,
          _considerarNoCreditoSeguroMeta,
        ),
      );
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      tipo: $ContasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      saldoInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_inicial'],
      )!,
      dataSaldoInicial: $ContasTable.$converterdataSaldoInicial.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_saldo_inicial'],
        )!,
      ),
      considerarNoCreditoSeguro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}considerar_no_credito_seguro'],
      )!,
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativa'],
      )!,
    );
  }

  @override
  $ContasTable createAlias(String alias) {
    return $ContasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoConta, String, String> $convertertipo =
      const EnumNameConverter<TipoConta>(TipoConta.values);
  static TypeConverter<DateTime, int> $converterdataSaldoInicial =
      const ConversorData();
}

class Conta extends DataClass implements Insertable<Conta> {
  final int id;
  final String nome;
  final TipoConta tipo;
  final int saldoInicial;
  final DateTime dataSaldoInicial;
  final bool considerarNoCreditoSeguro;
  final bool ativa;
  const Conta({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.saldoInicial,
    required this.dataSaldoInicial,
    required this.considerarNoCreditoSeguro,
    required this.ativa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    {
      map['tipo'] = Variable<String>($ContasTable.$convertertipo.toSql(tipo));
    }
    map['saldo_inicial'] = Variable<int>(saldoInicial);
    {
      map['data_saldo_inicial'] = Variable<int>(
        $ContasTable.$converterdataSaldoInicial.toSql(dataSaldoInicial),
      );
    }
    map['considerar_no_credito_seguro'] = Variable<bool>(
      considerarNoCreditoSeguro,
    );
    map['ativa'] = Variable<bool>(ativa);
    return map;
  }

  ContasCompanion toCompanion(bool nullToAbsent) {
    return ContasCompanion(
      id: Value(id),
      nome: Value(nome),
      tipo: Value(tipo),
      saldoInicial: Value(saldoInicial),
      dataSaldoInicial: Value(dataSaldoInicial),
      considerarNoCreditoSeguro: Value(considerarNoCreditoSeguro),
      ativa: Value(ativa),
    );
  }

  factory Conta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conta(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      tipo: $ContasTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      saldoInicial: serializer.fromJson<int>(json['saldoInicial']),
      dataSaldoInicial: serializer.fromJson<DateTime>(json['dataSaldoInicial']),
      considerarNoCreditoSeguro: serializer.fromJson<bool>(
        json['considerarNoCreditoSeguro'],
      ),
      ativa: serializer.fromJson<bool>(json['ativa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'tipo': serializer.toJson<String>(
        $ContasTable.$convertertipo.toJson(tipo),
      ),
      'saldoInicial': serializer.toJson<int>(saldoInicial),
      'dataSaldoInicial': serializer.toJson<DateTime>(dataSaldoInicial),
      'considerarNoCreditoSeguro': serializer.toJson<bool>(
        considerarNoCreditoSeguro,
      ),
      'ativa': serializer.toJson<bool>(ativa),
    };
  }

  Conta copyWith({
    int? id,
    String? nome,
    TipoConta? tipo,
    int? saldoInicial,
    DateTime? dataSaldoInicial,
    bool? considerarNoCreditoSeguro,
    bool? ativa,
  }) => Conta(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    saldoInicial: saldoInicial ?? this.saldoInicial,
    dataSaldoInicial: dataSaldoInicial ?? this.dataSaldoInicial,
    considerarNoCreditoSeguro:
        considerarNoCreditoSeguro ?? this.considerarNoCreditoSeguro,
    ativa: ativa ?? this.ativa,
  );
  Conta copyWithCompanion(ContasCompanion data) {
    return Conta(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      saldoInicial: data.saldoInicial.present
          ? data.saldoInicial.value
          : this.saldoInicial,
      dataSaldoInicial: data.dataSaldoInicial.present
          ? data.dataSaldoInicial.value
          : this.dataSaldoInicial,
      considerarNoCreditoSeguro: data.considerarNoCreditoSeguro.present
          ? data.considerarNoCreditoSeguro.value
          : this.considerarNoCreditoSeguro,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conta(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('saldoInicial: $saldoInicial, ')
          ..write('dataSaldoInicial: $dataSaldoInicial, ')
          ..write('considerarNoCreditoSeguro: $considerarNoCreditoSeguro, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    tipo,
    saldoInicial,
    dataSaldoInicial,
    considerarNoCreditoSeguro,
    ativa,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conta &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.tipo == this.tipo &&
          other.saldoInicial == this.saldoInicial &&
          other.dataSaldoInicial == this.dataSaldoInicial &&
          other.considerarNoCreditoSeguro == this.considerarNoCreditoSeguro &&
          other.ativa == this.ativa);
}

class ContasCompanion extends UpdateCompanion<Conta> {
  final Value<int> id;
  final Value<String> nome;
  final Value<TipoConta> tipo;
  final Value<int> saldoInicial;
  final Value<DateTime> dataSaldoInicial;
  final Value<bool> considerarNoCreditoSeguro;
  final Value<bool> ativa;
  const ContasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.tipo = const Value.absent(),
    this.saldoInicial = const Value.absent(),
    this.dataSaldoInicial = const Value.absent(),
    this.considerarNoCreditoSeguro = const Value.absent(),
    this.ativa = const Value.absent(),
  });
  ContasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required TipoConta tipo,
    this.saldoInicial = const Value.absent(),
    required DateTime dataSaldoInicial,
    this.considerarNoCreditoSeguro = const Value.absent(),
    this.ativa = const Value.absent(),
  }) : nome = Value(nome),
       tipo = Value(tipo),
       dataSaldoInicial = Value(dataSaldoInicial);
  static Insertable<Conta> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? tipo,
    Expression<int>? saldoInicial,
    Expression<int>? dataSaldoInicial,
    Expression<bool>? considerarNoCreditoSeguro,
    Expression<bool>? ativa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (tipo != null) 'tipo': tipo,
      if (saldoInicial != null) 'saldo_inicial': saldoInicial,
      if (dataSaldoInicial != null) 'data_saldo_inicial': dataSaldoInicial,
      if (considerarNoCreditoSeguro != null)
        'considerar_no_credito_seguro': considerarNoCreditoSeguro,
      if (ativa != null) 'ativa': ativa,
    });
  }

  ContasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<TipoConta>? tipo,
    Value<int>? saldoInicial,
    Value<DateTime>? dataSaldoInicial,
    Value<bool>? considerarNoCreditoSeguro,
    Value<bool>? ativa,
  }) {
    return ContasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      saldoInicial: saldoInicial ?? this.saldoInicial,
      dataSaldoInicial: dataSaldoInicial ?? this.dataSaldoInicial,
      considerarNoCreditoSeguro:
          considerarNoCreditoSeguro ?? this.considerarNoCreditoSeguro,
      ativa: ativa ?? this.ativa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $ContasTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (saldoInicial.present) {
      map['saldo_inicial'] = Variable<int>(saldoInicial.value);
    }
    if (dataSaldoInicial.present) {
      map['data_saldo_inicial'] = Variable<int>(
        $ContasTable.$converterdataSaldoInicial.toSql(dataSaldoInicial.value),
      );
    }
    if (considerarNoCreditoSeguro.present) {
      map['considerar_no_credito_seguro'] = Variable<bool>(
        considerarNoCreditoSeguro.value,
      );
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('saldoInicial: $saldoInicial, ')
          ..write('dataSaldoInicial: $dataSaldoInicial, ')
          ..write('considerarNoCreditoSeguro: $considerarNoCreditoSeguro, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }
}

class $CartoesTable extends Cartoes with TableInfo<$CartoesTable, Cartao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limiteMeta = const VerificationMeta('limite');
  @override
  late final GeneratedColumn<int> limite = GeneratedColumn<int>(
    'limite',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _diaFechamentoMeta = const VerificationMeta(
    'diaFechamento',
  );
  @override
  late final GeneratedColumn<int> diaFechamento = GeneratedColumn<int>(
    'dia_fechamento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaVencimentoMeta = const VerificationMeta(
    'diaVencimento',
  );
  @override
  late final GeneratedColumn<int> diaVencimento = GeneratedColumn<int>(
    'dia_vencimento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contaPagamentoIdMeta = const VerificationMeta(
    'contaPagamentoId',
  );
  @override
  late final GeneratedColumn<int> contaPagamentoId = GeneratedColumn<int>(
    'conta_pagamento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contas (id)',
    ),
  );
  static const VerificationMeta _corMeta = const VerificationMeta('cor');
  @override
  late final GeneratedColumn<int> cor = GeneratedColumn<int>(
    'cor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF0F766E),
  );
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    limite,
    diaFechamento,
    diaVencimento,
    contaPagamentoId,
    cor,
    ativo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cartoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cartao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('limite')) {
      context.handle(
        _limiteMeta,
        limite.isAcceptableOrUnknown(data['limite']!, _limiteMeta),
      );
    }
    if (data.containsKey('dia_fechamento')) {
      context.handle(
        _diaFechamentoMeta,
        diaFechamento.isAcceptableOrUnknown(
          data['dia_fechamento']!,
          _diaFechamentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaFechamentoMeta);
    }
    if (data.containsKey('dia_vencimento')) {
      context.handle(
        _diaVencimentoMeta,
        diaVencimento.isAcceptableOrUnknown(
          data['dia_vencimento']!,
          _diaVencimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaVencimentoMeta);
    }
    if (data.containsKey('conta_pagamento_id')) {
      context.handle(
        _contaPagamentoIdMeta,
        contaPagamentoId.isAcceptableOrUnknown(
          data['conta_pagamento_id']!,
          _contaPagamentoIdMeta,
        ),
      );
    }
    if (data.containsKey('cor')) {
      context.handle(
        _corMeta,
        cor.isAcceptableOrUnknown(data['cor']!, _corMeta),
      );
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cartao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cartao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      limite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limite'],
      )!,
      diaFechamento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_fechamento'],
      )!,
      diaVencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_vencimento'],
      )!,
      contaPagamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_pagamento_id'],
      ),
      cor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cor'],
      )!,
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
    );
  }

  @override
  $CartoesTable createAlias(String alias) {
    return $CartoesTable(attachedDatabase, alias);
  }
}

class Cartao extends DataClass implements Insertable<Cartao> {
  final int id;
  final String nome;
  final int limite;
  final int diaFechamento;
  final int diaVencimento;
  final int? contaPagamentoId;
  final int cor;
  final bool ativo;
  const Cartao({
    required this.id,
    required this.nome,
    required this.limite,
    required this.diaFechamento,
    required this.diaVencimento,
    this.contaPagamentoId,
    required this.cor,
    required this.ativo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['limite'] = Variable<int>(limite);
    map['dia_fechamento'] = Variable<int>(diaFechamento);
    map['dia_vencimento'] = Variable<int>(diaVencimento);
    if (!nullToAbsent || contaPagamentoId != null) {
      map['conta_pagamento_id'] = Variable<int>(contaPagamentoId);
    }
    map['cor'] = Variable<int>(cor);
    map['ativo'] = Variable<bool>(ativo);
    return map;
  }

  CartoesCompanion toCompanion(bool nullToAbsent) {
    return CartoesCompanion(
      id: Value(id),
      nome: Value(nome),
      limite: Value(limite),
      diaFechamento: Value(diaFechamento),
      diaVencimento: Value(diaVencimento),
      contaPagamentoId: contaPagamentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaPagamentoId),
      cor: Value(cor),
      ativo: Value(ativo),
    );
  }

  factory Cartao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cartao(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      limite: serializer.fromJson<int>(json['limite']),
      diaFechamento: serializer.fromJson<int>(json['diaFechamento']),
      diaVencimento: serializer.fromJson<int>(json['diaVencimento']),
      contaPagamentoId: serializer.fromJson<int?>(json['contaPagamentoId']),
      cor: serializer.fromJson<int>(json['cor']),
      ativo: serializer.fromJson<bool>(json['ativo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'limite': serializer.toJson<int>(limite),
      'diaFechamento': serializer.toJson<int>(diaFechamento),
      'diaVencimento': serializer.toJson<int>(diaVencimento),
      'contaPagamentoId': serializer.toJson<int?>(contaPagamentoId),
      'cor': serializer.toJson<int>(cor),
      'ativo': serializer.toJson<bool>(ativo),
    };
  }

  Cartao copyWith({
    int? id,
    String? nome,
    int? limite,
    int? diaFechamento,
    int? diaVencimento,
    Value<int?> contaPagamentoId = const Value.absent(),
    int? cor,
    bool? ativo,
  }) => Cartao(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    limite: limite ?? this.limite,
    diaFechamento: diaFechamento ?? this.diaFechamento,
    diaVencimento: diaVencimento ?? this.diaVencimento,
    contaPagamentoId: contaPagamentoId.present
        ? contaPagamentoId.value
        : this.contaPagamentoId,
    cor: cor ?? this.cor,
    ativo: ativo ?? this.ativo,
  );
  Cartao copyWithCompanion(CartoesCompanion data) {
    return Cartao(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      limite: data.limite.present ? data.limite.value : this.limite,
      diaFechamento: data.diaFechamento.present
          ? data.diaFechamento.value
          : this.diaFechamento,
      diaVencimento: data.diaVencimento.present
          ? data.diaVencimento.value
          : this.diaVencimento,
      contaPagamentoId: data.contaPagamentoId.present
          ? data.contaPagamentoId.value
          : this.contaPagamentoId,
      cor: data.cor.present ? data.cor.value : this.cor,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cartao(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('limite: $limite, ')
          ..write('diaFechamento: $diaFechamento, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('contaPagamentoId: $contaPagamentoId, ')
          ..write('cor: $cor, ')
          ..write('ativo: $ativo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    limite,
    diaFechamento,
    diaVencimento,
    contaPagamentoId,
    cor,
    ativo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cartao &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.limite == this.limite &&
          other.diaFechamento == this.diaFechamento &&
          other.diaVencimento == this.diaVencimento &&
          other.contaPagamentoId == this.contaPagamentoId &&
          other.cor == this.cor &&
          other.ativo == this.ativo);
}

class CartoesCompanion extends UpdateCompanion<Cartao> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> limite;
  final Value<int> diaFechamento;
  final Value<int> diaVencimento;
  final Value<int?> contaPagamentoId;
  final Value<int> cor;
  final Value<bool> ativo;
  const CartoesCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.limite = const Value.absent(),
    this.diaFechamento = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.contaPagamentoId = const Value.absent(),
    this.cor = const Value.absent(),
    this.ativo = const Value.absent(),
  });
  CartoesCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.limite = const Value.absent(),
    required int diaFechamento,
    required int diaVencimento,
    this.contaPagamentoId = const Value.absent(),
    this.cor = const Value.absent(),
    this.ativo = const Value.absent(),
  }) : nome = Value(nome),
       diaFechamento = Value(diaFechamento),
       diaVencimento = Value(diaVencimento);
  static Insertable<Cartao> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? limite,
    Expression<int>? diaFechamento,
    Expression<int>? diaVencimento,
    Expression<int>? contaPagamentoId,
    Expression<int>? cor,
    Expression<bool>? ativo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (limite != null) 'limite': limite,
      if (diaFechamento != null) 'dia_fechamento': diaFechamento,
      if (diaVencimento != null) 'dia_vencimento': diaVencimento,
      if (contaPagamentoId != null) 'conta_pagamento_id': contaPagamentoId,
      if (cor != null) 'cor': cor,
      if (ativo != null) 'ativo': ativo,
    });
  }

  CartoesCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int>? limite,
    Value<int>? diaFechamento,
    Value<int>? diaVencimento,
    Value<int?>? contaPagamentoId,
    Value<int>? cor,
    Value<bool>? ativo,
  }) {
    return CartoesCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      limite: limite ?? this.limite,
      diaFechamento: diaFechamento ?? this.diaFechamento,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      contaPagamentoId: contaPagamentoId ?? this.contaPagamentoId,
      cor: cor ?? this.cor,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (limite.present) {
      map['limite'] = Variable<int>(limite.value);
    }
    if (diaFechamento.present) {
      map['dia_fechamento'] = Variable<int>(diaFechamento.value);
    }
    if (diaVencimento.present) {
      map['dia_vencimento'] = Variable<int>(diaVencimento.value);
    }
    if (contaPagamentoId.present) {
      map['conta_pagamento_id'] = Variable<int>(contaPagamentoId.value);
    }
    if (cor.present) {
      map['cor'] = Variable<int>(cor.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartoesCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('limite: $limite, ')
          ..write('diaFechamento: $diaFechamento, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('contaPagamentoId: $contaPagamentoId, ')
          ..write('cor: $cor, ')
          ..write('ativo: $ativo')
          ..write(')'))
        .toString();
  }
}

class $FaturasTable extends Faturas with TableInfo<$FaturasTable, Fatura> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FaturasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cartoes (id)',
    ),
  );
  static const VerificationMeta _competenciaMeta = const VerificationMeta(
    'competencia',
  );
  @override
  late final GeneratedColumn<String> competencia = GeneratedColumn<String>(
    'competencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dataFechamento =
      GeneratedColumn<int>(
        'data_fechamento',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($FaturasTable.$converterdataFechamento);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dataVencimento =
      GeneratedColumn<int>(
        'data_vencimento',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($FaturasTable.$converterdataVencimento);
  @override
  late final GeneratedColumnWithTypeConverter<StatusFatura, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('aberta'),
      ).withConverter<StatusFatura>($FaturasTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> dataPagamento =
      GeneratedColumn<int>(
        'data_pagamento',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($FaturasTable.$converterdataPagamenton);
  static const VerificationMeta _lancamentoPagamentoIdMeta =
      const VerificationMeta('lancamentoPagamentoId');
  @override
  late final GeneratedColumn<int> lancamentoPagamentoId = GeneratedColumn<int>(
    'lancamento_pagamento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cartaoId,
    competencia,
    dataFechamento,
    dataVencimento,
    status,
    dataPagamento,
    lancamentoPagamentoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'faturas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fatura> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cartaoIdMeta);
    }
    if (data.containsKey('competencia')) {
      context.handle(
        _competenciaMeta,
        competencia.isAcceptableOrUnknown(
          data['competencia']!,
          _competenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_competenciaMeta);
    }
    if (data.containsKey('lancamento_pagamento_id')) {
      context.handle(
        _lancamentoPagamentoIdMeta,
        lancamentoPagamentoId.isAcceptableOrUnknown(
          data['lancamento_pagamento_id']!,
          _lancamentoPagamentoIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cartaoId, competencia},
  ];
  @override
  Fatura map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fatura(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      )!,
      competencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competencia'],
      )!,
      dataFechamento: $FaturasTable.$converterdataFechamento.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_fechamento'],
        )!,
      ),
      dataVencimento: $FaturasTable.$converterdataVencimento.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_vencimento'],
        )!,
      ),
      status: $FaturasTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      dataPagamento: $FaturasTable.$converterdataPagamenton.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_pagamento'],
        ),
      ),
      lancamentoPagamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lancamento_pagamento_id'],
      ),
    );
  }

  @override
  $FaturasTable createAlias(String alias) {
    return $FaturasTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdataFechamento =
      const ConversorData();
  static TypeConverter<DateTime, int> $converterdataVencimento =
      const ConversorData();
  static JsonTypeConverter2<StatusFatura, String, String> $converterstatus =
      const EnumNameConverter<StatusFatura>(StatusFatura.values);
  static TypeConverter<DateTime, int> $converterdataPagamento =
      const ConversorData();
  static TypeConverter<DateTime?, int?> $converterdataPagamenton =
      NullAwareTypeConverter.wrap($converterdataPagamento);
}

class Fatura extends DataClass implements Insertable<Fatura> {
  final int id;
  final int cartaoId;

  /// Mês em que a fatura **fecha** (`aaaa-mm`).
  final String competencia;
  final DateTime dataFechamento;
  final DateTime dataVencimento;
  final StatusFatura status;
  final DateTime? dataPagamento;
  final int? lancamentoPagamentoId;
  const Fatura({
    required this.id,
    required this.cartaoId,
    required this.competencia,
    required this.dataFechamento,
    required this.dataVencimento,
    required this.status,
    this.dataPagamento,
    this.lancamentoPagamentoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cartao_id'] = Variable<int>(cartaoId);
    map['competencia'] = Variable<String>(competencia);
    {
      map['data_fechamento'] = Variable<int>(
        $FaturasTable.$converterdataFechamento.toSql(dataFechamento),
      );
    }
    {
      map['data_vencimento'] = Variable<int>(
        $FaturasTable.$converterdataVencimento.toSql(dataVencimento),
      );
    }
    {
      map['status'] = Variable<String>(
        $FaturasTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || dataPagamento != null) {
      map['data_pagamento'] = Variable<int>(
        $FaturasTable.$converterdataPagamenton.toSql(dataPagamento),
      );
    }
    if (!nullToAbsent || lancamentoPagamentoId != null) {
      map['lancamento_pagamento_id'] = Variable<int>(lancamentoPagamentoId);
    }
    return map;
  }

  FaturasCompanion toCompanion(bool nullToAbsent) {
    return FaturasCompanion(
      id: Value(id),
      cartaoId: Value(cartaoId),
      competencia: Value(competencia),
      dataFechamento: Value(dataFechamento),
      dataVencimento: Value(dataVencimento),
      status: Value(status),
      dataPagamento: dataPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(dataPagamento),
      lancamentoPagamentoId: lancamentoPagamentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(lancamentoPagamentoId),
    );
  }

  factory Fatura.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fatura(
      id: serializer.fromJson<int>(json['id']),
      cartaoId: serializer.fromJson<int>(json['cartaoId']),
      competencia: serializer.fromJson<String>(json['competencia']),
      dataFechamento: serializer.fromJson<DateTime>(json['dataFechamento']),
      dataVencimento: serializer.fromJson<DateTime>(json['dataVencimento']),
      status: $FaturasTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      dataPagamento: serializer.fromJson<DateTime?>(json['dataPagamento']),
      lancamentoPagamentoId: serializer.fromJson<int?>(
        json['lancamentoPagamentoId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cartaoId': serializer.toJson<int>(cartaoId),
      'competencia': serializer.toJson<String>(competencia),
      'dataFechamento': serializer.toJson<DateTime>(dataFechamento),
      'dataVencimento': serializer.toJson<DateTime>(dataVencimento),
      'status': serializer.toJson<String>(
        $FaturasTable.$converterstatus.toJson(status),
      ),
      'dataPagamento': serializer.toJson<DateTime?>(dataPagamento),
      'lancamentoPagamentoId': serializer.toJson<int?>(lancamentoPagamentoId),
    };
  }

  Fatura copyWith({
    int? id,
    int? cartaoId,
    String? competencia,
    DateTime? dataFechamento,
    DateTime? dataVencimento,
    StatusFatura? status,
    Value<DateTime?> dataPagamento = const Value.absent(),
    Value<int?> lancamentoPagamentoId = const Value.absent(),
  }) => Fatura(
    id: id ?? this.id,
    cartaoId: cartaoId ?? this.cartaoId,
    competencia: competencia ?? this.competencia,
    dataFechamento: dataFechamento ?? this.dataFechamento,
    dataVencimento: dataVencimento ?? this.dataVencimento,
    status: status ?? this.status,
    dataPagamento: dataPagamento.present
        ? dataPagamento.value
        : this.dataPagamento,
    lancamentoPagamentoId: lancamentoPagamentoId.present
        ? lancamentoPagamentoId.value
        : this.lancamentoPagamentoId,
  );
  Fatura copyWithCompanion(FaturasCompanion data) {
    return Fatura(
      id: data.id.present ? data.id.value : this.id,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      competencia: data.competencia.present
          ? data.competencia.value
          : this.competencia,
      dataFechamento: data.dataFechamento.present
          ? data.dataFechamento.value
          : this.dataFechamento,
      dataVencimento: data.dataVencimento.present
          ? data.dataVencimento.value
          : this.dataVencimento,
      status: data.status.present ? data.status.value : this.status,
      dataPagamento: data.dataPagamento.present
          ? data.dataPagamento.value
          : this.dataPagamento,
      lancamentoPagamentoId: data.lancamentoPagamentoId.present
          ? data.lancamentoPagamentoId.value
          : this.lancamentoPagamentoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fatura(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('competencia: $competencia, ')
          ..write('dataFechamento: $dataFechamento, ')
          ..write('dataVencimento: $dataVencimento, ')
          ..write('status: $status, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('lancamentoPagamentoId: $lancamentoPagamentoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cartaoId,
    competencia,
    dataFechamento,
    dataVencimento,
    status,
    dataPagamento,
    lancamentoPagamentoId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fatura &&
          other.id == this.id &&
          other.cartaoId == this.cartaoId &&
          other.competencia == this.competencia &&
          other.dataFechamento == this.dataFechamento &&
          other.dataVencimento == this.dataVencimento &&
          other.status == this.status &&
          other.dataPagamento == this.dataPagamento &&
          other.lancamentoPagamentoId == this.lancamentoPagamentoId);
}

class FaturasCompanion extends UpdateCompanion<Fatura> {
  final Value<int> id;
  final Value<int> cartaoId;
  final Value<String> competencia;
  final Value<DateTime> dataFechamento;
  final Value<DateTime> dataVencimento;
  final Value<StatusFatura> status;
  final Value<DateTime?> dataPagamento;
  final Value<int?> lancamentoPagamentoId;
  const FaturasCompanion({
    this.id = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.competencia = const Value.absent(),
    this.dataFechamento = const Value.absent(),
    this.dataVencimento = const Value.absent(),
    this.status = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.lancamentoPagamentoId = const Value.absent(),
  });
  FaturasCompanion.insert({
    this.id = const Value.absent(),
    required int cartaoId,
    required String competencia,
    required DateTime dataFechamento,
    required DateTime dataVencimento,
    this.status = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.lancamentoPagamentoId = const Value.absent(),
  }) : cartaoId = Value(cartaoId),
       competencia = Value(competencia),
       dataFechamento = Value(dataFechamento),
       dataVencimento = Value(dataVencimento);
  static Insertable<Fatura> custom({
    Expression<int>? id,
    Expression<int>? cartaoId,
    Expression<String>? competencia,
    Expression<int>? dataFechamento,
    Expression<int>? dataVencimento,
    Expression<String>? status,
    Expression<int>? dataPagamento,
    Expression<int>? lancamentoPagamentoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (competencia != null) 'competencia': competencia,
      if (dataFechamento != null) 'data_fechamento': dataFechamento,
      if (dataVencimento != null) 'data_vencimento': dataVencimento,
      if (status != null) 'status': status,
      if (dataPagamento != null) 'data_pagamento': dataPagamento,
      if (lancamentoPagamentoId != null)
        'lancamento_pagamento_id': lancamentoPagamentoId,
    });
  }

  FaturasCompanion copyWith({
    Value<int>? id,
    Value<int>? cartaoId,
    Value<String>? competencia,
    Value<DateTime>? dataFechamento,
    Value<DateTime>? dataVencimento,
    Value<StatusFatura>? status,
    Value<DateTime?>? dataPagamento,
    Value<int?>? lancamentoPagamentoId,
  }) {
    return FaturasCompanion(
      id: id ?? this.id,
      cartaoId: cartaoId ?? this.cartaoId,
      competencia: competencia ?? this.competencia,
      dataFechamento: dataFechamento ?? this.dataFechamento,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      status: status ?? this.status,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      lancamentoPagamentoId:
          lancamentoPagamentoId ?? this.lancamentoPagamentoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (competencia.present) {
      map['competencia'] = Variable<String>(competencia.value);
    }
    if (dataFechamento.present) {
      map['data_fechamento'] = Variable<int>(
        $FaturasTable.$converterdataFechamento.toSql(dataFechamento.value),
      );
    }
    if (dataVencimento.present) {
      map['data_vencimento'] = Variable<int>(
        $FaturasTable.$converterdataVencimento.toSql(dataVencimento.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $FaturasTable.$converterstatus.toSql(status.value),
      );
    }
    if (dataPagamento.present) {
      map['data_pagamento'] = Variable<int>(
        $FaturasTable.$converterdataPagamenton.toSql(dataPagamento.value),
      );
    }
    if (lancamentoPagamentoId.present) {
      map['lancamento_pagamento_id'] = Variable<int>(
        lancamentoPagamentoId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaturasCompanion(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('competencia: $competencia, ')
          ..write('dataFechamento: $dataFechamento, ')
          ..write('dataVencimento: $dataVencimento, ')
          ..write('status: $status, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('lancamentoPagamentoId: $lancamentoPagamentoId')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconeMeta = const VerificationMeta('icone');
  @override
  late final GeneratedColumn<String> icone = GeneratedColumn<String>(
    'icone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('category'),
  );
  static const VerificationMeta _corMeta = const VerificationMeta('cor');
  @override
  late final GeneratedColumn<int> cor = GeneratedColumn<int>(
    'cor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF14B8A6),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoCategoria, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoCategoria>($CategoriasTable.$convertertipo);
  static const VerificationMeta _categoriaPaiIdMeta = const VerificationMeta(
    'categoriaPaiId',
  );
  @override
  late final GeneratedColumn<int> categoriaPaiId = GeneratedColumn<int>(
    'categoria_pai_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    icone,
    cor,
    tipo,
    categoriaPaiId,
    ordem,
    ativa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('icone')) {
      context.handle(
        _iconeMeta,
        icone.isAcceptableOrUnknown(data['icone']!, _iconeMeta),
      );
    }
    if (data.containsKey('cor')) {
      context.handle(
        _corMeta,
        cor.isAcceptableOrUnknown(data['cor']!, _corMeta),
      );
    }
    if (data.containsKey('categoria_pai_id')) {
      context.handle(
        _categoriaPaiIdMeta,
        categoriaPaiId.isAcceptableOrUnknown(
          data['categoria_pai_id']!,
          _categoriaPaiIdMeta,
        ),
      );
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      icone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icone'],
      )!,
      cor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cor'],
      )!,
      tipo: $CategoriasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      categoriaPaiId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_pai_id'],
      ),
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativa'],
      )!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoCategoria, String, String> $convertertipo =
      const EnumNameConverter<TipoCategoria>(TipoCategoria.values);
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nome;

  /// Chave do ícone (ver `core/icones.dart`).
  final String icone;
  final int cor;
  final TipoCategoria tipo;
  final int? categoriaPaiId;
  final int ordem;
  final bool ativa;
  const Categoria({
    required this.id,
    required this.nome,
    required this.icone,
    required this.cor,
    required this.tipo,
    this.categoriaPaiId,
    required this.ordem,
    required this.ativa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['icone'] = Variable<String>(icone);
    map['cor'] = Variable<int>(cor);
    {
      map['tipo'] = Variable<String>(
        $CategoriasTable.$convertertipo.toSql(tipo),
      );
    }
    if (!nullToAbsent || categoriaPaiId != null) {
      map['categoria_pai_id'] = Variable<int>(categoriaPaiId);
    }
    map['ordem'] = Variable<int>(ordem);
    map['ativa'] = Variable<bool>(ativa);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nome: Value(nome),
      icone: Value(icone),
      cor: Value(cor),
      tipo: Value(tipo),
      categoriaPaiId: categoriaPaiId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaPaiId),
      ordem: Value(ordem),
      ativa: Value(ativa),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      icone: serializer.fromJson<String>(json['icone']),
      cor: serializer.fromJson<int>(json['cor']),
      tipo: $CategoriasTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      categoriaPaiId: serializer.fromJson<int?>(json['categoriaPaiId']),
      ordem: serializer.fromJson<int>(json['ordem']),
      ativa: serializer.fromJson<bool>(json['ativa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'icone': serializer.toJson<String>(icone),
      'cor': serializer.toJson<int>(cor),
      'tipo': serializer.toJson<String>(
        $CategoriasTable.$convertertipo.toJson(tipo),
      ),
      'categoriaPaiId': serializer.toJson<int?>(categoriaPaiId),
      'ordem': serializer.toJson<int>(ordem),
      'ativa': serializer.toJson<bool>(ativa),
    };
  }

  Categoria copyWith({
    int? id,
    String? nome,
    String? icone,
    int? cor,
    TipoCategoria? tipo,
    Value<int?> categoriaPaiId = const Value.absent(),
    int? ordem,
    bool? ativa,
  }) => Categoria(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    icone: icone ?? this.icone,
    cor: cor ?? this.cor,
    tipo: tipo ?? this.tipo,
    categoriaPaiId: categoriaPaiId.present
        ? categoriaPaiId.value
        : this.categoriaPaiId,
    ordem: ordem ?? this.ordem,
    ativa: ativa ?? this.ativa,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      icone: data.icone.present ? data.icone.value : this.icone,
      cor: data.cor.present ? data.cor.value : this.cor,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      categoriaPaiId: data.categoriaPaiId.present
          ? data.categoriaPaiId.value
          : this.categoriaPaiId,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('icone: $icone, ')
          ..write('cor: $cor, ')
          ..write('tipo: $tipo, ')
          ..write('categoriaPaiId: $categoriaPaiId, ')
          ..write('ordem: $ordem, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, icone, cor, tipo, categoriaPaiId, ordem, ativa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.icone == this.icone &&
          other.cor == this.cor &&
          other.tipo == this.tipo &&
          other.categoriaPaiId == this.categoriaPaiId &&
          other.ordem == this.ordem &&
          other.ativa == this.ativa);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> icone;
  final Value<int> cor;
  final Value<TipoCategoria> tipo;
  final Value<int?> categoriaPaiId;
  final Value<int> ordem;
  final Value<bool> ativa;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.icone = const Value.absent(),
    this.cor = const Value.absent(),
    this.tipo = const Value.absent(),
    this.categoriaPaiId = const Value.absent(),
    this.ordem = const Value.absent(),
    this.ativa = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.icone = const Value.absent(),
    this.cor = const Value.absent(),
    required TipoCategoria tipo,
    this.categoriaPaiId = const Value.absent(),
    this.ordem = const Value.absent(),
    this.ativa = const Value.absent(),
  }) : nome = Value(nome),
       tipo = Value(tipo);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? icone,
    Expression<int>? cor,
    Expression<String>? tipo,
    Expression<int>? categoriaPaiId,
    Expression<int>? ordem,
    Expression<bool>? ativa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (icone != null) 'icone': icone,
      if (cor != null) 'cor': cor,
      if (tipo != null) 'tipo': tipo,
      if (categoriaPaiId != null) 'categoria_pai_id': categoriaPaiId,
      if (ordem != null) 'ordem': ordem,
      if (ativa != null) 'ativa': ativa,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String>? icone,
    Value<int>? cor,
    Value<TipoCategoria>? tipo,
    Value<int?>? categoriaPaiId,
    Value<int>? ordem,
    Value<bool>? ativa,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      icone: icone ?? this.icone,
      cor: cor ?? this.cor,
      tipo: tipo ?? this.tipo,
      categoriaPaiId: categoriaPaiId ?? this.categoriaPaiId,
      ordem: ordem ?? this.ordem,
      ativa: ativa ?? this.ativa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (icone.present) {
      map['icone'] = Variable<String>(icone.value);
    }
    if (cor.present) {
      map['cor'] = Variable<int>(cor.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $CategoriasTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (categoriaPaiId.present) {
      map['categoria_pai_id'] = Variable<int>(categoriaPaiId.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('icone: $icone, ')
          ..write('cor: $cor, ')
          ..write('tipo: $tipo, ')
          ..write('categoriaPaiId: $categoriaPaiId, ')
          ..write('ordem: $ordem, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }
}

class $ComprasParceladasTable extends ComprasParceladas
    with TableInfo<$ComprasParceladasTable, CompraParcelada> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprasParceladasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cartoes (id)',
    ),
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _valorTotalMeta = const VerificationMeta(
    'valorTotal',
  );
  @override
  late final GeneratedColumn<int> valorTotal = GeneratedColumn<int>(
    'valor_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroParcelasMeta = const VerificationMeta(
    'numeroParcelas',
  );
  @override
  late final GeneratedColumn<int> numeroParcelas = GeneratedColumn<int>(
    'numero_parcelas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dataCompra =
      GeneratedColumn<int>(
        'data_compra',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ComprasParceladasTable.$converterdataCompra);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cartaoId,
    descricao,
    categoriaId,
    valorTotal,
    numeroParcelas,
    dataCompra,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compras_parceladas';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompraParcelada> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cartaoIdMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('valor_total')) {
      context.handle(
        _valorTotalMeta,
        valorTotal.isAcceptableOrUnknown(data['valor_total']!, _valorTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_valorTotalMeta);
    }
    if (data.containsKey('numero_parcelas')) {
      context.handle(
        _numeroParcelasMeta,
        numeroParcelas.isAcceptableOrUnknown(
          data['numero_parcelas']!,
          _numeroParcelasMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numeroParcelasMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompraParcelada map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompraParcelada(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      ),
      valorTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_total'],
      )!,
      numeroParcelas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero_parcelas'],
      )!,
      dataCompra: $ComprasParceladasTable.$converterdataCompra.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_compra'],
        )!,
      ),
    );
  }

  @override
  $ComprasParceladasTable createAlias(String alias) {
    return $ComprasParceladasTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdataCompra =
      const ConversorData();
}

class CompraParcelada extends DataClass implements Insertable<CompraParcelada> {
  final int id;
  final int cartaoId;
  final String descricao;
  final int? categoriaId;
  final int valorTotal;
  final int numeroParcelas;
  final DateTime dataCompra;
  const CompraParcelada({
    required this.id,
    required this.cartaoId,
    required this.descricao,
    this.categoriaId,
    required this.valorTotal,
    required this.numeroParcelas,
    required this.dataCompra,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cartao_id'] = Variable<int>(cartaoId);
    map['descricao'] = Variable<String>(descricao);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    map['valor_total'] = Variable<int>(valorTotal);
    map['numero_parcelas'] = Variable<int>(numeroParcelas);
    {
      map['data_compra'] = Variable<int>(
        $ComprasParceladasTable.$converterdataCompra.toSql(dataCompra),
      );
    }
    return map;
  }

  ComprasParceladasCompanion toCompanion(bool nullToAbsent) {
    return ComprasParceladasCompanion(
      id: Value(id),
      cartaoId: Value(cartaoId),
      descricao: Value(descricao),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      valorTotal: Value(valorTotal),
      numeroParcelas: Value(numeroParcelas),
      dataCompra: Value(dataCompra),
    );
  }

  factory CompraParcelada.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompraParcelada(
      id: serializer.fromJson<int>(json['id']),
      cartaoId: serializer.fromJson<int>(json['cartaoId']),
      descricao: serializer.fromJson<String>(json['descricao']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      valorTotal: serializer.fromJson<int>(json['valorTotal']),
      numeroParcelas: serializer.fromJson<int>(json['numeroParcelas']),
      dataCompra: serializer.fromJson<DateTime>(json['dataCompra']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cartaoId': serializer.toJson<int>(cartaoId),
      'descricao': serializer.toJson<String>(descricao),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'valorTotal': serializer.toJson<int>(valorTotal),
      'numeroParcelas': serializer.toJson<int>(numeroParcelas),
      'dataCompra': serializer.toJson<DateTime>(dataCompra),
    };
  }

  CompraParcelada copyWith({
    int? id,
    int? cartaoId,
    String? descricao,
    Value<int?> categoriaId = const Value.absent(),
    int? valorTotal,
    int? numeroParcelas,
    DateTime? dataCompra,
  }) => CompraParcelada(
    id: id ?? this.id,
    cartaoId: cartaoId ?? this.cartaoId,
    descricao: descricao ?? this.descricao,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    valorTotal: valorTotal ?? this.valorTotal,
    numeroParcelas: numeroParcelas ?? this.numeroParcelas,
    dataCompra: dataCompra ?? this.dataCompra,
  );
  CompraParcelada copyWithCompanion(ComprasParceladasCompanion data) {
    return CompraParcelada(
      id: data.id.present ? data.id.value : this.id,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      valorTotal: data.valorTotal.present
          ? data.valorTotal.value
          : this.valorTotal,
      numeroParcelas: data.numeroParcelas.present
          ? data.numeroParcelas.value
          : this.numeroParcelas,
      dataCompra: data.dataCompra.present
          ? data.dataCompra.value
          : this.dataCompra,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompraParcelada(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('descricao: $descricao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('valorTotal: $valorTotal, ')
          ..write('numeroParcelas: $numeroParcelas, ')
          ..write('dataCompra: $dataCompra')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cartaoId,
    descricao,
    categoriaId,
    valorTotal,
    numeroParcelas,
    dataCompra,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompraParcelada &&
          other.id == this.id &&
          other.cartaoId == this.cartaoId &&
          other.descricao == this.descricao &&
          other.categoriaId == this.categoriaId &&
          other.valorTotal == this.valorTotal &&
          other.numeroParcelas == this.numeroParcelas &&
          other.dataCompra == this.dataCompra);
}

class ComprasParceladasCompanion extends UpdateCompanion<CompraParcelada> {
  final Value<int> id;
  final Value<int> cartaoId;
  final Value<String> descricao;
  final Value<int?> categoriaId;
  final Value<int> valorTotal;
  final Value<int> numeroParcelas;
  final Value<DateTime> dataCompra;
  const ComprasParceladasCompanion({
    this.id = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.descricao = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.valorTotal = const Value.absent(),
    this.numeroParcelas = const Value.absent(),
    this.dataCompra = const Value.absent(),
  });
  ComprasParceladasCompanion.insert({
    this.id = const Value.absent(),
    required int cartaoId,
    required String descricao,
    this.categoriaId = const Value.absent(),
    required int valorTotal,
    required int numeroParcelas,
    required DateTime dataCompra,
  }) : cartaoId = Value(cartaoId),
       descricao = Value(descricao),
       valorTotal = Value(valorTotal),
       numeroParcelas = Value(numeroParcelas),
       dataCompra = Value(dataCompra);
  static Insertable<CompraParcelada> custom({
    Expression<int>? id,
    Expression<int>? cartaoId,
    Expression<String>? descricao,
    Expression<int>? categoriaId,
    Expression<int>? valorTotal,
    Expression<int>? numeroParcelas,
    Expression<int>? dataCompra,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (descricao != null) 'descricao': descricao,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (valorTotal != null) 'valor_total': valorTotal,
      if (numeroParcelas != null) 'numero_parcelas': numeroParcelas,
      if (dataCompra != null) 'data_compra': dataCompra,
    });
  }

  ComprasParceladasCompanion copyWith({
    Value<int>? id,
    Value<int>? cartaoId,
    Value<String>? descricao,
    Value<int?>? categoriaId,
    Value<int>? valorTotal,
    Value<int>? numeroParcelas,
    Value<DateTime>? dataCompra,
  }) {
    return ComprasParceladasCompanion(
      id: id ?? this.id,
      cartaoId: cartaoId ?? this.cartaoId,
      descricao: descricao ?? this.descricao,
      categoriaId: categoriaId ?? this.categoriaId,
      valorTotal: valorTotal ?? this.valorTotal,
      numeroParcelas: numeroParcelas ?? this.numeroParcelas,
      dataCompra: dataCompra ?? this.dataCompra,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (valorTotal.present) {
      map['valor_total'] = Variable<int>(valorTotal.value);
    }
    if (numeroParcelas.present) {
      map['numero_parcelas'] = Variable<int>(numeroParcelas.value);
    }
    if (dataCompra.present) {
      map['data_compra'] = Variable<int>(
        $ComprasParceladasTable.$converterdataCompra.toSql(dataCompra.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprasParceladasCompanion(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('descricao: $descricao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('valorTotal: $valorTotal, ')
          ..write('numeroParcelas: $numeroParcelas, ')
          ..write('dataCompra: $dataCompra')
          ..write(')'))
        .toString();
  }
}

class $InvestimentosTable extends Investimentos
    with TableInfo<$InvestimentosTable, Investimento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestimentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoInvestimento, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoInvestimento>($InvestimentosTable.$convertertipo);
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome, tipo, ativo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investimentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investimento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investimento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investimento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      tipo: $InvestimentosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
    );
  }

  @override
  $InvestimentosTable createAlias(String alias) {
    return $InvestimentosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoInvestimento, String, String> $convertertipo =
      const EnumNameConverter<TipoInvestimento>(TipoInvestimento.values);
}

class Investimento extends DataClass implements Insertable<Investimento> {
  final int id;
  final String nome;
  final TipoInvestimento tipo;
  final bool ativo;
  const Investimento({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.ativo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    {
      map['tipo'] = Variable<String>(
        $InvestimentosTable.$convertertipo.toSql(tipo),
      );
    }
    map['ativo'] = Variable<bool>(ativo);
    return map;
  }

  InvestimentosCompanion toCompanion(bool nullToAbsent) {
    return InvestimentosCompanion(
      id: Value(id),
      nome: Value(nome),
      tipo: Value(tipo),
      ativo: Value(ativo),
    );
  }

  factory Investimento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investimento(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      tipo: $InvestimentosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      ativo: serializer.fromJson<bool>(json['ativo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'tipo': serializer.toJson<String>(
        $InvestimentosTable.$convertertipo.toJson(tipo),
      ),
      'ativo': serializer.toJson<bool>(ativo),
    };
  }

  Investimento copyWith({
    int? id,
    String? nome,
    TipoInvestimento? tipo,
    bool? ativo,
  }) => Investimento(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    ativo: ativo ?? this.ativo,
  );
  Investimento copyWithCompanion(InvestimentosCompanion data) {
    return Investimento(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investimento(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('ativo: $ativo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, tipo, ativo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investimento &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.tipo == this.tipo &&
          other.ativo == this.ativo);
}

class InvestimentosCompanion extends UpdateCompanion<Investimento> {
  final Value<int> id;
  final Value<String> nome;
  final Value<TipoInvestimento> tipo;
  final Value<bool> ativo;
  const InvestimentosCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.tipo = const Value.absent(),
    this.ativo = const Value.absent(),
  });
  InvestimentosCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required TipoInvestimento tipo,
    this.ativo = const Value.absent(),
  }) : nome = Value(nome),
       tipo = Value(tipo);
  static Insertable<Investimento> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? tipo,
    Expression<bool>? ativo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (tipo != null) 'tipo': tipo,
      if (ativo != null) 'ativo': ativo,
    });
  }

  InvestimentosCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<TipoInvestimento>? tipo,
    Value<bool>? ativo,
  }) {
    return InvestimentosCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $InvestimentosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestimentosCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('ativo: $ativo')
          ..write(')'))
        .toString();
  }
}

class $LancamentosTable extends Lancamentos
    with TableInfo<$LancamentosTable, Lancamento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LancamentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoLancamento, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoLancamento>($LancamentosTable.$convertertipo);
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<int> valor = GeneratedColumn<int>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> data =
      GeneratedColumn<int>(
        'data',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($LancamentosTable.$converterdata);
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FormaPagamento?, String>
  formaPagamento = GeneratedColumn<String>(
    'forma_pagamento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<FormaPagamento?>($LancamentosTable.$converterformaPagamenton);
  static const VerificationMeta _contaIdMeta = const VerificationMeta(
    'contaId',
  );
  @override
  late final GeneratedColumn<int> contaId = GeneratedColumn<int>(
    'conta_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contas (id)',
    ),
  );
  static const VerificationMeta _contaDestinoIdMeta = const VerificationMeta(
    'contaDestinoId',
  );
  @override
  late final GeneratedColumn<int> contaDestinoId = GeneratedColumn<int>(
    'conta_destino_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contas (id)',
    ),
  );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cartoes (id)',
    ),
  );
  static const VerificationMeta _faturaIdMeta = const VerificationMeta(
    'faturaId',
  );
  @override
  late final GeneratedColumn<int> faturaId = GeneratedColumn<int>(
    'fatura_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES faturas (id)',
    ),
  );
  static const VerificationMeta _compraParceladaIdMeta = const VerificationMeta(
    'compraParceladaId',
  );
  @override
  late final GeneratedColumn<int> compraParceladaId = GeneratedColumn<int>(
    'compra_parcelada_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES compras_parceladas (id)',
    ),
  );
  static const VerificationMeta _parcelaNumeroMeta = const VerificationMeta(
    'parcelaNumero',
  );
  @override
  late final GeneratedColumn<int> parcelaNumero = GeneratedColumn<int>(
    'parcela_numero',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocorrenciaCompromissoIdMeta =
      const VerificationMeta('ocorrenciaCompromissoId');
  @override
  late final GeneratedColumn<int> ocorrenciaCompromissoId =
      GeneratedColumn<int>(
        'ocorrencia_compromisso_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _investimentoIdMeta = const VerificationMeta(
    'investimentoId',
  );
  @override
  late final GeneratedColumn<int> investimentoId = GeneratedColumn<int>(
    'investimento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investimentos (id)',
    ),
  );
  static const VerificationMeta _receitaRecorrenteIdMeta =
      const VerificationMeta('receitaRecorrenteId');
  @override
  late final GeneratedColumn<int> receitaRecorrenteId = GeneratedColumn<int>(
    'receita_recorrente_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OrigemLancamento, String> origem =
      GeneratedColumn<String>(
        'origem',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('manual'),
      ).withConverter<OrigemLancamento>($LancamentosTable.$converterorigem);
  static const VerificationMeta _chaveImportacaoMeta = const VerificationMeta(
    'chaveImportacao',
  );
  @override
  late final GeneratedColumn<String> chaveImportacao = GeneratedColumn<String>(
    'chave_importacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipo,
    valor,
    data,
    descricao,
    categoriaId,
    formaPagamento,
    contaId,
    contaDestinoId,
    cartaoId,
    faturaId,
    compraParceladaId,
    parcelaNumero,
    ocorrenciaCompromissoId,
    investimentoId,
    receitaRecorrenteId,
    origem,
    chaveImportacao,
    criadoEm,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lancamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lancamento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('conta_id')) {
      context.handle(
        _contaIdMeta,
        contaId.isAcceptableOrUnknown(data['conta_id']!, _contaIdMeta),
      );
    }
    if (data.containsKey('conta_destino_id')) {
      context.handle(
        _contaDestinoIdMeta,
        contaDestinoId.isAcceptableOrUnknown(
          data['conta_destino_id']!,
          _contaDestinoIdMeta,
        ),
      );
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    }
    if (data.containsKey('fatura_id')) {
      context.handle(
        _faturaIdMeta,
        faturaId.isAcceptableOrUnknown(data['fatura_id']!, _faturaIdMeta),
      );
    }
    if (data.containsKey('compra_parcelada_id')) {
      context.handle(
        _compraParceladaIdMeta,
        compraParceladaId.isAcceptableOrUnknown(
          data['compra_parcelada_id']!,
          _compraParceladaIdMeta,
        ),
      );
    }
    if (data.containsKey('parcela_numero')) {
      context.handle(
        _parcelaNumeroMeta,
        parcelaNumero.isAcceptableOrUnknown(
          data['parcela_numero']!,
          _parcelaNumeroMeta,
        ),
      );
    }
    if (data.containsKey('ocorrencia_compromisso_id')) {
      context.handle(
        _ocorrenciaCompromissoIdMeta,
        ocorrenciaCompromissoId.isAcceptableOrUnknown(
          data['ocorrencia_compromisso_id']!,
          _ocorrenciaCompromissoIdMeta,
        ),
      );
    }
    if (data.containsKey('investimento_id')) {
      context.handle(
        _investimentoIdMeta,
        investimentoId.isAcceptableOrUnknown(
          data['investimento_id']!,
          _investimentoIdMeta,
        ),
      );
    }
    if (data.containsKey('receita_recorrente_id')) {
      context.handle(
        _receitaRecorrenteIdMeta,
        receitaRecorrenteId.isAcceptableOrUnknown(
          data['receita_recorrente_id']!,
          _receitaRecorrenteIdMeta,
        ),
      );
    }
    if (data.containsKey('chave_importacao')) {
      context.handle(
        _chaveImportacaoMeta,
        chaveImportacao.isAcceptableOrUnknown(
          data['chave_importacao']!,
          _chaveImportacaoMeta,
        ),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lancamento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lancamento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipo: $LancamentosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor'],
      )!,
      data: $LancamentosTable.$converterdata.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data'],
        )!,
      ),
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      ),
      formaPagamento: $LancamentosTable.$converterformaPagamenton.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forma_pagamento'],
        ),
      ),
      contaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_id'],
      ),
      contaDestinoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_destino_id'],
      ),
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      ),
      faturaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatura_id'],
      ),
      compraParceladaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compra_parcelada_id'],
      ),
      parcelaNumero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parcela_numero'],
      ),
      ocorrenciaCompromissoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ocorrencia_compromisso_id'],
      ),
      investimentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}investimento_id'],
      ),
      receitaRecorrenteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receita_recorrente_id'],
      ),
      origem: $LancamentosTable.$converterorigem.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origem'],
        )!,
      ),
      chaveImportacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave_importacao'],
      ),
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $LancamentosTable createAlias(String alias) {
    return $LancamentosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoLancamento, String, String> $convertertipo =
      const EnumNameConverter<TipoLancamento>(TipoLancamento.values);
  static TypeConverter<DateTime, int> $converterdata = const ConversorData();
  static JsonTypeConverter2<FormaPagamento, String, String>
  $converterformaPagamento = const EnumNameConverter<FormaPagamento>(
    FormaPagamento.values,
  );
  static JsonTypeConverter2<FormaPagamento?, String?, String?>
  $converterformaPagamenton = JsonTypeConverter2.asNullable(
    $converterformaPagamento,
  );
  static JsonTypeConverter2<OrigemLancamento, String, String> $converterorigem =
      const EnumNameConverter<OrigemLancamento>(OrigemLancamento.values);
}

class Lancamento extends DataClass implements Insertable<Lancamento> {
  final int id;
  final TipoLancamento tipo;

  /// Centavos, sempre positivo (o [tipo] define o sentido).
  /// Exceção: em `ajusteSaldo` o sinal define o sentido do ajuste.
  final int valor;
  final DateTime data;
  final String descricao;
  final int? categoriaId;
  final FormaPagamento? formaPagamento;

  /// Conta afetada. Nulo nas compras no crédito (que pertencem a um cartão).
  final int? contaId;
  final int? contaDestinoId;
  final int? cartaoId;
  final int? faturaId;
  final int? compraParceladaId;
  final int? parcelaNumero;
  final int? ocorrenciaCompromissoId;
  final int? investimentoId;
  final int? receitaRecorrenteId;
  final OrigemLancamento origem;

  /// FITID do OFX, ou data|valor|descrição normalizada. Serve para deduplicar.
  final String? chaveImportacao;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  const Lancamento({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.data,
    required this.descricao,
    this.categoriaId,
    this.formaPagamento,
    this.contaId,
    this.contaDestinoId,
    this.cartaoId,
    this.faturaId,
    this.compraParceladaId,
    this.parcelaNumero,
    this.ocorrenciaCompromissoId,
    this.investimentoId,
    this.receitaRecorrenteId,
    required this.origem,
    this.chaveImportacao,
    required this.criadoEm,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['tipo'] = Variable<String>(
        $LancamentosTable.$convertertipo.toSql(tipo),
      );
    }
    map['valor'] = Variable<int>(valor);
    {
      map['data'] = Variable<int>($LancamentosTable.$converterdata.toSql(data));
    }
    map['descricao'] = Variable<String>(descricao);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    if (!nullToAbsent || formaPagamento != null) {
      map['forma_pagamento'] = Variable<String>(
        $LancamentosTable.$converterformaPagamenton.toSql(formaPagamento),
      );
    }
    if (!nullToAbsent || contaId != null) {
      map['conta_id'] = Variable<int>(contaId);
    }
    if (!nullToAbsent || contaDestinoId != null) {
      map['conta_destino_id'] = Variable<int>(contaDestinoId);
    }
    if (!nullToAbsent || cartaoId != null) {
      map['cartao_id'] = Variable<int>(cartaoId);
    }
    if (!nullToAbsent || faturaId != null) {
      map['fatura_id'] = Variable<int>(faturaId);
    }
    if (!nullToAbsent || compraParceladaId != null) {
      map['compra_parcelada_id'] = Variable<int>(compraParceladaId);
    }
    if (!nullToAbsent || parcelaNumero != null) {
      map['parcela_numero'] = Variable<int>(parcelaNumero);
    }
    if (!nullToAbsent || ocorrenciaCompromissoId != null) {
      map['ocorrencia_compromisso_id'] = Variable<int>(ocorrenciaCompromissoId);
    }
    if (!nullToAbsent || investimentoId != null) {
      map['investimento_id'] = Variable<int>(investimentoId);
    }
    if (!nullToAbsent || receitaRecorrenteId != null) {
      map['receita_recorrente_id'] = Variable<int>(receitaRecorrenteId);
    }
    {
      map['origem'] = Variable<String>(
        $LancamentosTable.$converterorigem.toSql(origem),
      );
    }
    if (!nullToAbsent || chaveImportacao != null) {
      map['chave_importacao'] = Variable<String>(chaveImportacao);
    }
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  LancamentosCompanion toCompanion(bool nullToAbsent) {
    return LancamentosCompanion(
      id: Value(id),
      tipo: Value(tipo),
      valor: Value(valor),
      data: Value(data),
      descricao: Value(descricao),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      formaPagamento: formaPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(formaPagamento),
      contaId: contaId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaId),
      contaDestinoId: contaDestinoId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaDestinoId),
      cartaoId: cartaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cartaoId),
      faturaId: faturaId == null && nullToAbsent
          ? const Value.absent()
          : Value(faturaId),
      compraParceladaId: compraParceladaId == null && nullToAbsent
          ? const Value.absent()
          : Value(compraParceladaId),
      parcelaNumero: parcelaNumero == null && nullToAbsent
          ? const Value.absent()
          : Value(parcelaNumero),
      ocorrenciaCompromissoId: ocorrenciaCompromissoId == null && nullToAbsent
          ? const Value.absent()
          : Value(ocorrenciaCompromissoId),
      investimentoId: investimentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(investimentoId),
      receitaRecorrenteId: receitaRecorrenteId == null && nullToAbsent
          ? const Value.absent()
          : Value(receitaRecorrenteId),
      origem: Value(origem),
      chaveImportacao: chaveImportacao == null && nullToAbsent
          ? const Value.absent()
          : Value(chaveImportacao),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory Lancamento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lancamento(
      id: serializer.fromJson<int>(json['id']),
      tipo: $LancamentosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      valor: serializer.fromJson<int>(json['valor']),
      data: serializer.fromJson<DateTime>(json['data']),
      descricao: serializer.fromJson<String>(json['descricao']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      formaPagamento: $LancamentosTable.$converterformaPagamenton.fromJson(
        serializer.fromJson<String?>(json['formaPagamento']),
      ),
      contaId: serializer.fromJson<int?>(json['contaId']),
      contaDestinoId: serializer.fromJson<int?>(json['contaDestinoId']),
      cartaoId: serializer.fromJson<int?>(json['cartaoId']),
      faturaId: serializer.fromJson<int?>(json['faturaId']),
      compraParceladaId: serializer.fromJson<int?>(json['compraParceladaId']),
      parcelaNumero: serializer.fromJson<int?>(json['parcelaNumero']),
      ocorrenciaCompromissoId: serializer.fromJson<int?>(
        json['ocorrenciaCompromissoId'],
      ),
      investimentoId: serializer.fromJson<int?>(json['investimentoId']),
      receitaRecorrenteId: serializer.fromJson<int?>(
        json['receitaRecorrenteId'],
      ),
      origem: $LancamentosTable.$converterorigem.fromJson(
        serializer.fromJson<String>(json['origem']),
      ),
      chaveImportacao: serializer.fromJson<String?>(json['chaveImportacao']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipo': serializer.toJson<String>(
        $LancamentosTable.$convertertipo.toJson(tipo),
      ),
      'valor': serializer.toJson<int>(valor),
      'data': serializer.toJson<DateTime>(data),
      'descricao': serializer.toJson<String>(descricao),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'formaPagamento': serializer.toJson<String?>(
        $LancamentosTable.$converterformaPagamenton.toJson(formaPagamento),
      ),
      'contaId': serializer.toJson<int?>(contaId),
      'contaDestinoId': serializer.toJson<int?>(contaDestinoId),
      'cartaoId': serializer.toJson<int?>(cartaoId),
      'faturaId': serializer.toJson<int?>(faturaId),
      'compraParceladaId': serializer.toJson<int?>(compraParceladaId),
      'parcelaNumero': serializer.toJson<int?>(parcelaNumero),
      'ocorrenciaCompromissoId': serializer.toJson<int?>(
        ocorrenciaCompromissoId,
      ),
      'investimentoId': serializer.toJson<int?>(investimentoId),
      'receitaRecorrenteId': serializer.toJson<int?>(receitaRecorrenteId),
      'origem': serializer.toJson<String>(
        $LancamentosTable.$converterorigem.toJson(origem),
      ),
      'chaveImportacao': serializer.toJson<String?>(chaveImportacao),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  Lancamento copyWith({
    int? id,
    TipoLancamento? tipo,
    int? valor,
    DateTime? data,
    String? descricao,
    Value<int?> categoriaId = const Value.absent(),
    Value<FormaPagamento?> formaPagamento = const Value.absent(),
    Value<int?> contaId = const Value.absent(),
    Value<int?> contaDestinoId = const Value.absent(),
    Value<int?> cartaoId = const Value.absent(),
    Value<int?> faturaId = const Value.absent(),
    Value<int?> compraParceladaId = const Value.absent(),
    Value<int?> parcelaNumero = const Value.absent(),
    Value<int?> ocorrenciaCompromissoId = const Value.absent(),
    Value<int?> investimentoId = const Value.absent(),
    Value<int?> receitaRecorrenteId = const Value.absent(),
    OrigemLancamento? origem,
    Value<String?> chaveImportacao = const Value.absent(),
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) => Lancamento(
    id: id ?? this.id,
    tipo: tipo ?? this.tipo,
    valor: valor ?? this.valor,
    data: data ?? this.data,
    descricao: descricao ?? this.descricao,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    formaPagamento: formaPagamento.present
        ? formaPagamento.value
        : this.formaPagamento,
    contaId: contaId.present ? contaId.value : this.contaId,
    contaDestinoId: contaDestinoId.present
        ? contaDestinoId.value
        : this.contaDestinoId,
    cartaoId: cartaoId.present ? cartaoId.value : this.cartaoId,
    faturaId: faturaId.present ? faturaId.value : this.faturaId,
    compraParceladaId: compraParceladaId.present
        ? compraParceladaId.value
        : this.compraParceladaId,
    parcelaNumero: parcelaNumero.present
        ? parcelaNumero.value
        : this.parcelaNumero,
    ocorrenciaCompromissoId: ocorrenciaCompromissoId.present
        ? ocorrenciaCompromissoId.value
        : this.ocorrenciaCompromissoId,
    investimentoId: investimentoId.present
        ? investimentoId.value
        : this.investimentoId,
    receitaRecorrenteId: receitaRecorrenteId.present
        ? receitaRecorrenteId.value
        : this.receitaRecorrenteId,
    origem: origem ?? this.origem,
    chaveImportacao: chaveImportacao.present
        ? chaveImportacao.value
        : this.chaveImportacao,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  Lancamento copyWithCompanion(LancamentosCompanion data) {
    return Lancamento(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      valor: data.valor.present ? data.valor.value : this.valor,
      data: data.data.present ? data.data.value : this.data,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      formaPagamento: data.formaPagamento.present
          ? data.formaPagamento.value
          : this.formaPagamento,
      contaId: data.contaId.present ? data.contaId.value : this.contaId,
      contaDestinoId: data.contaDestinoId.present
          ? data.contaDestinoId.value
          : this.contaDestinoId,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      faturaId: data.faturaId.present ? data.faturaId.value : this.faturaId,
      compraParceladaId: data.compraParceladaId.present
          ? data.compraParceladaId.value
          : this.compraParceladaId,
      parcelaNumero: data.parcelaNumero.present
          ? data.parcelaNumero.value
          : this.parcelaNumero,
      ocorrenciaCompromissoId: data.ocorrenciaCompromissoId.present
          ? data.ocorrenciaCompromissoId.value
          : this.ocorrenciaCompromissoId,
      investimentoId: data.investimentoId.present
          ? data.investimentoId.value
          : this.investimentoId,
      receitaRecorrenteId: data.receitaRecorrenteId.present
          ? data.receitaRecorrenteId.value
          : this.receitaRecorrenteId,
      origem: data.origem.present ? data.origem.value : this.origem,
      chaveImportacao: data.chaveImportacao.present
          ? data.chaveImportacao.value
          : this.chaveImportacao,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lancamento(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('valor: $valor, ')
          ..write('data: $data, ')
          ..write('descricao: $descricao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('formaPagamento: $formaPagamento, ')
          ..write('contaId: $contaId, ')
          ..write('contaDestinoId: $contaDestinoId, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('faturaId: $faturaId, ')
          ..write('compraParceladaId: $compraParceladaId, ')
          ..write('parcelaNumero: $parcelaNumero, ')
          ..write('ocorrenciaCompromissoId: $ocorrenciaCompromissoId, ')
          ..write('investimentoId: $investimentoId, ')
          ..write('receitaRecorrenteId: $receitaRecorrenteId, ')
          ..write('origem: $origem, ')
          ..write('chaveImportacao: $chaveImportacao, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipo,
    valor,
    data,
    descricao,
    categoriaId,
    formaPagamento,
    contaId,
    contaDestinoId,
    cartaoId,
    faturaId,
    compraParceladaId,
    parcelaNumero,
    ocorrenciaCompromissoId,
    investimentoId,
    receitaRecorrenteId,
    origem,
    chaveImportacao,
    criadoEm,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lancamento &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.valor == this.valor &&
          other.data == this.data &&
          other.descricao == this.descricao &&
          other.categoriaId == this.categoriaId &&
          other.formaPagamento == this.formaPagamento &&
          other.contaId == this.contaId &&
          other.contaDestinoId == this.contaDestinoId &&
          other.cartaoId == this.cartaoId &&
          other.faturaId == this.faturaId &&
          other.compraParceladaId == this.compraParceladaId &&
          other.parcelaNumero == this.parcelaNumero &&
          other.ocorrenciaCompromissoId == this.ocorrenciaCompromissoId &&
          other.investimentoId == this.investimentoId &&
          other.receitaRecorrenteId == this.receitaRecorrenteId &&
          other.origem == this.origem &&
          other.chaveImportacao == this.chaveImportacao &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm);
}

class LancamentosCompanion extends UpdateCompanion<Lancamento> {
  final Value<int> id;
  final Value<TipoLancamento> tipo;
  final Value<int> valor;
  final Value<DateTime> data;
  final Value<String> descricao;
  final Value<int?> categoriaId;
  final Value<FormaPagamento?> formaPagamento;
  final Value<int?> contaId;
  final Value<int?> contaDestinoId;
  final Value<int?> cartaoId;
  final Value<int?> faturaId;
  final Value<int?> compraParceladaId;
  final Value<int?> parcelaNumero;
  final Value<int?> ocorrenciaCompromissoId;
  final Value<int?> investimentoId;
  final Value<int?> receitaRecorrenteId;
  final Value<OrigemLancamento> origem;
  final Value<String?> chaveImportacao;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  const LancamentosCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.valor = const Value.absent(),
    this.data = const Value.absent(),
    this.descricao = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.formaPagamento = const Value.absent(),
    this.contaId = const Value.absent(),
    this.contaDestinoId = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.faturaId = const Value.absent(),
    this.compraParceladaId = const Value.absent(),
    this.parcelaNumero = const Value.absent(),
    this.ocorrenciaCompromissoId = const Value.absent(),
    this.investimentoId = const Value.absent(),
    this.receitaRecorrenteId = const Value.absent(),
    this.origem = const Value.absent(),
    this.chaveImportacao = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  });
  LancamentosCompanion.insert({
    this.id = const Value.absent(),
    required TipoLancamento tipo,
    required int valor,
    required DateTime data,
    this.descricao = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.formaPagamento = const Value.absent(),
    this.contaId = const Value.absent(),
    this.contaDestinoId = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.faturaId = const Value.absent(),
    this.compraParceladaId = const Value.absent(),
    this.parcelaNumero = const Value.absent(),
    this.ocorrenciaCompromissoId = const Value.absent(),
    this.investimentoId = const Value.absent(),
    this.receitaRecorrenteId = const Value.absent(),
    this.origem = const Value.absent(),
    this.chaveImportacao = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  }) : tipo = Value(tipo),
       valor = Value(valor),
       data = Value(data);
  static Insertable<Lancamento> custom({
    Expression<int>? id,
    Expression<String>? tipo,
    Expression<int>? valor,
    Expression<int>? data,
    Expression<String>? descricao,
    Expression<int>? categoriaId,
    Expression<String>? formaPagamento,
    Expression<int>? contaId,
    Expression<int>? contaDestinoId,
    Expression<int>? cartaoId,
    Expression<int>? faturaId,
    Expression<int>? compraParceladaId,
    Expression<int>? parcelaNumero,
    Expression<int>? ocorrenciaCompromissoId,
    Expression<int>? investimentoId,
    Expression<int>? receitaRecorrenteId,
    Expression<String>? origem,
    Expression<String>? chaveImportacao,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (valor != null) 'valor': valor,
      if (data != null) 'data': data,
      if (descricao != null) 'descricao': descricao,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (formaPagamento != null) 'forma_pagamento': formaPagamento,
      if (contaId != null) 'conta_id': contaId,
      if (contaDestinoId != null) 'conta_destino_id': contaDestinoId,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (faturaId != null) 'fatura_id': faturaId,
      if (compraParceladaId != null) 'compra_parcelada_id': compraParceladaId,
      if (parcelaNumero != null) 'parcela_numero': parcelaNumero,
      if (ocorrenciaCompromissoId != null)
        'ocorrencia_compromisso_id': ocorrenciaCompromissoId,
      if (investimentoId != null) 'investimento_id': investimentoId,
      if (receitaRecorrenteId != null)
        'receita_recorrente_id': receitaRecorrenteId,
      if (origem != null) 'origem': origem,
      if (chaveImportacao != null) 'chave_importacao': chaveImportacao,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
    });
  }

  LancamentosCompanion copyWith({
    Value<int>? id,
    Value<TipoLancamento>? tipo,
    Value<int>? valor,
    Value<DateTime>? data,
    Value<String>? descricao,
    Value<int?>? categoriaId,
    Value<FormaPagamento?>? formaPagamento,
    Value<int?>? contaId,
    Value<int?>? contaDestinoId,
    Value<int?>? cartaoId,
    Value<int?>? faturaId,
    Value<int?>? compraParceladaId,
    Value<int?>? parcelaNumero,
    Value<int?>? ocorrenciaCompromissoId,
    Value<int?>? investimentoId,
    Value<int?>? receitaRecorrenteId,
    Value<OrigemLancamento>? origem,
    Value<String?>? chaveImportacao,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
  }) {
    return LancamentosCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
      categoriaId: categoriaId ?? this.categoriaId,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      contaId: contaId ?? this.contaId,
      contaDestinoId: contaDestinoId ?? this.contaDestinoId,
      cartaoId: cartaoId ?? this.cartaoId,
      faturaId: faturaId ?? this.faturaId,
      compraParceladaId: compraParceladaId ?? this.compraParceladaId,
      parcelaNumero: parcelaNumero ?? this.parcelaNumero,
      ocorrenciaCompromissoId:
          ocorrenciaCompromissoId ?? this.ocorrenciaCompromissoId,
      investimentoId: investimentoId ?? this.investimentoId,
      receitaRecorrenteId: receitaRecorrenteId ?? this.receitaRecorrenteId,
      origem: origem ?? this.origem,
      chaveImportacao: chaveImportacao ?? this.chaveImportacao,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $LancamentosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (valor.present) {
      map['valor'] = Variable<int>(valor.value);
    }
    if (data.present) {
      map['data'] = Variable<int>(
        $LancamentosTable.$converterdata.toSql(data.value),
      );
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (formaPagamento.present) {
      map['forma_pagamento'] = Variable<String>(
        $LancamentosTable.$converterformaPagamenton.toSql(formaPagamento.value),
      );
    }
    if (contaId.present) {
      map['conta_id'] = Variable<int>(contaId.value);
    }
    if (contaDestinoId.present) {
      map['conta_destino_id'] = Variable<int>(contaDestinoId.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (faturaId.present) {
      map['fatura_id'] = Variable<int>(faturaId.value);
    }
    if (compraParceladaId.present) {
      map['compra_parcelada_id'] = Variable<int>(compraParceladaId.value);
    }
    if (parcelaNumero.present) {
      map['parcela_numero'] = Variable<int>(parcelaNumero.value);
    }
    if (ocorrenciaCompromissoId.present) {
      map['ocorrencia_compromisso_id'] = Variable<int>(
        ocorrenciaCompromissoId.value,
      );
    }
    if (investimentoId.present) {
      map['investimento_id'] = Variable<int>(investimentoId.value);
    }
    if (receitaRecorrenteId.present) {
      map['receita_recorrente_id'] = Variable<int>(receitaRecorrenteId.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(
        $LancamentosTable.$converterorigem.toSql(origem.value),
      );
    }
    if (chaveImportacao.present) {
      map['chave_importacao'] = Variable<String>(chaveImportacao.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LancamentosCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('valor: $valor, ')
          ..write('data: $data, ')
          ..write('descricao: $descricao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('formaPagamento: $formaPagamento, ')
          ..write('contaId: $contaId, ')
          ..write('contaDestinoId: $contaDestinoId, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('faturaId: $faturaId, ')
          ..write('compraParceladaId: $compraParceladaId, ')
          ..write('parcelaNumero: $parcelaNumero, ')
          ..write('ocorrenciaCompromissoId: $ocorrenciaCompromissoId, ')
          ..write('investimentoId: $investimentoId, ')
          ..write('receitaRecorrenteId: $receitaRecorrenteId, ')
          ..write('origem: $origem, ')
          ..write('chaveImportacao: $chaveImportacao, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }
}

class $CompromissosTable extends Compromissos
    with TableInfo<$CompromissosTable, Compromisso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompromissosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FormaPagamento, String>
  formaPagamento = GeneratedColumn<String>(
    'forma_pagamento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('boleto'),
  ).withConverter<FormaPagamento>($CompromissosTable.$converterformaPagamento);
  static const VerificationMeta _contaIdMeta = const VerificationMeta(
    'contaId',
  );
  @override
  late final GeneratedColumn<int> contaId = GeneratedColumn<int>(
    'conta_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contas (id)',
    ),
  );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cartoes (id)',
    ),
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<int> valor = GeneratedColumn<int>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaVencimentoMeta = const VerificationMeta(
    'diaVencimento',
  );
  @override
  late final GeneratedColumn<int> diaVencimento = GeneratedColumn<int>(
    'dia_vencimento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dataInicio =
      GeneratedColumn<int>(
        'data_inicio',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CompromissosTable.$converterdataInicio);
  @override
  late final GeneratedColumnWithTypeConverter<TipoCompromisso, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoCompromisso>($CompromissosTable.$convertertipo);
  static const VerificationMeta _numeroParcelasMeta = const VerificationMeta(
    'numeroParcelas',
  );
  @override
  late final GeneratedColumn<int> numeroParcelas = GeneratedColumn<int>(
    'numero_parcelas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    descricao,
    categoriaId,
    formaPagamento,
    contaId,
    cartaoId,
    valor,
    diaVencimento,
    dataInicio,
    tipo,
    numeroParcelas,
    ativo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compromissos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Compromisso> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('conta_id')) {
      context.handle(
        _contaIdMeta,
        contaId.isAcceptableOrUnknown(data['conta_id']!, _contaIdMeta),
      );
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('dia_vencimento')) {
      context.handle(
        _diaVencimentoMeta,
        diaVencimento.isAcceptableOrUnknown(
          data['dia_vencimento']!,
          _diaVencimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaVencimentoMeta);
    }
    if (data.containsKey('numero_parcelas')) {
      context.handle(
        _numeroParcelasMeta,
        numeroParcelas.isAcceptableOrUnknown(
          data['numero_parcelas']!,
          _numeroParcelasMeta,
        ),
      );
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Compromisso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Compromisso(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      ),
      formaPagamento: $CompromissosTable.$converterformaPagamento.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forma_pagamento'],
        )!,
      ),
      contaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_id'],
      ),
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      ),
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor'],
      )!,
      diaVencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_vencimento'],
      )!,
      dataInicio: $CompromissosTable.$converterdataInicio.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_inicio'],
        )!,
      ),
      tipo: $CompromissosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      numeroParcelas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero_parcelas'],
      ),
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
    );
  }

  @override
  $CompromissosTable createAlias(String alias) {
    return $CompromissosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FormaPagamento, String, String>
  $converterformaPagamento = const EnumNameConverter<FormaPagamento>(
    FormaPagamento.values,
  );
  static TypeConverter<DateTime, int> $converterdataInicio =
      const ConversorData();
  static JsonTypeConverter2<TipoCompromisso, String, String> $convertertipo =
      const EnumNameConverter<TipoCompromisso>(TipoCompromisso.values);
}

class Compromisso extends DataClass implements Insertable<Compromisso> {
  final int id;
  final String descricao;
  final int? categoriaId;
  final FormaPagamento formaPagamento;
  final int? contaId;

  /// Gasto fixo **no crédito**: cartão em que a cobrança cai todo mês.
  final int? cartaoId;
  final int valor;
  final int diaVencimento;
  final DateTime dataInicio;
  final TipoCompromisso tipo;
  final int? numeroParcelas;
  final bool ativo;
  const Compromisso({
    required this.id,
    required this.descricao,
    this.categoriaId,
    required this.formaPagamento,
    this.contaId,
    this.cartaoId,
    required this.valor,
    required this.diaVencimento,
    required this.dataInicio,
    required this.tipo,
    this.numeroParcelas,
    required this.ativo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['descricao'] = Variable<String>(descricao);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    {
      map['forma_pagamento'] = Variable<String>(
        $CompromissosTable.$converterformaPagamento.toSql(formaPagamento),
      );
    }
    if (!nullToAbsent || contaId != null) {
      map['conta_id'] = Variable<int>(contaId);
    }
    if (!nullToAbsent || cartaoId != null) {
      map['cartao_id'] = Variable<int>(cartaoId);
    }
    map['valor'] = Variable<int>(valor);
    map['dia_vencimento'] = Variable<int>(diaVencimento);
    {
      map['data_inicio'] = Variable<int>(
        $CompromissosTable.$converterdataInicio.toSql(dataInicio),
      );
    }
    {
      map['tipo'] = Variable<String>(
        $CompromissosTable.$convertertipo.toSql(tipo),
      );
    }
    if (!nullToAbsent || numeroParcelas != null) {
      map['numero_parcelas'] = Variable<int>(numeroParcelas);
    }
    map['ativo'] = Variable<bool>(ativo);
    return map;
  }

  CompromissosCompanion toCompanion(bool nullToAbsent) {
    return CompromissosCompanion(
      id: Value(id),
      descricao: Value(descricao),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      formaPagamento: Value(formaPagamento),
      contaId: contaId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaId),
      cartaoId: cartaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cartaoId),
      valor: Value(valor),
      diaVencimento: Value(diaVencimento),
      dataInicio: Value(dataInicio),
      tipo: Value(tipo),
      numeroParcelas: numeroParcelas == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroParcelas),
      ativo: Value(ativo),
    );
  }

  factory Compromisso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Compromisso(
      id: serializer.fromJson<int>(json['id']),
      descricao: serializer.fromJson<String>(json['descricao']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      formaPagamento: $CompromissosTable.$converterformaPagamento.fromJson(
        serializer.fromJson<String>(json['formaPagamento']),
      ),
      contaId: serializer.fromJson<int?>(json['contaId']),
      cartaoId: serializer.fromJson<int?>(json['cartaoId']),
      valor: serializer.fromJson<int>(json['valor']),
      diaVencimento: serializer.fromJson<int>(json['diaVencimento']),
      dataInicio: serializer.fromJson<DateTime>(json['dataInicio']),
      tipo: $CompromissosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      numeroParcelas: serializer.fromJson<int?>(json['numeroParcelas']),
      ativo: serializer.fromJson<bool>(json['ativo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'descricao': serializer.toJson<String>(descricao),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'formaPagamento': serializer.toJson<String>(
        $CompromissosTable.$converterformaPagamento.toJson(formaPagamento),
      ),
      'contaId': serializer.toJson<int?>(contaId),
      'cartaoId': serializer.toJson<int?>(cartaoId),
      'valor': serializer.toJson<int>(valor),
      'diaVencimento': serializer.toJson<int>(diaVencimento),
      'dataInicio': serializer.toJson<DateTime>(dataInicio),
      'tipo': serializer.toJson<String>(
        $CompromissosTable.$convertertipo.toJson(tipo),
      ),
      'numeroParcelas': serializer.toJson<int?>(numeroParcelas),
      'ativo': serializer.toJson<bool>(ativo),
    };
  }

  Compromisso copyWith({
    int? id,
    String? descricao,
    Value<int?> categoriaId = const Value.absent(),
    FormaPagamento? formaPagamento,
    Value<int?> contaId = const Value.absent(),
    Value<int?> cartaoId = const Value.absent(),
    int? valor,
    int? diaVencimento,
    DateTime? dataInicio,
    TipoCompromisso? tipo,
    Value<int?> numeroParcelas = const Value.absent(),
    bool? ativo,
  }) => Compromisso(
    id: id ?? this.id,
    descricao: descricao ?? this.descricao,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    formaPagamento: formaPagamento ?? this.formaPagamento,
    contaId: contaId.present ? contaId.value : this.contaId,
    cartaoId: cartaoId.present ? cartaoId.value : this.cartaoId,
    valor: valor ?? this.valor,
    diaVencimento: diaVencimento ?? this.diaVencimento,
    dataInicio: dataInicio ?? this.dataInicio,
    tipo: tipo ?? this.tipo,
    numeroParcelas: numeroParcelas.present
        ? numeroParcelas.value
        : this.numeroParcelas,
    ativo: ativo ?? this.ativo,
  );
  Compromisso copyWithCompanion(CompromissosCompanion data) {
    return Compromisso(
      id: data.id.present ? data.id.value : this.id,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      formaPagamento: data.formaPagamento.present
          ? data.formaPagamento.value
          : this.formaPagamento,
      contaId: data.contaId.present ? data.contaId.value : this.contaId,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      valor: data.valor.present ? data.valor.value : this.valor,
      diaVencimento: data.diaVencimento.present
          ? data.diaVencimento.value
          : this.diaVencimento,
      dataInicio: data.dataInicio.present
          ? data.dataInicio.value
          : this.dataInicio,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      numeroParcelas: data.numeroParcelas.present
          ? data.numeroParcelas.value
          : this.numeroParcelas,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Compromisso(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('formaPagamento: $formaPagamento, ')
          ..write('contaId: $contaId, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('valor: $valor, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('tipo: $tipo, ')
          ..write('numeroParcelas: $numeroParcelas, ')
          ..write('ativo: $ativo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    descricao,
    categoriaId,
    formaPagamento,
    contaId,
    cartaoId,
    valor,
    diaVencimento,
    dataInicio,
    tipo,
    numeroParcelas,
    ativo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Compromisso &&
          other.id == this.id &&
          other.descricao == this.descricao &&
          other.categoriaId == this.categoriaId &&
          other.formaPagamento == this.formaPagamento &&
          other.contaId == this.contaId &&
          other.cartaoId == this.cartaoId &&
          other.valor == this.valor &&
          other.diaVencimento == this.diaVencimento &&
          other.dataInicio == this.dataInicio &&
          other.tipo == this.tipo &&
          other.numeroParcelas == this.numeroParcelas &&
          other.ativo == this.ativo);
}

class CompromissosCompanion extends UpdateCompanion<Compromisso> {
  final Value<int> id;
  final Value<String> descricao;
  final Value<int?> categoriaId;
  final Value<FormaPagamento> formaPagamento;
  final Value<int?> contaId;
  final Value<int?> cartaoId;
  final Value<int> valor;
  final Value<int> diaVencimento;
  final Value<DateTime> dataInicio;
  final Value<TipoCompromisso> tipo;
  final Value<int?> numeroParcelas;
  final Value<bool> ativo;
  const CompromissosCompanion({
    this.id = const Value.absent(),
    this.descricao = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.formaPagamento = const Value.absent(),
    this.contaId = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.valor = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.dataInicio = const Value.absent(),
    this.tipo = const Value.absent(),
    this.numeroParcelas = const Value.absent(),
    this.ativo = const Value.absent(),
  });
  CompromissosCompanion.insert({
    this.id = const Value.absent(),
    required String descricao,
    this.categoriaId = const Value.absent(),
    this.formaPagamento = const Value.absent(),
    this.contaId = const Value.absent(),
    this.cartaoId = const Value.absent(),
    required int valor,
    required int diaVencimento,
    required DateTime dataInicio,
    required TipoCompromisso tipo,
    this.numeroParcelas = const Value.absent(),
    this.ativo = const Value.absent(),
  }) : descricao = Value(descricao),
       valor = Value(valor),
       diaVencimento = Value(diaVencimento),
       dataInicio = Value(dataInicio),
       tipo = Value(tipo);
  static Insertable<Compromisso> custom({
    Expression<int>? id,
    Expression<String>? descricao,
    Expression<int>? categoriaId,
    Expression<String>? formaPagamento,
    Expression<int>? contaId,
    Expression<int>? cartaoId,
    Expression<int>? valor,
    Expression<int>? diaVencimento,
    Expression<int>? dataInicio,
    Expression<String>? tipo,
    Expression<int>? numeroParcelas,
    Expression<bool>? ativo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descricao != null) 'descricao': descricao,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (formaPagamento != null) 'forma_pagamento': formaPagamento,
      if (contaId != null) 'conta_id': contaId,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (valor != null) 'valor': valor,
      if (diaVencimento != null) 'dia_vencimento': diaVencimento,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (tipo != null) 'tipo': tipo,
      if (numeroParcelas != null) 'numero_parcelas': numeroParcelas,
      if (ativo != null) 'ativo': ativo,
    });
  }

  CompromissosCompanion copyWith({
    Value<int>? id,
    Value<String>? descricao,
    Value<int?>? categoriaId,
    Value<FormaPagamento>? formaPagamento,
    Value<int?>? contaId,
    Value<int?>? cartaoId,
    Value<int>? valor,
    Value<int>? diaVencimento,
    Value<DateTime>? dataInicio,
    Value<TipoCompromisso>? tipo,
    Value<int?>? numeroParcelas,
    Value<bool>? ativo,
  }) {
    return CompromissosCompanion(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      categoriaId: categoriaId ?? this.categoriaId,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      contaId: contaId ?? this.contaId,
      cartaoId: cartaoId ?? this.cartaoId,
      valor: valor ?? this.valor,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      dataInicio: dataInicio ?? this.dataInicio,
      tipo: tipo ?? this.tipo,
      numeroParcelas: numeroParcelas ?? this.numeroParcelas,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (formaPagamento.present) {
      map['forma_pagamento'] = Variable<String>(
        $CompromissosTable.$converterformaPagamento.toSql(formaPagamento.value),
      );
    }
    if (contaId.present) {
      map['conta_id'] = Variable<int>(contaId.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (valor.present) {
      map['valor'] = Variable<int>(valor.value);
    }
    if (diaVencimento.present) {
      map['dia_vencimento'] = Variable<int>(diaVencimento.value);
    }
    if (dataInicio.present) {
      map['data_inicio'] = Variable<int>(
        $CompromissosTable.$converterdataInicio.toSql(dataInicio.value),
      );
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $CompromissosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (numeroParcelas.present) {
      map['numero_parcelas'] = Variable<int>(numeroParcelas.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompromissosCompanion(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('formaPagamento: $formaPagamento, ')
          ..write('contaId: $contaId, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('valor: $valor, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('tipo: $tipo, ')
          ..write('numeroParcelas: $numeroParcelas, ')
          ..write('ativo: $ativo')
          ..write(')'))
        .toString();
  }
}

class $OcorrenciasCompromissoTable extends OcorrenciasCompromisso
    with TableInfo<$OcorrenciasCompromissoTable, OcorrenciaCompromisso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OcorrenciasCompromissoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _compromissoIdMeta = const VerificationMeta(
    'compromissoId',
  );
  @override
  late final GeneratedColumn<int> compromissoId = GeneratedColumn<int>(
    'compromisso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES compromissos (id)',
    ),
  );
  static const VerificationMeta _competenciaMeta = const VerificationMeta(
    'competencia',
  );
  @override
  late final GeneratedColumn<String> competencia = GeneratedColumn<String>(
    'competencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroParcelaMeta = const VerificationMeta(
    'numeroParcela',
  );
  @override
  late final GeneratedColumn<int> numeroParcela = GeneratedColumn<int>(
    'numero_parcela',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<int> valor = GeneratedColumn<int>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dataVencimento =
      GeneratedColumn<int>(
        'data_vencimento',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $OcorrenciasCompromissoTable.$converterdataVencimento,
      );
  @override
  late final GeneratedColumnWithTypeConverter<StatusOcorrencia, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pendente'),
      ).withConverter<StatusOcorrencia>(
        $OcorrenciasCompromissoTable.$converterstatus,
      );
  static const VerificationMeta _lancamentoIdMeta = const VerificationMeta(
    'lancamentoId',
  );
  @override
  late final GeneratedColumn<int> lancamentoId = GeneratedColumn<int>(
    'lancamento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    compromissoId,
    competencia,
    numeroParcela,
    valor,
    dataVencimento,
    status,
    lancamentoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ocorrencias_compromisso';
  @override
  VerificationContext validateIntegrity(
    Insertable<OcorrenciaCompromisso> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('compromisso_id')) {
      context.handle(
        _compromissoIdMeta,
        compromissoId.isAcceptableOrUnknown(
          data['compromisso_id']!,
          _compromissoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compromissoIdMeta);
    }
    if (data.containsKey('competencia')) {
      context.handle(
        _competenciaMeta,
        competencia.isAcceptableOrUnknown(
          data['competencia']!,
          _competenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_competenciaMeta);
    }
    if (data.containsKey('numero_parcela')) {
      context.handle(
        _numeroParcelaMeta,
        numeroParcela.isAcceptableOrUnknown(
          data['numero_parcela']!,
          _numeroParcelaMeta,
        ),
      );
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('lancamento_id')) {
      context.handle(
        _lancamentoIdMeta,
        lancamentoId.isAcceptableOrUnknown(
          data['lancamento_id']!,
          _lancamentoIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {compromissoId, competencia},
  ];
  @override
  OcorrenciaCompromisso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OcorrenciaCompromisso(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      compromissoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compromisso_id'],
      )!,
      competencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competencia'],
      )!,
      numeroParcela: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero_parcela'],
      ),
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor'],
      )!,
      dataVencimento: $OcorrenciasCompromissoTable.$converterdataVencimento
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}data_vencimento'],
            )!,
          ),
      status: $OcorrenciasCompromissoTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      lancamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lancamento_id'],
      ),
    );
  }

  @override
  $OcorrenciasCompromissoTable createAlias(String alias) {
    return $OcorrenciasCompromissoTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdataVencimento =
      const ConversorData();
  static JsonTypeConverter2<StatusOcorrencia, String, String> $converterstatus =
      const EnumNameConverter<StatusOcorrencia>(StatusOcorrencia.values);
}

class OcorrenciaCompromisso extends DataClass
    implements Insertable<OcorrenciaCompromisso> {
  final int id;
  final int compromissoId;
  final String competencia;
  final int? numeroParcela;
  final int valor;
  final DateTime dataVencimento;
  final StatusOcorrencia status;
  final int? lancamentoId;
  const OcorrenciaCompromisso({
    required this.id,
    required this.compromissoId,
    required this.competencia,
    this.numeroParcela,
    required this.valor,
    required this.dataVencimento,
    required this.status,
    this.lancamentoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['compromisso_id'] = Variable<int>(compromissoId);
    map['competencia'] = Variable<String>(competencia);
    if (!nullToAbsent || numeroParcela != null) {
      map['numero_parcela'] = Variable<int>(numeroParcela);
    }
    map['valor'] = Variable<int>(valor);
    {
      map['data_vencimento'] = Variable<int>(
        $OcorrenciasCompromissoTable.$converterdataVencimento.toSql(
          dataVencimento,
        ),
      );
    }
    {
      map['status'] = Variable<String>(
        $OcorrenciasCompromissoTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || lancamentoId != null) {
      map['lancamento_id'] = Variable<int>(lancamentoId);
    }
    return map;
  }

  OcorrenciasCompromissoCompanion toCompanion(bool nullToAbsent) {
    return OcorrenciasCompromissoCompanion(
      id: Value(id),
      compromissoId: Value(compromissoId),
      competencia: Value(competencia),
      numeroParcela: numeroParcela == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroParcela),
      valor: Value(valor),
      dataVencimento: Value(dataVencimento),
      status: Value(status),
      lancamentoId: lancamentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(lancamentoId),
    );
  }

  factory OcorrenciaCompromisso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OcorrenciaCompromisso(
      id: serializer.fromJson<int>(json['id']),
      compromissoId: serializer.fromJson<int>(json['compromissoId']),
      competencia: serializer.fromJson<String>(json['competencia']),
      numeroParcela: serializer.fromJson<int?>(json['numeroParcela']),
      valor: serializer.fromJson<int>(json['valor']),
      dataVencimento: serializer.fromJson<DateTime>(json['dataVencimento']),
      status: $OcorrenciasCompromissoTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      lancamentoId: serializer.fromJson<int?>(json['lancamentoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'compromissoId': serializer.toJson<int>(compromissoId),
      'competencia': serializer.toJson<String>(competencia),
      'numeroParcela': serializer.toJson<int?>(numeroParcela),
      'valor': serializer.toJson<int>(valor),
      'dataVencimento': serializer.toJson<DateTime>(dataVencimento),
      'status': serializer.toJson<String>(
        $OcorrenciasCompromissoTable.$converterstatus.toJson(status),
      ),
      'lancamentoId': serializer.toJson<int?>(lancamentoId),
    };
  }

  OcorrenciaCompromisso copyWith({
    int? id,
    int? compromissoId,
    String? competencia,
    Value<int?> numeroParcela = const Value.absent(),
    int? valor,
    DateTime? dataVencimento,
    StatusOcorrencia? status,
    Value<int?> lancamentoId = const Value.absent(),
  }) => OcorrenciaCompromisso(
    id: id ?? this.id,
    compromissoId: compromissoId ?? this.compromissoId,
    competencia: competencia ?? this.competencia,
    numeroParcela: numeroParcela.present
        ? numeroParcela.value
        : this.numeroParcela,
    valor: valor ?? this.valor,
    dataVencimento: dataVencimento ?? this.dataVencimento,
    status: status ?? this.status,
    lancamentoId: lancamentoId.present ? lancamentoId.value : this.lancamentoId,
  );
  OcorrenciaCompromisso copyWithCompanion(
    OcorrenciasCompromissoCompanion data,
  ) {
    return OcorrenciaCompromisso(
      id: data.id.present ? data.id.value : this.id,
      compromissoId: data.compromissoId.present
          ? data.compromissoId.value
          : this.compromissoId,
      competencia: data.competencia.present
          ? data.competencia.value
          : this.competencia,
      numeroParcela: data.numeroParcela.present
          ? data.numeroParcela.value
          : this.numeroParcela,
      valor: data.valor.present ? data.valor.value : this.valor,
      dataVencimento: data.dataVencimento.present
          ? data.dataVencimento.value
          : this.dataVencimento,
      status: data.status.present ? data.status.value : this.status,
      lancamentoId: data.lancamentoId.present
          ? data.lancamentoId.value
          : this.lancamentoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OcorrenciaCompromisso(')
          ..write('id: $id, ')
          ..write('compromissoId: $compromissoId, ')
          ..write('competencia: $competencia, ')
          ..write('numeroParcela: $numeroParcela, ')
          ..write('valor: $valor, ')
          ..write('dataVencimento: $dataVencimento, ')
          ..write('status: $status, ')
          ..write('lancamentoId: $lancamentoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    compromissoId,
    competencia,
    numeroParcela,
    valor,
    dataVencimento,
    status,
    lancamentoId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OcorrenciaCompromisso &&
          other.id == this.id &&
          other.compromissoId == this.compromissoId &&
          other.competencia == this.competencia &&
          other.numeroParcela == this.numeroParcela &&
          other.valor == this.valor &&
          other.dataVencimento == this.dataVencimento &&
          other.status == this.status &&
          other.lancamentoId == this.lancamentoId);
}

class OcorrenciasCompromissoCompanion
    extends UpdateCompanion<OcorrenciaCompromisso> {
  final Value<int> id;
  final Value<int> compromissoId;
  final Value<String> competencia;
  final Value<int?> numeroParcela;
  final Value<int> valor;
  final Value<DateTime> dataVencimento;
  final Value<StatusOcorrencia> status;
  final Value<int?> lancamentoId;
  const OcorrenciasCompromissoCompanion({
    this.id = const Value.absent(),
    this.compromissoId = const Value.absent(),
    this.competencia = const Value.absent(),
    this.numeroParcela = const Value.absent(),
    this.valor = const Value.absent(),
    this.dataVencimento = const Value.absent(),
    this.status = const Value.absent(),
    this.lancamentoId = const Value.absent(),
  });
  OcorrenciasCompromissoCompanion.insert({
    this.id = const Value.absent(),
    required int compromissoId,
    required String competencia,
    this.numeroParcela = const Value.absent(),
    required int valor,
    required DateTime dataVencimento,
    this.status = const Value.absent(),
    this.lancamentoId = const Value.absent(),
  }) : compromissoId = Value(compromissoId),
       competencia = Value(competencia),
       valor = Value(valor),
       dataVencimento = Value(dataVencimento);
  static Insertable<OcorrenciaCompromisso> custom({
    Expression<int>? id,
    Expression<int>? compromissoId,
    Expression<String>? competencia,
    Expression<int>? numeroParcela,
    Expression<int>? valor,
    Expression<int>? dataVencimento,
    Expression<String>? status,
    Expression<int>? lancamentoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (compromissoId != null) 'compromisso_id': compromissoId,
      if (competencia != null) 'competencia': competencia,
      if (numeroParcela != null) 'numero_parcela': numeroParcela,
      if (valor != null) 'valor': valor,
      if (dataVencimento != null) 'data_vencimento': dataVencimento,
      if (status != null) 'status': status,
      if (lancamentoId != null) 'lancamento_id': lancamentoId,
    });
  }

  OcorrenciasCompromissoCompanion copyWith({
    Value<int>? id,
    Value<int>? compromissoId,
    Value<String>? competencia,
    Value<int?>? numeroParcela,
    Value<int>? valor,
    Value<DateTime>? dataVencimento,
    Value<StatusOcorrencia>? status,
    Value<int?>? lancamentoId,
  }) {
    return OcorrenciasCompromissoCompanion(
      id: id ?? this.id,
      compromissoId: compromissoId ?? this.compromissoId,
      competencia: competencia ?? this.competencia,
      numeroParcela: numeroParcela ?? this.numeroParcela,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      status: status ?? this.status,
      lancamentoId: lancamentoId ?? this.lancamentoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (compromissoId.present) {
      map['compromisso_id'] = Variable<int>(compromissoId.value);
    }
    if (competencia.present) {
      map['competencia'] = Variable<String>(competencia.value);
    }
    if (numeroParcela.present) {
      map['numero_parcela'] = Variable<int>(numeroParcela.value);
    }
    if (valor.present) {
      map['valor'] = Variable<int>(valor.value);
    }
    if (dataVencimento.present) {
      map['data_vencimento'] = Variable<int>(
        $OcorrenciasCompromissoTable.$converterdataVencimento.toSql(
          dataVencimento.value,
        ),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $OcorrenciasCompromissoTable.$converterstatus.toSql(status.value),
      );
    }
    if (lancamentoId.present) {
      map['lancamento_id'] = Variable<int>(lancamentoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OcorrenciasCompromissoCompanion(')
          ..write('id: $id, ')
          ..write('compromissoId: $compromissoId, ')
          ..write('competencia: $competencia, ')
          ..write('numeroParcela: $numeroParcela, ')
          ..write('valor: $valor, ')
          ..write('dataVencimento: $dataVencimento, ')
          ..write('status: $status, ')
          ..write('lancamentoId: $lancamentoId')
          ..write(')'))
        .toString();
  }
}

class $ReceitasRecorrentesTable extends ReceitasRecorrentes
    with TableInfo<$ReceitasRecorrentesTable, ReceitaRecorrente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceitasRecorrentesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _contaIdMeta = const VerificationMeta(
    'contaId',
  );
  @override
  late final GeneratedColumn<int> contaId = GeneratedColumn<int>(
    'conta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contas (id)',
    ),
  );
  static const VerificationMeta _valorPrevistoMeta = const VerificationMeta(
    'valorPrevisto',
  );
  @override
  late final GeneratedColumn<int> valorPrevisto = GeneratedColumn<int>(
    'valor_previsto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaPrevistoMeta = const VerificationMeta(
    'diaPrevisto',
  );
  @override
  late final GeneratedColumn<int> diaPrevisto = GeneratedColumn<int>(
    'dia_previsto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dataInicio =
      GeneratedColumn<int>(
        'data_inicio',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReceitasRecorrentesTable.$converterdataInicio);
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    descricao,
    categoriaId,
    contaId,
    valorPrevisto,
    diaPrevisto,
    dataInicio,
    ativa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receitas_recorrentes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceitaRecorrente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('conta_id')) {
      context.handle(
        _contaIdMeta,
        contaId.isAcceptableOrUnknown(data['conta_id']!, _contaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contaIdMeta);
    }
    if (data.containsKey('valor_previsto')) {
      context.handle(
        _valorPrevistoMeta,
        valorPrevisto.isAcceptableOrUnknown(
          data['valor_previsto']!,
          _valorPrevistoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorPrevistoMeta);
    }
    if (data.containsKey('dia_previsto')) {
      context.handle(
        _diaPrevistoMeta,
        diaPrevisto.isAcceptableOrUnknown(
          data['dia_previsto']!,
          _diaPrevistoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaPrevistoMeta);
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceitaRecorrente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceitaRecorrente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      ),
      contaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_id'],
      )!,
      valorPrevisto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_previsto'],
      )!,
      diaPrevisto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_previsto'],
      )!,
      dataInicio: $ReceitasRecorrentesTable.$converterdataInicio.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_inicio'],
        )!,
      ),
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativa'],
      )!,
    );
  }

  @override
  $ReceitasRecorrentesTable createAlias(String alias) {
    return $ReceitasRecorrentesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdataInicio =
      const ConversorData();
}

class ReceitaRecorrente extends DataClass
    implements Insertable<ReceitaRecorrente> {
  final int id;
  final String descricao;
  final int? categoriaId;
  final int contaId;
  final int valorPrevisto;
  final int diaPrevisto;
  final DateTime dataInicio;
  final bool ativa;
  const ReceitaRecorrente({
    required this.id,
    required this.descricao,
    this.categoriaId,
    required this.contaId,
    required this.valorPrevisto,
    required this.diaPrevisto,
    required this.dataInicio,
    required this.ativa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['descricao'] = Variable<String>(descricao);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    map['conta_id'] = Variable<int>(contaId);
    map['valor_previsto'] = Variable<int>(valorPrevisto);
    map['dia_previsto'] = Variable<int>(diaPrevisto);
    {
      map['data_inicio'] = Variable<int>(
        $ReceitasRecorrentesTable.$converterdataInicio.toSql(dataInicio),
      );
    }
    map['ativa'] = Variable<bool>(ativa);
    return map;
  }

  ReceitasRecorrentesCompanion toCompanion(bool nullToAbsent) {
    return ReceitasRecorrentesCompanion(
      id: Value(id),
      descricao: Value(descricao),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      contaId: Value(contaId),
      valorPrevisto: Value(valorPrevisto),
      diaPrevisto: Value(diaPrevisto),
      dataInicio: Value(dataInicio),
      ativa: Value(ativa),
    );
  }

  factory ReceitaRecorrente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceitaRecorrente(
      id: serializer.fromJson<int>(json['id']),
      descricao: serializer.fromJson<String>(json['descricao']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      contaId: serializer.fromJson<int>(json['contaId']),
      valorPrevisto: serializer.fromJson<int>(json['valorPrevisto']),
      diaPrevisto: serializer.fromJson<int>(json['diaPrevisto']),
      dataInicio: serializer.fromJson<DateTime>(json['dataInicio']),
      ativa: serializer.fromJson<bool>(json['ativa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'descricao': serializer.toJson<String>(descricao),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'contaId': serializer.toJson<int>(contaId),
      'valorPrevisto': serializer.toJson<int>(valorPrevisto),
      'diaPrevisto': serializer.toJson<int>(diaPrevisto),
      'dataInicio': serializer.toJson<DateTime>(dataInicio),
      'ativa': serializer.toJson<bool>(ativa),
    };
  }

  ReceitaRecorrente copyWith({
    int? id,
    String? descricao,
    Value<int?> categoriaId = const Value.absent(),
    int? contaId,
    int? valorPrevisto,
    int? diaPrevisto,
    DateTime? dataInicio,
    bool? ativa,
  }) => ReceitaRecorrente(
    id: id ?? this.id,
    descricao: descricao ?? this.descricao,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    contaId: contaId ?? this.contaId,
    valorPrevisto: valorPrevisto ?? this.valorPrevisto,
    diaPrevisto: diaPrevisto ?? this.diaPrevisto,
    dataInicio: dataInicio ?? this.dataInicio,
    ativa: ativa ?? this.ativa,
  );
  ReceitaRecorrente copyWithCompanion(ReceitasRecorrentesCompanion data) {
    return ReceitaRecorrente(
      id: data.id.present ? data.id.value : this.id,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      contaId: data.contaId.present ? data.contaId.value : this.contaId,
      valorPrevisto: data.valorPrevisto.present
          ? data.valorPrevisto.value
          : this.valorPrevisto,
      diaPrevisto: data.diaPrevisto.present
          ? data.diaPrevisto.value
          : this.diaPrevisto,
      dataInicio: data.dataInicio.present
          ? data.dataInicio.value
          : this.dataInicio,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceitaRecorrente(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('contaId: $contaId, ')
          ..write('valorPrevisto: $valorPrevisto, ')
          ..write('diaPrevisto: $diaPrevisto, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    descricao,
    categoriaId,
    contaId,
    valorPrevisto,
    diaPrevisto,
    dataInicio,
    ativa,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceitaRecorrente &&
          other.id == this.id &&
          other.descricao == this.descricao &&
          other.categoriaId == this.categoriaId &&
          other.contaId == this.contaId &&
          other.valorPrevisto == this.valorPrevisto &&
          other.diaPrevisto == this.diaPrevisto &&
          other.dataInicio == this.dataInicio &&
          other.ativa == this.ativa);
}

class ReceitasRecorrentesCompanion extends UpdateCompanion<ReceitaRecorrente> {
  final Value<int> id;
  final Value<String> descricao;
  final Value<int?> categoriaId;
  final Value<int> contaId;
  final Value<int> valorPrevisto;
  final Value<int> diaPrevisto;
  final Value<DateTime> dataInicio;
  final Value<bool> ativa;
  const ReceitasRecorrentesCompanion({
    this.id = const Value.absent(),
    this.descricao = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.contaId = const Value.absent(),
    this.valorPrevisto = const Value.absent(),
    this.diaPrevisto = const Value.absent(),
    this.dataInicio = const Value.absent(),
    this.ativa = const Value.absent(),
  });
  ReceitasRecorrentesCompanion.insert({
    this.id = const Value.absent(),
    required String descricao,
    this.categoriaId = const Value.absent(),
    required int contaId,
    required int valorPrevisto,
    required int diaPrevisto,
    required DateTime dataInicio,
    this.ativa = const Value.absent(),
  }) : descricao = Value(descricao),
       contaId = Value(contaId),
       valorPrevisto = Value(valorPrevisto),
       diaPrevisto = Value(diaPrevisto),
       dataInicio = Value(dataInicio);
  static Insertable<ReceitaRecorrente> custom({
    Expression<int>? id,
    Expression<String>? descricao,
    Expression<int>? categoriaId,
    Expression<int>? contaId,
    Expression<int>? valorPrevisto,
    Expression<int>? diaPrevisto,
    Expression<int>? dataInicio,
    Expression<bool>? ativa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descricao != null) 'descricao': descricao,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (contaId != null) 'conta_id': contaId,
      if (valorPrevisto != null) 'valor_previsto': valorPrevisto,
      if (diaPrevisto != null) 'dia_previsto': diaPrevisto,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (ativa != null) 'ativa': ativa,
    });
  }

  ReceitasRecorrentesCompanion copyWith({
    Value<int>? id,
    Value<String>? descricao,
    Value<int?>? categoriaId,
    Value<int>? contaId,
    Value<int>? valorPrevisto,
    Value<int>? diaPrevisto,
    Value<DateTime>? dataInicio,
    Value<bool>? ativa,
  }) {
    return ReceitasRecorrentesCompanion(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      categoriaId: categoriaId ?? this.categoriaId,
      contaId: contaId ?? this.contaId,
      valorPrevisto: valorPrevisto ?? this.valorPrevisto,
      diaPrevisto: diaPrevisto ?? this.diaPrevisto,
      dataInicio: dataInicio ?? this.dataInicio,
      ativa: ativa ?? this.ativa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (contaId.present) {
      map['conta_id'] = Variable<int>(contaId.value);
    }
    if (valorPrevisto.present) {
      map['valor_previsto'] = Variable<int>(valorPrevisto.value);
    }
    if (diaPrevisto.present) {
      map['dia_previsto'] = Variable<int>(diaPrevisto.value);
    }
    if (dataInicio.present) {
      map['data_inicio'] = Variable<int>(
        $ReceitasRecorrentesTable.$converterdataInicio.toSql(dataInicio.value),
      );
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceitasRecorrentesCompanion(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('contaId: $contaId, ')
          ..write('valorPrevisto: $valorPrevisto, ')
          ..write('diaPrevisto: $diaPrevisto, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }
}

class $MovimentosInvestimentoTable extends MovimentosInvestimento
    with TableInfo<$MovimentosInvestimentoTable, MovimentoInvestimento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimentosInvestimentoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _investimentoIdMeta = const VerificationMeta(
    'investimentoId',
  );
  @override
  late final GeneratedColumn<int> investimentoId = GeneratedColumn<int>(
    'investimento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investimentos (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoMovimentoInvestimento, String>
  tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoMovimentoInvestimento>(
        $MovimentosInvestimentoTable.$convertertipo,
      );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<int> valor = GeneratedColumn<int>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> data =
      GeneratedColumn<int>(
        'data',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MovimentosInvestimentoTable.$converterdata);
  static const VerificationMeta _lancamentoIdMeta = const VerificationMeta(
    'lancamentoId',
  );
  @override
  late final GeneratedColumn<int> lancamentoId = GeneratedColumn<int>(
    'lancamento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    investimentoId,
    tipo,
    valor,
    data,
    lancamentoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimentos_investimento';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovimentoInvestimento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('investimento_id')) {
      context.handle(
        _investimentoIdMeta,
        investimentoId.isAcceptableOrUnknown(
          data['investimento_id']!,
          _investimentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investimentoIdMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('lancamento_id')) {
      context.handle(
        _lancamentoIdMeta,
        lancamentoId.isAcceptableOrUnknown(
          data['lancamento_id']!,
          _lancamentoIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovimentoInvestimento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimentoInvestimento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      investimentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}investimento_id'],
      )!,
      tipo: $MovimentosInvestimentoTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor'],
      )!,
      data: $MovimentosInvestimentoTable.$converterdata.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data'],
        )!,
      ),
      lancamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lancamento_id'],
      ),
    );
  }

  @override
  $MovimentosInvestimentoTable createAlias(String alias) {
    return $MovimentosInvestimentoTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoMovimentoInvestimento, String, String>
  $convertertipo = const EnumNameConverter<TipoMovimentoInvestimento>(
    TipoMovimentoInvestimento.values,
  );
  static TypeConverter<DateTime, int> $converterdata = const ConversorData();
}

class MovimentoInvestimento extends DataClass
    implements Insertable<MovimentoInvestimento> {
  final int id;
  final int investimentoId;
  final TipoMovimentoInvestimento tipo;
  final int valor;
  final DateTime data;
  final int? lancamentoId;
  const MovimentoInvestimento({
    required this.id,
    required this.investimentoId,
    required this.tipo,
    required this.valor,
    required this.data,
    this.lancamentoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['investimento_id'] = Variable<int>(investimentoId);
    {
      map['tipo'] = Variable<String>(
        $MovimentosInvestimentoTable.$convertertipo.toSql(tipo),
      );
    }
    map['valor'] = Variable<int>(valor);
    {
      map['data'] = Variable<int>(
        $MovimentosInvestimentoTable.$converterdata.toSql(data),
      );
    }
    if (!nullToAbsent || lancamentoId != null) {
      map['lancamento_id'] = Variable<int>(lancamentoId);
    }
    return map;
  }

  MovimentosInvestimentoCompanion toCompanion(bool nullToAbsent) {
    return MovimentosInvestimentoCompanion(
      id: Value(id),
      investimentoId: Value(investimentoId),
      tipo: Value(tipo),
      valor: Value(valor),
      data: Value(data),
      lancamentoId: lancamentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(lancamentoId),
    );
  }

  factory MovimentoInvestimento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimentoInvestimento(
      id: serializer.fromJson<int>(json['id']),
      investimentoId: serializer.fromJson<int>(json['investimentoId']),
      tipo: $MovimentosInvestimentoTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      valor: serializer.fromJson<int>(json['valor']),
      data: serializer.fromJson<DateTime>(json['data']),
      lancamentoId: serializer.fromJson<int?>(json['lancamentoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'investimentoId': serializer.toJson<int>(investimentoId),
      'tipo': serializer.toJson<String>(
        $MovimentosInvestimentoTable.$convertertipo.toJson(tipo),
      ),
      'valor': serializer.toJson<int>(valor),
      'data': serializer.toJson<DateTime>(data),
      'lancamentoId': serializer.toJson<int?>(lancamentoId),
    };
  }

  MovimentoInvestimento copyWith({
    int? id,
    int? investimentoId,
    TipoMovimentoInvestimento? tipo,
    int? valor,
    DateTime? data,
    Value<int?> lancamentoId = const Value.absent(),
  }) => MovimentoInvestimento(
    id: id ?? this.id,
    investimentoId: investimentoId ?? this.investimentoId,
    tipo: tipo ?? this.tipo,
    valor: valor ?? this.valor,
    data: data ?? this.data,
    lancamentoId: lancamentoId.present ? lancamentoId.value : this.lancamentoId,
  );
  MovimentoInvestimento copyWithCompanion(
    MovimentosInvestimentoCompanion data,
  ) {
    return MovimentoInvestimento(
      id: data.id.present ? data.id.value : this.id,
      investimentoId: data.investimentoId.present
          ? data.investimentoId.value
          : this.investimentoId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      valor: data.valor.present ? data.valor.value : this.valor,
      data: data.data.present ? data.data.value : this.data,
      lancamentoId: data.lancamentoId.present
          ? data.lancamentoId.value
          : this.lancamentoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimentoInvestimento(')
          ..write('id: $id, ')
          ..write('investimentoId: $investimentoId, ')
          ..write('tipo: $tipo, ')
          ..write('valor: $valor, ')
          ..write('data: $data, ')
          ..write('lancamentoId: $lancamentoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, investimentoId, tipo, valor, data, lancamentoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimentoInvestimento &&
          other.id == this.id &&
          other.investimentoId == this.investimentoId &&
          other.tipo == this.tipo &&
          other.valor == this.valor &&
          other.data == this.data &&
          other.lancamentoId == this.lancamentoId);
}

class MovimentosInvestimentoCompanion
    extends UpdateCompanion<MovimentoInvestimento> {
  final Value<int> id;
  final Value<int> investimentoId;
  final Value<TipoMovimentoInvestimento> tipo;
  final Value<int> valor;
  final Value<DateTime> data;
  final Value<int?> lancamentoId;
  const MovimentosInvestimentoCompanion({
    this.id = const Value.absent(),
    this.investimentoId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.valor = const Value.absent(),
    this.data = const Value.absent(),
    this.lancamentoId = const Value.absent(),
  });
  MovimentosInvestimentoCompanion.insert({
    this.id = const Value.absent(),
    required int investimentoId,
    required TipoMovimentoInvestimento tipo,
    required int valor,
    required DateTime data,
    this.lancamentoId = const Value.absent(),
  }) : investimentoId = Value(investimentoId),
       tipo = Value(tipo),
       valor = Value(valor),
       data = Value(data);
  static Insertable<MovimentoInvestimento> custom({
    Expression<int>? id,
    Expression<int>? investimentoId,
    Expression<String>? tipo,
    Expression<int>? valor,
    Expression<int>? data,
    Expression<int>? lancamentoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (investimentoId != null) 'investimento_id': investimentoId,
      if (tipo != null) 'tipo': tipo,
      if (valor != null) 'valor': valor,
      if (data != null) 'data': data,
      if (lancamentoId != null) 'lancamento_id': lancamentoId,
    });
  }

  MovimentosInvestimentoCompanion copyWith({
    Value<int>? id,
    Value<int>? investimentoId,
    Value<TipoMovimentoInvestimento>? tipo,
    Value<int>? valor,
    Value<DateTime>? data,
    Value<int?>? lancamentoId,
  }) {
    return MovimentosInvestimentoCompanion(
      id: id ?? this.id,
      investimentoId: investimentoId ?? this.investimentoId,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      lancamentoId: lancamentoId ?? this.lancamentoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (investimentoId.present) {
      map['investimento_id'] = Variable<int>(investimentoId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $MovimentosInvestimentoTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (valor.present) {
      map['valor'] = Variable<int>(valor.value);
    }
    if (data.present) {
      map['data'] = Variable<int>(
        $MovimentosInvestimentoTable.$converterdata.toSql(data.value),
      );
    }
    if (lancamentoId.present) {
      map['lancamento_id'] = Variable<int>(lancamentoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimentosInvestimentoCompanion(')
          ..write('id: $id, ')
          ..write('investimentoId: $investimentoId, ')
          ..write('tipo: $tipo, ')
          ..write('valor: $valor, ')
          ..write('data: $data, ')
          ..write('lancamentoId: $lancamentoId')
          ..write(')'))
        .toString();
  }
}

class $MetasTable extends Metas with TableInfo<$MetasTable, Meta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorAlvoMeta = const VerificationMeta(
    'valorAlvo',
  );
  @override
  late final GeneratedColumn<int> valorAlvo = GeneratedColumn<int>(
    'valor_alvo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> prazo =
      GeneratedColumn<int>(
        'prazo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MetasTable.$converterprazo);
  static const VerificationMeta _investimentoIdMeta = const VerificationMeta(
    'investimentoId',
  );
  @override
  late final GeneratedColumn<int> investimentoId = GeneratedColumn<int>(
    'investimento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investimentos (id)',
    ),
  );
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    valorAlvo,
    prazo,
    investimentoId,
    ativa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Meta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('valor_alvo')) {
      context.handle(
        _valorAlvoMeta,
        valorAlvo.isAcceptableOrUnknown(data['valor_alvo']!, _valorAlvoMeta),
      );
    } else if (isInserting) {
      context.missing(_valorAlvoMeta);
    }
    if (data.containsKey('investimento_id')) {
      context.handle(
        _investimentoIdMeta,
        investimentoId.isAcceptableOrUnknown(
          data['investimento_id']!,
          _investimentoIdMeta,
        ),
      );
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      valorAlvo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_alvo'],
      )!,
      prazo: $MetasTable.$converterprazo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}prazo'],
        )!,
      ),
      investimentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}investimento_id'],
      ),
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativa'],
      )!,
    );
  }

  @override
  $MetasTable createAlias(String alias) {
    return $MetasTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterprazo = const ConversorData();
}

class Meta extends DataClass implements Insertable<Meta> {
  final int id;
  final String nome;
  final int valorAlvo;
  final DateTime prazo;
  final int? investimentoId;
  final bool ativa;
  const Meta({
    required this.id,
    required this.nome,
    required this.valorAlvo,
    required this.prazo,
    this.investimentoId,
    required this.ativa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['valor_alvo'] = Variable<int>(valorAlvo);
    {
      map['prazo'] = Variable<int>($MetasTable.$converterprazo.toSql(prazo));
    }
    if (!nullToAbsent || investimentoId != null) {
      map['investimento_id'] = Variable<int>(investimentoId);
    }
    map['ativa'] = Variable<bool>(ativa);
    return map;
  }

  MetasCompanion toCompanion(bool nullToAbsent) {
    return MetasCompanion(
      id: Value(id),
      nome: Value(nome),
      valorAlvo: Value(valorAlvo),
      prazo: Value(prazo),
      investimentoId: investimentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(investimentoId),
      ativa: Value(ativa),
    );
  }

  factory Meta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meta(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      valorAlvo: serializer.fromJson<int>(json['valorAlvo']),
      prazo: serializer.fromJson<DateTime>(json['prazo']),
      investimentoId: serializer.fromJson<int?>(json['investimentoId']),
      ativa: serializer.fromJson<bool>(json['ativa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'valorAlvo': serializer.toJson<int>(valorAlvo),
      'prazo': serializer.toJson<DateTime>(prazo),
      'investimentoId': serializer.toJson<int?>(investimentoId),
      'ativa': serializer.toJson<bool>(ativa),
    };
  }

  Meta copyWith({
    int? id,
    String? nome,
    int? valorAlvo,
    DateTime? prazo,
    Value<int?> investimentoId = const Value.absent(),
    bool? ativa,
  }) => Meta(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    valorAlvo: valorAlvo ?? this.valorAlvo,
    prazo: prazo ?? this.prazo,
    investimentoId: investimentoId.present
        ? investimentoId.value
        : this.investimentoId,
    ativa: ativa ?? this.ativa,
  );
  Meta copyWithCompanion(MetasCompanion data) {
    return Meta(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      valorAlvo: data.valorAlvo.present ? data.valorAlvo.value : this.valorAlvo,
      prazo: data.prazo.present ? data.prazo.value : this.prazo,
      investimentoId: data.investimentoId.present
          ? data.investimentoId.value
          : this.investimentoId,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meta(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('valorAlvo: $valorAlvo, ')
          ..write('prazo: $prazo, ')
          ..write('investimentoId: $investimentoId, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, valorAlvo, prazo, investimentoId, ativa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meta &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.valorAlvo == this.valorAlvo &&
          other.prazo == this.prazo &&
          other.investimentoId == this.investimentoId &&
          other.ativa == this.ativa);
}

class MetasCompanion extends UpdateCompanion<Meta> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> valorAlvo;
  final Value<DateTime> prazo;
  final Value<int?> investimentoId;
  final Value<bool> ativa;
  const MetasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.valorAlvo = const Value.absent(),
    this.prazo = const Value.absent(),
    this.investimentoId = const Value.absent(),
    this.ativa = const Value.absent(),
  });
  MetasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int valorAlvo,
    required DateTime prazo,
    this.investimentoId = const Value.absent(),
    this.ativa = const Value.absent(),
  }) : nome = Value(nome),
       valorAlvo = Value(valorAlvo),
       prazo = Value(prazo);
  static Insertable<Meta> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? valorAlvo,
    Expression<int>? prazo,
    Expression<int>? investimentoId,
    Expression<bool>? ativa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (valorAlvo != null) 'valor_alvo': valorAlvo,
      if (prazo != null) 'prazo': prazo,
      if (investimentoId != null) 'investimento_id': investimentoId,
      if (ativa != null) 'ativa': ativa,
    });
  }

  MetasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int>? valorAlvo,
    Value<DateTime>? prazo,
    Value<int?>? investimentoId,
    Value<bool>? ativa,
  }) {
    return MetasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valorAlvo: valorAlvo ?? this.valorAlvo,
      prazo: prazo ?? this.prazo,
      investimentoId: investimentoId ?? this.investimentoId,
      ativa: ativa ?? this.ativa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (valorAlvo.present) {
      map['valor_alvo'] = Variable<int>(valorAlvo.value);
    }
    if (prazo.present) {
      map['prazo'] = Variable<int>(
        $MetasTable.$converterprazo.toSql(prazo.value),
      );
    }
    if (investimentoId.present) {
      map['investimento_id'] = Variable<int>(investimentoId.value);
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('valorAlvo: $valorAlvo, ')
          ..write('prazo: $prazo, ')
          ..write('investimentoId: $investimentoId, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }
}

class $OrcamentosTable extends Orcamentos
    with TableInfo<$OrcamentosTable, Orcamento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrcamentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _competenciaMeta = const VerificationMeta(
    'competencia',
  );
  @override
  late final GeneratedColumn<String> competencia = GeneratedColumn<String>(
    'competencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limiteMeta = const VerificationMeta('limite');
  @override
  late final GeneratedColumn<int> limite = GeneratedColumn<int>(
    'limite',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, categoriaId, competencia, limite];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orcamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Orcamento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('competencia')) {
      context.handle(
        _competenciaMeta,
        competencia.isAcceptableOrUnknown(
          data['competencia']!,
          _competenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_competenciaMeta);
    }
    if (data.containsKey('limite')) {
      context.handle(
        _limiteMeta,
        limite.isAcceptableOrUnknown(data['limite']!, _limiteMeta),
      );
    } else if (isInserting) {
      context.missing(_limiteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {categoriaId, competencia},
  ];
  @override
  Orcamento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Orcamento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      competencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competencia'],
      )!,
      limite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limite'],
      )!,
    );
  }

  @override
  $OrcamentosTable createAlias(String alias) {
    return $OrcamentosTable(attachedDatabase, alias);
  }
}

class Orcamento extends DataClass implements Insertable<Orcamento> {
  final int id;
  final int categoriaId;
  final String competencia;
  final int limite;
  const Orcamento({
    required this.id,
    required this.categoriaId,
    required this.competencia,
    required this.limite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['categoria_id'] = Variable<int>(categoriaId);
    map['competencia'] = Variable<String>(competencia);
    map['limite'] = Variable<int>(limite);
    return map;
  }

  OrcamentosCompanion toCompanion(bool nullToAbsent) {
    return OrcamentosCompanion(
      id: Value(id),
      categoriaId: Value(categoriaId),
      competencia: Value(competencia),
      limite: Value(limite),
    );
  }

  factory Orcamento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Orcamento(
      id: serializer.fromJson<int>(json['id']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      competencia: serializer.fromJson<String>(json['competencia']),
      limite: serializer.fromJson<int>(json['limite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'competencia': serializer.toJson<String>(competencia),
      'limite': serializer.toJson<int>(limite),
    };
  }

  Orcamento copyWith({
    int? id,
    int? categoriaId,
    String? competencia,
    int? limite,
  }) => Orcamento(
    id: id ?? this.id,
    categoriaId: categoriaId ?? this.categoriaId,
    competencia: competencia ?? this.competencia,
    limite: limite ?? this.limite,
  );
  Orcamento copyWithCompanion(OrcamentosCompanion data) {
    return Orcamento(
      id: data.id.present ? data.id.value : this.id,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      competencia: data.competencia.present
          ? data.competencia.value
          : this.competencia,
      limite: data.limite.present ? data.limite.value : this.limite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Orcamento(')
          ..write('id: $id, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('competencia: $competencia, ')
          ..write('limite: $limite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoriaId, competencia, limite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Orcamento &&
          other.id == this.id &&
          other.categoriaId == this.categoriaId &&
          other.competencia == this.competencia &&
          other.limite == this.limite);
}

class OrcamentosCompanion extends UpdateCompanion<Orcamento> {
  final Value<int> id;
  final Value<int> categoriaId;
  final Value<String> competencia;
  final Value<int> limite;
  const OrcamentosCompanion({
    this.id = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.competencia = const Value.absent(),
    this.limite = const Value.absent(),
  });
  OrcamentosCompanion.insert({
    this.id = const Value.absent(),
    required int categoriaId,
    required String competencia,
    required int limite,
  }) : categoriaId = Value(categoriaId),
       competencia = Value(competencia),
       limite = Value(limite);
  static Insertable<Orcamento> custom({
    Expression<int>? id,
    Expression<int>? categoriaId,
    Expression<String>? competencia,
    Expression<int>? limite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (competencia != null) 'competencia': competencia,
      if (limite != null) 'limite': limite,
    });
  }

  OrcamentosCompanion copyWith({
    Value<int>? id,
    Value<int>? categoriaId,
    Value<String>? competencia,
    Value<int>? limite,
  }) {
    return OrcamentosCompanion(
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      competencia: competencia ?? this.competencia,
      limite: limite ?? this.limite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (competencia.present) {
      map['competencia'] = Variable<String>(competencia.value);
    }
    if (limite.present) {
      map['limite'] = Variable<int>(limite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrcamentosCompanion(')
          ..write('id: $id, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('competencia: $competencia, ')
          ..write('limite: $limite')
          ..write(')'))
        .toString();
  }
}

class $RegrasCategorizacaoTable extends RegrasCategorizacao
    with TableInfo<$RegrasCategorizacaoTable, RegraCategorizacao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegrasCategorizacaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _padraoMeta = const VerificationMeta('padrao');
  @override
  late final GeneratedColumn<String> padrao = GeneratedColumn<String>(
    'padrao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _prioridadeMeta = const VerificationMeta(
    'prioridade',
  );
  @override
  late final GeneratedColumn<int> prioridade = GeneratedColumn<int>(
    'prioridade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, padrao, categoriaId, prioridade];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'regras_categorizacao';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegraCategorizacao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('padrao')) {
      context.handle(
        _padraoMeta,
        padrao.isAcceptableOrUnknown(data['padrao']!, _padraoMeta),
      );
    } else if (isInserting) {
      context.missing(_padraoMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('prioridade')) {
      context.handle(
        _prioridadeMeta,
        prioridade.isAcceptableOrUnknown(data['prioridade']!, _prioridadeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegraCategorizacao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegraCategorizacao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      padrao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}padrao'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      prioridade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prioridade'],
      )!,
    );
  }

  @override
  $RegrasCategorizacaoTable createAlias(String alias) {
    return $RegrasCategorizacaoTable(attachedDatabase, alias);
  }
}

class RegraCategorizacao extends DataClass
    implements Insertable<RegraCategorizacao> {
  final int id;

  /// Texto procurado na descrição (sem acento, sem diferenciar maiúsculas).
  final String padrao;
  final int categoriaId;
  final int prioridade;
  const RegraCategorizacao({
    required this.id,
    required this.padrao,
    required this.categoriaId,
    required this.prioridade,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['padrao'] = Variable<String>(padrao);
    map['categoria_id'] = Variable<int>(categoriaId);
    map['prioridade'] = Variable<int>(prioridade);
    return map;
  }

  RegrasCategorizacaoCompanion toCompanion(bool nullToAbsent) {
    return RegrasCategorizacaoCompanion(
      id: Value(id),
      padrao: Value(padrao),
      categoriaId: Value(categoriaId),
      prioridade: Value(prioridade),
    );
  }

  factory RegraCategorizacao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegraCategorizacao(
      id: serializer.fromJson<int>(json['id']),
      padrao: serializer.fromJson<String>(json['padrao']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      prioridade: serializer.fromJson<int>(json['prioridade']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'padrao': serializer.toJson<String>(padrao),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'prioridade': serializer.toJson<int>(prioridade),
    };
  }

  RegraCategorizacao copyWith({
    int? id,
    String? padrao,
    int? categoriaId,
    int? prioridade,
  }) => RegraCategorizacao(
    id: id ?? this.id,
    padrao: padrao ?? this.padrao,
    categoriaId: categoriaId ?? this.categoriaId,
    prioridade: prioridade ?? this.prioridade,
  );
  RegraCategorizacao copyWithCompanion(RegrasCategorizacaoCompanion data) {
    return RegraCategorizacao(
      id: data.id.present ? data.id.value : this.id,
      padrao: data.padrao.present ? data.padrao.value : this.padrao,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      prioridade: data.prioridade.present
          ? data.prioridade.value
          : this.prioridade,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegraCategorizacao(')
          ..write('id: $id, ')
          ..write('padrao: $padrao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('prioridade: $prioridade')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, padrao, categoriaId, prioridade);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegraCategorizacao &&
          other.id == this.id &&
          other.padrao == this.padrao &&
          other.categoriaId == this.categoriaId &&
          other.prioridade == this.prioridade);
}

class RegrasCategorizacaoCompanion extends UpdateCompanion<RegraCategorizacao> {
  final Value<int> id;
  final Value<String> padrao;
  final Value<int> categoriaId;
  final Value<int> prioridade;
  const RegrasCategorizacaoCompanion({
    this.id = const Value.absent(),
    this.padrao = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.prioridade = const Value.absent(),
  });
  RegrasCategorizacaoCompanion.insert({
    this.id = const Value.absent(),
    required String padrao,
    required int categoriaId,
    this.prioridade = const Value.absent(),
  }) : padrao = Value(padrao),
       categoriaId = Value(categoriaId);
  static Insertable<RegraCategorizacao> custom({
    Expression<int>? id,
    Expression<String>? padrao,
    Expression<int>? categoriaId,
    Expression<int>? prioridade,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (padrao != null) 'padrao': padrao,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (prioridade != null) 'prioridade': prioridade,
    });
  }

  RegrasCategorizacaoCompanion copyWith({
    Value<int>? id,
    Value<String>? padrao,
    Value<int>? categoriaId,
    Value<int>? prioridade,
  }) {
    return RegrasCategorizacaoCompanion(
      id: id ?? this.id,
      padrao: padrao ?? this.padrao,
      categoriaId: categoriaId ?? this.categoriaId,
      prioridade: prioridade ?? this.prioridade,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (padrao.present) {
      map['padrao'] = Variable<String>(padrao.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (prioridade.present) {
      map['prioridade'] = Variable<int>(prioridade.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegrasCategorizacaoCompanion(')
          ..write('id: $id, ')
          ..write('padrao: $padrao, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('prioridade: $prioridade')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracoesTable extends Configuracoes
    with TableInfo<$ConfiguracoesTable, Configuracao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Configuracao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  Configuracao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Configuracao(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $ConfiguracoesTable createAlias(String alias) {
    return $ConfiguracoesTable(attachedDatabase, alias);
  }
}

class Configuracao extends DataClass implements Insertable<Configuracao> {
  final String chave;
  final String valor;
  const Configuracao({required this.chave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  ConfiguracoesCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracoesCompanion(chave: Value(chave), valor: Value(valor));
  }

  factory Configuracao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Configuracao(
      chave: serializer.fromJson<String>(json['chave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  Configuracao copyWith({String? chave, String? valor}) =>
      Configuracao(chave: chave ?? this.chave, valor: valor ?? this.valor);
  Configuracao copyWithCompanion(ConfiguracoesCompanion data) {
    return Configuracao(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Configuracao(')
          ..write('chave: $chave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Configuracao &&
          other.chave == this.chave &&
          other.valor == this.valor);
}

class ConfiguracoesCompanion extends UpdateCompanion<Configuracao> {
  final Value<String> chave;
  final Value<String> valor;
  final Value<int> rowid;
  const ConfiguracoesCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfiguracoesCompanion.insert({
    required String chave,
    required String valor,
    this.rowid = const Value.absent(),
  }) : chave = Value(chave),
       valor = Value(valor);
  static Insertable<Configuracao> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfiguracoesCompanion copyWith({
    Value<String>? chave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return ConfiguracoesCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracoesCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MapeamentosCsvTable extends MapeamentosCsv
    with TableInfo<$MapeamentosCsvTable, MapeamentoCsvSalvo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MapeamentosCsvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _separadorMeta = const VerificationMeta(
    'separador',
  );
  @override
  late final GeneratedColumn<String> separador = GeneratedColumn<String>(
    'separador',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(';'),
  );
  static const VerificationMeta _temCabecalhoMeta = const VerificationMeta(
    'temCabecalho',
  );
  @override
  late final GeneratedColumn<bool> temCabecalho = GeneratedColumn<bool>(
    'tem_cabecalho',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tem_cabecalho" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _colunaDataMeta = const VerificationMeta(
    'colunaData',
  );
  @override
  late final GeneratedColumn<int> colunaData = GeneratedColumn<int>(
    'coluna_data',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colunaDescricaoMeta = const VerificationMeta(
    'colunaDescricao',
  );
  @override
  late final GeneratedColumn<int> colunaDescricao = GeneratedColumn<int>(
    'coluna_descricao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colunaValorMeta = const VerificationMeta(
    'colunaValor',
  );
  @override
  late final GeneratedColumn<int> colunaValor = GeneratedColumn<int>(
    'coluna_valor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colunaTipoMeta = const VerificationMeta(
    'colunaTipo',
  );
  @override
  late final GeneratedColumn<int> colunaTipo = GeneratedColumn<int>(
    'coluna_tipo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatoDataMeta = const VerificationMeta(
    'formatoData',
  );
  @override
  late final GeneratedColumn<String> formatoData = GeneratedColumn<String>(
    'formato_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dd/MM/yyyy'),
  );
  static const VerificationMeta _positivoEhGastoMeta = const VerificationMeta(
    'positivoEhGasto',
  );
  @override
  late final GeneratedColumn<bool> positivoEhGasto = GeneratedColumn<bool>(
    'positivo_eh_gasto',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("positivo_eh_gasto" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    separador,
    temCabecalho,
    colunaData,
    colunaDescricao,
    colunaValor,
    colunaTipo,
    formatoData,
    positivoEhGasto,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mapeamentos_csv';
  @override
  VerificationContext validateIntegrity(
    Insertable<MapeamentoCsvSalvo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('separador')) {
      context.handle(
        _separadorMeta,
        separador.isAcceptableOrUnknown(data['separador']!, _separadorMeta),
      );
    }
    if (data.containsKey('tem_cabecalho')) {
      context.handle(
        _temCabecalhoMeta,
        temCabecalho.isAcceptableOrUnknown(
          data['tem_cabecalho']!,
          _temCabecalhoMeta,
        ),
      );
    }
    if (data.containsKey('coluna_data')) {
      context.handle(
        _colunaDataMeta,
        colunaData.isAcceptableOrUnknown(data['coluna_data']!, _colunaDataMeta),
      );
    } else if (isInserting) {
      context.missing(_colunaDataMeta);
    }
    if (data.containsKey('coluna_descricao')) {
      context.handle(
        _colunaDescricaoMeta,
        colunaDescricao.isAcceptableOrUnknown(
          data['coluna_descricao']!,
          _colunaDescricaoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_colunaDescricaoMeta);
    }
    if (data.containsKey('coluna_valor')) {
      context.handle(
        _colunaValorMeta,
        colunaValor.isAcceptableOrUnknown(
          data['coluna_valor']!,
          _colunaValorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_colunaValorMeta);
    }
    if (data.containsKey('coluna_tipo')) {
      context.handle(
        _colunaTipoMeta,
        colunaTipo.isAcceptableOrUnknown(data['coluna_tipo']!, _colunaTipoMeta),
      );
    }
    if (data.containsKey('formato_data')) {
      context.handle(
        _formatoDataMeta,
        formatoData.isAcceptableOrUnknown(
          data['formato_data']!,
          _formatoDataMeta,
        ),
      );
    }
    if (data.containsKey('positivo_eh_gasto')) {
      context.handle(
        _positivoEhGastoMeta,
        positivoEhGasto.isAcceptableOrUnknown(
          data['positivo_eh_gasto']!,
          _positivoEhGastoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MapeamentoCsvSalvo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MapeamentoCsvSalvo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      separador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}separador'],
      )!,
      temCabecalho: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tem_cabecalho'],
      )!,
      colunaData: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coluna_data'],
      )!,
      colunaDescricao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coluna_descricao'],
      )!,
      colunaValor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coluna_valor'],
      )!,
      colunaTipo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coluna_tipo'],
      ),
      formatoData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formato_data'],
      )!,
      positivoEhGasto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}positivo_eh_gasto'],
      )!,
    );
  }

  @override
  $MapeamentosCsvTable createAlias(String alias) {
    return $MapeamentosCsvTable(attachedDatabase, alias);
  }
}

class MapeamentoCsvSalvo extends DataClass
    implements Insertable<MapeamentoCsvSalvo> {
  final int id;
  final String nome;
  final String separador;
  final bool temCabecalho;
  final int colunaData;
  final int colunaDescricao;
  final int colunaValor;
  final int? colunaTipo;
  final String formatoData;

  /// Faturas de cartão costumam trazer compras como valor positivo.
  final bool positivoEhGasto;
  const MapeamentoCsvSalvo({
    required this.id,
    required this.nome,
    required this.separador,
    required this.temCabecalho,
    required this.colunaData,
    required this.colunaDescricao,
    required this.colunaValor,
    this.colunaTipo,
    required this.formatoData,
    required this.positivoEhGasto,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['separador'] = Variable<String>(separador);
    map['tem_cabecalho'] = Variable<bool>(temCabecalho);
    map['coluna_data'] = Variable<int>(colunaData);
    map['coluna_descricao'] = Variable<int>(colunaDescricao);
    map['coluna_valor'] = Variable<int>(colunaValor);
    if (!nullToAbsent || colunaTipo != null) {
      map['coluna_tipo'] = Variable<int>(colunaTipo);
    }
    map['formato_data'] = Variable<String>(formatoData);
    map['positivo_eh_gasto'] = Variable<bool>(positivoEhGasto);
    return map;
  }

  MapeamentosCsvCompanion toCompanion(bool nullToAbsent) {
    return MapeamentosCsvCompanion(
      id: Value(id),
      nome: Value(nome),
      separador: Value(separador),
      temCabecalho: Value(temCabecalho),
      colunaData: Value(colunaData),
      colunaDescricao: Value(colunaDescricao),
      colunaValor: Value(colunaValor),
      colunaTipo: colunaTipo == null && nullToAbsent
          ? const Value.absent()
          : Value(colunaTipo),
      formatoData: Value(formatoData),
      positivoEhGasto: Value(positivoEhGasto),
    );
  }

  factory MapeamentoCsvSalvo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MapeamentoCsvSalvo(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      separador: serializer.fromJson<String>(json['separador']),
      temCabecalho: serializer.fromJson<bool>(json['temCabecalho']),
      colunaData: serializer.fromJson<int>(json['colunaData']),
      colunaDescricao: serializer.fromJson<int>(json['colunaDescricao']),
      colunaValor: serializer.fromJson<int>(json['colunaValor']),
      colunaTipo: serializer.fromJson<int?>(json['colunaTipo']),
      formatoData: serializer.fromJson<String>(json['formatoData']),
      positivoEhGasto: serializer.fromJson<bool>(json['positivoEhGasto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'separador': serializer.toJson<String>(separador),
      'temCabecalho': serializer.toJson<bool>(temCabecalho),
      'colunaData': serializer.toJson<int>(colunaData),
      'colunaDescricao': serializer.toJson<int>(colunaDescricao),
      'colunaValor': serializer.toJson<int>(colunaValor),
      'colunaTipo': serializer.toJson<int?>(colunaTipo),
      'formatoData': serializer.toJson<String>(formatoData),
      'positivoEhGasto': serializer.toJson<bool>(positivoEhGasto),
    };
  }

  MapeamentoCsvSalvo copyWith({
    int? id,
    String? nome,
    String? separador,
    bool? temCabecalho,
    int? colunaData,
    int? colunaDescricao,
    int? colunaValor,
    Value<int?> colunaTipo = const Value.absent(),
    String? formatoData,
    bool? positivoEhGasto,
  }) => MapeamentoCsvSalvo(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    separador: separador ?? this.separador,
    temCabecalho: temCabecalho ?? this.temCabecalho,
    colunaData: colunaData ?? this.colunaData,
    colunaDescricao: colunaDescricao ?? this.colunaDescricao,
    colunaValor: colunaValor ?? this.colunaValor,
    colunaTipo: colunaTipo.present ? colunaTipo.value : this.colunaTipo,
    formatoData: formatoData ?? this.formatoData,
    positivoEhGasto: positivoEhGasto ?? this.positivoEhGasto,
  );
  MapeamentoCsvSalvo copyWithCompanion(MapeamentosCsvCompanion data) {
    return MapeamentoCsvSalvo(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      separador: data.separador.present ? data.separador.value : this.separador,
      temCabecalho: data.temCabecalho.present
          ? data.temCabecalho.value
          : this.temCabecalho,
      colunaData: data.colunaData.present
          ? data.colunaData.value
          : this.colunaData,
      colunaDescricao: data.colunaDescricao.present
          ? data.colunaDescricao.value
          : this.colunaDescricao,
      colunaValor: data.colunaValor.present
          ? data.colunaValor.value
          : this.colunaValor,
      colunaTipo: data.colunaTipo.present
          ? data.colunaTipo.value
          : this.colunaTipo,
      formatoData: data.formatoData.present
          ? data.formatoData.value
          : this.formatoData,
      positivoEhGasto: data.positivoEhGasto.present
          ? data.positivoEhGasto.value
          : this.positivoEhGasto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MapeamentoCsvSalvo(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('separador: $separador, ')
          ..write('temCabecalho: $temCabecalho, ')
          ..write('colunaData: $colunaData, ')
          ..write('colunaDescricao: $colunaDescricao, ')
          ..write('colunaValor: $colunaValor, ')
          ..write('colunaTipo: $colunaTipo, ')
          ..write('formatoData: $formatoData, ')
          ..write('positivoEhGasto: $positivoEhGasto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    separador,
    temCabecalho,
    colunaData,
    colunaDescricao,
    colunaValor,
    colunaTipo,
    formatoData,
    positivoEhGasto,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapeamentoCsvSalvo &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.separador == this.separador &&
          other.temCabecalho == this.temCabecalho &&
          other.colunaData == this.colunaData &&
          other.colunaDescricao == this.colunaDescricao &&
          other.colunaValor == this.colunaValor &&
          other.colunaTipo == this.colunaTipo &&
          other.formatoData == this.formatoData &&
          other.positivoEhGasto == this.positivoEhGasto);
}

class MapeamentosCsvCompanion extends UpdateCompanion<MapeamentoCsvSalvo> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> separador;
  final Value<bool> temCabecalho;
  final Value<int> colunaData;
  final Value<int> colunaDescricao;
  final Value<int> colunaValor;
  final Value<int?> colunaTipo;
  final Value<String> formatoData;
  final Value<bool> positivoEhGasto;
  const MapeamentosCsvCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.separador = const Value.absent(),
    this.temCabecalho = const Value.absent(),
    this.colunaData = const Value.absent(),
    this.colunaDescricao = const Value.absent(),
    this.colunaValor = const Value.absent(),
    this.colunaTipo = const Value.absent(),
    this.formatoData = const Value.absent(),
    this.positivoEhGasto = const Value.absent(),
  });
  MapeamentosCsvCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.separador = const Value.absent(),
    this.temCabecalho = const Value.absent(),
    required int colunaData,
    required int colunaDescricao,
    required int colunaValor,
    this.colunaTipo = const Value.absent(),
    this.formatoData = const Value.absent(),
    this.positivoEhGasto = const Value.absent(),
  }) : nome = Value(nome),
       colunaData = Value(colunaData),
       colunaDescricao = Value(colunaDescricao),
       colunaValor = Value(colunaValor);
  static Insertable<MapeamentoCsvSalvo> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? separador,
    Expression<bool>? temCabecalho,
    Expression<int>? colunaData,
    Expression<int>? colunaDescricao,
    Expression<int>? colunaValor,
    Expression<int>? colunaTipo,
    Expression<String>? formatoData,
    Expression<bool>? positivoEhGasto,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (separador != null) 'separador': separador,
      if (temCabecalho != null) 'tem_cabecalho': temCabecalho,
      if (colunaData != null) 'coluna_data': colunaData,
      if (colunaDescricao != null) 'coluna_descricao': colunaDescricao,
      if (colunaValor != null) 'coluna_valor': colunaValor,
      if (colunaTipo != null) 'coluna_tipo': colunaTipo,
      if (formatoData != null) 'formato_data': formatoData,
      if (positivoEhGasto != null) 'positivo_eh_gasto': positivoEhGasto,
    });
  }

  MapeamentosCsvCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String>? separador,
    Value<bool>? temCabecalho,
    Value<int>? colunaData,
    Value<int>? colunaDescricao,
    Value<int>? colunaValor,
    Value<int?>? colunaTipo,
    Value<String>? formatoData,
    Value<bool>? positivoEhGasto,
  }) {
    return MapeamentosCsvCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      separador: separador ?? this.separador,
      temCabecalho: temCabecalho ?? this.temCabecalho,
      colunaData: colunaData ?? this.colunaData,
      colunaDescricao: colunaDescricao ?? this.colunaDescricao,
      colunaValor: colunaValor ?? this.colunaValor,
      colunaTipo: colunaTipo ?? this.colunaTipo,
      formatoData: formatoData ?? this.formatoData,
      positivoEhGasto: positivoEhGasto ?? this.positivoEhGasto,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (separador.present) {
      map['separador'] = Variable<String>(separador.value);
    }
    if (temCabecalho.present) {
      map['tem_cabecalho'] = Variable<bool>(temCabecalho.value);
    }
    if (colunaData.present) {
      map['coluna_data'] = Variable<int>(colunaData.value);
    }
    if (colunaDescricao.present) {
      map['coluna_descricao'] = Variable<int>(colunaDescricao.value);
    }
    if (colunaValor.present) {
      map['coluna_valor'] = Variable<int>(colunaValor.value);
    }
    if (colunaTipo.present) {
      map['coluna_tipo'] = Variable<int>(colunaTipo.value);
    }
    if (formatoData.present) {
      map['formato_data'] = Variable<String>(formatoData.value);
    }
    if (positivoEhGasto.present) {
      map['positivo_eh_gasto'] = Variable<bool>(positivoEhGasto.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MapeamentosCsvCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('separador: $separador, ')
          ..write('temCabecalho: $temCabecalho, ')
          ..write('colunaData: $colunaData, ')
          ..write('colunaDescricao: $colunaDescricao, ')
          ..write('colunaValor: $colunaValor, ')
          ..write('colunaTipo: $colunaTipo, ')
          ..write('formatoData: $formatoData, ')
          ..write('positivoEhGasto: $positivoEhGasto')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContasTable contas = $ContasTable(this);
  late final $CartoesTable cartoes = $CartoesTable(this);
  late final $FaturasTable faturas = $FaturasTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $ComprasParceladasTable comprasParceladas =
      $ComprasParceladasTable(this);
  late final $InvestimentosTable investimentos = $InvestimentosTable(this);
  late final $LancamentosTable lancamentos = $LancamentosTable(this);
  late final $CompromissosTable compromissos = $CompromissosTable(this);
  late final $OcorrenciasCompromissoTable ocorrenciasCompromisso =
      $OcorrenciasCompromissoTable(this);
  late final $ReceitasRecorrentesTable receitasRecorrentes =
      $ReceitasRecorrentesTable(this);
  late final $MovimentosInvestimentoTable movimentosInvestimento =
      $MovimentosInvestimentoTable(this);
  late final $MetasTable metas = $MetasTable(this);
  late final $OrcamentosTable orcamentos = $OrcamentosTable(this);
  late final $RegrasCategorizacaoTable regrasCategorizacao =
      $RegrasCategorizacaoTable(this);
  late final $ConfiguracoesTable configuracoes = $ConfiguracoesTable(this);
  late final $MapeamentosCsvTable mapeamentosCsv = $MapeamentosCsvTable(this);
  late final Index idxLancamentosData = Index(
    'idx_lancamentos_data',
    'CREATE INDEX idx_lancamentos_data ON lancamentos (data)',
  );
  late final Index idxLancamentosConta = Index(
    'idx_lancamentos_conta',
    'CREATE INDEX idx_lancamentos_conta ON lancamentos (conta_id)',
  );
  late final Index idxLancamentosFatura = Index(
    'idx_lancamentos_fatura',
    'CREATE INDEX idx_lancamentos_fatura ON lancamentos (fatura_id)',
  );
  late final Index idxLancamentosChave = Index(
    'idx_lancamentos_chave',
    'CREATE INDEX idx_lancamentos_chave ON lancamentos (chave_importacao)',
  );
  late final ContasDao contasDao = ContasDao(this as AppDatabase);
  late final CartoesDao cartoesDao = CartoesDao(this as AppDatabase);
  late final CategoriasDao categoriasDao = CategoriasDao(this as AppDatabase);
  late final LancamentosDao lancamentosDao = LancamentosDao(
    this as AppDatabase,
  );
  late final CompromissosDao compromissosDao = CompromissosDao(
    this as AppDatabase,
  );
  late final InvestimentosDao investimentosDao = InvestimentosDao(
    this as AppDatabase,
  );
  late final ConfiguracoesDao configuracoesDao = ConfiguracoesDao(
    this as AppDatabase,
  );
  late final MapeamentosDao mapeamentosDao = MapeamentosDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contas,
    cartoes,
    faturas,
    categorias,
    comprasParceladas,
    investimentos,
    lancamentos,
    compromissos,
    ocorrenciasCompromisso,
    receitasRecorrentes,
    movimentosInvestimento,
    metas,
    orcamentos,
    regrasCategorizacao,
    configuracoes,
    mapeamentosCsv,
    idxLancamentosData,
    idxLancamentosConta,
    idxLancamentosFatura,
    idxLancamentosChave,
  ];
}

typedef $$ContasTableCreateCompanionBuilder = ContasCompanion Function({
  Value<int> id,
  required String nome,
  required TipoConta tipo,
  Value<int> saldoInicial,
  required DateTime dataSaldoInicial,
  Value<bool> considerarNoCreditoSeguro,
  Value<bool> ativa,
});
typedef $$ContasTableUpdateCompanionBuilder = ContasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<TipoConta> tipo,
  Value<int> saldoInicial,
  Value<DateTime> dataSaldoInicial,
  Value<bool> considerarNoCreditoSeguro,
  Value<bool> ativa,
});

final class $$ContasTableReferences
    extends BaseReferences<_$AppDatabase, $ContasTable, Conta> {
  $$ContasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CartoesTable, List<Cartao>> _cartoesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cartoes,
    aliasName: 'contas__id__cartoes__conta_pagamento_id',
  );

  $$CartoesTableProcessedTableManager get cartoesRefs {
    final manager = $$CartoesTableTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.contaPagamentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cartoesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LancamentosTable, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'contas__id__lancamentos__conta_id',
  );

  $$LancamentosTableProcessedTableManager get lancamentosRefs {
    final manager = $$LancamentosTableTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.contaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LancamentosTable, List<Lancamento>>
  _lancamentosDestinoTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'contas__id__lancamentos__conta_destino_id',
  );

  $$LancamentosTableProcessedTableManager get lancamentosDestino {
    final manager = $$LancamentosTableTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.contaDestinoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosDestinoTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompromissosTable, List<Compromisso>>
  _compromissosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.compromissos,
    aliasName: 'contas__id__compromissos__conta_id',
  );

  $$CompromissosTableProcessedTableManager get compromissosRefs {
    final manager = $$CompromissosTableTableManager(
      $_db,
      $_db.compromissos,
    ).filter((f) => f.contaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_compromissosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReceitasRecorrentesTable, List<ReceitaRecorrente>>
  _receitasRecorrentesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.receitasRecorrentes,
        aliasName: 'contas__id__receitas_recorrentes__conta_id',
      );

  $$ReceitasRecorrentesTableProcessedTableManager get receitasRecorrentesRefs {
    final manager = $$ReceitasRecorrentesTableTableManager(
      $_db,
      $_db.receitasRecorrentes,
    ).filter((f) => f.contaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _receitasRecorrentesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContasTableFilterComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoConta, TipoConta, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int>
  get dataSaldoInicial => $composableBuilder(
    column: $table.dataSaldoInicial,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get considerarNoCreditoSeguro => $composableBuilder(
    column: $table.considerarNoCreditoSeguro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cartoesRefs(
    Expression<bool> Function($$CartoesTableFilterComposer f) f,
  ) {
    final $$CartoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.contaPagamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($$LancamentosTableFilterComposer f) f,
  ) {
    final $$LancamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lancamentosDestino(
    Expression<bool> Function($$LancamentosTableFilterComposer f) f,
  ) {
    final $$LancamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.contaDestinoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> compromissosRefs(
    Expression<bool> Function($$CompromissosTableFilterComposer f) f,
  ) {
    final $$CompromissosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableFilterComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> receitasRecorrentesRefs(
    Expression<bool> Function($$ReceitasRecorrentesTableFilterComposer f) f,
  ) {
    final $$ReceitasRecorrentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receitasRecorrentes,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitasRecorrentesTableFilterComposer(
            $db: $db,
            $table: $db.receitasRecorrentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContasTableOrderingComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataSaldoInicial => $composableBuilder(
    column: $table.dataSaldoInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get considerarNoCreditoSeguro => $composableBuilder(
    column: $table.considerarNoCreditoSeguro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoConta, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get dataSaldoInicial =>
      $composableBuilder(
        column: $table.dataSaldoInicial,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get considerarNoCreditoSeguro => $composableBuilder(
    column: $table.considerarNoCreditoSeguro,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  Expression<T> cartoesRefs<T extends Object>(
    Expression<T> Function($$CartoesTableAnnotationComposer a) f,
  ) {
    final $$CartoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.contaPagamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($$LancamentosTableAnnotationComposer a) f,
  ) {
    final $$LancamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lancamentosDestino<T extends Object>(
    Expression<T> Function($$LancamentosTableAnnotationComposer a) f,
  ) {
    final $$LancamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.contaDestinoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> compromissosRefs<T extends Object>(
    Expression<T> Function($$CompromissosTableAnnotationComposer a) f,
  ) {
    final $$CompromissosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableAnnotationComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> receitasRecorrentesRefs<T extends Object>(
    Expression<T> Function($$ReceitasRecorrentesTableAnnotationComposer a) f,
  ) {
    final $$ReceitasRecorrentesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.receitasRecorrentes,
          getReferencedColumn: (t) => t.contaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReceitasRecorrentesTableAnnotationComposer(
                $db: $db,
                $table: $db.receitasRecorrentes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContasTable,
          Conta,
          $$ContasTableFilterComposer,
          $$ContasTableOrderingComposer,
          $$ContasTableAnnotationComposer,
          $$ContasTableCreateCompanionBuilder,
          $$ContasTableUpdateCompanionBuilder,
          (Conta, $$ContasTableReferences),
          Conta,
          PrefetchHooks Function({
            bool cartoesRefs,
            bool lancamentosRefs,
            bool lancamentosDestino,
            bool compromissosRefs,
            bool receitasRecorrentesRefs,
          })
        > {
  $$ContasTableTableManager(_$AppDatabase db, $ContasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<TipoConta> tipo = const Value.absent(),
                Value<int> saldoInicial = const Value.absent(),
                Value<DateTime> dataSaldoInicial = const Value.absent(),
                Value<bool> considerarNoCreditoSeguro = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => ContasCompanion(
                id: id,
                nome: nome,
                tipo: tipo,
                saldoInicial: saldoInicial,
                dataSaldoInicial: dataSaldoInicial,
                considerarNoCreditoSeguro: considerarNoCreditoSeguro,
                ativa: ativa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required TipoConta tipo,
                Value<int> saldoInicial = const Value.absent(),
                required DateTime dataSaldoInicial,
                Value<bool> considerarNoCreditoSeguro = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => ContasCompanion.insert(
                id: id,
                nome: nome,
                tipo: tipo,
                saldoInicial: saldoInicial,
                dataSaldoInicial: dataSaldoInicial,
                considerarNoCreditoSeguro: considerarNoCreditoSeguro,
                ativa: ativa,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContasTable, Conta>(table),
                  $$ContasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cartoesRefs = false,
                lancamentosRefs = false,
                lancamentosDestino = false,
                compromissosRefs = false,
                receitasRecorrentesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cartoesRefs) db.cartoes,
                    if (lancamentosRefs) db.lancamentos,
                    if (lancamentosDestino) db.lancamentos,
                    if (compromissosRefs) db.compromissos,
                    if (receitasRecorrentesRefs) db.receitasRecorrentes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cartoesRefs)
                        await $_getPrefetchedDataByColumns<
                          Conta,
                          $ContasTable,
                          Cartao,
                          $CartoesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContasTableReferences
                              ._cartoesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContasTableReferences(
                                db,
                                table,
                                p0,
                              ).cartoesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'conta_pagamento_id',
                          typedResults: items,
                        ),
                      if (lancamentosRefs)
                        await $_getPrefetchedDataByColumns<
                          Conta,
                          $ContasTable,
                          Lancamento,
                          $LancamentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContasTableReferences
                              ._lancamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContasTableReferences(
                                db,
                                table,
                                p0,
                              ).lancamentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'conta_id',
                          typedResults: items,
                        ),
                      if (lancamentosDestino)
                        await $_getPrefetchedDataByColumns<
                          Conta,
                          $ContasTable,
                          Lancamento,
                          $LancamentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContasTableReferences
                              ._lancamentosDestinoTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContasTableReferences(
                                db,
                                table,
                                p0,
                              ).lancamentosDestino,
                          currentColumn: 'id',
                          referencedColumn: 'conta_destino_id',
                          typedResults: items,
                        ),
                      if (compromissosRefs)
                        await $_getPrefetchedDataByColumns<
                          Conta,
                          $ContasTable,
                          Compromisso,
                          $CompromissosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContasTableReferences
                              ._compromissosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContasTableReferences(
                                db,
                                table,
                                p0,
                              ).compromissosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'conta_id',
                          typedResults: items,
                        ),
                      if (receitasRecorrentesRefs)
                        await $_getPrefetchedDataByColumns<
                          Conta,
                          $ContasTable,
                          ReceitaRecorrente,
                          $ReceitasRecorrentesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContasTableReferences
                              ._receitasRecorrentesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContasTableReferences(
                                db,
                                table,
                                p0,
                              ).receitasRecorrentesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'conta_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ContasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContasTable,
      Conta,
      $$ContasTableFilterComposer,
      $$ContasTableOrderingComposer,
      $$ContasTableAnnotationComposer,
      $$ContasTableCreateCompanionBuilder,
      $$ContasTableUpdateCompanionBuilder,
      (Conta, $$ContasTableReferences),
      Conta,
      PrefetchHooks Function({
        bool cartoesRefs,
        bool lancamentosRefs,
        bool lancamentosDestino,
        bool compromissosRefs,
        bool receitasRecorrentesRefs,
      })
    >;
typedef $$CartoesTableCreateCompanionBuilder = CartoesCompanion Function({
  Value<int> id,
  required String nome,
  Value<int> limite,
  required int diaFechamento,
  required int diaVencimento,
  Value<int?> contaPagamentoId,
  Value<int> cor,
  Value<bool> ativo,
});
typedef $$CartoesTableUpdateCompanionBuilder = CartoesCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> limite,
  Value<int> diaFechamento,
  Value<int> diaVencimento,
  Value<int?> contaPagamentoId,
  Value<int> cor,
  Value<bool> ativo,
});

final class $$CartoesTableReferences
    extends BaseReferences<_$AppDatabase, $CartoesTable, Cartao> {
  $$CartoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContasTable _contaPagamentoIdTable(_$AppDatabase db) =>
      db.contas.createAlias('cartoes__conta_pagamento_id__contas__id');

  $$ContasTableProcessedTableManager? get contaPagamentoId {
    final $_column = $_itemColumn<int>('conta_pagamento_id');
    if ($_column == null) return null;
    final manager = $$ContasTableTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaPagamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FaturasTable, List<Fatura>> _faturasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.faturas,
    aliasName: 'cartoes__id__faturas__cartao_id',
  );

  $$FaturasTableProcessedTableManager get faturasRefs {
    final manager = $$FaturasTableTableManager(
      $_db,
      $_db.faturas,
    ).filter((f) => f.cartaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_faturasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComprasParceladasTable, List<CompraParcelada>>
  _comprasParceladasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.comprasParceladas,
        aliasName: 'cartoes__id__compras_parceladas__cartao_id',
      );

  $$ComprasParceladasTableProcessedTableManager get comprasParceladasRefs {
    final manager = $$ComprasParceladasTableTableManager(
      $_db,
      $_db.comprasParceladas,
    ).filter((f) => f.cartaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _comprasParceladasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LancamentosTable, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'cartoes__id__lancamentos__cartao_id',
  );

  $$LancamentosTableProcessedTableManager get lancamentosRefs {
    final manager = $$LancamentosTableTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.cartaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompromissosTable, List<Compromisso>>
  _compromissosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.compromissos,
    aliasName: 'cartoes__id__compromissos__cartao_id',
  );

  $$CompromissosTableProcessedTableManager get compromissosRefs {
    final manager = $$CompromissosTableTableManager(
      $_db,
      $_db.compromissos,
    ).filter((f) => f.cartaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_compromissosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CartoesTableFilterComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limite => $composableBuilder(
    column: $table.limite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  $$ContasTableFilterComposer get contaPagamentoId {
    final $$ContasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> faturasRefs(
    Expression<bool> Function($$FaturasTableFilterComposer f) f,
  ) {
    final $$FaturasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasTableFilterComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> comprasParceladasRefs(
    Expression<bool> Function($$ComprasParceladasTableFilterComposer f) f,
  ) {
    final $$ComprasParceladasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comprasParceladas,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasParceladasTableFilterComposer(
            $db: $db,
            $table: $db.comprasParceladas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($$LancamentosTableFilterComposer f) f,
  ) {
    final $$LancamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> compromissosRefs(
    Expression<bool> Function($$CompromissosTableFilterComposer f) f,
  ) {
    final $$CompromissosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableFilterComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CartoesTableOrderingComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limite => $composableBuilder(
    column: $table.limite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContasTableOrderingComposer get contaPagamentoId {
    final $$ContasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CartoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get limite =>
      $composableBuilder(column: $table.limite, builder: (column) => column);

  GeneratedColumn<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cor =>
      $composableBuilder(column: $table.cor, builder: (column) => column);

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  $$ContasTableAnnotationComposer get contaPagamentoId {
    final $$ContasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> faturasRefs<T extends Object>(
    Expression<T> Function($$FaturasTableAnnotationComposer a) f,
  ) {
    final $$FaturasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasTableAnnotationComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> comprasParceladasRefs<T extends Object>(
    Expression<T> Function($$ComprasParceladasTableAnnotationComposer a) f,
  ) {
    final $$ComprasParceladasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.comprasParceladas,
          getReferencedColumn: (t) => t.cartaoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ComprasParceladasTableAnnotationComposer(
                $db: $db,
                $table: $db.comprasParceladas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($$LancamentosTableAnnotationComposer a) f,
  ) {
    final $$LancamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> compromissosRefs<T extends Object>(
    Expression<T> Function($$CompromissosTableAnnotationComposer a) f,
  ) {
    final $$CompromissosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableAnnotationComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CartoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartoesTable,
          Cartao,
          $$CartoesTableFilterComposer,
          $$CartoesTableOrderingComposer,
          $$CartoesTableAnnotationComposer,
          $$CartoesTableCreateCompanionBuilder,
          $$CartoesTableUpdateCompanionBuilder,
          (Cartao, $$CartoesTableReferences),
          Cartao,
          PrefetchHooks Function({
            bool contaPagamentoId,
            bool faturasRefs,
            bool comprasParceladasRefs,
            bool lancamentosRefs,
            bool compromissosRefs,
          })
        > {
  $$CartoesTableTableManager(_$AppDatabase db, $CartoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> limite = const Value.absent(),
                Value<int> diaFechamento = const Value.absent(),
                Value<int> diaVencimento = const Value.absent(),
                Value<int?> contaPagamentoId = const Value.absent(),
                Value<int> cor = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
              }) => CartoesCompanion(
                id: id,
                nome: nome,
                limite: limite,
                diaFechamento: diaFechamento,
                diaVencimento: diaVencimento,
                contaPagamentoId: contaPagamentoId,
                cor: cor,
                ativo: ativo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                Value<int> limite = const Value.absent(),
                required int diaFechamento,
                required int diaVencimento,
                Value<int?> contaPagamentoId = const Value.absent(),
                Value<int> cor = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
              }) => CartoesCompanion.insert(
                id: id,
                nome: nome,
                limite: limite,
                diaFechamento: diaFechamento,
                diaVencimento: diaVencimento,
                contaPagamentoId: contaPagamentoId,
                cor: cor,
                ativo: ativo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CartoesTable, Cartao>(table),
                  $$CartoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contaPagamentoId = false,
                faturasRefs = false,
                comprasParceladasRefs = false,
                lancamentosRefs = false,
                compromissosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (faturasRefs) db.faturas,
                    if (comprasParceladasRefs) db.comprasParceladas,
                    if (lancamentosRefs) db.lancamentos,
                    if (compromissosRefs) db.compromissos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (contaPagamentoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaPagamentoId,
                            referencedTable: $$CartoesTableReferences
                                ._contaPagamentoIdTable(db),
                            referencedColumn: $$CartoesTableReferences
                                ._contaPagamentoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (faturasRefs)
                        await $_getPrefetchedDataByColumns<
                          Cartao,
                          $CartoesTable,
                          Fatura,
                          $FaturasTable
                        >(
                          currentTable: table,
                          referencedTable: $$CartoesTableReferences
                              ._faturasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CartoesTableReferences(
                                db,
                                table,
                                p0,
                              ).faturasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cartao_id',
                          typedResults: items,
                        ),
                      if (comprasParceladasRefs)
                        await $_getPrefetchedDataByColumns<
                          Cartao,
                          $CartoesTable,
                          CompraParcelada,
                          $ComprasParceladasTable
                        >(
                          currentTable: table,
                          referencedTable: $$CartoesTableReferences
                              ._comprasParceladasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CartoesTableReferences(
                                db,
                                table,
                                p0,
                              ).comprasParceladasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cartao_id',
                          typedResults: items,
                        ),
                      if (lancamentosRefs)
                        await $_getPrefetchedDataByColumns<
                          Cartao,
                          $CartoesTable,
                          Lancamento,
                          $LancamentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$CartoesTableReferences
                              ._lancamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CartoesTableReferences(
                                db,
                                table,
                                p0,
                              ).lancamentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cartao_id',
                          typedResults: items,
                        ),
                      if (compromissosRefs)
                        await $_getPrefetchedDataByColumns<
                          Cartao,
                          $CartoesTable,
                          Compromisso,
                          $CompromissosTable
                        >(
                          currentTable: table,
                          referencedTable: $$CartoesTableReferences
                              ._compromissosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CartoesTableReferences(
                                db,
                                table,
                                p0,
                              ).compromissosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cartao_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CartoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartoesTable,
      Cartao,
      $$CartoesTableFilterComposer,
      $$CartoesTableOrderingComposer,
      $$CartoesTableAnnotationComposer,
      $$CartoesTableCreateCompanionBuilder,
      $$CartoesTableUpdateCompanionBuilder,
      (Cartao, $$CartoesTableReferences),
      Cartao,
      PrefetchHooks Function({
        bool contaPagamentoId,
        bool faturasRefs,
        bool comprasParceladasRefs,
        bool lancamentosRefs,
        bool compromissosRefs,
      })
    >;
typedef $$FaturasTableCreateCompanionBuilder = FaturasCompanion Function({
  Value<int> id,
  required int cartaoId,
  required String competencia,
  required DateTime dataFechamento,
  required DateTime dataVencimento,
  Value<StatusFatura> status,
  Value<DateTime?> dataPagamento,
  Value<int?> lancamentoPagamentoId,
});
typedef $$FaturasTableUpdateCompanionBuilder = FaturasCompanion Function({
  Value<int> id,
  Value<int> cartaoId,
  Value<String> competencia,
  Value<DateTime> dataFechamento,
  Value<DateTime> dataVencimento,
  Value<StatusFatura> status,
  Value<DateTime?> dataPagamento,
  Value<int?> lancamentoPagamentoId,
});

final class $$FaturasTableReferences
    extends BaseReferences<_$AppDatabase, $FaturasTable, Fatura> {
  $$FaturasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CartoesTable _cartaoIdTable(_$AppDatabase db) =>
      db.cartoes.createAlias('faturas__cartao_id__cartoes__id');

  $$CartoesTableProcessedTableManager get cartaoId {
    final $_column = $_itemColumn<int>('cartao_id')!;

    final manager = $$CartoesTableTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LancamentosTable, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'faturas__id__lancamentos__fatura_id',
  );

  $$LancamentosTableProcessedTableManager get lancamentosRefs {
    final manager = $$LancamentosTableTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.faturaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FaturasTableFilterComposer
    extends Composer<_$AppDatabase, $FaturasTable> {
  $$FaturasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dataFechamento =>
      $composableBuilder(
        column: $table.dataFechamento,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dataVencimento =>
      $composableBuilder(
        column: $table.dataVencimento,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<StatusFatura, StatusFatura, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get dataPagamento =>
      $composableBuilder(
        column: $table.dataPagamento,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get lancamentoPagamentoId => $composableBuilder(
    column: $table.lancamentoPagamentoId,
    builder: (column) => ColumnFilters(column),
  );

  $$CartoesTableFilterComposer get cartaoId {
    final $$CartoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($$LancamentosTableFilterComposer f) f,
  ) {
    final $$LancamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.faturaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FaturasTableOrderingComposer
    extends Composer<_$AppDatabase, $FaturasTable> {
  $$FaturasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataFechamento => $composableBuilder(
    column: $table.dataFechamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataVencimento => $composableBuilder(
    column: $table.dataVencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lancamentoPagamentoId => $composableBuilder(
    column: $table.lancamentoPagamentoId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CartoesTableOrderingComposer get cartaoId {
    final $$CartoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableOrderingComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FaturasTableAnnotationComposer
    extends Composer<_$AppDatabase, $FaturasTable> {
  $$FaturasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get dataFechamento =>
      $composableBuilder(
        column: $table.dataFechamento,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get dataVencimento =>
      $composableBuilder(
        column: $table.dataVencimento,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<StatusFatura, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get dataPagamento =>
      $composableBuilder(
        column: $table.dataPagamento,
        builder: (column) => column,
      );

  GeneratedColumn<int> get lancamentoPagamentoId => $composableBuilder(
    column: $table.lancamentoPagamentoId,
    builder: (column) => column,
  );

  $$CartoesTableAnnotationComposer get cartaoId {
    final $$CartoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($$LancamentosTableAnnotationComposer a) f,
  ) {
    final $$LancamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.faturaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FaturasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FaturasTable,
          Fatura,
          $$FaturasTableFilterComposer,
          $$FaturasTableOrderingComposer,
          $$FaturasTableAnnotationComposer,
          $$FaturasTableCreateCompanionBuilder,
          $$FaturasTableUpdateCompanionBuilder,
          (Fatura, $$FaturasTableReferences),
          Fatura,
          PrefetchHooks Function({bool cartaoId, bool lancamentosRefs})
        > {
  $$FaturasTableTableManager(_$AppDatabase db, $FaturasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FaturasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FaturasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FaturasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cartaoId = const Value.absent(),
                Value<String> competencia = const Value.absent(),
                Value<DateTime> dataFechamento = const Value.absent(),
                Value<DateTime> dataVencimento = const Value.absent(),
                Value<StatusFatura> status = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
                Value<int?> lancamentoPagamentoId = const Value.absent(),
              }) => FaturasCompanion(
                id: id,
                cartaoId: cartaoId,
                competencia: competencia,
                dataFechamento: dataFechamento,
                dataVencimento: dataVencimento,
                status: status,
                dataPagamento: dataPagamento,
                lancamentoPagamentoId: lancamentoPagamentoId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cartaoId,
                required String competencia,
                required DateTime dataFechamento,
                required DateTime dataVencimento,
                Value<StatusFatura> status = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
                Value<int?> lancamentoPagamentoId = const Value.absent(),
              }) => FaturasCompanion.insert(
                id: id,
                cartaoId: cartaoId,
                competencia: competencia,
                dataFechamento: dataFechamento,
                dataVencimento: dataVencimento,
                status: status,
                dataPagamento: dataPagamento,
                lancamentoPagamentoId: lancamentoPagamentoId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FaturasTable, Fatura>(table),
                  $$FaturasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cartaoId = false, lancamentosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lancamentosRefs) db.lancamentos],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cartaoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cartaoId,
                        referencedTable: $$FaturasTableReferences
                            ._cartaoIdTable(db),
                        referencedColumn: $$FaturasTableReferences
                            ._cartaoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lancamentosRefs)
                    await $_getPrefetchedDataByColumns<
                      Fatura,
                      $FaturasTable,
                      Lancamento,
                      $LancamentosTable
                    >(
                      currentTable: table,
                      referencedTable: $$FaturasTableReferences
                          ._lancamentosRefsTable(db),
                      managerFromTypedResult: (p0) => $$FaturasTableReferences(
                        db,
                        table,
                        p0,
                      ).lancamentosRefs,
                      currentColumn: 'id',
                      referencedColumn: 'fatura_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FaturasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FaturasTable,
      Fatura,
      $$FaturasTableFilterComposer,
      $$FaturasTableOrderingComposer,
      $$FaturasTableAnnotationComposer,
      $$FaturasTableCreateCompanionBuilder,
      $$FaturasTableUpdateCompanionBuilder,
      (Fatura, $$FaturasTableReferences),
      Fatura,
      PrefetchHooks Function({bool cartaoId, bool lancamentosRefs})
    >;
typedef $$CategoriasTableCreateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  required String nome,
  Value<String> icone,
  Value<int> cor,
  required TipoCategoria tipo,
  Value<int?> categoriaPaiId,
  Value<int> ordem,
  Value<bool> ativa,
});
typedef $$CategoriasTableUpdateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String> icone,
  Value<int> cor,
  Value<TipoCategoria> tipo,
  Value<int?> categoriaPaiId,
  Value<int> ordem,
  Value<bool> ativa,
});

final class $$CategoriasTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriasTable, Categoria> {
  $$CategoriasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriasTable _categoriaPaiIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('categorias__categoria_pai_id__categorias__id');

  $$CategoriasTableProcessedTableManager? get categoriaPaiId {
    final $_column = $_itemColumn<int>('categoria_pai_id');
    if ($_column == null) return null;
    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaPaiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ComprasParceladasTable, List<CompraParcelada>>
  _comprasParceladasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.comprasParceladas,
        aliasName: 'categorias__id__compras_parceladas__categoria_id',
      );

  $$ComprasParceladasTableProcessedTableManager get comprasParceladasRefs {
    final manager = $$ComprasParceladasTableTableManager(
      $_db,
      $_db.comprasParceladas,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _comprasParceladasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LancamentosTable, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'categorias__id__lancamentos__categoria_id',
  );

  $$LancamentosTableProcessedTableManager get lancamentosRefs {
    final manager = $$LancamentosTableTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompromissosTable, List<Compromisso>>
  _compromissosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.compromissos,
    aliasName: 'categorias__id__compromissos__categoria_id',
  );

  $$CompromissosTableProcessedTableManager get compromissosRefs {
    final manager = $$CompromissosTableTableManager(
      $_db,
      $_db.compromissos,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_compromissosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReceitasRecorrentesTable, List<ReceitaRecorrente>>
  _receitasRecorrentesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.receitasRecorrentes,
        aliasName: 'categorias__id__receitas_recorrentes__categoria_id',
      );

  $$ReceitasRecorrentesTableProcessedTableManager get receitasRecorrentesRefs {
    final manager = $$ReceitasRecorrentesTableTableManager(
      $_db,
      $_db.receitasRecorrentes,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _receitasRecorrentesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrcamentosTable, List<Orcamento>>
  _orcamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orcamentos,
    aliasName: 'categorias__id__orcamentos__categoria_id',
  );

  $$OrcamentosTableProcessedTableManager get orcamentosRefs {
    final manager = $$OrcamentosTableTableManager(
      $_db,
      $_db.orcamentos,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orcamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RegrasCategorizacaoTable,
    List<RegraCategorizacao>
  >
  _regrasCategorizacaoRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.regrasCategorizacao,
        aliasName: 'categorias__id__regras_categorizacao__categoria_id',
      );

  $$RegrasCategorizacaoTableProcessedTableManager get regrasCategorizacaoRefs {
    final manager = $$RegrasCategorizacaoTableTableManager(
      $_db,
      $_db.regrasCategorizacao,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _regrasCategorizacaoRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoCategoria, TipoCategoria, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaPaiId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaPaiId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> comprasParceladasRefs(
    Expression<bool> Function($$ComprasParceladasTableFilterComposer f) f,
  ) {
    final $$ComprasParceladasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comprasParceladas,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasParceladasTableFilterComposer(
            $db: $db,
            $table: $db.comprasParceladas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($$LancamentosTableFilterComposer f) f,
  ) {
    final $$LancamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> compromissosRefs(
    Expression<bool> Function($$CompromissosTableFilterComposer f) f,
  ) {
    final $$CompromissosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableFilterComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> receitasRecorrentesRefs(
    Expression<bool> Function($$ReceitasRecorrentesTableFilterComposer f) f,
  ) {
    final $$ReceitasRecorrentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receitasRecorrentes,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitasRecorrentesTableFilterComposer(
            $db: $db,
            $table: $db.receitasRecorrentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> orcamentosRefs(
    Expression<bool> Function($$OrcamentosTableFilterComposer f) f,
  ) {
    final $$OrcamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableFilterComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> regrasCategorizacaoRefs(
    Expression<bool> Function($$RegrasCategorizacaoTableFilterComposer f) f,
  ) {
    final $$RegrasCategorizacaoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.regrasCategorizacao,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegrasCategorizacaoTableFilterComposer(
            $db: $db,
            $table: $db.regrasCategorizacao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaPaiId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaPaiId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get icone =>
      $composableBuilder(column: $table.icone, builder: (column) => column);

  GeneratedColumn<int> get cor =>
      $composableBuilder(column: $table.cor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoCategoria, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  $$CategoriasTableAnnotationComposer get categoriaPaiId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaPaiId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> comprasParceladasRefs<T extends Object>(
    Expression<T> Function($$ComprasParceladasTableAnnotationComposer a) f,
  ) {
    final $$ComprasParceladasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.comprasParceladas,
          getReferencedColumn: (t) => t.categoriaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ComprasParceladasTableAnnotationComposer(
                $db: $db,
                $table: $db.comprasParceladas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($$LancamentosTableAnnotationComposer a) f,
  ) {
    final $$LancamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> compromissosRefs<T extends Object>(
    Expression<T> Function($$CompromissosTableAnnotationComposer a) f,
  ) {
    final $$CompromissosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableAnnotationComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> receitasRecorrentesRefs<T extends Object>(
    Expression<T> Function($$ReceitasRecorrentesTableAnnotationComposer a) f,
  ) {
    final $$ReceitasRecorrentesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.receitasRecorrentes,
          getReferencedColumn: (t) => t.categoriaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReceitasRecorrentesTableAnnotationComposer(
                $db: $db,
                $table: $db.receitasRecorrentes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> orcamentosRefs<T extends Object>(
    Expression<T> Function($$OrcamentosTableAnnotationComposer a) f,
  ) {
    final $$OrcamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> regrasCategorizacaoRefs<T extends Object>(
    Expression<T> Function($$RegrasCategorizacaoTableAnnotationComposer a) f,
  ) {
    final $$RegrasCategorizacaoTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.regrasCategorizacao,
          getReferencedColumn: (t) => t.categoriaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RegrasCategorizacaoTableAnnotationComposer(
                $db: $db,
                $table: $db.regrasCategorizacao,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (Categoria, $$CategoriasTableReferences),
          Categoria,
          PrefetchHooks Function({
            bool categoriaPaiId,
            bool comprasParceladasRefs,
            bool lancamentosRefs,
            bool compromissosRefs,
            bool receitasRecorrentesRefs,
            bool orcamentosRefs,
            bool regrasCategorizacaoRefs,
          })
        > {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> icone = const Value.absent(),
                Value<int> cor = const Value.absent(),
                Value<TipoCategoria> tipo = const Value.absent(),
                Value<int?> categoriaPaiId = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                nome: nome,
                icone: icone,
                cor: cor,
                tipo: tipo,
                categoriaPaiId: categoriaPaiId,
                ordem: ordem,
                ativa: ativa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                Value<String> icone = const Value.absent(),
                Value<int> cor = const Value.absent(),
                required TipoCategoria tipo,
                Value<int?> categoriaPaiId = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => CategoriasCompanion.insert(
                id: id,
                nome: nome,
                icone: icone,
                cor: cor,
                tipo: tipo,
                categoriaPaiId: categoriaPaiId,
                ordem: ordem,
                ativa: ativa,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriasTable, Categoria>(table),
                  $$CategoriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoriaPaiId = false,
                comprasParceladasRefs = false,
                lancamentosRefs = false,
                compromissosRefs = false,
                receitasRecorrentesRefs = false,
                orcamentosRefs = false,
                regrasCategorizacaoRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (comprasParceladasRefs) db.comprasParceladas,
                    if (lancamentosRefs) db.lancamentos,
                    if (compromissosRefs) db.compromissos,
                    if (receitasRecorrentesRefs) db.receitasRecorrentes,
                    if (orcamentosRefs) db.orcamentos,
                    if (regrasCategorizacaoRefs) db.regrasCategorizacao,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoriaPaiId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoriaPaiId,
                            referencedTable: $$CategoriasTableReferences
                                ._categoriaPaiIdTable(db),
                            referencedColumn: $$CategoriasTableReferences
                                ._categoriaPaiIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (comprasParceladasRefs)
                        await $_getPrefetchedDataByColumns<
                          Categoria,
                          $CategoriasTable,
                          CompraParcelada,
                          $ComprasParceladasTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriasTableReferences
                              ._comprasParceladasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).comprasParceladasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'categoria_id',
                          typedResults: items,
                        ),
                      if (lancamentosRefs)
                        await $_getPrefetchedDataByColumns<
                          Categoria,
                          $CategoriasTable,
                          Lancamento,
                          $LancamentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriasTableReferences
                              ._lancamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).lancamentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'categoria_id',
                          typedResults: items,
                        ),
                      if (compromissosRefs)
                        await $_getPrefetchedDataByColumns<
                          Categoria,
                          $CategoriasTable,
                          Compromisso,
                          $CompromissosTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriasTableReferences
                              ._compromissosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).compromissosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'categoria_id',
                          typedResults: items,
                        ),
                      if (receitasRecorrentesRefs)
                        await $_getPrefetchedDataByColumns<
                          Categoria,
                          $CategoriasTable,
                          ReceitaRecorrente,
                          $ReceitasRecorrentesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriasTableReferences
                              ._receitasRecorrentesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).receitasRecorrentesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'categoria_id',
                          typedResults: items,
                        ),
                      if (orcamentosRefs)
                        await $_getPrefetchedDataByColumns<
                          Categoria,
                          $CategoriasTable,
                          Orcamento,
                          $OrcamentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriasTableReferences
                              ._orcamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).orcamentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'categoria_id',
                          typedResults: items,
                        ),
                      if (regrasCategorizacaoRefs)
                        await $_getPrefetchedDataByColumns<
                          Categoria,
                          $CategoriasTable,
                          RegraCategorizacao,
                          $RegrasCategorizacaoTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriasTableReferences
                              ._regrasCategorizacaoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).regrasCategorizacaoRefs,
                          currentColumn: 'id',
                          referencedColumn: 'categoria_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, $$CategoriasTableReferences),
      Categoria,
      PrefetchHooks Function({
        bool categoriaPaiId,
        bool comprasParceladasRefs,
        bool lancamentosRefs,
        bool compromissosRefs,
        bool receitasRecorrentesRefs,
        bool orcamentosRefs,
        bool regrasCategorizacaoRefs,
      })
    >;
typedef $$ComprasParceladasTableCreateCompanionBuilder =
    ComprasParceladasCompanion Function({
      Value<int> id,
      required int cartaoId,
      required String descricao,
      Value<int?> categoriaId,
      required int valorTotal,
      required int numeroParcelas,
      required DateTime dataCompra,
    });
typedef $$ComprasParceladasTableUpdateCompanionBuilder =
    ComprasParceladasCompanion Function({
      Value<int> id,
      Value<int> cartaoId,
      Value<String> descricao,
      Value<int?> categoriaId,
      Value<int> valorTotal,
      Value<int> numeroParcelas,
      Value<DateTime> dataCompra,
    });

final class $$ComprasParceladasTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ComprasParceladasTable,
          CompraParcelada
        > {
  $$ComprasParceladasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CartoesTable _cartaoIdTable(_$AppDatabase db) =>
      db.cartoes.createAlias('compras_parceladas__cartao_id__cartoes__id');

  $$CartoesTableProcessedTableManager get cartaoId {
    final $_column = $_itemColumn<int>('cartao_id')!;

    final manager = $$CartoesTableTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) => db.categorias
      .createAlias('compras_parceladas__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager? get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id');
    if ($_column == null) return null;
    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LancamentosTable, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'compras_parceladas__id__lancamentos__compra_parcelada_id',
  );

  $$LancamentosTableProcessedTableManager get lancamentosRefs {
    final manager = $$LancamentosTableTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.compraParceladaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ComprasParceladasTableFilterComposer
    extends Composer<_$AppDatabase, $ComprasParceladasTable> {
  $$ComprasParceladasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorTotal => $composableBuilder(
    column: $table.valorTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dataCompra =>
      $composableBuilder(
        column: $table.dataCompra,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CartoesTableFilterComposer get cartaoId {
    final $$CartoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($$LancamentosTableFilterComposer f) f,
  ) {
    final $$LancamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.compraParceladaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComprasParceladasTableOrderingComposer
    extends Composer<_$AppDatabase, $ComprasParceladasTable> {
  $$ComprasParceladasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorTotal => $composableBuilder(
    column: $table.valorTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataCompra => $composableBuilder(
    column: $table.dataCompra,
    builder: (column) => ColumnOrderings(column),
  );

  $$CartoesTableOrderingComposer get cartaoId {
    final $$CartoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableOrderingComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasParceladasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComprasParceladasTable> {
  $$ComprasParceladasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<int> get valorTotal => $composableBuilder(
    column: $table.valorTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get dataCompra =>
      $composableBuilder(
        column: $table.dataCompra,
        builder: (column) => column,
      );

  $$CartoesTableAnnotationComposer get cartaoId {
    final $$CartoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($$LancamentosTableAnnotationComposer a) f,
  ) {
    final $$LancamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.compraParceladaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComprasParceladasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComprasParceladasTable,
          CompraParcelada,
          $$ComprasParceladasTableFilterComposer,
          $$ComprasParceladasTableOrderingComposer,
          $$ComprasParceladasTableAnnotationComposer,
          $$ComprasParceladasTableCreateCompanionBuilder,
          $$ComprasParceladasTableUpdateCompanionBuilder,
          (CompraParcelada, $$ComprasParceladasTableReferences),
          CompraParcelada,
          PrefetchHooks Function({
            bool cartaoId,
            bool categoriaId,
            bool lancamentosRefs,
          })
        > {
  $$ComprasParceladasTableTableManager(
    _$AppDatabase db,
    $ComprasParceladasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprasParceladasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprasParceladasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprasParceladasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cartaoId = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<int> valorTotal = const Value.absent(),
                Value<int> numeroParcelas = const Value.absent(),
                Value<DateTime> dataCompra = const Value.absent(),
              }) => ComprasParceladasCompanion(
                id: id,
                cartaoId: cartaoId,
                descricao: descricao,
                categoriaId: categoriaId,
                valorTotal: valorTotal,
                numeroParcelas: numeroParcelas,
                dataCompra: dataCompra,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cartaoId,
                required String descricao,
                Value<int?> categoriaId = const Value.absent(),
                required int valorTotal,
                required int numeroParcelas,
                required DateTime dataCompra,
              }) => ComprasParceladasCompanion.insert(
                id: id,
                cartaoId: cartaoId,
                descricao: descricao,
                categoriaId: categoriaId,
                valorTotal: valorTotal,
                numeroParcelas: numeroParcelas,
                dataCompra: dataCompra,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ComprasParceladasTable, CompraParcelada>(table),
                  $$ComprasParceladasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cartaoId = false,
                categoriaId = false,
                lancamentosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lancamentosRefs) db.lancamentos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cartaoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cartaoId,
                            referencedTable: $$ComprasParceladasTableReferences
                                ._cartaoIdTable(db),
                            referencedColumn: $$ComprasParceladasTableReferences
                                ._cartaoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (categoriaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoriaId,
                            referencedTable: $$ComprasParceladasTableReferences
                                ._categoriaIdTable(db),
                            referencedColumn: $$ComprasParceladasTableReferences
                                ._categoriaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lancamentosRefs)
                        await $_getPrefetchedDataByColumns<
                          CompraParcelada,
                          $ComprasParceladasTable,
                          Lancamento,
                          $LancamentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ComprasParceladasTableReferences
                              ._lancamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComprasParceladasTableReferences(
                                db,
                                table,
                                p0,
                              ).lancamentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'compra_parcelada_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ComprasParceladasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComprasParceladasTable,
      CompraParcelada,
      $$ComprasParceladasTableFilterComposer,
      $$ComprasParceladasTableOrderingComposer,
      $$ComprasParceladasTableAnnotationComposer,
      $$ComprasParceladasTableCreateCompanionBuilder,
      $$ComprasParceladasTableUpdateCompanionBuilder,
      (CompraParcelada, $$ComprasParceladasTableReferences),
      CompraParcelada,
      PrefetchHooks Function({
        bool cartaoId,
        bool categoriaId,
        bool lancamentosRefs,
      })
    >;
typedef $$InvestimentosTableCreateCompanionBuilder =
    InvestimentosCompanion Function({
      Value<int> id,
      required String nome,
      required TipoInvestimento tipo,
      Value<bool> ativo,
    });
typedef $$InvestimentosTableUpdateCompanionBuilder =
    InvestimentosCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<TipoInvestimento> tipo,
      Value<bool> ativo,
    });

final class $$InvestimentosTableReferences
    extends BaseReferences<_$AppDatabase, $InvestimentosTable, Investimento> {
  $$InvestimentosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LancamentosTable, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'investimentos__id__lancamentos__investimento_id',
  );

  $$LancamentosTableProcessedTableManager get lancamentosRefs {
    final manager = $$LancamentosTableTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.investimentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MovimentosInvestimentoTable,
    List<MovimentoInvestimento>
  >
  _movimentosInvestimentoRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.movimentosInvestimento,
        aliasName:
            'investimentos__id__movimentos_investimento__investimento_id',
      );

  $$MovimentosInvestimentoTableProcessedTableManager
  get movimentosInvestimentoRefs {
    final manager = $$MovimentosInvestimentoTableTableManager(
      $_db,
      $_db.movimentosInvestimento,
    ).filter((f) => f.investimentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _movimentosInvestimentoRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MetasTable, List<Meta>> _metasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.metas,
    aliasName: 'investimentos__id__metas__investimento_id',
  );

  $$MetasTableProcessedTableManager get metasRefs {
    final manager = $$MetasTableTableManager(
      $_db,
      $_db.metas,
    ).filter((f) => f.investimentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_metasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvestimentosTableFilterComposer
    extends Composer<_$AppDatabase, $InvestimentosTable> {
  $$InvestimentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoInvestimento, TipoInvestimento, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($$LancamentosTableFilterComposer f) f,
  ) {
    final $$LancamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.investimentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> movimentosInvestimentoRefs(
    Expression<bool> Function($$MovimentosInvestimentoTableFilterComposer f) f,
  ) {
    final $$MovimentosInvestimentoTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movimentosInvestimento,
          getReferencedColumn: (t) => t.investimentoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovimentosInvestimentoTableFilterComposer(
                $db: $db,
                $table: $db.movimentosInvestimento,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> metasRefs(
    Expression<bool> Function($$MetasTableFilterComposer f) f,
  ) {
    final $$MetasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.metas,
      getReferencedColumn: (t) => t.investimentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetasTableFilterComposer(
            $db: $db,
            $table: $db.metas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestimentosTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestimentosTable> {
  $$InvestimentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestimentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestimentosTable> {
  $$InvestimentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoInvestimento, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($$LancamentosTableAnnotationComposer a) f,
  ) {
    final $$LancamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.investimentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LancamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> movimentosInvestimentoRefs<T extends Object>(
    Expression<T> Function($$MovimentosInvestimentoTableAnnotationComposer a) f,
  ) {
    final $$MovimentosInvestimentoTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movimentosInvestimento,
          getReferencedColumn: (t) => t.investimentoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovimentosInvestimentoTableAnnotationComposer(
                $db: $db,
                $table: $db.movimentosInvestimento,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> metasRefs<T extends Object>(
    Expression<T> Function($$MetasTableAnnotationComposer a) f,
  ) {
    final $$MetasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.metas,
      getReferencedColumn: (t) => t.investimentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MetasTableAnnotationComposer(
            $db: $db,
            $table: $db.metas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestimentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestimentosTable,
          Investimento,
          $$InvestimentosTableFilterComposer,
          $$InvestimentosTableOrderingComposer,
          $$InvestimentosTableAnnotationComposer,
          $$InvestimentosTableCreateCompanionBuilder,
          $$InvestimentosTableUpdateCompanionBuilder,
          (Investimento, $$InvestimentosTableReferences),
          Investimento,
          PrefetchHooks Function({
            bool lancamentosRefs,
            bool movimentosInvestimentoRefs,
            bool metasRefs,
          })
        > {
  $$InvestimentosTableTableManager(_$AppDatabase db, $InvestimentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestimentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestimentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestimentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<TipoInvestimento> tipo = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
              }) => InvestimentosCompanion(
                id: id,
                nome: nome,
                tipo: tipo,
                ativo: ativo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required TipoInvestimento tipo,
                Value<bool> ativo = const Value.absent(),
              }) => InvestimentosCompanion.insert(
                id: id,
                nome: nome,
                tipo: tipo,
                ativo: ativo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvestimentosTable, Investimento>(table),
                  $$InvestimentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                lancamentosRefs = false,
                movimentosInvestimentoRefs = false,
                metasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lancamentosRefs) db.lancamentos,
                    if (movimentosInvestimentoRefs) db.movimentosInvestimento,
                    if (metasRefs) db.metas,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lancamentosRefs)
                        await $_getPrefetchedDataByColumns<
                          Investimento,
                          $InvestimentosTable,
                          Lancamento,
                          $LancamentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$InvestimentosTableReferences
                              ._lancamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestimentosTableReferences(
                                db,
                                table,
                                p0,
                              ).lancamentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'investimento_id',
                          typedResults: items,
                        ),
                      if (movimentosInvestimentoRefs)
                        await $_getPrefetchedDataByColumns<
                          Investimento,
                          $InvestimentosTable,
                          MovimentoInvestimento,
                          $MovimentosInvestimentoTable
                        >(
                          currentTable: table,
                          referencedTable: $$InvestimentosTableReferences
                              ._movimentosInvestimentoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestimentosTableReferences(
                                db,
                                table,
                                p0,
                              ).movimentosInvestimentoRefs,
                          currentColumn: 'id',
                          referencedColumn: 'investimento_id',
                          typedResults: items,
                        ),
                      if (metasRefs)
                        await $_getPrefetchedDataByColumns<
                          Investimento,
                          $InvestimentosTable,
                          Meta,
                          $MetasTable
                        >(
                          currentTable: table,
                          referencedTable: $$InvestimentosTableReferences
                              ._metasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestimentosTableReferences(
                                db,
                                table,
                                p0,
                              ).metasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'investimento_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InvestimentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestimentosTable,
      Investimento,
      $$InvestimentosTableFilterComposer,
      $$InvestimentosTableOrderingComposer,
      $$InvestimentosTableAnnotationComposer,
      $$InvestimentosTableCreateCompanionBuilder,
      $$InvestimentosTableUpdateCompanionBuilder,
      (Investimento, $$InvestimentosTableReferences),
      Investimento,
      PrefetchHooks Function({
        bool lancamentosRefs,
        bool movimentosInvestimentoRefs,
        bool metasRefs,
      })
    >;
typedef $$LancamentosTableCreateCompanionBuilder =
    LancamentosCompanion Function({
      Value<int> id,
      required TipoLancamento tipo,
      required int valor,
      required DateTime data,
      Value<String> descricao,
      Value<int?> categoriaId,
      Value<FormaPagamento?> formaPagamento,
      Value<int?> contaId,
      Value<int?> contaDestinoId,
      Value<int?> cartaoId,
      Value<int?> faturaId,
      Value<int?> compraParceladaId,
      Value<int?> parcelaNumero,
      Value<int?> ocorrenciaCompromissoId,
      Value<int?> investimentoId,
      Value<int?> receitaRecorrenteId,
      Value<OrigemLancamento> origem,
      Value<String?> chaveImportacao,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
    });
typedef $$LancamentosTableUpdateCompanionBuilder =
    LancamentosCompanion Function({
      Value<int> id,
      Value<TipoLancamento> tipo,
      Value<int> valor,
      Value<DateTime> data,
      Value<String> descricao,
      Value<int?> categoriaId,
      Value<FormaPagamento?> formaPagamento,
      Value<int?> contaId,
      Value<int?> contaDestinoId,
      Value<int?> cartaoId,
      Value<int?> faturaId,
      Value<int?> compraParceladaId,
      Value<int?> parcelaNumero,
      Value<int?> ocorrenciaCompromissoId,
      Value<int?> investimentoId,
      Value<int?> receitaRecorrenteId,
      Value<OrigemLancamento> origem,
      Value<String?> chaveImportacao,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
    });

final class $$LancamentosTableReferences
    extends BaseReferences<_$AppDatabase, $LancamentosTable, Lancamento> {
  $$LancamentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('lancamentos__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager? get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id');
    if ($_column == null) return null;
    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContasTable _contaIdTable(_$AppDatabase db) =>
      db.contas.createAlias('lancamentos__conta_id__contas__id');

  $$ContasTableProcessedTableManager? get contaId {
    final $_column = $_itemColumn<int>('conta_id');
    if ($_column == null) return null;
    final manager = $$ContasTableTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContasTable _contaDestinoIdTable(_$AppDatabase db) =>
      db.contas.createAlias('lancamentos__conta_destino_id__contas__id');

  $$ContasTableProcessedTableManager? get contaDestinoId {
    final $_column = $_itemColumn<int>('conta_destino_id');
    if ($_column == null) return null;
    final manager = $$ContasTableTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaDestinoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CartoesTable _cartaoIdTable(_$AppDatabase db) =>
      db.cartoes.createAlias('lancamentos__cartao_id__cartoes__id');

  $$CartoesTableProcessedTableManager? get cartaoId {
    final $_column = $_itemColumn<int>('cartao_id');
    if ($_column == null) return null;
    final manager = $$CartoesTableTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FaturasTable _faturaIdTable(_$AppDatabase db) =>
      db.faturas.createAlias('lancamentos__fatura_id__faturas__id');

  $$FaturasTableProcessedTableManager? get faturaId {
    final $_column = $_itemColumn<int>('fatura_id');
    if ($_column == null) return null;
    final manager = $$FaturasTableTableManager(
      $_db,
      $_db.faturas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_faturaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ComprasParceladasTable _compraParceladaIdTable(_$AppDatabase db) => db
      .comprasParceladas
      .createAlias('lancamentos__compra_parcelada_id__compras_parceladas__id');

  $$ComprasParceladasTableProcessedTableManager? get compraParceladaId {
    final $_column = $_itemColumn<int>('compra_parcelada_id');
    if ($_column == null) return null;
    final manager = $$ComprasParceladasTableTableManager(
      $_db,
      $_db.comprasParceladas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compraParceladaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InvestimentosTable _investimentoIdTable(_$AppDatabase db) => db
      .investimentos
      .createAlias('lancamentos__investimento_id__investimentos__id');

  $$InvestimentosTableProcessedTableManager? get investimentoId {
    final $_column = $_itemColumn<int>('investimento_id');
    if ($_column == null) return null;
    final manager = $$InvestimentosTableTableManager(
      $_db,
      $_db.investimentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investimentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LancamentosTableFilterComposer
    extends Composer<_$AppDatabase, $LancamentosTable> {
  $$LancamentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoLancamento, TipoLancamento, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get data =>
      $composableBuilder(
        column: $table.data,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FormaPagamento?, FormaPagamento, String>
  get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get parcelaNumero => $composableBuilder(
    column: $table.parcelaNumero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ocorrenciaCompromissoId => $composableBuilder(
    column: $table.ocorrenciaCompromissoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receitaRecorrenteId => $composableBuilder(
    column: $table.receitaRecorrenteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OrigemLancamento, OrigemLancamento, String>
  get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get chaveImportacao => $composableBuilder(
    column: $table.chaveImportacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableFilterComposer get contaId {
    final $$ContasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableFilterComposer get contaDestinoId {
    final $$ContasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaDestinoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CartoesTableFilterComposer get cartaoId {
    final $$CartoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FaturasTableFilterComposer get faturaId {
    final $$FaturasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.faturaId,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasTableFilterComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComprasParceladasTableFilterComposer get compraParceladaId {
    final $$ComprasParceladasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraParceladaId,
      referencedTable: $db.comprasParceladas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasParceladasTableFilterComposer(
            $db: $db,
            $table: $db.comprasParceladas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestimentosTableFilterComposer get investimentoId {
    final $$InvestimentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableFilterComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LancamentosTableOrderingComposer
    extends Composer<_$AppDatabase, $LancamentosTable> {
  $$LancamentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parcelaNumero => $composableBuilder(
    column: $table.parcelaNumero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ocorrenciaCompromissoId => $composableBuilder(
    column: $table.ocorrenciaCompromissoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receitaRecorrenteId => $composableBuilder(
    column: $table.receitaRecorrenteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chaveImportacao => $composableBuilder(
    column: $table.chaveImportacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableOrderingComposer get contaId {
    final $$ContasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableOrderingComposer get contaDestinoId {
    final $$ContasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaDestinoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CartoesTableOrderingComposer get cartaoId {
    final $$CartoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableOrderingComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FaturasTableOrderingComposer get faturaId {
    final $$FaturasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.faturaId,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasTableOrderingComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComprasParceladasTableOrderingComposer get compraParceladaId {
    final $$ComprasParceladasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraParceladaId,
      referencedTable: $db.comprasParceladas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasParceladasTableOrderingComposer(
            $db: $db,
            $table: $db.comprasParceladas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestimentosTableOrderingComposer get investimentoId {
    final $$InvestimentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableOrderingComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LancamentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $LancamentosTable> {
  $$LancamentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoLancamento, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FormaPagamento?, String>
  get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parcelaNumero => $composableBuilder(
    column: $table.parcelaNumero,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ocorrenciaCompromissoId => $composableBuilder(
    column: $table.ocorrenciaCompromissoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receitaRecorrenteId => $composableBuilder(
    column: $table.receitaRecorrenteId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OrigemLancamento, String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);

  GeneratedColumn<String> get chaveImportacao => $composableBuilder(
    column: $table.chaveImportacao,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableAnnotationComposer get contaId {
    final $$ContasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableAnnotationComposer get contaDestinoId {
    final $$ContasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaDestinoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CartoesTableAnnotationComposer get cartaoId {
    final $$CartoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FaturasTableAnnotationComposer get faturaId {
    final $$FaturasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.faturaId,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasTableAnnotationComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ComprasParceladasTableAnnotationComposer get compraParceladaId {
    final $$ComprasParceladasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.compraParceladaId,
          referencedTable: $db.comprasParceladas,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ComprasParceladasTableAnnotationComposer(
                $db: $db,
                $table: $db.comprasParceladas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$InvestimentosTableAnnotationComposer get investimentoId {
    final $$InvestimentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableAnnotationComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LancamentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LancamentosTable,
          Lancamento,
          $$LancamentosTableFilterComposer,
          $$LancamentosTableOrderingComposer,
          $$LancamentosTableAnnotationComposer,
          $$LancamentosTableCreateCompanionBuilder,
          $$LancamentosTableUpdateCompanionBuilder,
          (Lancamento, $$LancamentosTableReferences),
          Lancamento,
          PrefetchHooks Function({
            bool categoriaId,
            bool contaId,
            bool contaDestinoId,
            bool cartaoId,
            bool faturaId,
            bool compraParceladaId,
            bool investimentoId,
          })
        > {
  $$LancamentosTableTableManager(_$AppDatabase db, $LancamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LancamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LancamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LancamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<TipoLancamento> tipo = const Value.absent(),
                Value<int> valor = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<FormaPagamento?> formaPagamento = const Value.absent(),
                Value<int?> contaId = const Value.absent(),
                Value<int?> contaDestinoId = const Value.absent(),
                Value<int?> cartaoId = const Value.absent(),
                Value<int?> faturaId = const Value.absent(),
                Value<int?> compraParceladaId = const Value.absent(),
                Value<int?> parcelaNumero = const Value.absent(),
                Value<int?> ocorrenciaCompromissoId = const Value.absent(),
                Value<int?> investimentoId = const Value.absent(),
                Value<int?> receitaRecorrenteId = const Value.absent(),
                Value<OrigemLancamento> origem = const Value.absent(),
                Value<String?> chaveImportacao = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => LancamentosCompanion(
                id: id,
                tipo: tipo,
                valor: valor,
                data: data,
                descricao: descricao,
                categoriaId: categoriaId,
                formaPagamento: formaPagamento,
                contaId: contaId,
                contaDestinoId: contaDestinoId,
                cartaoId: cartaoId,
                faturaId: faturaId,
                compraParceladaId: compraParceladaId,
                parcelaNumero: parcelaNumero,
                ocorrenciaCompromissoId: ocorrenciaCompromissoId,
                investimentoId: investimentoId,
                receitaRecorrenteId: receitaRecorrenteId,
                origem: origem,
                chaveImportacao: chaveImportacao,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required TipoLancamento tipo,
                required int valor,
                required DateTime data,
                Value<String> descricao = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<FormaPagamento?> formaPagamento = const Value.absent(),
                Value<int?> contaId = const Value.absent(),
                Value<int?> contaDestinoId = const Value.absent(),
                Value<int?> cartaoId = const Value.absent(),
                Value<int?> faturaId = const Value.absent(),
                Value<int?> compraParceladaId = const Value.absent(),
                Value<int?> parcelaNumero = const Value.absent(),
                Value<int?> ocorrenciaCompromissoId = const Value.absent(),
                Value<int?> investimentoId = const Value.absent(),
                Value<int?> receitaRecorrenteId = const Value.absent(),
                Value<OrigemLancamento> origem = const Value.absent(),
                Value<String?> chaveImportacao = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => LancamentosCompanion.insert(
                id: id,
                tipo: tipo,
                valor: valor,
                data: data,
                descricao: descricao,
                categoriaId: categoriaId,
                formaPagamento: formaPagamento,
                contaId: contaId,
                contaDestinoId: contaDestinoId,
                cartaoId: cartaoId,
                faturaId: faturaId,
                compraParceladaId: compraParceladaId,
                parcelaNumero: parcelaNumero,
                ocorrenciaCompromissoId: ocorrenciaCompromissoId,
                investimentoId: investimentoId,
                receitaRecorrenteId: receitaRecorrenteId,
                origem: origem,
                chaveImportacao: chaveImportacao,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LancamentosTable, Lancamento>(table),
                  $$LancamentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoriaId = false,
                contaId = false,
                contaDestinoId = false,
                cartaoId = false,
                faturaId = false,
                compraParceladaId = false,
                investimentoId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoriaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoriaId,
                            referencedTable: $$LancamentosTableReferences
                                ._categoriaIdTable(db),
                            referencedColumn: $$LancamentosTableReferences
                                ._categoriaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (contaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaId,
                            referencedTable: $$LancamentosTableReferences
                                ._contaIdTable(db),
                            referencedColumn: $$LancamentosTableReferences
                                ._contaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (contaDestinoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaDestinoId,
                            referencedTable: $$LancamentosTableReferences
                                ._contaDestinoIdTable(db),
                            referencedColumn: $$LancamentosTableReferences
                                ._contaDestinoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (cartaoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cartaoId,
                            referencedTable: $$LancamentosTableReferences
                                ._cartaoIdTable(db),
                            referencedColumn: $$LancamentosTableReferences
                                ._cartaoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (faturaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.faturaId,
                            referencedTable: $$LancamentosTableReferences
                                ._faturaIdTable(db),
                            referencedColumn: $$LancamentosTableReferences
                                ._faturaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (compraParceladaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.compraParceladaId,
                            referencedTable: $$LancamentosTableReferences
                                ._compraParceladaIdTable(db),
                            referencedColumn: $$LancamentosTableReferences
                                ._compraParceladaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (investimentoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.investimentoId,
                            referencedTable: $$LancamentosTableReferences
                                ._investimentoIdTable(db),
                            referencedColumn: $$LancamentosTableReferences
                                ._investimentoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$LancamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LancamentosTable,
      Lancamento,
      $$LancamentosTableFilterComposer,
      $$LancamentosTableOrderingComposer,
      $$LancamentosTableAnnotationComposer,
      $$LancamentosTableCreateCompanionBuilder,
      $$LancamentosTableUpdateCompanionBuilder,
      (Lancamento, $$LancamentosTableReferences),
      Lancamento,
      PrefetchHooks Function({
        bool categoriaId,
        bool contaId,
        bool contaDestinoId,
        bool cartaoId,
        bool faturaId,
        bool compraParceladaId,
        bool investimentoId,
      })
    >;
typedef $$CompromissosTableCreateCompanionBuilder =
    CompromissosCompanion Function({
      Value<int> id,
      required String descricao,
      Value<int?> categoriaId,
      Value<FormaPagamento> formaPagamento,
      Value<int?> contaId,
      Value<int?> cartaoId,
      required int valor,
      required int diaVencimento,
      required DateTime dataInicio,
      required TipoCompromisso tipo,
      Value<int?> numeroParcelas,
      Value<bool> ativo,
    });
typedef $$CompromissosTableUpdateCompanionBuilder =
    CompromissosCompanion Function({
      Value<int> id,
      Value<String> descricao,
      Value<int?> categoriaId,
      Value<FormaPagamento> formaPagamento,
      Value<int?> contaId,
      Value<int?> cartaoId,
      Value<int> valor,
      Value<int> diaVencimento,
      Value<DateTime> dataInicio,
      Value<TipoCompromisso> tipo,
      Value<int?> numeroParcelas,
      Value<bool> ativo,
    });

final class $$CompromissosTableReferences
    extends BaseReferences<_$AppDatabase, $CompromissosTable, Compromisso> {
  $$CompromissosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('compromissos__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager? get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id');
    if ($_column == null) return null;
    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContasTable _contaIdTable(_$AppDatabase db) =>
      db.contas.createAlias('compromissos__conta_id__contas__id');

  $$ContasTableProcessedTableManager? get contaId {
    final $_column = $_itemColumn<int>('conta_id');
    if ($_column == null) return null;
    final manager = $$ContasTableTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CartoesTable _cartaoIdTable(_$AppDatabase db) =>
      db.cartoes.createAlias('compromissos__cartao_id__cartoes__id');

  $$CartoesTableProcessedTableManager? get cartaoId {
    final $_column = $_itemColumn<int>('cartao_id');
    if ($_column == null) return null;
    final manager = $$CartoesTableTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $OcorrenciasCompromissoTable,
    List<OcorrenciaCompromisso>
  >
  _ocorrenciasCompromissoRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ocorrenciasCompromisso,
        aliasName: 'compromissos__id__ocorrencias_compromisso__compromisso_id',
      );

  $$OcorrenciasCompromissoTableProcessedTableManager
  get ocorrenciasCompromissoRefs {
    final manager = $$OcorrenciasCompromissoTableTableManager(
      $_db,
      $_db.ocorrenciasCompromisso,
    ).filter((f) => f.compromissoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ocorrenciasCompromissoRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompromissosTableFilterComposer
    extends Composer<_$AppDatabase, $CompromissosTable> {
  $$CompromissosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FormaPagamento, FormaPagamento, String>
  get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dataInicio =>
      $composableBuilder(
        column: $table.dataInicio,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TipoCompromisso, TipoCompromisso, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableFilterComposer get contaId {
    final $$ContasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CartoesTableFilterComposer get cartaoId {
    final $$CartoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ocorrenciasCompromissoRefs(
    Expression<bool> Function($$OcorrenciasCompromissoTableFilterComposer f) f,
  ) {
    final $$OcorrenciasCompromissoTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ocorrenciasCompromisso,
          getReferencedColumn: (t) => t.compromissoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OcorrenciasCompromissoTableFilterComposer(
                $db: $db,
                $table: $db.ocorrenciasCompromisso,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CompromissosTableOrderingComposer
    extends Composer<_$AppDatabase, $CompromissosTable> {
  $$CompromissosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataInicio => $composableBuilder(
    column: $table.dataInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableOrderingComposer get contaId {
    final $$ContasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CartoesTableOrderingComposer get cartaoId {
    final $$CartoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableOrderingComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompromissosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompromissosTable> {
  $$CompromissosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FormaPagamento, String> get formaPagamento =>
      $composableBuilder(
        column: $table.formaPagamento,
        builder: (column) => column,
      );

  GeneratedColumn<int> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get dataInicio =>
      $composableBuilder(
        column: $table.dataInicio,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<TipoCompromisso, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get numeroParcelas => $composableBuilder(
    column: $table.numeroParcelas,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableAnnotationComposer get contaId {
    final $$ContasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CartoesTableAnnotationComposer get cartaoId {
    final $$CartoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ocorrenciasCompromissoRefs<T extends Object>(
    Expression<T> Function($$OcorrenciasCompromissoTableAnnotationComposer a) f,
  ) {
    final $$OcorrenciasCompromissoTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ocorrenciasCompromisso,
          getReferencedColumn: (t) => t.compromissoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OcorrenciasCompromissoTableAnnotationComposer(
                $db: $db,
                $table: $db.ocorrenciasCompromisso,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CompromissosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompromissosTable,
          Compromisso,
          $$CompromissosTableFilterComposer,
          $$CompromissosTableOrderingComposer,
          $$CompromissosTableAnnotationComposer,
          $$CompromissosTableCreateCompanionBuilder,
          $$CompromissosTableUpdateCompanionBuilder,
          (Compromisso, $$CompromissosTableReferences),
          Compromisso,
          PrefetchHooks Function({
            bool categoriaId,
            bool contaId,
            bool cartaoId,
            bool ocorrenciasCompromissoRefs,
          })
        > {
  $$CompromissosTableTableManager(_$AppDatabase db, $CompromissosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompromissosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompromissosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompromissosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<FormaPagamento> formaPagamento = const Value.absent(),
                Value<int?> contaId = const Value.absent(),
                Value<int?> cartaoId = const Value.absent(),
                Value<int> valor = const Value.absent(),
                Value<int> diaVencimento = const Value.absent(),
                Value<DateTime> dataInicio = const Value.absent(),
                Value<TipoCompromisso> tipo = const Value.absent(),
                Value<int?> numeroParcelas = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
              }) => CompromissosCompanion(
                id: id,
                descricao: descricao,
                categoriaId: categoriaId,
                formaPagamento: formaPagamento,
                contaId: contaId,
                cartaoId: cartaoId,
                valor: valor,
                diaVencimento: diaVencimento,
                dataInicio: dataInicio,
                tipo: tipo,
                numeroParcelas: numeroParcelas,
                ativo: ativo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String descricao,
                Value<int?> categoriaId = const Value.absent(),
                Value<FormaPagamento> formaPagamento = const Value.absent(),
                Value<int?> contaId = const Value.absent(),
                Value<int?> cartaoId = const Value.absent(),
                required int valor,
                required int diaVencimento,
                required DateTime dataInicio,
                required TipoCompromisso tipo,
                Value<int?> numeroParcelas = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
              }) => CompromissosCompanion.insert(
                id: id,
                descricao: descricao,
                categoriaId: categoriaId,
                formaPagamento: formaPagamento,
                contaId: contaId,
                cartaoId: cartaoId,
                valor: valor,
                diaVencimento: diaVencimento,
                dataInicio: dataInicio,
                tipo: tipo,
                numeroParcelas: numeroParcelas,
                ativo: ativo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompromissosTable, Compromisso>(table),
                  $$CompromissosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoriaId = false,
                contaId = false,
                cartaoId = false,
                ocorrenciasCompromissoRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ocorrenciasCompromissoRefs) db.ocorrenciasCompromisso,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoriaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoriaId,
                            referencedTable: $$CompromissosTableReferences
                                ._categoriaIdTable(db),
                            referencedColumn: $$CompromissosTableReferences
                                ._categoriaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (contaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaId,
                            referencedTable: $$CompromissosTableReferences
                                ._contaIdTable(db),
                            referencedColumn: $$CompromissosTableReferences
                                ._contaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (cartaoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cartaoId,
                            referencedTable: $$CompromissosTableReferences
                                ._cartaoIdTable(db),
                            referencedColumn: $$CompromissosTableReferences
                                ._cartaoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ocorrenciasCompromissoRefs)
                        await $_getPrefetchedDataByColumns<
                          Compromisso,
                          $CompromissosTable,
                          OcorrenciaCompromisso,
                          $OcorrenciasCompromissoTable
                        >(
                          currentTable: table,
                          referencedTable: $$CompromissosTableReferences
                              ._ocorrenciasCompromissoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompromissosTableReferences(
                                db,
                                table,
                                p0,
                              ).ocorrenciasCompromissoRefs,
                          currentColumn: 'id',
                          referencedColumn: 'compromisso_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompromissosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompromissosTable,
      Compromisso,
      $$CompromissosTableFilterComposer,
      $$CompromissosTableOrderingComposer,
      $$CompromissosTableAnnotationComposer,
      $$CompromissosTableCreateCompanionBuilder,
      $$CompromissosTableUpdateCompanionBuilder,
      (Compromisso, $$CompromissosTableReferences),
      Compromisso,
      PrefetchHooks Function({
        bool categoriaId,
        bool contaId,
        bool cartaoId,
        bool ocorrenciasCompromissoRefs,
      })
    >;
typedef $$OcorrenciasCompromissoTableCreateCompanionBuilder =
    OcorrenciasCompromissoCompanion Function({
      Value<int> id,
      required int compromissoId,
      required String competencia,
      Value<int?> numeroParcela,
      required int valor,
      required DateTime dataVencimento,
      Value<StatusOcorrencia> status,
      Value<int?> lancamentoId,
    });
typedef $$OcorrenciasCompromissoTableUpdateCompanionBuilder =
    OcorrenciasCompromissoCompanion Function({
      Value<int> id,
      Value<int> compromissoId,
      Value<String> competencia,
      Value<int?> numeroParcela,
      Value<int> valor,
      Value<DateTime> dataVencimento,
      Value<StatusOcorrencia> status,
      Value<int?> lancamentoId,
    });

final class $$OcorrenciasCompromissoTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OcorrenciasCompromissoTable,
          OcorrenciaCompromisso
        > {
  $$OcorrenciasCompromissoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompromissosTable _compromissoIdTable(_$AppDatabase db) => db
      .compromissos
      .createAlias('ocorrencias_compromisso__compromisso_id__compromissos__id');

  $$CompromissosTableProcessedTableManager get compromissoId {
    final $_column = $_itemColumn<int>('compromisso_id')!;

    final manager = $$CompromissosTableTableManager(
      $_db,
      $_db.compromissos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compromissoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OcorrenciasCompromissoTableFilterComposer
    extends Composer<_$AppDatabase, $OcorrenciasCompromissoTable> {
  $$OcorrenciasCompromissoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numeroParcela => $composableBuilder(
    column: $table.numeroParcela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dataVencimento =>
      $composableBuilder(
        column: $table.dataVencimento,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<StatusOcorrencia, StatusOcorrencia, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get lancamentoId => $composableBuilder(
    column: $table.lancamentoId,
    builder: (column) => ColumnFilters(column),
  );

  $$CompromissosTableFilterComposer get compromissoId {
    final $$CompromissosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compromissoId,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableFilterComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcorrenciasCompromissoTableOrderingComposer
    extends Composer<_$AppDatabase, $OcorrenciasCompromissoTable> {
  $$OcorrenciasCompromissoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numeroParcela => $composableBuilder(
    column: $table.numeroParcela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataVencimento => $composableBuilder(
    column: $table.dataVencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lancamentoId => $composableBuilder(
    column: $table.lancamentoId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompromissosTableOrderingComposer get compromissoId {
    final $$CompromissosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compromissoId,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableOrderingComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcorrenciasCompromissoTableAnnotationComposer
    extends Composer<_$AppDatabase, $OcorrenciasCompromissoTable> {
  $$OcorrenciasCompromissoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numeroParcela => $composableBuilder(
    column: $table.numeroParcela,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get dataVencimento =>
      $composableBuilder(
        column: $table.dataVencimento,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<StatusOcorrencia, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get lancamentoId => $composableBuilder(
    column: $table.lancamentoId,
    builder: (column) => column,
  );

  $$CompromissosTableAnnotationComposer get compromissoId {
    final $$CompromissosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compromissoId,
      referencedTable: $db.compromissos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompromissosTableAnnotationComposer(
            $db: $db,
            $table: $db.compromissos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcorrenciasCompromissoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OcorrenciasCompromissoTable,
          OcorrenciaCompromisso,
          $$OcorrenciasCompromissoTableFilterComposer,
          $$OcorrenciasCompromissoTableOrderingComposer,
          $$OcorrenciasCompromissoTableAnnotationComposer,
          $$OcorrenciasCompromissoTableCreateCompanionBuilder,
          $$OcorrenciasCompromissoTableUpdateCompanionBuilder,
          (OcorrenciaCompromisso, $$OcorrenciasCompromissoTableReferences),
          OcorrenciaCompromisso,
          PrefetchHooks Function({bool compromissoId})
        > {
  $$OcorrenciasCompromissoTableTableManager(
    _$AppDatabase db,
    $OcorrenciasCompromissoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OcorrenciasCompromissoTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OcorrenciasCompromissoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OcorrenciasCompromissoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> compromissoId = const Value.absent(),
                Value<String> competencia = const Value.absent(),
                Value<int?> numeroParcela = const Value.absent(),
                Value<int> valor = const Value.absent(),
                Value<DateTime> dataVencimento = const Value.absent(),
                Value<StatusOcorrencia> status = const Value.absent(),
                Value<int?> lancamentoId = const Value.absent(),
              }) => OcorrenciasCompromissoCompanion(
                id: id,
                compromissoId: compromissoId,
                competencia: competencia,
                numeroParcela: numeroParcela,
                valor: valor,
                dataVencimento: dataVencimento,
                status: status,
                lancamentoId: lancamentoId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int compromissoId,
                required String competencia,
                Value<int?> numeroParcela = const Value.absent(),
                required int valor,
                required DateTime dataVencimento,
                Value<StatusOcorrencia> status = const Value.absent(),
                Value<int?> lancamentoId = const Value.absent(),
              }) => OcorrenciasCompromissoCompanion.insert(
                id: id,
                compromissoId: compromissoId,
                competencia: competencia,
                numeroParcela: numeroParcela,
                valor: valor,
                dataVencimento: dataVencimento,
                status: status,
                lancamentoId: lancamentoId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $OcorrenciasCompromissoTable,
                    OcorrenciaCompromisso
                  >(table),
                  $$OcorrenciasCompromissoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compromissoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compromissoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.compromissoId,
                        referencedTable: $$OcorrenciasCompromissoTableReferences
                            ._compromissoIdTable(db),
                        referencedColumn:
                            $$OcorrenciasCompromissoTableReferences
                                ._compromissoIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OcorrenciasCompromissoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OcorrenciasCompromissoTable,
      OcorrenciaCompromisso,
      $$OcorrenciasCompromissoTableFilterComposer,
      $$OcorrenciasCompromissoTableOrderingComposer,
      $$OcorrenciasCompromissoTableAnnotationComposer,
      $$OcorrenciasCompromissoTableCreateCompanionBuilder,
      $$OcorrenciasCompromissoTableUpdateCompanionBuilder,
      (OcorrenciaCompromisso, $$OcorrenciasCompromissoTableReferences),
      OcorrenciaCompromisso,
      PrefetchHooks Function({bool compromissoId})
    >;
typedef $$ReceitasRecorrentesTableCreateCompanionBuilder =
    ReceitasRecorrentesCompanion Function({
      Value<int> id,
      required String descricao,
      Value<int?> categoriaId,
      required int contaId,
      required int valorPrevisto,
      required int diaPrevisto,
      required DateTime dataInicio,
      Value<bool> ativa,
    });
typedef $$ReceitasRecorrentesTableUpdateCompanionBuilder =
    ReceitasRecorrentesCompanion Function({
      Value<int> id,
      Value<String> descricao,
      Value<int?> categoriaId,
      Value<int> contaId,
      Value<int> valorPrevisto,
      Value<int> diaPrevisto,
      Value<DateTime> dataInicio,
      Value<bool> ativa,
    });

final class $$ReceitasRecorrentesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReceitasRecorrentesTable,
          ReceitaRecorrente
        > {
  $$ReceitasRecorrentesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) => db.categorias
      .createAlias('receitas_recorrentes__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager? get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id');
    if ($_column == null) return null;
    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContasTable _contaIdTable(_$AppDatabase db) =>
      db.contas.createAlias('receitas_recorrentes__conta_id__contas__id');

  $$ContasTableProcessedTableManager get contaId {
    final $_column = $_itemColumn<int>('conta_id')!;

    final manager = $$ContasTableTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceitasRecorrentesTableFilterComposer
    extends Composer<_$AppDatabase, $ReceitasRecorrentesTable> {
  $$ReceitasRecorrentesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorPrevisto => $composableBuilder(
    column: $table.valorPrevisto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaPrevisto => $composableBuilder(
    column: $table.diaPrevisto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dataInicio =>
      $composableBuilder(
        column: $table.dataInicio,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableFilterComposer get contaId {
    final $$ContasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceitasRecorrentesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceitasRecorrentesTable> {
  $$ReceitasRecorrentesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorPrevisto => $composableBuilder(
    column: $table.valorPrevisto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaPrevisto => $composableBuilder(
    column: $table.diaPrevisto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataInicio => $composableBuilder(
    column: $table.dataInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableOrderingComposer get contaId {
    final $$ContasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceitasRecorrentesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceitasRecorrentesTable> {
  $$ReceitasRecorrentesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<int> get valorPrevisto => $composableBuilder(
    column: $table.valorPrevisto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaPrevisto => $composableBuilder(
    column: $table.diaPrevisto,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get dataInicio =>
      $composableBuilder(
        column: $table.dataInicio,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContasTableAnnotationComposer get contaId {
    final $$ContasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceitasRecorrentesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceitasRecorrentesTable,
          ReceitaRecorrente,
          $$ReceitasRecorrentesTableFilterComposer,
          $$ReceitasRecorrentesTableOrderingComposer,
          $$ReceitasRecorrentesTableAnnotationComposer,
          $$ReceitasRecorrentesTableCreateCompanionBuilder,
          $$ReceitasRecorrentesTableUpdateCompanionBuilder,
          (ReceitaRecorrente, $$ReceitasRecorrentesTableReferences),
          ReceitaRecorrente,
          PrefetchHooks Function({bool categoriaId, bool contaId})
        > {
  $$ReceitasRecorrentesTableTableManager(
    _$AppDatabase db,
    $ReceitasRecorrentesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceitasRecorrentesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceitasRecorrentesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReceitasRecorrentesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<int> contaId = const Value.absent(),
                Value<int> valorPrevisto = const Value.absent(),
                Value<int> diaPrevisto = const Value.absent(),
                Value<DateTime> dataInicio = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => ReceitasRecorrentesCompanion(
                id: id,
                descricao: descricao,
                categoriaId: categoriaId,
                contaId: contaId,
                valorPrevisto: valorPrevisto,
                diaPrevisto: diaPrevisto,
                dataInicio: dataInicio,
                ativa: ativa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String descricao,
                Value<int?> categoriaId = const Value.absent(),
                required int contaId,
                required int valorPrevisto,
                required int diaPrevisto,
                required DateTime dataInicio,
                Value<bool> ativa = const Value.absent(),
              }) => ReceitasRecorrentesCompanion.insert(
                id: id,
                descricao: descricao,
                categoriaId: categoriaId,
                contaId: contaId,
                valorPrevisto: valorPrevisto,
                diaPrevisto: diaPrevisto,
                dataInicio: dataInicio,
                ativa: ativa,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReceitasRecorrentesTable, ReceitaRecorrente>(
                    table,
                  ),
                  $$ReceitasRecorrentesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoriaId = false, contaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoriaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoriaId,
                        referencedTable: $$ReceitasRecorrentesTableReferences
                            ._categoriaIdTable(db),
                        referencedColumn: $$ReceitasRecorrentesTableReferences
                            ._categoriaIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (contaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.contaId,
                        referencedTable: $$ReceitasRecorrentesTableReferences
                            ._contaIdTable(db),
                        referencedColumn: $$ReceitasRecorrentesTableReferences
                            ._contaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReceitasRecorrentesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceitasRecorrentesTable,
      ReceitaRecorrente,
      $$ReceitasRecorrentesTableFilterComposer,
      $$ReceitasRecorrentesTableOrderingComposer,
      $$ReceitasRecorrentesTableAnnotationComposer,
      $$ReceitasRecorrentesTableCreateCompanionBuilder,
      $$ReceitasRecorrentesTableUpdateCompanionBuilder,
      (ReceitaRecorrente, $$ReceitasRecorrentesTableReferences),
      ReceitaRecorrente,
      PrefetchHooks Function({bool categoriaId, bool contaId})
    >;
typedef $$MovimentosInvestimentoTableCreateCompanionBuilder =
    MovimentosInvestimentoCompanion Function({
      Value<int> id,
      required int investimentoId,
      required TipoMovimentoInvestimento tipo,
      required int valor,
      required DateTime data,
      Value<int?> lancamentoId,
    });
typedef $$MovimentosInvestimentoTableUpdateCompanionBuilder =
    MovimentosInvestimentoCompanion Function({
      Value<int> id,
      Value<int> investimentoId,
      Value<TipoMovimentoInvestimento> tipo,
      Value<int> valor,
      Value<DateTime> data,
      Value<int?> lancamentoId,
    });

final class $$MovimentosInvestimentoTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MovimentosInvestimentoTable,
          MovimentoInvestimento
        > {
  $$MovimentosInvestimentoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InvestimentosTable _investimentoIdTable(_$AppDatabase db) =>
      db.investimentos.createAlias(
        'movimentos_investimento__investimento_id__investimentos__id',
      );

  $$InvestimentosTableProcessedTableManager get investimentoId {
    final $_column = $_itemColumn<int>('investimento_id')!;

    final manager = $$InvestimentosTableTableManager(
      $_db,
      $_db.investimentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investimentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovimentosInvestimentoTableFilterComposer
    extends Composer<_$AppDatabase, $MovimentosInvestimentoTable> {
  $$MovimentosInvestimentoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TipoMovimentoInvestimento,
    TipoMovimentoInvestimento,
    String
  >
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get data =>
      $composableBuilder(
        column: $table.data,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get lancamentoId => $composableBuilder(
    column: $table.lancamentoId,
    builder: (column) => ColumnFilters(column),
  );

  $$InvestimentosTableFilterComposer get investimentoId {
    final $$InvestimentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableFilterComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimentosInvestimentoTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimentosInvestimentoTable> {
  $$MovimentosInvestimentoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lancamentoId => $composableBuilder(
    column: $table.lancamentoId,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvestimentosTableOrderingComposer get investimentoId {
    final $$InvestimentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableOrderingComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimentosInvestimentoTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimentosInvestimentoTable> {
  $$MovimentosInvestimentoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoMovimentoInvestimento, String>
  get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get lancamentoId => $composableBuilder(
    column: $table.lancamentoId,
    builder: (column) => column,
  );

  $$InvestimentosTableAnnotationComposer get investimentoId {
    final $$InvestimentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableAnnotationComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimentosInvestimentoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovimentosInvestimentoTable,
          MovimentoInvestimento,
          $$MovimentosInvestimentoTableFilterComposer,
          $$MovimentosInvestimentoTableOrderingComposer,
          $$MovimentosInvestimentoTableAnnotationComposer,
          $$MovimentosInvestimentoTableCreateCompanionBuilder,
          $$MovimentosInvestimentoTableUpdateCompanionBuilder,
          (MovimentoInvestimento, $$MovimentosInvestimentoTableReferences),
          MovimentoInvestimento,
          PrefetchHooks Function({bool investimentoId})
        > {
  $$MovimentosInvestimentoTableTableManager(
    _$AppDatabase db,
    $MovimentosInvestimentoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimentosInvestimentoTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MovimentosInvestimentoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MovimentosInvestimentoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> investimentoId = const Value.absent(),
                Value<TipoMovimentoInvestimento> tipo = const Value.absent(),
                Value<int> valor = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int?> lancamentoId = const Value.absent(),
              }) => MovimentosInvestimentoCompanion(
                id: id,
                investimentoId: investimentoId,
                tipo: tipo,
                valor: valor,
                data: data,
                lancamentoId: lancamentoId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int investimentoId,
                required TipoMovimentoInvestimento tipo,
                required int valor,
                required DateTime data,
                Value<int?> lancamentoId = const Value.absent(),
              }) => MovimentosInvestimentoCompanion.insert(
                id: id,
                investimentoId: investimentoId,
                tipo: tipo,
                valor: valor,
                data: data,
                lancamentoId: lancamentoId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $MovimentosInvestimentoTable,
                    MovimentoInvestimento
                  >(table),
                  $$MovimentosInvestimentoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({investimentoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (investimentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.investimentoId,
                        referencedTable: $$MovimentosInvestimentoTableReferences
                            ._investimentoIdTable(db),
                        referencedColumn:
                            $$MovimentosInvestimentoTableReferences
                                ._investimentoIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MovimentosInvestimentoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovimentosInvestimentoTable,
      MovimentoInvestimento,
      $$MovimentosInvestimentoTableFilterComposer,
      $$MovimentosInvestimentoTableOrderingComposer,
      $$MovimentosInvestimentoTableAnnotationComposer,
      $$MovimentosInvestimentoTableCreateCompanionBuilder,
      $$MovimentosInvestimentoTableUpdateCompanionBuilder,
      (MovimentoInvestimento, $$MovimentosInvestimentoTableReferences),
      MovimentoInvestimento,
      PrefetchHooks Function({bool investimentoId})
    >;
typedef $$MetasTableCreateCompanionBuilder = MetasCompanion Function({
  Value<int> id,
  required String nome,
  required int valorAlvo,
  required DateTime prazo,
  Value<int?> investimentoId,
  Value<bool> ativa,
});
typedef $$MetasTableUpdateCompanionBuilder = MetasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> valorAlvo,
  Value<DateTime> prazo,
  Value<int?> investimentoId,
  Value<bool> ativa,
});

final class $$MetasTableReferences
    extends BaseReferences<_$AppDatabase, $MetasTable, Meta> {
  $$MetasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvestimentosTable _investimentoIdTable(_$AppDatabase db) =>
      db.investimentos.createAlias('metas__investimento_id__investimentos__id');

  $$InvestimentosTableProcessedTableManager? get investimentoId {
    final $_column = $_itemColumn<int>('investimento_id');
    if ($_column == null) return null;
    final manager = $$InvestimentosTableTableManager(
      $_db,
      $_db.investimentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investimentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MetasTableFilterComposer extends Composer<_$AppDatabase, $MetasTable> {
  $$MetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorAlvo => $composableBuilder(
    column: $table.valorAlvo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get prazo =>
      $composableBuilder(
        column: $table.prazo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  $$InvestimentosTableFilterComposer get investimentoId {
    final $$InvestimentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableFilterComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MetasTableOrderingComposer
    extends Composer<_$AppDatabase, $MetasTable> {
  $$MetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorAlvo => $composableBuilder(
    column: $table.valorAlvo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prazo => $composableBuilder(
    column: $table.prazo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvestimentosTableOrderingComposer get investimentoId {
    final $$InvestimentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableOrderingComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetasTable> {
  $$MetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get valorAlvo =>
      $composableBuilder(column: $table.valorAlvo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get prazo =>
      $composableBuilder(column: $table.prazo, builder: (column) => column);

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  $$InvestimentosTableAnnotationComposer get investimentoId {
    final $$InvestimentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investimentoId,
      referencedTable: $db.investimentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestimentosTableAnnotationComposer(
            $db: $db,
            $table: $db.investimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MetasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetasTable,
          Meta,
          $$MetasTableFilterComposer,
          $$MetasTableOrderingComposer,
          $$MetasTableAnnotationComposer,
          $$MetasTableCreateCompanionBuilder,
          $$MetasTableUpdateCompanionBuilder,
          (Meta, $$MetasTableReferences),
          Meta,
          PrefetchHooks Function({bool investimentoId})
        > {
  $$MetasTableTableManager(_$AppDatabase db, $MetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> valorAlvo = const Value.absent(),
                Value<DateTime> prazo = const Value.absent(),
                Value<int?> investimentoId = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => MetasCompanion(
                id: id,
                nome: nome,
                valorAlvo: valorAlvo,
                prazo: prazo,
                investimentoId: investimentoId,
                ativa: ativa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required int valorAlvo,
                required DateTime prazo,
                Value<int?> investimentoId = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => MetasCompanion.insert(
                id: id,
                nome: nome,
                valorAlvo: valorAlvo,
                prazo: prazo,
                investimentoId: investimentoId,
                ativa: ativa,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetasTable, Meta>(table),
                  $$MetasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({investimentoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (investimentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.investimentoId,
                        referencedTable: $$MetasTableReferences
                            ._investimentoIdTable(db),
                        referencedColumn: $$MetasTableReferences
                            ._investimentoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MetasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetasTable,
      Meta,
      $$MetasTableFilterComposer,
      $$MetasTableOrderingComposer,
      $$MetasTableAnnotationComposer,
      $$MetasTableCreateCompanionBuilder,
      $$MetasTableUpdateCompanionBuilder,
      (Meta, $$MetasTableReferences),
      Meta,
      PrefetchHooks Function({bool investimentoId})
    >;
typedef $$OrcamentosTableCreateCompanionBuilder = OrcamentosCompanion Function({
  Value<int> id,
  required int categoriaId,
  required String competencia,
  required int limite,
});
typedef $$OrcamentosTableUpdateCompanionBuilder = OrcamentosCompanion Function({
  Value<int> id,
  Value<int> categoriaId,
  Value<String> competencia,
  Value<int> limite,
});

final class $$OrcamentosTableReferences
    extends BaseReferences<_$AppDatabase, $OrcamentosTable, Orcamento> {
  $$OrcamentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('orcamentos__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id')!;

    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrcamentosTableFilterComposer
    extends Composer<_$AppDatabase, $OrcamentosTable> {
  $$OrcamentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limite => $composableBuilder(
    column: $table.limite,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentosTableOrderingComposer
    extends Composer<_$AppDatabase, $OrcamentosTable> {
  $$OrcamentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limite => $composableBuilder(
    column: $table.limite,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrcamentosTable> {
  $$OrcamentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limite =>
      $composableBuilder(column: $table.limite, builder: (column) => column);

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrcamentosTable,
          Orcamento,
          $$OrcamentosTableFilterComposer,
          $$OrcamentosTableOrderingComposer,
          $$OrcamentosTableAnnotationComposer,
          $$OrcamentosTableCreateCompanionBuilder,
          $$OrcamentosTableUpdateCompanionBuilder,
          (Orcamento, $$OrcamentosTableReferences),
          Orcamento,
          PrefetchHooks Function({bool categoriaId})
        > {
  $$OrcamentosTableTableManager(_$AppDatabase db, $OrcamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrcamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrcamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrcamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<String> competencia = const Value.absent(),
                Value<int> limite = const Value.absent(),
              }) => OrcamentosCompanion(
                id: id,
                categoriaId: categoriaId,
                competencia: competencia,
                limite: limite,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoriaId,
                required String competencia,
                required int limite,
              }) => OrcamentosCompanion.insert(
                id: id,
                categoriaId: categoriaId,
                competencia: competencia,
                limite: limite,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrcamentosTable, Orcamento>(table),
                  $$OrcamentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoriaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoriaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoriaId,
                        referencedTable: $$OrcamentosTableReferences
                            ._categoriaIdTable(db),
                        referencedColumn: $$OrcamentosTableReferences
                            ._categoriaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrcamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrcamentosTable,
      Orcamento,
      $$OrcamentosTableFilterComposer,
      $$OrcamentosTableOrderingComposer,
      $$OrcamentosTableAnnotationComposer,
      $$OrcamentosTableCreateCompanionBuilder,
      $$OrcamentosTableUpdateCompanionBuilder,
      (Orcamento, $$OrcamentosTableReferences),
      Orcamento,
      PrefetchHooks Function({bool categoriaId})
    >;
typedef $$RegrasCategorizacaoTableCreateCompanionBuilder =
    RegrasCategorizacaoCompanion Function({
      Value<int> id,
      required String padrao,
      required int categoriaId,
      Value<int> prioridade,
    });
typedef $$RegrasCategorizacaoTableUpdateCompanionBuilder =
    RegrasCategorizacaoCompanion Function({
      Value<int> id,
      Value<String> padrao,
      Value<int> categoriaId,
      Value<int> prioridade,
    });

final class $$RegrasCategorizacaoTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RegrasCategorizacaoTable,
          RegraCategorizacao
        > {
  $$RegrasCategorizacaoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) => db.categorias
      .createAlias('regras_categorizacao__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id')!;

    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RegrasCategorizacaoTableFilterComposer
    extends Composer<_$AppDatabase, $RegrasCategorizacaoTable> {
  $$RegrasCategorizacaoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get padrao => $composableBuilder(
    column: $table.padrao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prioridade => $composableBuilder(
    column: $table.prioridade,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegrasCategorizacaoTableOrderingComposer
    extends Composer<_$AppDatabase, $RegrasCategorizacaoTable> {
  $$RegrasCategorizacaoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get padrao => $composableBuilder(
    column: $table.padrao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prioridade => $composableBuilder(
    column: $table.prioridade,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegrasCategorizacaoTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegrasCategorizacaoTable> {
  $$RegrasCategorizacaoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get padrao =>
      $composableBuilder(column: $table.padrao, builder: (column) => column);

  GeneratedColumn<int> get prioridade => $composableBuilder(
    column: $table.prioridade,
    builder: (column) => column,
  );

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegrasCategorizacaoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RegrasCategorizacaoTable,
          RegraCategorizacao,
          $$RegrasCategorizacaoTableFilterComposer,
          $$RegrasCategorizacaoTableOrderingComposer,
          $$RegrasCategorizacaoTableAnnotationComposer,
          $$RegrasCategorizacaoTableCreateCompanionBuilder,
          $$RegrasCategorizacaoTableUpdateCompanionBuilder,
          (RegraCategorizacao, $$RegrasCategorizacaoTableReferences),
          RegraCategorizacao,
          PrefetchHooks Function({bool categoriaId})
        > {
  $$RegrasCategorizacaoTableTableManager(
    _$AppDatabase db,
    $RegrasCategorizacaoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegrasCategorizacaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegrasCategorizacaoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RegrasCategorizacaoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> padrao = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<int> prioridade = const Value.absent(),
              }) => RegrasCategorizacaoCompanion(
                id: id,
                padrao: padrao,
                categoriaId: categoriaId,
                prioridade: prioridade,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String padrao,
                required int categoriaId,
                Value<int> prioridade = const Value.absent(),
              }) => RegrasCategorizacaoCompanion.insert(
                id: id,
                padrao: padrao,
                categoriaId: categoriaId,
                prioridade: prioridade,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RegrasCategorizacaoTable, RegraCategorizacao>(
                    table,
                  ),
                  $$RegrasCategorizacaoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoriaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoriaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoriaId,
                        referencedTable: $$RegrasCategorizacaoTableReferences
                            ._categoriaIdTable(db),
                        referencedColumn: $$RegrasCategorizacaoTableReferences
                            ._categoriaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RegrasCategorizacaoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RegrasCategorizacaoTable,
      RegraCategorizacao,
      $$RegrasCategorizacaoTableFilterComposer,
      $$RegrasCategorizacaoTableOrderingComposer,
      $$RegrasCategorizacaoTableAnnotationComposer,
      $$RegrasCategorizacaoTableCreateCompanionBuilder,
      $$RegrasCategorizacaoTableUpdateCompanionBuilder,
      (RegraCategorizacao, $$RegrasCategorizacaoTableReferences),
      RegraCategorizacao,
      PrefetchHooks Function({bool categoriaId})
    >;
typedef $$ConfiguracoesTableCreateCompanionBuilder =
    ConfiguracoesCompanion Function({
      required String chave,
      required String valor,
      Value<int> rowid,
    });
typedef $$ConfiguracoesTableUpdateCompanionBuilder =
    ConfiguracoesCompanion Function({
      Value<String> chave,
      Value<String> valor,
      Value<int> rowid,
    });

class $$ConfiguracoesTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfiguracoesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfiguracoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$ConfiguracoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfiguracoesTable,
          Configuracao,
          $$ConfiguracoesTableFilterComposer,
          $$ConfiguracoesTableOrderingComposer,
          $$ConfiguracoesTableAnnotationComposer,
          $$ConfiguracoesTableCreateCompanionBuilder,
          $$ConfiguracoesTableUpdateCompanionBuilder,
          (
            Configuracao,
            BaseReferences<_$AppDatabase, $ConfiguracoesTable, Configuracao>,
          ),
          Configuracao,
          PrefetchHooks Function()
        > {
  $$ConfiguracoesTableTableManager(_$AppDatabase db, $ConfiguracoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chave = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracoesCompanion(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chave,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracoesCompanion.insert(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfiguracoesTable, Configuracao>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConfiguracoesTable,
                    Configuracao
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfiguracoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfiguracoesTable,
      Configuracao,
      $$ConfiguracoesTableFilterComposer,
      $$ConfiguracoesTableOrderingComposer,
      $$ConfiguracoesTableAnnotationComposer,
      $$ConfiguracoesTableCreateCompanionBuilder,
      $$ConfiguracoesTableUpdateCompanionBuilder,
      (
        Configuracao,
        BaseReferences<_$AppDatabase, $ConfiguracoesTable, Configuracao>,
      ),
      Configuracao,
      PrefetchHooks Function()
    >;
typedef $$MapeamentosCsvTableCreateCompanionBuilder =
    MapeamentosCsvCompanion Function({
      Value<int> id,
      required String nome,
      Value<String> separador,
      Value<bool> temCabecalho,
      required int colunaData,
      required int colunaDescricao,
      required int colunaValor,
      Value<int?> colunaTipo,
      Value<String> formatoData,
      Value<bool> positivoEhGasto,
    });
typedef $$MapeamentosCsvTableUpdateCompanionBuilder =
    MapeamentosCsvCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<String> separador,
      Value<bool> temCabecalho,
      Value<int> colunaData,
      Value<int> colunaDescricao,
      Value<int> colunaValor,
      Value<int?> colunaTipo,
      Value<String> formatoData,
      Value<bool> positivoEhGasto,
    });

class $$MapeamentosCsvTableFilterComposer
    extends Composer<_$AppDatabase, $MapeamentosCsvTable> {
  $$MapeamentosCsvTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get separador => $composableBuilder(
    column: $table.separador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get temCabecalho => $composableBuilder(
    column: $table.temCabecalho,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colunaData => $composableBuilder(
    column: $table.colunaData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colunaDescricao => $composableBuilder(
    column: $table.colunaDescricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colunaValor => $composableBuilder(
    column: $table.colunaValor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colunaTipo => $composableBuilder(
    column: $table.colunaTipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formatoData => $composableBuilder(
    column: $table.formatoData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get positivoEhGasto => $composableBuilder(
    column: $table.positivoEhGasto,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MapeamentosCsvTableOrderingComposer
    extends Composer<_$AppDatabase, $MapeamentosCsvTable> {
  $$MapeamentosCsvTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get separador => $composableBuilder(
    column: $table.separador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get temCabecalho => $composableBuilder(
    column: $table.temCabecalho,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colunaData => $composableBuilder(
    column: $table.colunaData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colunaDescricao => $composableBuilder(
    column: $table.colunaDescricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colunaValor => $composableBuilder(
    column: $table.colunaValor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colunaTipo => $composableBuilder(
    column: $table.colunaTipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formatoData => $composableBuilder(
    column: $table.formatoData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get positivoEhGasto => $composableBuilder(
    column: $table.positivoEhGasto,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MapeamentosCsvTableAnnotationComposer
    extends Composer<_$AppDatabase, $MapeamentosCsvTable> {
  $$MapeamentosCsvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get separador =>
      $composableBuilder(column: $table.separador, builder: (column) => column);

  GeneratedColumn<bool> get temCabecalho => $composableBuilder(
    column: $table.temCabecalho,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colunaData => $composableBuilder(
    column: $table.colunaData,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colunaDescricao => $composableBuilder(
    column: $table.colunaDescricao,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colunaValor => $composableBuilder(
    column: $table.colunaValor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colunaTipo => $composableBuilder(
    column: $table.colunaTipo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formatoData => $composableBuilder(
    column: $table.formatoData,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get positivoEhGasto => $composableBuilder(
    column: $table.positivoEhGasto,
    builder: (column) => column,
  );
}

class $$MapeamentosCsvTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MapeamentosCsvTable,
          MapeamentoCsvSalvo,
          $$MapeamentosCsvTableFilterComposer,
          $$MapeamentosCsvTableOrderingComposer,
          $$MapeamentosCsvTableAnnotationComposer,
          $$MapeamentosCsvTableCreateCompanionBuilder,
          $$MapeamentosCsvTableUpdateCompanionBuilder,
          (
            MapeamentoCsvSalvo,
            BaseReferences<
              _$AppDatabase,
              $MapeamentosCsvTable,
              MapeamentoCsvSalvo
            >,
          ),
          MapeamentoCsvSalvo,
          PrefetchHooks Function()
        > {
  $$MapeamentosCsvTableTableManager(
    _$AppDatabase db,
    $MapeamentosCsvTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MapeamentosCsvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MapeamentosCsvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MapeamentosCsvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> separador = const Value.absent(),
                Value<bool> temCabecalho = const Value.absent(),
                Value<int> colunaData = const Value.absent(),
                Value<int> colunaDescricao = const Value.absent(),
                Value<int> colunaValor = const Value.absent(),
                Value<int?> colunaTipo = const Value.absent(),
                Value<String> formatoData = const Value.absent(),
                Value<bool> positivoEhGasto = const Value.absent(),
              }) => MapeamentosCsvCompanion(
                id: id,
                nome: nome,
                separador: separador,
                temCabecalho: temCabecalho,
                colunaData: colunaData,
                colunaDescricao: colunaDescricao,
                colunaValor: colunaValor,
                colunaTipo: colunaTipo,
                formatoData: formatoData,
                positivoEhGasto: positivoEhGasto,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                Value<String> separador = const Value.absent(),
                Value<bool> temCabecalho = const Value.absent(),
                required int colunaData,
                required int colunaDescricao,
                required int colunaValor,
                Value<int?> colunaTipo = const Value.absent(),
                Value<String> formatoData = const Value.absent(),
                Value<bool> positivoEhGasto = const Value.absent(),
              }) => MapeamentosCsvCompanion.insert(
                id: id,
                nome: nome,
                separador: separador,
                temCabecalho: temCabecalho,
                colunaData: colunaData,
                colunaDescricao: colunaDescricao,
                colunaValor: colunaValor,
                colunaTipo: colunaTipo,
                formatoData: formatoData,
                positivoEhGasto: positivoEhGasto,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MapeamentosCsvTable, MapeamentoCsvSalvo>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MapeamentosCsvTable,
                    MapeamentoCsvSalvo
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MapeamentosCsvTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MapeamentosCsvTable,
      MapeamentoCsvSalvo,
      $$MapeamentosCsvTableFilterComposer,
      $$MapeamentosCsvTableOrderingComposer,
      $$MapeamentosCsvTableAnnotationComposer,
      $$MapeamentosCsvTableCreateCompanionBuilder,
      $$MapeamentosCsvTableUpdateCompanionBuilder,
      (
        MapeamentoCsvSalvo,
        BaseReferences<_$AppDatabase, $MapeamentosCsvTable, MapeamentoCsvSalvo>,
      ),
      MapeamentoCsvSalvo,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContasTableTableManager get contas =>
      $$ContasTableTableManager(_db, _db.contas);
  $$CartoesTableTableManager get cartoes =>
      $$CartoesTableTableManager(_db, _db.cartoes);
  $$FaturasTableTableManager get faturas =>
      $$FaturasTableTableManager(_db, _db.faturas);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$ComprasParceladasTableTableManager get comprasParceladas =>
      $$ComprasParceladasTableTableManager(_db, _db.comprasParceladas);
  $$InvestimentosTableTableManager get investimentos =>
      $$InvestimentosTableTableManager(_db, _db.investimentos);
  $$LancamentosTableTableManager get lancamentos =>
      $$LancamentosTableTableManager(_db, _db.lancamentos);
  $$CompromissosTableTableManager get compromissos =>
      $$CompromissosTableTableManager(_db, _db.compromissos);
  $$OcorrenciasCompromissoTableTableManager get ocorrenciasCompromisso =>
      $$OcorrenciasCompromissoTableTableManager(
        _db,
        _db.ocorrenciasCompromisso,
      );
  $$ReceitasRecorrentesTableTableManager get receitasRecorrentes =>
      $$ReceitasRecorrentesTableTableManager(_db, _db.receitasRecorrentes);
  $$MovimentosInvestimentoTableTableManager get movimentosInvestimento =>
      $$MovimentosInvestimentoTableTableManager(
        _db,
        _db.movimentosInvestimento,
      );
  $$MetasTableTableManager get metas =>
      $$MetasTableTableManager(_db, _db.metas);
  $$OrcamentosTableTableManager get orcamentos =>
      $$OrcamentosTableTableManager(_db, _db.orcamentos);
  $$RegrasCategorizacaoTableTableManager get regrasCategorizacao =>
      $$RegrasCategorizacaoTableTableManager(_db, _db.regrasCategorizacao);
  $$ConfiguracoesTableTableManager get configuracoes =>
      $$ConfiguracoesTableTableManager(_db, _db.configuracoes);
  $$MapeamentosCsvTableTableManager get mapeamentosCsv =>
      $$MapeamentosCsvTableTableManager(_db, _db.mapeamentosCsv);
}
