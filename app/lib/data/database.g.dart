// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $KBoardsTable extends KBoards with TableInfo<$KBoardsTable, KBoard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KBoardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tidyDaysMeta = const VerificationMeta(
    'tidyDays',
  );
  @override
  late final GeneratedColumn<int> tidyDays = GeneratedColumn<int>(
    'tidy_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allAccessMeta = const VerificationMeta(
    'allAccess',
  );
  @override
  late final GeneratedColumn<bool> allAccess = GeneratedColumn<bool>(
    'all_access',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("all_access" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>(
    'creator_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _membersMeta = const VerificationMeta(
    'members',
  );
  @override
  late final GeneratedColumn<String> members = GeneratedColumn<String>(
    'members',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _canManageMeta = const VerificationMeta(
    'canManage',
  );
  @override
  late final GeneratedColumn<bool> canManage = GeneratedColumn<bool>(
    'can_manage',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_manage" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    tidyDays,
    allAccess,
    creatorId,
    members,
    canManage,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_boards';
  @override
  VerificationContext validateIntegrity(
    Insertable<KBoard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tidy_days')) {
      context.handle(
        _tidyDaysMeta,
        tidyDays.isAcceptableOrUnknown(data['tidy_days']!, _tidyDaysMeta),
      );
    }
    if (data.containsKey('all_access')) {
      context.handle(
        _allAccessMeta,
        allAccess.isAcceptableOrUnknown(data['all_access']!, _allAccessMeta),
      );
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    }
    if (data.containsKey('members')) {
      context.handle(
        _membersMeta,
        members.isAcceptableOrUnknown(data['members']!, _membersMeta),
      );
    }
    if (data.containsKey('can_manage')) {
      context.handle(
        _canManageMeta,
        canManage.isAcceptableOrUnknown(data['can_manage']!, _canManageMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KBoard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KBoard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      tidyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tidy_days'],
      ),
      allAccess: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}all_access'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creator_id'],
      ),
      members: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}members'],
      )!,
      canManage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KBoardsTable createAlias(String alias) {
    return $KBoardsTable(attachedDatabase, alias);
  }
}

class KBoard extends DataClass implements Insertable<KBoard> {
  final String id;
  final String name;
  final int? tidyDays;
  final bool allAccess;
  final int? creatorId;
  final String members;
  final bool canManage;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const KBoard({
    required this.id,
    required this.name,
    this.tidyDays,
    required this.allAccess,
    this.creatorId,
    required this.members,
    required this.canManage,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || tidyDays != null) {
      map['tidy_days'] = Variable<int>(tidyDays);
    }
    map['all_access'] = Variable<bool>(allAccess);
    if (!nullToAbsent || creatorId != null) {
      map['creator_id'] = Variable<int>(creatorId);
    }
    map['members'] = Variable<String>(members);
    map['can_manage'] = Variable<bool>(canManage);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KBoardsCompanion toCompanion(bool nullToAbsent) {
    return KBoardsCompanion(
      id: Value(id),
      name: Value(name),
      tidyDays: tidyDays == null && nullToAbsent
          ? const Value.absent()
          : Value(tidyDays),
      allAccess: Value(allAccess),
      creatorId: creatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(creatorId),
      members: Value(members),
      canManage: Value(canManage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KBoard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KBoard(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tidyDays: serializer.fromJson<int?>(json['tidyDays']),
      allAccess: serializer.fromJson<bool>(json['allAccess']),
      creatorId: serializer.fromJson<int?>(json['creatorId']),
      members: serializer.fromJson<String>(json['members']),
      canManage: serializer.fromJson<bool>(json['canManage']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'tidyDays': serializer.toJson<int?>(tidyDays),
      'allAccess': serializer.toJson<bool>(allAccess),
      'creatorId': serializer.toJson<int?>(creatorId),
      'members': serializer.toJson<String>(members),
      'canManage': serializer.toJson<bool>(canManage),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KBoard copyWith({
    String? id,
    String? name,
    Value<int?> tidyDays = const Value.absent(),
    bool? allAccess,
    Value<int?> creatorId = const Value.absent(),
    String? members,
    bool? canManage,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KBoard(
    id: id ?? this.id,
    name: name ?? this.name,
    tidyDays: tidyDays.present ? tidyDays.value : this.tidyDays,
    allAccess: allAccess ?? this.allAccess,
    creatorId: creatorId.present ? creatorId.value : this.creatorId,
    members: members ?? this.members,
    canManage: canManage ?? this.canManage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KBoard copyWithCompanion(KBoardsCompanion data) {
    return KBoard(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      tidyDays: data.tidyDays.present ? data.tidyDays.value : this.tidyDays,
      allAccess: data.allAccess.present ? data.allAccess.value : this.allAccess,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      members: data.members.present ? data.members.value : this.members,
      canManage: data.canManage.present ? data.canManage.value : this.canManage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KBoard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tidyDays: $tidyDays, ')
          ..write('allAccess: $allAccess, ')
          ..write('creatorId: $creatorId, ')
          ..write('members: $members, ')
          ..write('canManage: $canManage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    tidyDays,
    allAccess,
    creatorId,
    members,
    canManage,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KBoard &&
          other.id == this.id &&
          other.name == this.name &&
          other.tidyDays == this.tidyDays &&
          other.allAccess == this.allAccess &&
          other.creatorId == this.creatorId &&
          other.members == this.members &&
          other.canManage == this.canManage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class KBoardsCompanion extends UpdateCompanion<KBoard> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> tidyDays;
  final Value<bool> allAccess;
  final Value<int?> creatorId;
  final Value<String> members;
  final Value<bool> canManage;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KBoardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tidyDays = const Value.absent(),
    this.allAccess = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.members = const Value.absent(),
    this.canManage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KBoardsCompanion.insert({
    required String id,
    required String name,
    this.tidyDays = const Value.absent(),
    this.allAccess = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.members = const Value.absent(),
    this.canManage = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<KBoard> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? tidyDays,
    Expression<bool>? allAccess,
    Expression<int>? creatorId,
    Expression<String>? members,
    Expression<bool>? canManage,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tidyDays != null) 'tidy_days': tidyDays,
      if (allAccess != null) 'all_access': allAccess,
      if (creatorId != null) 'creator_id': creatorId,
      if (members != null) 'members': members,
      if (canManage != null) 'can_manage': canManage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KBoardsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int?>? tidyDays,
    Value<bool>? allAccess,
    Value<int?>? creatorId,
    Value<String>? members,
    Value<bool>? canManage,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KBoardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tidyDays: tidyDays ?? this.tidyDays,
      allAccess: allAccess ?? this.allAccess,
      creatorId: creatorId ?? this.creatorId,
      members: members ?? this.members,
      canManage: canManage ?? this.canManage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tidyDays.present) {
      map['tidy_days'] = Variable<int>(tidyDays.value);
    }
    if (allAccess.present) {
      map['all_access'] = Variable<bool>(allAccess.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<int>(creatorId.value);
    }
    if (members.present) {
      map['members'] = Variable<String>(members.value);
    }
    if (canManage.present) {
      map['can_manage'] = Variable<bool>(canManage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KBoardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tidyDays: $tidyDays, ')
          ..write('allAccess: $allAccess, ')
          ..write('creatorId: $creatorId, ')
          ..write('members: $members, ')
          ..write('canManage: $canManage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KColumnsTable extends KColumns with TableInfo<$KColumnsTable, KColumn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KColumnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    boardId,
    name,
    color,
    position,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_columns';
  @override
  VerificationContext validateIntegrity(
    Insertable<KColumn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KColumn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KColumn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KColumnsTable createAlias(String alias) {
    return $KColumnsTable(attachedDatabase, alias);
  }
}

class KColumn extends DataClass implements Insertable<KColumn> {
  final String id;
  final String boardId;
  final String name;
  final int color;
  final double position;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const KColumn({
    required this.id,
    required this.boardId,
    required this.name,
    required this.color,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['board_id'] = Variable<String>(boardId);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['position'] = Variable<double>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KColumnsCompanion toCompanion(bool nullToAbsent) {
    return KColumnsCompanion(
      id: Value(id),
      boardId: Value(boardId),
      name: Value(name),
      color: Value(color),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KColumn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KColumn(
      id: serializer.fromJson<String>(json['id']),
      boardId: serializer.fromJson<String>(json['boardId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      position: serializer.fromJson<double>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'boardId': serializer.toJson<String>(boardId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'position': serializer.toJson<double>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KColumn copyWith({
    String? id,
    String? boardId,
    String? name,
    int? color,
    double? position,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KColumn(
    id: id ?? this.id,
    boardId: boardId ?? this.boardId,
    name: name ?? this.name,
    color: color ?? this.color,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KColumn copyWithCompanion(KColumnsCompanion data) {
    return KColumn(
      id: data.id.present ? data.id.value : this.id,
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KColumn(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    boardId,
    name,
    color,
    position,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KColumn &&
          other.id == this.id &&
          other.boardId == this.boardId &&
          other.name == this.name &&
          other.color == this.color &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class KColumnsCompanion extends UpdateCompanion<KColumn> {
  final Value<String> id;
  final Value<String> boardId;
  final Value<String> name;
  final Value<int> color;
  final Value<double> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KColumnsCompanion({
    this.id = const Value.absent(),
    this.boardId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KColumnsCompanion.insert({
    required String id,
    required String boardId,
    required String name,
    this.color = const Value.absent(),
    required double position,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       boardId = Value(boardId),
       name = Value(name),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<KColumn> custom({
    Expression<String>? id,
    Expression<String>? boardId,
    Expression<String>? name,
    Expression<int>? color,
    Expression<double>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boardId != null) 'board_id': boardId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KColumnsCompanion copyWith({
    Value<String>? id,
    Value<String>? boardId,
    Value<String>? name,
    Value<int>? color,
    Value<double>? position,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KColumnsCompanion(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      name: name ?? this.name,
      color: color ?? this.color,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KColumnsCompanion(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KCardsTable extends KCards with TableInfo<$KCardsTable, KCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _columnIdMeta = const VerificationMeta(
    'columnId',
  );
  @override
  late final GeneratedColumn<String> columnId = GeneratedColumn<String>(
    'column_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<int> closedAt = GeneratedColumn<int>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _laterAtMeta = const VerificationMeta(
    'laterAt',
  );
  @override
  late final GeneratedColumn<int> laterAt = GeneratedColumn<int>(
    'later_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _laterReasonMeta = const VerificationMeta(
    'laterReason',
  );
  @override
  late final GeneratedColumn<String> laterReason = GeneratedColumn<String>(
    'later_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityAtMeta = const VerificationMeta(
    'priorityAt',
  );
  @override
  late final GeneratedColumn<int> priorityAt = GeneratedColumn<int>(
    'priority_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueHasTimeMeta = const VerificationMeta(
    'dueHasTime',
  );
  @override
  late final GeneratedColumn<bool> dueHasTime = GeneratedColumn<bool>(
    'due_has_time',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("due_has_time" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta(
    'lastActiveAt',
  );
  @override
  late final GeneratedColumn<int> lastActiveAt = GeneratedColumn<int>(
    'last_active_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>(
    'creator_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('published'),
  );
  static const VerificationMeta _coverIdMeta = const VerificationMeta(
    'coverId',
  );
  @override
  late final GeneratedColumn<String> coverId = GeneratedColumn<String>(
    'cover_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    boardId,
    number,
    title,
    description,
    columnId,
    closedAt,
    laterAt,
    laterReason,
    priorityAt,
    dueAt,
    dueHasTime,
    lastActiveAt,
    rev,
    synced,
    creatorId,
    status,
    coverId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<KCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('column_id')) {
      context.handle(
        _columnIdMeta,
        columnId.isAcceptableOrUnknown(data['column_id']!, _columnIdMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('later_at')) {
      context.handle(
        _laterAtMeta,
        laterAt.isAcceptableOrUnknown(data['later_at']!, _laterAtMeta),
      );
    }
    if (data.containsKey('later_reason')) {
      context.handle(
        _laterReasonMeta,
        laterReason.isAcceptableOrUnknown(
          data['later_reason']!,
          _laterReasonMeta,
        ),
      );
    }
    if (data.containsKey('priority_at')) {
      context.handle(
        _priorityAtMeta,
        priorityAt.isAcceptableOrUnknown(data['priority_at']!, _priorityAtMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('due_has_time')) {
      context.handle(
        _dueHasTimeMeta,
        dueHasTime.isAcceptableOrUnknown(
          data['due_has_time']!,
          _dueHasTimeMeta,
        ),
      );
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
        _lastActiveAtMeta,
        lastActiveAt.isAcceptableOrUnknown(
          data['last_active_at']!,
          _lastActiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActiveAtMeta);
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('cover_id')) {
      context.handle(
        _coverIdMeta,
        coverId.isAcceptableOrUnknown(data['cover_id']!, _coverIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      columnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}column_id'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_at'],
      ),
      laterAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}later_at'],
      ),
      laterReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}later_reason'],
      ),
      priorityAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority_at'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      dueHasTime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}due_has_time'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_active_at'],
      )!,
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creator_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      coverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KCardsTable createAlias(String alias) {
    return $KCardsTable(attachedDatabase, alias);
  }
}

class KCard extends DataClass implements Insertable<KCard> {
  final String id;
  final String boardId;
  final int number;
  final String title;
  final String description;
  final String? columnId;
  final int? closedAt;
  final int? laterAt;
  final String? laterReason;
  final int? priorityAt;
  final int? dueAt;
  final bool dueHasTime;
  final int lastActiveAt;
  final int rev;
  final bool synced;
  final int? creatorId;
  final String status;
  final String? coverId;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const KCard({
    required this.id,
    required this.boardId,
    required this.number,
    required this.title,
    required this.description,
    this.columnId,
    this.closedAt,
    this.laterAt,
    this.laterReason,
    this.priorityAt,
    this.dueAt,
    required this.dueHasTime,
    required this.lastActiveAt,
    required this.rev,
    required this.synced,
    this.creatorId,
    required this.status,
    this.coverId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['board_id'] = Variable<String>(boardId);
    map['number'] = Variable<int>(number);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || columnId != null) {
      map['column_id'] = Variable<String>(columnId);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<int>(closedAt);
    }
    if (!nullToAbsent || laterAt != null) {
      map['later_at'] = Variable<int>(laterAt);
    }
    if (!nullToAbsent || laterReason != null) {
      map['later_reason'] = Variable<String>(laterReason);
    }
    if (!nullToAbsent || priorityAt != null) {
      map['priority_at'] = Variable<int>(priorityAt);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['due_has_time'] = Variable<bool>(dueHasTime);
    map['last_active_at'] = Variable<int>(lastActiveAt);
    map['rev'] = Variable<int>(rev);
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || creatorId != null) {
      map['creator_id'] = Variable<int>(creatorId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || coverId != null) {
      map['cover_id'] = Variable<String>(coverId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KCardsCompanion toCompanion(bool nullToAbsent) {
    return KCardsCompanion(
      id: Value(id),
      boardId: Value(boardId),
      number: Value(number),
      title: Value(title),
      description: Value(description),
      columnId: columnId == null && nullToAbsent
          ? const Value.absent()
          : Value(columnId),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      laterAt: laterAt == null && nullToAbsent
          ? const Value.absent()
          : Value(laterAt),
      laterReason: laterReason == null && nullToAbsent
          ? const Value.absent()
          : Value(laterReason),
      priorityAt: priorityAt == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityAt),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      dueHasTime: Value(dueHasTime),
      lastActiveAt: Value(lastActiveAt),
      rev: Value(rev),
      synced: Value(synced),
      creatorId: creatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(creatorId),
      status: Value(status),
      coverId: coverId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KCard(
      id: serializer.fromJson<String>(json['id']),
      boardId: serializer.fromJson<String>(json['boardId']),
      number: serializer.fromJson<int>(json['number']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      columnId: serializer.fromJson<String?>(json['columnId']),
      closedAt: serializer.fromJson<int?>(json['closedAt']),
      laterAt: serializer.fromJson<int?>(json['laterAt']),
      laterReason: serializer.fromJson<String?>(json['laterReason']),
      priorityAt: serializer.fromJson<int?>(json['priorityAt']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      dueHasTime: serializer.fromJson<bool>(json['dueHasTime']),
      lastActiveAt: serializer.fromJson<int>(json['lastActiveAt']),
      rev: serializer.fromJson<int>(json['rev']),
      synced: serializer.fromJson<bool>(json['synced']),
      creatorId: serializer.fromJson<int?>(json['creatorId']),
      status: serializer.fromJson<String>(json['status']),
      coverId: serializer.fromJson<String?>(json['coverId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'boardId': serializer.toJson<String>(boardId),
      'number': serializer.toJson<int>(number),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'columnId': serializer.toJson<String?>(columnId),
      'closedAt': serializer.toJson<int?>(closedAt),
      'laterAt': serializer.toJson<int?>(laterAt),
      'laterReason': serializer.toJson<String?>(laterReason),
      'priorityAt': serializer.toJson<int?>(priorityAt),
      'dueAt': serializer.toJson<int?>(dueAt),
      'dueHasTime': serializer.toJson<bool>(dueHasTime),
      'lastActiveAt': serializer.toJson<int>(lastActiveAt),
      'rev': serializer.toJson<int>(rev),
      'synced': serializer.toJson<bool>(synced),
      'creatorId': serializer.toJson<int?>(creatorId),
      'status': serializer.toJson<String>(status),
      'coverId': serializer.toJson<String?>(coverId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KCard copyWith({
    String? id,
    String? boardId,
    int? number,
    String? title,
    String? description,
    Value<String?> columnId = const Value.absent(),
    Value<int?> closedAt = const Value.absent(),
    Value<int?> laterAt = const Value.absent(),
    Value<String?> laterReason = const Value.absent(),
    Value<int?> priorityAt = const Value.absent(),
    Value<int?> dueAt = const Value.absent(),
    bool? dueHasTime,
    int? lastActiveAt,
    int? rev,
    bool? synced,
    Value<int?> creatorId = const Value.absent(),
    String? status,
    Value<String?> coverId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KCard(
    id: id ?? this.id,
    boardId: boardId ?? this.boardId,
    number: number ?? this.number,
    title: title ?? this.title,
    description: description ?? this.description,
    columnId: columnId.present ? columnId.value : this.columnId,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    laterAt: laterAt.present ? laterAt.value : this.laterAt,
    laterReason: laterReason.present ? laterReason.value : this.laterReason,
    priorityAt: priorityAt.present ? priorityAt.value : this.priorityAt,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    dueHasTime: dueHasTime ?? this.dueHasTime,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    rev: rev ?? this.rev,
    synced: synced ?? this.synced,
    creatorId: creatorId.present ? creatorId.value : this.creatorId,
    status: status ?? this.status,
    coverId: coverId.present ? coverId.value : this.coverId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KCard copyWithCompanion(KCardsCompanion data) {
    return KCard(
      id: data.id.present ? data.id.value : this.id,
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      number: data.number.present ? data.number.value : this.number,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      columnId: data.columnId.present ? data.columnId.value : this.columnId,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      laterAt: data.laterAt.present ? data.laterAt.value : this.laterAt,
      laterReason: data.laterReason.present
          ? data.laterReason.value
          : this.laterReason,
      priorityAt: data.priorityAt.present
          ? data.priorityAt.value
          : this.priorityAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      dueHasTime: data.dueHasTime.present
          ? data.dueHasTime.value
          : this.dueHasTime,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      synced: data.synced.present ? data.synced.value : this.synced,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      status: data.status.present ? data.status.value : this.status,
      coverId: data.coverId.present ? data.coverId.value : this.coverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KCard(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('columnId: $columnId, ')
          ..write('closedAt: $closedAt, ')
          ..write('laterAt: $laterAt, ')
          ..write('laterReason: $laterReason, ')
          ..write('priorityAt: $priorityAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('dueHasTime: $dueHasTime, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('rev: $rev, ')
          ..write('synced: $synced, ')
          ..write('creatorId: $creatorId, ')
          ..write('status: $status, ')
          ..write('coverId: $coverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    boardId,
    number,
    title,
    description,
    columnId,
    closedAt,
    laterAt,
    laterReason,
    priorityAt,
    dueAt,
    dueHasTime,
    lastActiveAt,
    rev,
    synced,
    creatorId,
    status,
    coverId,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KCard &&
          other.id == this.id &&
          other.boardId == this.boardId &&
          other.number == this.number &&
          other.title == this.title &&
          other.description == this.description &&
          other.columnId == this.columnId &&
          other.closedAt == this.closedAt &&
          other.laterAt == this.laterAt &&
          other.laterReason == this.laterReason &&
          other.priorityAt == this.priorityAt &&
          other.dueAt == this.dueAt &&
          other.dueHasTime == this.dueHasTime &&
          other.lastActiveAt == this.lastActiveAt &&
          other.rev == this.rev &&
          other.synced == this.synced &&
          other.creatorId == this.creatorId &&
          other.status == this.status &&
          other.coverId == this.coverId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class KCardsCompanion extends UpdateCompanion<KCard> {
  final Value<String> id;
  final Value<String> boardId;
  final Value<int> number;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> columnId;
  final Value<int?> closedAt;
  final Value<int?> laterAt;
  final Value<String?> laterReason;
  final Value<int?> priorityAt;
  final Value<int?> dueAt;
  final Value<bool> dueHasTime;
  final Value<int> lastActiveAt;
  final Value<int> rev;
  final Value<bool> synced;
  final Value<int?> creatorId;
  final Value<String> status;
  final Value<String?> coverId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KCardsCompanion({
    this.id = const Value.absent(),
    this.boardId = const Value.absent(),
    this.number = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.columnId = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.laterAt = const Value.absent(),
    this.laterReason = const Value.absent(),
    this.priorityAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.dueHasTime = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.synced = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.status = const Value.absent(),
    this.coverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KCardsCompanion.insert({
    required String id,
    required String boardId,
    required int number,
    required String title,
    this.description = const Value.absent(),
    this.columnId = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.laterAt = const Value.absent(),
    this.laterReason = const Value.absent(),
    this.priorityAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.dueHasTime = const Value.absent(),
    required int lastActiveAt,
    this.rev = const Value.absent(),
    this.synced = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.status = const Value.absent(),
    this.coverId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       boardId = Value(boardId),
       number = Value(number),
       title = Value(title),
       lastActiveAt = Value(lastActiveAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<KCard> custom({
    Expression<String>? id,
    Expression<String>? boardId,
    Expression<int>? number,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? columnId,
    Expression<int>? closedAt,
    Expression<int>? laterAt,
    Expression<String>? laterReason,
    Expression<int>? priorityAt,
    Expression<int>? dueAt,
    Expression<bool>? dueHasTime,
    Expression<int>? lastActiveAt,
    Expression<int>? rev,
    Expression<bool>? synced,
    Expression<int>? creatorId,
    Expression<String>? status,
    Expression<String>? coverId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boardId != null) 'board_id': boardId,
      if (number != null) 'number': number,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (columnId != null) 'column_id': columnId,
      if (closedAt != null) 'closed_at': closedAt,
      if (laterAt != null) 'later_at': laterAt,
      if (laterReason != null) 'later_reason': laterReason,
      if (priorityAt != null) 'priority_at': priorityAt,
      if (dueAt != null) 'due_at': dueAt,
      if (dueHasTime != null) 'due_has_time': dueHasTime,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      if (rev != null) 'rev': rev,
      if (synced != null) 'synced': synced,
      if (creatorId != null) 'creator_id': creatorId,
      if (status != null) 'status': status,
      if (coverId != null) 'cover_id': coverId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? boardId,
    Value<int>? number,
    Value<String>? title,
    Value<String>? description,
    Value<String?>? columnId,
    Value<int?>? closedAt,
    Value<int?>? laterAt,
    Value<String?>? laterReason,
    Value<int?>? priorityAt,
    Value<int?>? dueAt,
    Value<bool>? dueHasTime,
    Value<int>? lastActiveAt,
    Value<int>? rev,
    Value<bool>? synced,
    Value<int?>? creatorId,
    Value<String>? status,
    Value<String?>? coverId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KCardsCompanion(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      number: number ?? this.number,
      title: title ?? this.title,
      description: description ?? this.description,
      columnId: columnId ?? this.columnId,
      closedAt: closedAt ?? this.closedAt,
      laterAt: laterAt ?? this.laterAt,
      laterReason: laterReason ?? this.laterReason,
      priorityAt: priorityAt ?? this.priorityAt,
      dueAt: dueAt ?? this.dueAt,
      dueHasTime: dueHasTime ?? this.dueHasTime,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      rev: rev ?? this.rev,
      synced: synced ?? this.synced,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      coverId: coverId ?? this.coverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (columnId.present) {
      map['column_id'] = Variable<String>(columnId.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<int>(closedAt.value);
    }
    if (laterAt.present) {
      map['later_at'] = Variable<int>(laterAt.value);
    }
    if (laterReason.present) {
      map['later_reason'] = Variable<String>(laterReason.value);
    }
    if (priorityAt.present) {
      map['priority_at'] = Variable<int>(priorityAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (dueHasTime.present) {
      map['due_has_time'] = Variable<bool>(dueHasTime.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<int>(lastActiveAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<int>(creatorId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (coverId.present) {
      map['cover_id'] = Variable<String>(coverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KCardsCompanion(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('columnId: $columnId, ')
          ..write('closedAt: $closedAt, ')
          ..write('laterAt: $laterAt, ')
          ..write('laterReason: $laterReason, ')
          ..write('priorityAt: $priorityAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('dueHasTime: $dueHasTime, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('rev: $rev, ')
          ..write('synced: $synced, ')
          ..write('creatorId: $creatorId, ')
          ..write('status: $status, ')
          ..write('coverId: $coverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KPeopleTable extends KPeople with TableInfo<$KPeopleTable, KPerson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KPeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_people';
  @override
  VerificationContext validateIntegrity(
    Insertable<KPerson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KPerson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KPerson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $KPeopleTable createAlias(String alias) {
    return $KPeopleTable(attachedDatabase, alias);
  }
}

class KPerson extends DataClass implements Insertable<KPerson> {
  final int id;
  final String name;
  const KPerson({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  KPeopleCompanion toCompanion(bool nullToAbsent) {
    return KPeopleCompanion(id: Value(id), name: Value(name));
  }

  factory KPerson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KPerson(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  KPerson copyWith({int? id, String? name}) =>
      KPerson(id: id ?? this.id, name: name ?? this.name);
  KPerson copyWithCompanion(KPeopleCompanion data) {
    return KPerson(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KPerson(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KPerson && other.id == this.id && other.name == this.name);
}

class KPeopleCompanion extends UpdateCompanion<KPerson> {
  final Value<int> id;
  final Value<String> name;
  const KPeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  KPeopleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<KPerson> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  KPeopleCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return KPeopleCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KPeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $KSettingsTable extends KSettings
    with TableInfo<$KSettingsTable, KSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<KSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KSettingsTable createAlias(String alias) {
    return $KSettingsTable(attachedDatabase, alias);
  }
}

class KSetting extends DataClass implements Insertable<KSetting> {
  final String key;
  final String value;
  const KSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KSettingsCompanion toCompanion(bool nullToAbsent) {
    return KSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory KSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KSetting copyWith({String? key, String? value}) =>
      KSetting(key: key ?? this.key, value: value ?? this.value);
  KSetting copyWithCompanion(KSettingsCompanion data) {
    return KSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KSetting && other.key == this.key && other.value == this.value);
}

class KSettingsCompanion extends UpdateCompanion<KSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KOutboxTable extends KOutbox
    with TableInfo<$KOutboxTable, KOutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KOutboxTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _argsMeta = const VerificationMeta('args');
  @override
  late final GeneratedColumn<String> args = GeneratedColumn<String>(
    'args',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientTsMeta = const VerificationMeta(
    'clientTs',
  );
  @override
  late final GeneratedColumn<int> clientTs = GeneratedColumn<int>(
    'client_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, mutationId, name, args, clientTs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<KOutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('args')) {
      context.handle(
        _argsMeta,
        args.isAcceptableOrUnknown(data['args']!, _argsMeta),
      );
    } else if (isInserting) {
      context.missing(_argsMeta);
    }
    if (data.containsKey('client_ts')) {
      context.handle(
        _clientTsMeta,
        clientTs.isAcceptableOrUnknown(data['client_ts']!, _clientTsMeta),
      );
    } else if (isInserting) {
      context.missing(_clientTsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KOutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KOutboxEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      args: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}args'],
      )!,
      clientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_ts'],
      )!,
    );
  }

  @override
  $KOutboxTable createAlias(String alias) {
    return $KOutboxTable(attachedDatabase, alias);
  }
}

class KOutboxEntry extends DataClass implements Insertable<KOutboxEntry> {
  final int id;
  final String mutationId;
  final String name;
  final String args;
  final int clientTs;
  const KOutboxEntry({
    required this.id,
    required this.mutationId,
    required this.name,
    required this.args,
    required this.clientTs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mutation_id'] = Variable<String>(mutationId);
    map['name'] = Variable<String>(name);
    map['args'] = Variable<String>(args);
    map['client_ts'] = Variable<int>(clientTs);
    return map;
  }

  KOutboxCompanion toCompanion(bool nullToAbsent) {
    return KOutboxCompanion(
      id: Value(id),
      mutationId: Value(mutationId),
      name: Value(name),
      args: Value(args),
      clientTs: Value(clientTs),
    );
  }

  factory KOutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KOutboxEntry(
      id: serializer.fromJson<int>(json['id']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      name: serializer.fromJson<String>(json['name']),
      args: serializer.fromJson<String>(json['args']),
      clientTs: serializer.fromJson<int>(json['clientTs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mutationId': serializer.toJson<String>(mutationId),
      'name': serializer.toJson<String>(name),
      'args': serializer.toJson<String>(args),
      'clientTs': serializer.toJson<int>(clientTs),
    };
  }

  KOutboxEntry copyWith({
    int? id,
    String? mutationId,
    String? name,
    String? args,
    int? clientTs,
  }) => KOutboxEntry(
    id: id ?? this.id,
    mutationId: mutationId ?? this.mutationId,
    name: name ?? this.name,
    args: args ?? this.args,
    clientTs: clientTs ?? this.clientTs,
  );
  KOutboxEntry copyWithCompanion(KOutboxCompanion data) {
    return KOutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      name: data.name.present ? data.name.value : this.name,
      args: data.args.present ? data.args.value : this.args,
      clientTs: data.clientTs.present ? data.clientTs.value : this.clientTs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KOutboxEntry(')
          ..write('id: $id, ')
          ..write('mutationId: $mutationId, ')
          ..write('name: $name, ')
          ..write('args: $args, ')
          ..write('clientTs: $clientTs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mutationId, name, args, clientTs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KOutboxEntry &&
          other.id == this.id &&
          other.mutationId == this.mutationId &&
          other.name == this.name &&
          other.args == this.args &&
          other.clientTs == this.clientTs);
}

class KOutboxCompanion extends UpdateCompanion<KOutboxEntry> {
  final Value<int> id;
  final Value<String> mutationId;
  final Value<String> name;
  final Value<String> args;
  final Value<int> clientTs;
  const KOutboxCompanion({
    this.id = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.name = const Value.absent(),
    this.args = const Value.absent(),
    this.clientTs = const Value.absent(),
  });
  KOutboxCompanion.insert({
    this.id = const Value.absent(),
    required String mutationId,
    required String name,
    required String args,
    required int clientTs,
  }) : mutationId = Value(mutationId),
       name = Value(name),
       args = Value(args),
       clientTs = Value(clientTs);
  static Insertable<KOutboxEntry> custom({
    Expression<int>? id,
    Expression<String>? mutationId,
    Expression<String>? name,
    Expression<String>? args,
    Expression<int>? clientTs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mutationId != null) 'mutation_id': mutationId,
      if (name != null) 'name': name,
      if (args != null) 'args': args,
      if (clientTs != null) 'client_ts': clientTs,
    });
  }

  KOutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? mutationId,
    Value<String>? name,
    Value<String>? args,
    Value<int>? clientTs,
  }) {
    return KOutboxCompanion(
      id: id ?? this.id,
      mutationId: mutationId ?? this.mutationId,
      name: name ?? this.name,
      args: args ?? this.args,
      clientTs: clientTs ?? this.clientTs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (args.present) {
      map['args'] = Variable<String>(args.value);
    }
    if (clientTs.present) {
      map['client_ts'] = Variable<int>(clientTs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KOutboxCompanion(')
          ..write('id: $id, ')
          ..write('mutationId: $mutationId, ')
          ..write('name: $name, ')
          ..write('args: $args, ')
          ..write('clientTs: $clientTs')
          ..write(')'))
        .toString();
  }
}

class $KStepsTable extends KSteps with TableInfo<$KStepsTable, KStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    content,
    done,
    position,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<KStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KStepsTable createAlias(String alias) {
    return $KStepsTable(attachedDatabase, alias);
  }
}

class KStep extends DataClass implements Insertable<KStep> {
  final String id;
  final String cardId;
  final String content;
  final bool done;
  final double position;
  final int createdAt;
  final int? deletedAt;
  const KStep({
    required this.id,
    required this.cardId,
    required this.content,
    required this.done,
    required this.position,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['content'] = Variable<String>(content);
    map['done'] = Variable<bool>(done);
    map['position'] = Variable<double>(position);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KStepsCompanion toCompanion(bool nullToAbsent) {
    return KStepsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      content: Value(content),
      done: Value(done),
      position: Value(position),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KStep(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      content: serializer.fromJson<String>(json['content']),
      done: serializer.fromJson<bool>(json['done']),
      position: serializer.fromJson<double>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'content': serializer.toJson<String>(content),
      'done': serializer.toJson<bool>(done),
      'position': serializer.toJson<double>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KStep copyWith({
    String? id,
    String? cardId,
    String? content,
    bool? done,
    double? position,
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KStep(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    content: content ?? this.content,
    done: done ?? this.done,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KStep copyWithCompanion(KStepsCompanion data) {
    return KStep(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      content: data.content.present ? data.content.value : this.content,
      done: data.done.present ? data.done.value : this.done,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KStep(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('content: $content, ')
          ..write('done: $done, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, content, done, position, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KStep &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.content == this.content &&
          other.done == this.done &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class KStepsCompanion extends UpdateCompanion<KStep> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<String> content;
  final Value<bool> done;
  final Value<double> position;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KStepsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.content = const Value.absent(),
    this.done = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KStepsCompanion.insert({
    required String id,
    required String cardId,
    required String content,
    this.done = const Value.absent(),
    this.position = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<KStep> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<String>? content,
    Expression<bool>? done,
    Expression<double>? position,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (content != null) 'content': content,
      if (done != null) 'done': done,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<String>? content,
    Value<bool>? done,
    Value<double>? position,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KStepsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      content: content ?? this.content,
      done: done ?? this.done,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KStepsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('content: $content, ')
          ..write('done: $done, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KCommentsTable extends KComments
    with TableInfo<$KCommentsTable, KComment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<int> editedAt = GeneratedColumn<int>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    userId,
    body,
    createdAt,
    editedAt,
    deletedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<KComment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KComment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KComment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edited_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $KCommentsTable createAlias(String alias) {
    return $KCommentsTable(attachedDatabase, alias);
  }
}

class KComment extends DataClass implements Insertable<KComment> {
  final String id;
  final String cardId;
  final int userId;
  final String body;
  final int createdAt;
  final int? editedAt;
  final int? deletedAt;
  final bool synced;
  const KComment({
    required this.id,
    required this.cardId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['user_id'] = Variable<int>(userId);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<int>(editedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  KCommentsCompanion toCompanion(bool nullToAbsent) {
    return KCommentsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      userId: Value(userId),
      body: Value(body),
      createdAt: Value(createdAt),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      synced: Value(synced),
    );
  }

  factory KComment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KComment(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      userId: serializer.fromJson<int>(json['userId']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      editedAt: serializer.fromJson<int?>(json['editedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'userId': serializer.toJson<int>(userId),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<int>(createdAt),
      'editedAt': serializer.toJson<int?>(editedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  KComment copyWith({
    String? id,
    String? cardId,
    int? userId,
    String? body,
    int? createdAt,
    Value<int?> editedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    bool? synced,
  }) => KComment(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    userId: userId ?? this.userId,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    synced: synced ?? this.synced,
  );
  KComment copyWithCompanion(KCommentsCompanion data) {
    return KComment(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      userId: data.userId.present ? data.userId.value : this.userId,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KComment(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('userId: $userId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    userId,
    body,
    createdAt,
    editedAt,
    deletedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KComment &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.userId == this.userId &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.editedAt == this.editedAt &&
          other.deletedAt == this.deletedAt &&
          other.synced == this.synced);
}

class KCommentsCompanion extends UpdateCompanion<KComment> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<int> userId;
  final Value<String> body;
  final Value<int> createdAt;
  final Value<int?> editedAt;
  final Value<int?> deletedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const KCommentsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.userId = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KCommentsCompanion.insert({
    required String id,
    required String cardId,
    required int userId,
    required String body,
    required int createdAt,
    this.editedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       userId = Value(userId),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<KComment> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<int>? userId,
    Expression<String>? body,
    Expression<int>? createdAt,
    Expression<int>? editedAt,
    Expression<int>? deletedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (userId != null) 'user_id': userId,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (editedAt != null) 'edited_at': editedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KCommentsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<int>? userId,
    Value<String>? body,
    Value<int>? createdAt,
    Value<int?>? editedAt,
    Value<int?>? deletedAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return KCommentsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<int>(editedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KCommentsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('userId: $userId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KReactionsTable extends KReactions
    with TableInfo<$KReactionsTable, KReaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KReactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentIdMeta = const VerificationMeta(
    'commentId',
  );
  @override
  late final GeneratedColumn<String> commentId = GeneratedColumn<String>(
    'comment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    commentId,
    userId,
    emoji,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_reactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<KReaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('comment_id')) {
      context.handle(
        _commentIdMeta,
        commentId.isAcceptableOrUnknown(data['comment_id']!, _commentIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KReaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KReaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      commentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KReactionsTable createAlias(String alias) {
    return $KReactionsTable(attachedDatabase, alias);
  }
}

class KReaction extends DataClass implements Insertable<KReaction> {
  final String id;
  final String cardId;
  final String? commentId;
  final int userId;
  final String emoji;
  final int createdAt;
  final int? deletedAt;
  const KReaction({
    required this.id,
    required this.cardId,
    this.commentId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    if (!nullToAbsent || commentId != null) {
      map['comment_id'] = Variable<String>(commentId);
    }
    map['user_id'] = Variable<int>(userId);
    map['emoji'] = Variable<String>(emoji);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KReactionsCompanion toCompanion(bool nullToAbsent) {
    return KReactionsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      commentId: commentId == null && nullToAbsent
          ? const Value.absent()
          : Value(commentId),
      userId: Value(userId),
      emoji: Value(emoji),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KReaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KReaction(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      commentId: serializer.fromJson<String?>(json['commentId']),
      userId: serializer.fromJson<int>(json['userId']),
      emoji: serializer.fromJson<String>(json['emoji']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'commentId': serializer.toJson<String?>(commentId),
      'userId': serializer.toJson<int>(userId),
      'emoji': serializer.toJson<String>(emoji),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KReaction copyWith({
    String? id,
    String? cardId,
    Value<String?> commentId = const Value.absent(),
    int? userId,
    String? emoji,
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KReaction(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    commentId: commentId.present ? commentId.value : this.commentId,
    userId: userId ?? this.userId,
    emoji: emoji ?? this.emoji,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KReaction copyWithCompanion(KReactionsCompanion data) {
    return KReaction(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      commentId: data.commentId.present ? data.commentId.value : this.commentId,
      userId: data.userId.present ? data.userId.value : this.userId,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KReaction(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('commentId: $commentId, ')
          ..write('userId: $userId, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, commentId, userId, emoji, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KReaction &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.commentId == this.commentId &&
          other.userId == this.userId &&
          other.emoji == this.emoji &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class KReactionsCompanion extends UpdateCompanion<KReaction> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<String?> commentId;
  final Value<int> userId;
  final Value<String> emoji;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KReactionsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.commentId = const Value.absent(),
    this.userId = const Value.absent(),
    this.emoji = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KReactionsCompanion.insert({
    required String id,
    required String cardId,
    this.commentId = const Value.absent(),
    required int userId,
    required String emoji,
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       userId = Value(userId),
       emoji = Value(emoji),
       createdAt = Value(createdAt);
  static Insertable<KReaction> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<String>? commentId,
    Expression<int>? userId,
    Expression<String>? emoji,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (commentId != null) 'comment_id': commentId,
      if (userId != null) 'user_id': userId,
      if (emoji != null) 'emoji': emoji,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KReactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<String?>? commentId,
    Value<int>? userId,
    Value<String>? emoji,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KReactionsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      commentId: commentId ?? this.commentId,
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (commentId.present) {
      map['comment_id'] = Variable<String>(commentId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KReactionsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('commentId: $commentId, ')
          ..write('userId: $userId, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KTagsTable extends KTags with TableInfo<$KTagsTable, KTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, tag, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<KTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, tag};
  @override
  KTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KTag(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KTagsTable createAlias(String alias) {
    return $KTagsTable(attachedDatabase, alias);
  }
}

class KTag extends DataClass implements Insertable<KTag> {
  final String cardId;
  final String tag;
  final int? deletedAt;
  const KTag({required this.cardId, required this.tag, this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['tag'] = Variable<String>(tag);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KTagsCompanion toCompanion(bool nullToAbsent) {
    return KTagsCompanion(
      cardId: Value(cardId),
      tag: Value(tag),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KTag(
      cardId: serializer.fromJson<String>(json['cardId']),
      tag: serializer.fromJson<String>(json['tag']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'tag': serializer.toJson<String>(tag),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KTag copyWith({
    String? cardId,
    String? tag,
    Value<int?> deletedAt = const Value.absent(),
  }) => KTag(
    cardId: cardId ?? this.cardId,
    tag: tag ?? this.tag,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KTag copyWithCompanion(KTagsCompanion data) {
    return KTag(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      tag: data.tag.present ? data.tag.value : this.tag,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KTag(')
          ..write('cardId: $cardId, ')
          ..write('tag: $tag, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, tag, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KTag &&
          other.cardId == this.cardId &&
          other.tag == this.tag &&
          other.deletedAt == this.deletedAt);
}

class KTagsCompanion extends UpdateCompanion<KTag> {
  final Value<String> cardId;
  final Value<String> tag;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KTagsCompanion({
    this.cardId = const Value.absent(),
    this.tag = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KTagsCompanion.insert({
    required String cardId,
    required String tag,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       tag = Value(tag);
  static Insertable<KTag> custom({
    Expression<String>? cardId,
    Expression<String>? tag,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (tag != null) 'tag': tag,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KTagsCompanion copyWith({
    Value<String>? cardId,
    Value<String>? tag,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KTagsCompanion(
      cardId: cardId ?? this.cardId,
      tag: tag ?? this.tag,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KTagsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('tag: $tag, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KAssigneesTable extends KAssignees
    with TableInfo<$KAssigneesTable, KAssignee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KAssigneesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, userId, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_assignees';
  @override
  VerificationContext validateIntegrity(
    Insertable<KAssignee> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, userId};
  @override
  KAssignee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KAssignee(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KAssigneesTable createAlias(String alias) {
    return $KAssigneesTable(attachedDatabase, alias);
  }
}

class KAssignee extends DataClass implements Insertable<KAssignee> {
  final String cardId;
  final int userId;
  final int? deletedAt;
  const KAssignee({required this.cardId, required this.userId, this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KAssigneesCompanion toCompanion(bool nullToAbsent) {
    return KAssigneesCompanion(
      cardId: Value(cardId),
      userId: Value(userId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KAssignee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KAssignee(
      cardId: serializer.fromJson<String>(json['cardId']),
      userId: serializer.fromJson<int>(json['userId']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'userId': serializer.toJson<int>(userId),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KAssignee copyWith({
    String? cardId,
    int? userId,
    Value<int?> deletedAt = const Value.absent(),
  }) => KAssignee(
    cardId: cardId ?? this.cardId,
    userId: userId ?? this.userId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KAssignee copyWithCompanion(KAssigneesCompanion data) {
    return KAssignee(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KAssignee(')
          ..write('cardId: $cardId, ')
          ..write('userId: $userId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, userId, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KAssignee &&
          other.cardId == this.cardId &&
          other.userId == this.userId &&
          other.deletedAt == this.deletedAt);
}

class KAssigneesCompanion extends UpdateCompanion<KAssignee> {
  final Value<String> cardId;
  final Value<int> userId;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KAssigneesCompanion({
    this.cardId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KAssigneesCompanion.insert({
    required String cardId,
    required int userId,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       userId = Value(userId);
  static Insertable<KAssignee> custom({
    Expression<String>? cardId,
    Expression<int>? userId,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (userId != null) 'user_id': userId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KAssigneesCompanion copyWith({
    Value<String>? cardId,
    Value<int>? userId,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KAssigneesCompanion(
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KAssigneesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('userId: $userId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KWatchesTable extends KWatches with TableInfo<$KWatchesTable, KWatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KWatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watchingMeta = const VerificationMeta(
    'watching',
  );
  @override
  late final GeneratedColumn<bool> watching = GeneratedColumn<bool>(
    'watching',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("watching" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, watching];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_watches';
  @override
  VerificationContext validateIntegrity(
    Insertable<KWatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('watching')) {
      context.handle(
        _watchingMeta,
        watching.isAcceptableOrUnknown(data['watching']!, _watchingMeta),
      );
    } else if (isInserting) {
      context.missing(_watchingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  KWatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KWatch(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      watching: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}watching'],
      )!,
    );
  }

  @override
  $KWatchesTable createAlias(String alias) {
    return $KWatchesTable(attachedDatabase, alias);
  }
}

class KWatch extends DataClass implements Insertable<KWatch> {
  final String cardId;
  final bool watching;
  const KWatch({required this.cardId, required this.watching});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['watching'] = Variable<bool>(watching);
    return map;
  }

  KWatchesCompanion toCompanion(bool nullToAbsent) {
    return KWatchesCompanion(cardId: Value(cardId), watching: Value(watching));
  }

  factory KWatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KWatch(
      cardId: serializer.fromJson<String>(json['cardId']),
      watching: serializer.fromJson<bool>(json['watching']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'watching': serializer.toJson<bool>(watching),
    };
  }

  KWatch copyWith({String? cardId, bool? watching}) => KWatch(
    cardId: cardId ?? this.cardId,
    watching: watching ?? this.watching,
  );
  KWatch copyWithCompanion(KWatchesCompanion data) {
    return KWatch(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      watching: data.watching.present ? data.watching.value : this.watching,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KWatch(')
          ..write('cardId: $cardId, ')
          ..write('watching: $watching')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, watching);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KWatch &&
          other.cardId == this.cardId &&
          other.watching == this.watching);
}

class KWatchesCompanion extends UpdateCompanion<KWatch> {
  final Value<String> cardId;
  final Value<bool> watching;
  final Value<int> rowid;
  const KWatchesCompanion({
    this.cardId = const Value.absent(),
    this.watching = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KWatchesCompanion.insert({
    required String cardId,
    required bool watching,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       watching = Value(watching);
  static Insertable<KWatch> custom({
    Expression<String>? cardId,
    Expression<bool>? watching,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (watching != null) 'watching': watching,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KWatchesCompanion copyWith({
    Value<String>? cardId,
    Value<bool>? watching,
    Value<int>? rowid,
  }) {
    return KWatchesCompanion(
      cardId: cardId ?? this.cardId,
      watching: watching ?? this.watching,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (watching.present) {
      map['watching'] = Variable<bool>(watching.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KWatchesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('watching: $watching, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KPinsTable extends KPins with TableInfo<$KPinsTable, KPin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KPinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedAtMeta = const VerificationMeta(
    'pinnedAt',
  );
  @override
  late final GeneratedColumn<int> pinnedAt = GeneratedColumn<int>(
    'pinned_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, pinnedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_pins';
  @override
  VerificationContext validateIntegrity(
    Insertable<KPin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('pinned_at')) {
      context.handle(
        _pinnedAtMeta,
        pinnedAt.isAcceptableOrUnknown(data['pinned_at']!, _pinnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pinnedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  KPin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KPin(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      pinnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pinned_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KPinsTable createAlias(String alias) {
    return $KPinsTable(attachedDatabase, alias);
  }
}

class KPin extends DataClass implements Insertable<KPin> {
  final String cardId;
  final int pinnedAt;
  final int? deletedAt;
  const KPin({required this.cardId, required this.pinnedAt, this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['pinned_at'] = Variable<int>(pinnedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KPinsCompanion toCompanion(bool nullToAbsent) {
    return KPinsCompanion(
      cardId: Value(cardId),
      pinnedAt: Value(pinnedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KPin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KPin(
      cardId: serializer.fromJson<String>(json['cardId']),
      pinnedAt: serializer.fromJson<int>(json['pinnedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'pinnedAt': serializer.toJson<int>(pinnedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KPin copyWith({
    String? cardId,
    int? pinnedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KPin(
    cardId: cardId ?? this.cardId,
    pinnedAt: pinnedAt ?? this.pinnedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KPin copyWithCompanion(KPinsCompanion data) {
    return KPin(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      pinnedAt: data.pinnedAt.present ? data.pinnedAt.value : this.pinnedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KPin(')
          ..write('cardId: $cardId, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, pinnedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KPin &&
          other.cardId == this.cardId &&
          other.pinnedAt == this.pinnedAt &&
          other.deletedAt == this.deletedAt);
}

class KPinsCompanion extends UpdateCompanion<KPin> {
  final Value<String> cardId;
  final Value<int> pinnedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KPinsCompanion({
    this.cardId = const Value.absent(),
    this.pinnedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KPinsCompanion.insert({
    required String cardId,
    required int pinnedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       pinnedAt = Value(pinnedAt);
  static Insertable<KPin> custom({
    Expression<String>? cardId,
    Expression<int>? pinnedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (pinnedAt != null) 'pinned_at': pinnedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KPinsCompanion copyWith({
    Value<String>? cardId,
    Value<int>? pinnedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KPinsCompanion(
      cardId: cardId ?? this.cardId,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (pinnedAt.present) {
      map['pinned_at'] = Variable<int>(pinnedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KPinsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KFilesTable extends KFiles with TableInfo<$KFilesTable, KFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentIdMeta = const VerificationMeta(
    'commentId',
  );
  @override
  late final GeneratedColumn<String> commentId = GeneratedColumn<String>(
    'comment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('application/octet-stream'),
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasThumbMeta = const VerificationMeta(
    'hasThumb',
  );
  @override
  late final GeneratedColumn<bool> hasThumb = GeneratedColumn<bool>(
    'has_thumb',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_thumb" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    commentId,
    userId,
    filename,
    mime,
    size,
    width,
    height,
    hasThumb,
    createdAt,
    deletedAt,
    localPath,
    uploaded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<KFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('comment_id')) {
      context.handle(
        _commentIdMeta,
        commentId.isAcceptableOrUnknown(data['comment_id']!, _commentIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('has_thumb')) {
      context.handle(
        _hasThumbMeta,
        hasThumb.isAcceptableOrUnknown(data['has_thumb']!, _hasThumbMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      commentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      hasThumb: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_thumb'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
    );
  }

  @override
  $KFilesTable createAlias(String alias) {
    return $KFilesTable(attachedDatabase, alias);
  }
}

class KFile extends DataClass implements Insertable<KFile> {
  final String id;
  final String cardId;
  final String? commentId;
  final int userId;
  final String filename;
  final String mime;
  final int size;
  final int? width;
  final int? height;
  final bool hasThumb;
  final int createdAt;
  final int? deletedAt;
  final String? localPath;
  final bool uploaded;
  const KFile({
    required this.id,
    required this.cardId,
    this.commentId,
    required this.userId,
    required this.filename,
    required this.mime,
    required this.size,
    this.width,
    this.height,
    required this.hasThumb,
    required this.createdAt,
    this.deletedAt,
    this.localPath,
    required this.uploaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    if (!nullToAbsent || commentId != null) {
      map['comment_id'] = Variable<String>(commentId);
    }
    map['user_id'] = Variable<int>(userId);
    map['filename'] = Variable<String>(filename);
    map['mime'] = Variable<String>(mime);
    map['size'] = Variable<int>(size);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['has_thumb'] = Variable<bool>(hasThumb);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['uploaded'] = Variable<bool>(uploaded);
    return map;
  }

  KFilesCompanion toCompanion(bool nullToAbsent) {
    return KFilesCompanion(
      id: Value(id),
      cardId: Value(cardId),
      commentId: commentId == null && nullToAbsent
          ? const Value.absent()
          : Value(commentId),
      userId: Value(userId),
      filename: Value(filename),
      mime: Value(mime),
      size: Value(size),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      hasThumb: Value(hasThumb),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      uploaded: Value(uploaded),
    );
  }

  factory KFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KFile(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      commentId: serializer.fromJson<String?>(json['commentId']),
      userId: serializer.fromJson<int>(json['userId']),
      filename: serializer.fromJson<String>(json['filename']),
      mime: serializer.fromJson<String>(json['mime']),
      size: serializer.fromJson<int>(json['size']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      hasThumb: serializer.fromJson<bool>(json['hasThumb']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'commentId': serializer.toJson<String?>(commentId),
      'userId': serializer.toJson<int>(userId),
      'filename': serializer.toJson<String>(filename),
      'mime': serializer.toJson<String>(mime),
      'size': serializer.toJson<int>(size),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'hasThumb': serializer.toJson<bool>(hasThumb),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localPath': serializer.toJson<String?>(localPath),
      'uploaded': serializer.toJson<bool>(uploaded),
    };
  }

  KFile copyWith({
    String? id,
    String? cardId,
    Value<String?> commentId = const Value.absent(),
    int? userId,
    String? filename,
    String? mime,
    int? size,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    bool? hasThumb,
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    bool? uploaded,
  }) => KFile(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    commentId: commentId.present ? commentId.value : this.commentId,
    userId: userId ?? this.userId,
    filename: filename ?? this.filename,
    mime: mime ?? this.mime,
    size: size ?? this.size,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    hasThumb: hasThumb ?? this.hasThumb,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localPath: localPath.present ? localPath.value : this.localPath,
    uploaded: uploaded ?? this.uploaded,
  );
  KFile copyWithCompanion(KFilesCompanion data) {
    return KFile(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      commentId: data.commentId.present ? data.commentId.value : this.commentId,
      userId: data.userId.present ? data.userId.value : this.userId,
      filename: data.filename.present ? data.filename.value : this.filename,
      mime: data.mime.present ? data.mime.value : this.mime,
      size: data.size.present ? data.size.value : this.size,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      hasThumb: data.hasThumb.present ? data.hasThumb.value : this.hasThumb,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KFile(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('commentId: $commentId, ')
          ..write('userId: $userId, ')
          ..write('filename: $filename, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('hasThumb: $hasThumb, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localPath: $localPath, ')
          ..write('uploaded: $uploaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    commentId,
    userId,
    filename,
    mime,
    size,
    width,
    height,
    hasThumb,
    createdAt,
    deletedAt,
    localPath,
    uploaded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KFile &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.commentId == this.commentId &&
          other.userId == this.userId &&
          other.filename == this.filename &&
          other.mime == this.mime &&
          other.size == this.size &&
          other.width == this.width &&
          other.height == this.height &&
          other.hasThumb == this.hasThumb &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.localPath == this.localPath &&
          other.uploaded == this.uploaded);
}

class KFilesCompanion extends UpdateCompanion<KFile> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<String?> commentId;
  final Value<int> userId;
  final Value<String> filename;
  final Value<String> mime;
  final Value<int> size;
  final Value<int?> width;
  final Value<int?> height;
  final Value<bool> hasThumb;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<String?> localPath;
  final Value<bool> uploaded;
  final Value<int> rowid;
  const KFilesCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.commentId = const Value.absent(),
    this.userId = const Value.absent(),
    this.filename = const Value.absent(),
    this.mime = const Value.absent(),
    this.size = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.hasThumb = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localPath = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KFilesCompanion.insert({
    required String id,
    required String cardId,
    this.commentId = const Value.absent(),
    this.userId = const Value.absent(),
    required String filename,
    this.mime = const Value.absent(),
    this.size = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.hasThumb = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.localPath = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       filename = Value(filename),
       createdAt = Value(createdAt);
  static Insertable<KFile> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<String>? commentId,
    Expression<int>? userId,
    Expression<String>? filename,
    Expression<String>? mime,
    Expression<int>? size,
    Expression<int>? width,
    Expression<int>? height,
    Expression<bool>? hasThumb,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<String>? localPath,
    Expression<bool>? uploaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (commentId != null) 'comment_id': commentId,
      if (userId != null) 'user_id': userId,
      if (filename != null) 'filename': filename,
      if (mime != null) 'mime': mime,
      if (size != null) 'size': size,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (hasThumb != null) 'has_thumb': hasThumb,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localPath != null) 'local_path': localPath,
      if (uploaded != null) 'uploaded': uploaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<String?>? commentId,
    Value<int>? userId,
    Value<String>? filename,
    Value<String>? mime,
    Value<int>? size,
    Value<int?>? width,
    Value<int?>? height,
    Value<bool>? hasThumb,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<String?>? localPath,
    Value<bool>? uploaded,
    Value<int>? rowid,
  }) {
    return KFilesCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      commentId: commentId ?? this.commentId,
      userId: userId ?? this.userId,
      filename: filename ?? this.filename,
      mime: mime ?? this.mime,
      size: size ?? this.size,
      width: width ?? this.width,
      height: height ?? this.height,
      hasThumb: hasThumb ?? this.hasThumb,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localPath: localPath ?? this.localPath,
      uploaded: uploaded ?? this.uploaded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (commentId.present) {
      map['comment_id'] = Variable<String>(commentId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (hasThumb.present) {
      map['has_thumb'] = Variable<bool>(hasThumb.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KFilesCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('commentId: $commentId, ')
          ..write('userId: $userId, ')
          ..write('filename: $filename, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('hasThumb: $hasThumb, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localPath: $localPath, ')
          ..write('uploaded: $uploaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KEventsTable extends KEvents with TableInfo<$KEventsTable, KEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _particularsMeta = const VerificationMeta(
    'particulars',
  );
  @override
  late final GeneratedColumn<String> particulars = GeneratedColumn<String>(
    'particulars',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    userId,
    action,
    particulars,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<KEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('particulars')) {
      context.handle(
        _particularsMeta,
        particulars.isAcceptableOrUnknown(
          data['particulars']!,
          _particularsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      particulars: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}particulars'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $KEventsTable createAlias(String alias) {
    return $KEventsTable(attachedDatabase, alias);
  }
}

class KEvent extends DataClass implements Insertable<KEvent> {
  final int id;
  final String cardId;
  final int userId;
  final String action;
  final String particulars;
  final int createdAt;
  const KEvent({
    required this.id,
    required this.cardId,
    required this.userId,
    required this.action,
    required this.particulars,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['user_id'] = Variable<int>(userId);
    map['action'] = Variable<String>(action);
    map['particulars'] = Variable<String>(particulars);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  KEventsCompanion toCompanion(bool nullToAbsent) {
    return KEventsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      userId: Value(userId),
      action: Value(action),
      particulars: Value(particulars),
      createdAt: Value(createdAt),
    );
  }

  factory KEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KEvent(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      userId: serializer.fromJson<int>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      particulars: serializer.fromJson<String>(json['particulars']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'userId': serializer.toJson<int>(userId),
      'action': serializer.toJson<String>(action),
      'particulars': serializer.toJson<String>(particulars),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  KEvent copyWith({
    int? id,
    String? cardId,
    int? userId,
    String? action,
    String? particulars,
    int? createdAt,
  }) => KEvent(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    userId: userId ?? this.userId,
    action: action ?? this.action,
    particulars: particulars ?? this.particulars,
    createdAt: createdAt ?? this.createdAt,
  );
  KEvent copyWithCompanion(KEventsCompanion data) {
    return KEvent(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      particulars: data.particulars.present
          ? data.particulars.value
          : this.particulars,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KEvent(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('particulars: $particulars, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, userId, action, particulars, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KEvent &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.particulars == this.particulars &&
          other.createdAt == this.createdAt);
}

class KEventsCompanion extends UpdateCompanion<KEvent> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<int> userId;
  final Value<String> action;
  final Value<String> particulars;
  final Value<int> createdAt;
  const KEventsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.particulars = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  KEventsCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required int userId,
    required String action,
    this.particulars = const Value.absent(),
    required int createdAt,
  }) : cardId = Value(cardId),
       userId = Value(userId),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<KEvent> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<int>? userId,
    Expression<String>? action,
    Expression<String>? particulars,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (particulars != null) 'particulars': particulars,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  KEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardId,
    Value<int>? userId,
    Value<String>? action,
    Value<String>? particulars,
    Value<int>? createdAt,
  }) {
    return KEventsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      particulars: particulars ?? this.particulars,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (particulars.present) {
      map['particulars'] = Variable<String>(particulars.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KEventsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('particulars: $particulars, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $KPlannersTable extends KPlanners
    with TableInfo<$KPlannersTable, KPlanner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KPlannersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>(
    'creator_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rollOverMeta = const VerificationMeta(
    'rollOver',
  );
  @override
  late final GeneratedColumn<bool> rollOver = GeneratedColumn<bool>(
    'roll_over',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("roll_over" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sinkDoneMeta = const VerificationMeta(
    'sinkDone',
  );
  @override
  late final GeneratedColumn<bool> sinkDone = GeneratedColumn<bool>(
    'sink_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sink_done" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hideDoneMeta = const VerificationMeta(
    'hideDone',
  );
  @override
  late final GeneratedColumn<bool> hideDone = GeneratedColumn<bool>(
    'hide_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _boardIdsMeta = const VerificationMeta(
    'boardIds',
  );
  @override
  late final GeneratedColumn<String> boardIds = GeneratedColumn<String>(
    'board_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _canManageMeta = const VerificationMeta(
    'canManage',
  );
  @override
  late final GeneratedColumn<bool> canManage = GeneratedColumn<bool>(
    'can_manage',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_manage" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    creatorId,
    rollOver,
    sinkDone,
    hideDone,
    boardIds,
    canManage,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_planners';
  @override
  VerificationContext validateIntegrity(
    Insertable<KPlanner> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    }
    if (data.containsKey('roll_over')) {
      context.handle(
        _rollOverMeta,
        rollOver.isAcceptableOrUnknown(data['roll_over']!, _rollOverMeta),
      );
    }
    if (data.containsKey('sink_done')) {
      context.handle(
        _sinkDoneMeta,
        sinkDone.isAcceptableOrUnknown(data['sink_done']!, _sinkDoneMeta),
      );
    }
    if (data.containsKey('hide_done')) {
      context.handle(
        _hideDoneMeta,
        hideDone.isAcceptableOrUnknown(data['hide_done']!, _hideDoneMeta),
      );
    }
    if (data.containsKey('board_ids')) {
      context.handle(
        _boardIdsMeta,
        boardIds.isAcceptableOrUnknown(data['board_ids']!, _boardIdsMeta),
      );
    }
    if (data.containsKey('can_manage')) {
      context.handle(
        _canManageMeta,
        canManage.isAcceptableOrUnknown(data['can_manage']!, _canManageMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KPlanner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KPlanner(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creator_id'],
      ),
      rollOver: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}roll_over'],
      )!,
      sinkDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sink_done'],
      )!,
      hideDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_done'],
      )!,
      boardIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_ids'],
      )!,
      canManage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KPlannersTable createAlias(String alias) {
    return $KPlannersTable(attachedDatabase, alias);
  }
}

class KPlanner extends DataClass implements Insertable<KPlanner> {
  final String id;
  final String name;
  final int? creatorId;
  final bool rollOver;
  final bool sinkDone;
  final bool hideDone;
  final String boardIds;
  final bool canManage;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const KPlanner({
    required this.id,
    required this.name,
    this.creatorId,
    required this.rollOver,
    required this.sinkDone,
    required this.hideDone,
    required this.boardIds,
    required this.canManage,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || creatorId != null) {
      map['creator_id'] = Variable<int>(creatorId);
    }
    map['roll_over'] = Variable<bool>(rollOver);
    map['sink_done'] = Variable<bool>(sinkDone);
    map['hide_done'] = Variable<bool>(hideDone);
    map['board_ids'] = Variable<String>(boardIds);
    map['can_manage'] = Variable<bool>(canManage);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KPlannersCompanion toCompanion(bool nullToAbsent) {
    return KPlannersCompanion(
      id: Value(id),
      name: Value(name),
      creatorId: creatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(creatorId),
      rollOver: Value(rollOver),
      sinkDone: Value(sinkDone),
      hideDone: Value(hideDone),
      boardIds: Value(boardIds),
      canManage: Value(canManage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KPlanner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KPlanner(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      creatorId: serializer.fromJson<int?>(json['creatorId']),
      rollOver: serializer.fromJson<bool>(json['rollOver']),
      sinkDone: serializer.fromJson<bool>(json['sinkDone']),
      hideDone: serializer.fromJson<bool>(json['hideDone']),
      boardIds: serializer.fromJson<String>(json['boardIds']),
      canManage: serializer.fromJson<bool>(json['canManage']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'creatorId': serializer.toJson<int?>(creatorId),
      'rollOver': serializer.toJson<bool>(rollOver),
      'sinkDone': serializer.toJson<bool>(sinkDone),
      'hideDone': serializer.toJson<bool>(hideDone),
      'boardIds': serializer.toJson<String>(boardIds),
      'canManage': serializer.toJson<bool>(canManage),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KPlanner copyWith({
    String? id,
    String? name,
    Value<int?> creatorId = const Value.absent(),
    bool? rollOver,
    bool? sinkDone,
    bool? hideDone,
    String? boardIds,
    bool? canManage,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KPlanner(
    id: id ?? this.id,
    name: name ?? this.name,
    creatorId: creatorId.present ? creatorId.value : this.creatorId,
    rollOver: rollOver ?? this.rollOver,
    sinkDone: sinkDone ?? this.sinkDone,
    hideDone: hideDone ?? this.hideDone,
    boardIds: boardIds ?? this.boardIds,
    canManage: canManage ?? this.canManage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KPlanner copyWithCompanion(KPlannersCompanion data) {
    return KPlanner(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      rollOver: data.rollOver.present ? data.rollOver.value : this.rollOver,
      sinkDone: data.sinkDone.present ? data.sinkDone.value : this.sinkDone,
      hideDone: data.hideDone.present ? data.hideDone.value : this.hideDone,
      boardIds: data.boardIds.present ? data.boardIds.value : this.boardIds,
      canManage: data.canManage.present ? data.canManage.value : this.canManage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KPlanner(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('rollOver: $rollOver, ')
          ..write('sinkDone: $sinkDone, ')
          ..write('hideDone: $hideDone, ')
          ..write('boardIds: $boardIds, ')
          ..write('canManage: $canManage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    creatorId,
    rollOver,
    sinkDone,
    hideDone,
    boardIds,
    canManage,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KPlanner &&
          other.id == this.id &&
          other.name == this.name &&
          other.creatorId == this.creatorId &&
          other.rollOver == this.rollOver &&
          other.sinkDone == this.sinkDone &&
          other.hideDone == this.hideDone &&
          other.boardIds == this.boardIds &&
          other.canManage == this.canManage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class KPlannersCompanion extends UpdateCompanion<KPlanner> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> creatorId;
  final Value<bool> rollOver;
  final Value<bool> sinkDone;
  final Value<bool> hideDone;
  final Value<String> boardIds;
  final Value<bool> canManage;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KPlannersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.rollOver = const Value.absent(),
    this.sinkDone = const Value.absent(),
    this.hideDone = const Value.absent(),
    this.boardIds = const Value.absent(),
    this.canManage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KPlannersCompanion.insert({
    required String id,
    required String name,
    this.creatorId = const Value.absent(),
    this.rollOver = const Value.absent(),
    this.sinkDone = const Value.absent(),
    this.hideDone = const Value.absent(),
    this.boardIds = const Value.absent(),
    this.canManage = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<KPlanner> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? creatorId,
    Expression<bool>? rollOver,
    Expression<bool>? sinkDone,
    Expression<bool>? hideDone,
    Expression<String>? boardIds,
    Expression<bool>? canManage,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (creatorId != null) 'creator_id': creatorId,
      if (rollOver != null) 'roll_over': rollOver,
      if (sinkDone != null) 'sink_done': sinkDone,
      if (hideDone != null) 'hide_done': hideDone,
      if (boardIds != null) 'board_ids': boardIds,
      if (canManage != null) 'can_manage': canManage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KPlannersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int?>? creatorId,
    Value<bool>? rollOver,
    Value<bool>? sinkDone,
    Value<bool>? hideDone,
    Value<String>? boardIds,
    Value<bool>? canManage,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KPlannersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      rollOver: rollOver ?? this.rollOver,
      sinkDone: sinkDone ?? this.sinkDone,
      hideDone: hideDone ?? this.hideDone,
      boardIds: boardIds ?? this.boardIds,
      canManage: canManage ?? this.canManage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<int>(creatorId.value);
    }
    if (rollOver.present) {
      map['roll_over'] = Variable<bool>(rollOver.value);
    }
    if (sinkDone.present) {
      map['sink_done'] = Variable<bool>(sinkDone.value);
    }
    if (hideDone.present) {
      map['hide_done'] = Variable<bool>(hideDone.value);
    }
    if (boardIds.present) {
      map['board_ids'] = Variable<String>(boardIds.value);
    }
    if (canManage.present) {
      map['can_manage'] = Variable<bool>(canManage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KPlannersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('rollOver: $rollOver, ')
          ..write('sinkDone: $sinkDone, ')
          ..write('hideDone: $hideDone, ')
          ..write('boardIds: $boardIds, ')
          ..write('canManage: $canManage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KPlannerPeopleTable extends KPlannerPeople
    with TableInfo<$KPlannerPeopleTable, KPlannerPerson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KPlannerPeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _plannerIdMeta = const VerificationMeta(
    'plannerId',
  );
  @override
  late final GeneratedColumn<String> plannerId = GeneratedColumn<String>(
    'planner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('edit'),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [plannerId, userId, role, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_planner_people';
  @override
  VerificationContext validateIntegrity(
    Insertable<KPlannerPerson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('planner_id')) {
      context.handle(
        _plannerIdMeta,
        plannerId.isAcceptableOrUnknown(data['planner_id']!, _plannerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plannerIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {plannerId, userId};
  @override
  KPlannerPerson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KPlannerPerson(
      plannerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planner_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KPlannerPeopleTable createAlias(String alias) {
    return $KPlannerPeopleTable(attachedDatabase, alias);
  }
}

class KPlannerPerson extends DataClass implements Insertable<KPlannerPerson> {
  final String plannerId;
  final int userId;
  final String role;
  final int? deletedAt;
  const KPlannerPerson({
    required this.plannerId,
    required this.userId,
    required this.role,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['planner_id'] = Variable<String>(plannerId);
    map['user_id'] = Variable<int>(userId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KPlannerPeopleCompanion toCompanion(bool nullToAbsent) {
    return KPlannerPeopleCompanion(
      plannerId: Value(plannerId),
      userId: Value(userId),
      role: Value(role),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KPlannerPerson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KPlannerPerson(
      plannerId: serializer.fromJson<String>(json['plannerId']),
      userId: serializer.fromJson<int>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'plannerId': serializer.toJson<String>(plannerId),
      'userId': serializer.toJson<int>(userId),
      'role': serializer.toJson<String>(role),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KPlannerPerson copyWith({
    String? plannerId,
    int? userId,
    String? role,
    Value<int?> deletedAt = const Value.absent(),
  }) => KPlannerPerson(
    plannerId: plannerId ?? this.plannerId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KPlannerPerson copyWithCompanion(KPlannerPeopleCompanion data) {
    return KPlannerPerson(
      plannerId: data.plannerId.present ? data.plannerId.value : this.plannerId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KPlannerPerson(')
          ..write('plannerId: $plannerId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(plannerId, userId, role, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KPlannerPerson &&
          other.plannerId == this.plannerId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.deletedAt == this.deletedAt);
}

class KPlannerPeopleCompanion extends UpdateCompanion<KPlannerPerson> {
  final Value<String> plannerId;
  final Value<int> userId;
  final Value<String> role;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KPlannerPeopleCompanion({
    this.plannerId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KPlannerPeopleCompanion.insert({
    required String plannerId,
    required int userId,
    this.role = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : plannerId = Value(plannerId),
       userId = Value(userId);
  static Insertable<KPlannerPerson> custom({
    Expression<String>? plannerId,
    Expression<int>? userId,
    Expression<String>? role,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (plannerId != null) 'planner_id': plannerId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KPlannerPeopleCompanion copyWith({
    Value<String>? plannerId,
    Value<int>? userId,
    Value<String>? role,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KPlannerPeopleCompanion(
      plannerId: plannerId ?? this.plannerId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (plannerId.present) {
      map['planner_id'] = Variable<String>(plannerId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KPlannerPeopleCompanion(')
          ..write('plannerId: $plannerId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KTodosTable extends KTodos with TableInfo<$KTodosTable, KTodo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KTodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannerIdMeta = const VerificationMeta(
    'plannerId',
  );
  @override
  late final GeneratedColumn<String> plannerId = GeneratedColumn<String>(
    'planner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listMeta = const VerificationMeta('list');
  @override
  late final GeneratedColumn<int> list = GeneratedColumn<int>(
    'list',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<int> doneAt = GeneratedColumn<int>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assigneeIdMeta = const VerificationMeta(
    'assigneeId',
  );
  @override
  late final GeneratedColumn<int> assigneeId = GeneratedColumn<int>(
    'assignee_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>(
    'creator_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plannerId,
    day,
    list,
    title,
    note,
    doneAt,
    position,
    repeat,
    assigneeId,
    creatorId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<KTodo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('planner_id')) {
      context.handle(
        _plannerIdMeta,
        plannerId.isAcceptableOrUnknown(data['planner_id']!, _plannerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plannerIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('list')) {
      context.handle(
        _listMeta,
        list.isAcceptableOrUnknown(data['list']!, _listMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('repeat')) {
      context.handle(
        _repeatMeta,
        repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta),
      );
    }
    if (data.containsKey('assignee_id')) {
      context.handle(
        _assigneeIdMeta,
        assigneeId.isAcceptableOrUnknown(data['assignee_id']!, _assigneeIdMeta),
      );
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KTodo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KTodo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plannerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planner_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      ),
      list: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done_at'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      repeat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat'],
      ),
      assigneeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}assignee_id'],
      ),
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creator_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KTodosTable createAlias(String alias) {
    return $KTodosTable(attachedDatabase, alias);
  }
}

class KTodo extends DataClass implements Insertable<KTodo> {
  final String id;
  final String plannerId;
  final String? day;
  final int? list;
  final String title;
  final String note;
  final int? doneAt;
  final double position;
  final String? repeat;
  final int? assigneeId;
  final int? creatorId;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const KTodo({
    required this.id,
    required this.plannerId,
    this.day,
    this.list,
    required this.title,
    required this.note,
    this.doneAt,
    required this.position,
    this.repeat,
    this.assigneeId,
    this.creatorId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['planner_id'] = Variable<String>(plannerId);
    if (!nullToAbsent || day != null) {
      map['day'] = Variable<String>(day);
    }
    if (!nullToAbsent || list != null) {
      map['list'] = Variable<int>(list);
    }
    map['title'] = Variable<String>(title);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<int>(doneAt);
    }
    map['position'] = Variable<double>(position);
    if (!nullToAbsent || repeat != null) {
      map['repeat'] = Variable<String>(repeat);
    }
    if (!nullToAbsent || assigneeId != null) {
      map['assignee_id'] = Variable<int>(assigneeId);
    }
    if (!nullToAbsent || creatorId != null) {
      map['creator_id'] = Variable<int>(creatorId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KTodosCompanion toCompanion(bool nullToAbsent) {
    return KTodosCompanion(
      id: Value(id),
      plannerId: Value(plannerId),
      day: day == null && nullToAbsent ? const Value.absent() : Value(day),
      list: list == null && nullToAbsent ? const Value.absent() : Value(list),
      title: Value(title),
      note: Value(note),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      position: Value(position),
      repeat: repeat == null && nullToAbsent
          ? const Value.absent()
          : Value(repeat),
      assigneeId: assigneeId == null && nullToAbsent
          ? const Value.absent()
          : Value(assigneeId),
      creatorId: creatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(creatorId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KTodo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KTodo(
      id: serializer.fromJson<String>(json['id']),
      plannerId: serializer.fromJson<String>(json['plannerId']),
      day: serializer.fromJson<String?>(json['day']),
      list: serializer.fromJson<int?>(json['list']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String>(json['note']),
      doneAt: serializer.fromJson<int?>(json['doneAt']),
      position: serializer.fromJson<double>(json['position']),
      repeat: serializer.fromJson<String?>(json['repeat']),
      assigneeId: serializer.fromJson<int?>(json['assigneeId']),
      creatorId: serializer.fromJson<int?>(json['creatorId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plannerId': serializer.toJson<String>(plannerId),
      'day': serializer.toJson<String?>(day),
      'list': serializer.toJson<int?>(list),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String>(note),
      'doneAt': serializer.toJson<int?>(doneAt),
      'position': serializer.toJson<double>(position),
      'repeat': serializer.toJson<String?>(repeat),
      'assigneeId': serializer.toJson<int?>(assigneeId),
      'creatorId': serializer.toJson<int?>(creatorId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KTodo copyWith({
    String? id,
    String? plannerId,
    Value<String?> day = const Value.absent(),
    Value<int?> list = const Value.absent(),
    String? title,
    String? note,
    Value<int?> doneAt = const Value.absent(),
    double? position,
    Value<String?> repeat = const Value.absent(),
    Value<int?> assigneeId = const Value.absent(),
    Value<int?> creatorId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KTodo(
    id: id ?? this.id,
    plannerId: plannerId ?? this.plannerId,
    day: day.present ? day.value : this.day,
    list: list.present ? list.value : this.list,
    title: title ?? this.title,
    note: note ?? this.note,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    position: position ?? this.position,
    repeat: repeat.present ? repeat.value : this.repeat,
    assigneeId: assigneeId.present ? assigneeId.value : this.assigneeId,
    creatorId: creatorId.present ? creatorId.value : this.creatorId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KTodo copyWithCompanion(KTodosCompanion data) {
    return KTodo(
      id: data.id.present ? data.id.value : this.id,
      plannerId: data.plannerId.present ? data.plannerId.value : this.plannerId,
      day: data.day.present ? data.day.value : this.day,
      list: data.list.present ? data.list.value : this.list,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      position: data.position.present ? data.position.value : this.position,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      assigneeId: data.assigneeId.present
          ? data.assigneeId.value
          : this.assigneeId,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KTodo(')
          ..write('id: $id, ')
          ..write('plannerId: $plannerId, ')
          ..write('day: $day, ')
          ..write('list: $list, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('doneAt: $doneAt, ')
          ..write('position: $position, ')
          ..write('repeat: $repeat, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('creatorId: $creatorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plannerId,
    day,
    list,
    title,
    note,
    doneAt,
    position,
    repeat,
    assigneeId,
    creatorId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KTodo &&
          other.id == this.id &&
          other.plannerId == this.plannerId &&
          other.day == this.day &&
          other.list == this.list &&
          other.title == this.title &&
          other.note == this.note &&
          other.doneAt == this.doneAt &&
          other.position == this.position &&
          other.repeat == this.repeat &&
          other.assigneeId == this.assigneeId &&
          other.creatorId == this.creatorId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class KTodosCompanion extends UpdateCompanion<KTodo> {
  final Value<String> id;
  final Value<String> plannerId;
  final Value<String?> day;
  final Value<int?> list;
  final Value<String> title;
  final Value<String> note;
  final Value<int?> doneAt;
  final Value<double> position;
  final Value<String?> repeat;
  final Value<int?> assigneeId;
  final Value<int?> creatorId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KTodosCompanion({
    this.id = const Value.absent(),
    this.plannerId = const Value.absent(),
    this.day = const Value.absent(),
    this.list = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.position = const Value.absent(),
    this.repeat = const Value.absent(),
    this.assigneeId = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KTodosCompanion.insert({
    required String id,
    required String plannerId,
    this.day = const Value.absent(),
    this.list = const Value.absent(),
    required String title,
    this.note = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.position = const Value.absent(),
    this.repeat = const Value.absent(),
    this.assigneeId = const Value.absent(),
    this.creatorId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plannerId = Value(plannerId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<KTodo> custom({
    Expression<String>? id,
    Expression<String>? plannerId,
    Expression<String>? day,
    Expression<int>? list,
    Expression<String>? title,
    Expression<String>? note,
    Expression<int>? doneAt,
    Expression<double>? position,
    Expression<String>? repeat,
    Expression<int>? assigneeId,
    Expression<int>? creatorId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plannerId != null) 'planner_id': plannerId,
      if (day != null) 'day': day,
      if (list != null) 'list': list,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (doneAt != null) 'done_at': doneAt,
      if (position != null) 'position': position,
      if (repeat != null) 'repeat': repeat,
      if (assigneeId != null) 'assignee_id': assigneeId,
      if (creatorId != null) 'creator_id': creatorId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KTodosCompanion copyWith({
    Value<String>? id,
    Value<String>? plannerId,
    Value<String?>? day,
    Value<int?>? list,
    Value<String>? title,
    Value<String>? note,
    Value<int?>? doneAt,
    Value<double>? position,
    Value<String?>? repeat,
    Value<int?>? assigneeId,
    Value<int?>? creatorId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KTodosCompanion(
      id: id ?? this.id,
      plannerId: plannerId ?? this.plannerId,
      day: day ?? this.day,
      list: list ?? this.list,
      title: title ?? this.title,
      note: note ?? this.note,
      doneAt: doneAt ?? this.doneAt,
      position: position ?? this.position,
      repeat: repeat ?? this.repeat,
      assigneeId: assigneeId ?? this.assigneeId,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plannerId.present) {
      map['planner_id'] = Variable<String>(plannerId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (list.present) {
      map['list'] = Variable<int>(list.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<int>(doneAt.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (assigneeId.present) {
      map['assignee_id'] = Variable<int>(assigneeId.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<int>(creatorId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KTodosCompanion(')
          ..write('id: $id, ')
          ..write('plannerId: $plannerId, ')
          ..write('day: $day, ')
          ..write('list: $list, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('doneAt: $doneAt, ')
          ..write('position: $position, ')
          ..write('repeat: $repeat, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('creatorId: $creatorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KTodoMarksTable extends KTodoMarks
    with TableInfo<$KTodoMarksTable, KTodoMark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KTodoMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<String> todoId = GeneratedColumn<String>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markMeta = const VerificationMeta('mark');
  @override
  late final GeneratedColumn<String> mark = GeneratedColumn<String>(
    'mark',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [todoId, day, mark, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_todo_marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<KTodoMark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('mark')) {
      context.handle(
        _markMeta,
        mark.isAcceptableOrUnknown(data['mark']!, _markMeta),
      );
    } else if (isInserting) {
      context.missing(_markMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {todoId, day};
  @override
  KTodoMark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KTodoMark(
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      mark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mark'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KTodoMarksTable createAlias(String alias) {
    return $KTodoMarksTable(attachedDatabase, alias);
  }
}

class KTodoMark extends DataClass implements Insertable<KTodoMark> {
  final String todoId;
  final String day;
  final String mark;
  final int? deletedAt;
  const KTodoMark({
    required this.todoId,
    required this.day,
    required this.mark,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['todo_id'] = Variable<String>(todoId);
    map['day'] = Variable<String>(day);
    map['mark'] = Variable<String>(mark);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KTodoMarksCompanion toCompanion(bool nullToAbsent) {
    return KTodoMarksCompanion(
      todoId: Value(todoId),
      day: Value(day),
      mark: Value(mark),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KTodoMark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KTodoMark(
      todoId: serializer.fromJson<String>(json['todoId']),
      day: serializer.fromJson<String>(json['day']),
      mark: serializer.fromJson<String>(json['mark']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'todoId': serializer.toJson<String>(todoId),
      'day': serializer.toJson<String>(day),
      'mark': serializer.toJson<String>(mark),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KTodoMark copyWith({
    String? todoId,
    String? day,
    String? mark,
    Value<int?> deletedAt = const Value.absent(),
  }) => KTodoMark(
    todoId: todoId ?? this.todoId,
    day: day ?? this.day,
    mark: mark ?? this.mark,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KTodoMark copyWithCompanion(KTodoMarksCompanion data) {
    return KTodoMark(
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      day: data.day.present ? data.day.value : this.day,
      mark: data.mark.present ? data.mark.value : this.mark,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KTodoMark(')
          ..write('todoId: $todoId, ')
          ..write('day: $day, ')
          ..write('mark: $mark, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(todoId, day, mark, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KTodoMark &&
          other.todoId == this.todoId &&
          other.day == this.day &&
          other.mark == this.mark &&
          other.deletedAt == this.deletedAt);
}

class KTodoMarksCompanion extends UpdateCompanion<KTodoMark> {
  final Value<String> todoId;
  final Value<String> day;
  final Value<String> mark;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KTodoMarksCompanion({
    this.todoId = const Value.absent(),
    this.day = const Value.absent(),
    this.mark = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KTodoMarksCompanion.insert({
    required String todoId,
    required String day,
    required String mark,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : todoId = Value(todoId),
       day = Value(day),
       mark = Value(mark);
  static Insertable<KTodoMark> custom({
    Expression<String>? todoId,
    Expression<String>? day,
    Expression<String>? mark,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (todoId != null) 'todo_id': todoId,
      if (day != null) 'day': day,
      if (mark != null) 'mark': mark,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KTodoMarksCompanion copyWith({
    Value<String>? todoId,
    Value<String>? day,
    Value<String>? mark,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KTodoMarksCompanion(
      todoId: todoId ?? this.todoId,
      day: day ?? this.day,
      mark: mark ?? this.mark,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (todoId.present) {
      map['todo_id'] = Variable<String>(todoId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (mark.present) {
      map['mark'] = Variable<String>(mark.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KTodoMarksCompanion(')
          ..write('todoId: $todoId, ')
          ..write('day: $day, ')
          ..write('mark: $mark, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KTodoStepsTable extends KTodoSteps
    with TableInfo<$KTodoStepsTable, KTodoStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KTodoStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<String> todoId = GeneratedColumn<String>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _headingMeta = const VerificationMeta(
    'heading',
  );
  @override
  late final GeneratedColumn<bool> heading = GeneratedColumn<bool>(
    'heading',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("heading" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _indentMeta = const VerificationMeta('indent');
  @override
  late final GeneratedColumn<int> indent = GeneratedColumn<int>(
    'indent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starMeta = const VerificationMeta('star');
  @override
  late final GeneratedColumn<bool> star = GeneratedColumn<bool>(
    'star',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("star" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    todoId,
    content,
    done,
    heading,
    indent,
    star,
    position,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_todo_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<KTodoStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('heading')) {
      context.handle(
        _headingMeta,
        heading.isAcceptableOrUnknown(data['heading']!, _headingMeta),
      );
    }
    if (data.containsKey('indent')) {
      context.handle(
        _indentMeta,
        indent.isAcceptableOrUnknown(data['indent']!, _indentMeta),
      );
    }
    if (data.containsKey('star')) {
      context.handle(
        _starMeta,
        star.isAcceptableOrUnknown(data['star']!, _starMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KTodoStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KTodoStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      heading: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}heading'],
      )!,
      indent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}indent'],
      )!,
      star: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}star'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $KTodoStepsTable createAlias(String alias) {
    return $KTodoStepsTable(attachedDatabase, alias);
  }
}

class KTodoStep extends DataClass implements Insertable<KTodoStep> {
  final String id;
  final String todoId;
  final String content;
  final bool done;
  final bool heading;
  final int indent;
  final bool star;
  final double position;
  final int createdAt;
  final int? deletedAt;
  const KTodoStep({
    required this.id,
    required this.todoId,
    required this.content,
    required this.done,
    required this.heading,
    required this.indent,
    required this.star,
    required this.position,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['todo_id'] = Variable<String>(todoId);
    map['content'] = Variable<String>(content);
    map['done'] = Variable<bool>(done);
    map['heading'] = Variable<bool>(heading);
    map['indent'] = Variable<int>(indent);
    map['star'] = Variable<bool>(star);
    map['position'] = Variable<double>(position);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  KTodoStepsCompanion toCompanion(bool nullToAbsent) {
    return KTodoStepsCompanion(
      id: Value(id),
      todoId: Value(todoId),
      content: Value(content),
      done: Value(done),
      heading: Value(heading),
      indent: Value(indent),
      star: Value(star),
      position: Value(position),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory KTodoStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KTodoStep(
      id: serializer.fromJson<String>(json['id']),
      todoId: serializer.fromJson<String>(json['todoId']),
      content: serializer.fromJson<String>(json['content']),
      done: serializer.fromJson<bool>(json['done']),
      heading: serializer.fromJson<bool>(json['heading']),
      indent: serializer.fromJson<int>(json['indent']),
      star: serializer.fromJson<bool>(json['star']),
      position: serializer.fromJson<double>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'todoId': serializer.toJson<String>(todoId),
      'content': serializer.toJson<String>(content),
      'done': serializer.toJson<bool>(done),
      'heading': serializer.toJson<bool>(heading),
      'indent': serializer.toJson<int>(indent),
      'star': serializer.toJson<bool>(star),
      'position': serializer.toJson<double>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  KTodoStep copyWith({
    String? id,
    String? todoId,
    String? content,
    bool? done,
    bool? heading,
    int? indent,
    bool? star,
    double? position,
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => KTodoStep(
    id: id ?? this.id,
    todoId: todoId ?? this.todoId,
    content: content ?? this.content,
    done: done ?? this.done,
    heading: heading ?? this.heading,
    indent: indent ?? this.indent,
    star: star ?? this.star,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  KTodoStep copyWithCompanion(KTodoStepsCompanion data) {
    return KTodoStep(
      id: data.id.present ? data.id.value : this.id,
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      content: data.content.present ? data.content.value : this.content,
      done: data.done.present ? data.done.value : this.done,
      heading: data.heading.present ? data.heading.value : this.heading,
      indent: data.indent.present ? data.indent.value : this.indent,
      star: data.star.present ? data.star.value : this.star,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KTodoStep(')
          ..write('id: $id, ')
          ..write('todoId: $todoId, ')
          ..write('content: $content, ')
          ..write('done: $done, ')
          ..write('heading: $heading, ')
          ..write('indent: $indent, ')
          ..write('star: $star, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    todoId,
    content,
    done,
    heading,
    indent,
    star,
    position,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KTodoStep &&
          other.id == this.id &&
          other.todoId == this.todoId &&
          other.content == this.content &&
          other.done == this.done &&
          other.heading == this.heading &&
          other.indent == this.indent &&
          other.star == this.star &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class KTodoStepsCompanion extends UpdateCompanion<KTodoStep> {
  final Value<String> id;
  final Value<String> todoId;
  final Value<String> content;
  final Value<bool> done;
  final Value<bool> heading;
  final Value<int> indent;
  final Value<bool> star;
  final Value<double> position;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const KTodoStepsCompanion({
    this.id = const Value.absent(),
    this.todoId = const Value.absent(),
    this.content = const Value.absent(),
    this.done = const Value.absent(),
    this.heading = const Value.absent(),
    this.indent = const Value.absent(),
    this.star = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KTodoStepsCompanion.insert({
    required String id,
    required String todoId,
    required String content,
    this.done = const Value.absent(),
    this.heading = const Value.absent(),
    this.indent = const Value.absent(),
    this.star = const Value.absent(),
    this.position = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       todoId = Value(todoId),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<KTodoStep> custom({
    Expression<String>? id,
    Expression<String>? todoId,
    Expression<String>? content,
    Expression<bool>? done,
    Expression<bool>? heading,
    Expression<int>? indent,
    Expression<bool>? star,
    Expression<double>? position,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (todoId != null) 'todo_id': todoId,
      if (content != null) 'content': content,
      if (done != null) 'done': done,
      if (heading != null) 'heading': heading,
      if (indent != null) 'indent': indent,
      if (star != null) 'star': star,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KTodoStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? todoId,
    Value<String>? content,
    Value<bool>? done,
    Value<bool>? heading,
    Value<int>? indent,
    Value<bool>? star,
    Value<double>? position,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return KTodoStepsCompanion(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      content: content ?? this.content,
      done: done ?? this.done,
      heading: heading ?? this.heading,
      indent: indent ?? this.indent,
      star: star ?? this.star,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (todoId.present) {
      map['todo_id'] = Variable<String>(todoId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (heading.present) {
      map['heading'] = Variable<bool>(heading.value);
    }
    if (indent.present) {
      map['indent'] = Variable<int>(indent.value);
    }
    if (star.present) {
      map['star'] = Variable<bool>(star.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KTodoStepsCompanion(')
          ..write('id: $id, ')
          ..write('todoId: $todoId, ')
          ..write('content: $content, ')
          ..write('done: $done, ')
          ..write('heading: $heading, ')
          ..write('indent: $indent, ')
          ..write('star: $star, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KTodoFilesTable extends KTodoFiles
    with TableInfo<$KTodoFilesTable, KTodoFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KTodoFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<String> todoId = GeneratedColumn<String>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('application/octet-stream'),
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasThumbMeta = const VerificationMeta(
    'hasThumb',
  );
  @override
  late final GeneratedColumn<bool> hasThumb = GeneratedColumn<bool>(
    'has_thumb',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_thumb" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    todoId,
    userId,
    filename,
    mime,
    size,
    width,
    height,
    hasThumb,
    createdAt,
    deletedAt,
    localPath,
    uploaded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_todo_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<KTodoFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('has_thumb')) {
      context.handle(
        _hasThumbMeta,
        hasThumb.isAcceptableOrUnknown(data['has_thumb']!, _hasThumbMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KTodoFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KTodoFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      hasThumb: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_thumb'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
    );
  }

  @override
  $KTodoFilesTable createAlias(String alias) {
    return $KTodoFilesTable(attachedDatabase, alias);
  }
}

class KTodoFile extends DataClass implements Insertable<KTodoFile> {
  final String id;
  final String todoId;
  final int userId;
  final String filename;
  final String mime;
  final int size;
  final int? width;
  final int? height;
  final bool hasThumb;
  final int createdAt;
  final int? deletedAt;
  final String? localPath;
  final bool uploaded;
  const KTodoFile({
    required this.id,
    required this.todoId,
    required this.userId,
    required this.filename,
    required this.mime,
    required this.size,
    this.width,
    this.height,
    required this.hasThumb,
    required this.createdAt,
    this.deletedAt,
    this.localPath,
    required this.uploaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['todo_id'] = Variable<String>(todoId);
    map['user_id'] = Variable<int>(userId);
    map['filename'] = Variable<String>(filename);
    map['mime'] = Variable<String>(mime);
    map['size'] = Variable<int>(size);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['has_thumb'] = Variable<bool>(hasThumb);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['uploaded'] = Variable<bool>(uploaded);
    return map;
  }

  KTodoFilesCompanion toCompanion(bool nullToAbsent) {
    return KTodoFilesCompanion(
      id: Value(id),
      todoId: Value(todoId),
      userId: Value(userId),
      filename: Value(filename),
      mime: Value(mime),
      size: Value(size),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      hasThumb: Value(hasThumb),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      uploaded: Value(uploaded),
    );
  }

  factory KTodoFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KTodoFile(
      id: serializer.fromJson<String>(json['id']),
      todoId: serializer.fromJson<String>(json['todoId']),
      userId: serializer.fromJson<int>(json['userId']),
      filename: serializer.fromJson<String>(json['filename']),
      mime: serializer.fromJson<String>(json['mime']),
      size: serializer.fromJson<int>(json['size']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      hasThumb: serializer.fromJson<bool>(json['hasThumb']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'todoId': serializer.toJson<String>(todoId),
      'userId': serializer.toJson<int>(userId),
      'filename': serializer.toJson<String>(filename),
      'mime': serializer.toJson<String>(mime),
      'size': serializer.toJson<int>(size),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'hasThumb': serializer.toJson<bool>(hasThumb),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localPath': serializer.toJson<String?>(localPath),
      'uploaded': serializer.toJson<bool>(uploaded),
    };
  }

  KTodoFile copyWith({
    String? id,
    String? todoId,
    int? userId,
    String? filename,
    String? mime,
    int? size,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    bool? hasThumb,
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    bool? uploaded,
  }) => KTodoFile(
    id: id ?? this.id,
    todoId: todoId ?? this.todoId,
    userId: userId ?? this.userId,
    filename: filename ?? this.filename,
    mime: mime ?? this.mime,
    size: size ?? this.size,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    hasThumb: hasThumb ?? this.hasThumb,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localPath: localPath.present ? localPath.value : this.localPath,
    uploaded: uploaded ?? this.uploaded,
  );
  KTodoFile copyWithCompanion(KTodoFilesCompanion data) {
    return KTodoFile(
      id: data.id.present ? data.id.value : this.id,
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      userId: data.userId.present ? data.userId.value : this.userId,
      filename: data.filename.present ? data.filename.value : this.filename,
      mime: data.mime.present ? data.mime.value : this.mime,
      size: data.size.present ? data.size.value : this.size,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      hasThumb: data.hasThumb.present ? data.hasThumb.value : this.hasThumb,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KTodoFile(')
          ..write('id: $id, ')
          ..write('todoId: $todoId, ')
          ..write('userId: $userId, ')
          ..write('filename: $filename, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('hasThumb: $hasThumb, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localPath: $localPath, ')
          ..write('uploaded: $uploaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    todoId,
    userId,
    filename,
    mime,
    size,
    width,
    height,
    hasThumb,
    createdAt,
    deletedAt,
    localPath,
    uploaded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KTodoFile &&
          other.id == this.id &&
          other.todoId == this.todoId &&
          other.userId == this.userId &&
          other.filename == this.filename &&
          other.mime == this.mime &&
          other.size == this.size &&
          other.width == this.width &&
          other.height == this.height &&
          other.hasThumb == this.hasThumb &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.localPath == this.localPath &&
          other.uploaded == this.uploaded);
}

class KTodoFilesCompanion extends UpdateCompanion<KTodoFile> {
  final Value<String> id;
  final Value<String> todoId;
  final Value<int> userId;
  final Value<String> filename;
  final Value<String> mime;
  final Value<int> size;
  final Value<int?> width;
  final Value<int?> height;
  final Value<bool> hasThumb;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<String?> localPath;
  final Value<bool> uploaded;
  final Value<int> rowid;
  const KTodoFilesCompanion({
    this.id = const Value.absent(),
    this.todoId = const Value.absent(),
    this.userId = const Value.absent(),
    this.filename = const Value.absent(),
    this.mime = const Value.absent(),
    this.size = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.hasThumb = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localPath = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KTodoFilesCompanion.insert({
    required String id,
    required String todoId,
    this.userId = const Value.absent(),
    required String filename,
    this.mime = const Value.absent(),
    this.size = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.hasThumb = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.localPath = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       todoId = Value(todoId),
       filename = Value(filename),
       createdAt = Value(createdAt);
  static Insertable<KTodoFile> custom({
    Expression<String>? id,
    Expression<String>? todoId,
    Expression<int>? userId,
    Expression<String>? filename,
    Expression<String>? mime,
    Expression<int>? size,
    Expression<int>? width,
    Expression<int>? height,
    Expression<bool>? hasThumb,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<String>? localPath,
    Expression<bool>? uploaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (todoId != null) 'todo_id': todoId,
      if (userId != null) 'user_id': userId,
      if (filename != null) 'filename': filename,
      if (mime != null) 'mime': mime,
      if (size != null) 'size': size,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (hasThumb != null) 'has_thumb': hasThumb,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localPath != null) 'local_path': localPath,
      if (uploaded != null) 'uploaded': uploaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KTodoFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? todoId,
    Value<int>? userId,
    Value<String>? filename,
    Value<String>? mime,
    Value<int>? size,
    Value<int?>? width,
    Value<int?>? height,
    Value<bool>? hasThumb,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<String?>? localPath,
    Value<bool>? uploaded,
    Value<int>? rowid,
  }) {
    return KTodoFilesCompanion(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      userId: userId ?? this.userId,
      filename: filename ?? this.filename,
      mime: mime ?? this.mime,
      size: size ?? this.size,
      width: width ?? this.width,
      height: height ?? this.height,
      hasThumb: hasThumb ?? this.hasThumb,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localPath: localPath ?? this.localPath,
      uploaded: uploaded ?? this.uploaded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (todoId.present) {
      map['todo_id'] = Variable<String>(todoId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (hasThumb.present) {
      map['has_thumb'] = Variable<bool>(hasThumb.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KTodoFilesCompanion(')
          ..write('id: $id, ')
          ..write('todoId: $todoId, ')
          ..write('userId: $userId, ')
          ..write('filename: $filename, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('hasThumb: $hasThumb, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localPath: $localPath, ')
          ..write('uploaded: $uploaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KRemindersTable extends KReminders
    with TableInfo<$KRemindersTable, KReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, kind, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<KReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  KReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KReminder(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      ),
    );
  }

  @override
  $KRemindersTable createAlias(String alias) {
    return $KRemindersTable(attachedDatabase, alias);
  }
}

class KReminder extends DataClass implements Insertable<KReminder> {
  final String itemId;
  final String kind;
  final int? at;
  const KReminder({required this.itemId, required this.kind, this.at});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<int>(at);
    }
    return map;
  }

  KRemindersCompanion toCompanion(bool nullToAbsent) {
    return KRemindersCompanion(
      itemId: Value(itemId),
      kind: Value(kind),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
    );
  }

  factory KReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KReminder(
      itemId: serializer.fromJson<String>(json['itemId']),
      kind: serializer.fromJson<String>(json['kind']),
      at: serializer.fromJson<int?>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'kind': serializer.toJson<String>(kind),
      'at': serializer.toJson<int?>(at),
    };
  }

  KReminder copyWith({
    String? itemId,
    String? kind,
    Value<int?> at = const Value.absent(),
  }) => KReminder(
    itemId: itemId ?? this.itemId,
    kind: kind ?? this.kind,
    at: at.present ? at.value : this.at,
  );
  KReminder copyWithCompanion(KRemindersCompanion data) {
    return KReminder(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      kind: data.kind.present ? data.kind.value : this.kind,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KReminder(')
          ..write('itemId: $itemId, ')
          ..write('kind: $kind, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, kind, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KReminder &&
          other.itemId == this.itemId &&
          other.kind == this.kind &&
          other.at == this.at);
}

class KRemindersCompanion extends UpdateCompanion<KReminder> {
  final Value<String> itemId;
  final Value<String> kind;
  final Value<int?> at;
  final Value<int> rowid;
  const KRemindersCompanion({
    this.itemId = const Value.absent(),
    this.kind = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KRemindersCompanion.insert({
    required String itemId,
    required String kind,
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       kind = Value(kind);
  static Insertable<KReminder> custom({
    Expression<String>? itemId,
    Expression<String>? kind,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (kind != null) 'kind': kind,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KRemindersCompanion copyWith({
    Value<String>? itemId,
    Value<String>? kind,
    Value<int?>? at,
    Value<int>? rowid,
  }) {
    return KRemindersCompanion(
      itemId: itemId ?? this.itemId,
      kind: kind ?? this.kind,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KRemindersCompanion(')
          ..write('itemId: $itemId, ')
          ..write('kind: $kind, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$KolumnDb extends GeneratedDatabase {
  _$KolumnDb(QueryExecutor e) : super(e);
  $KolumnDbManager get managers => $KolumnDbManager(this);
  late final $KBoardsTable kBoards = $KBoardsTable(this);
  late final $KColumnsTable kColumns = $KColumnsTable(this);
  late final $KCardsTable kCards = $KCardsTable(this);
  late final $KPeopleTable kPeople = $KPeopleTable(this);
  late final $KSettingsTable kSettings = $KSettingsTable(this);
  late final $KOutboxTable kOutbox = $KOutboxTable(this);
  late final $KStepsTable kSteps = $KStepsTable(this);
  late final $KCommentsTable kComments = $KCommentsTable(this);
  late final $KReactionsTable kReactions = $KReactionsTable(this);
  late final $KTagsTable kTags = $KTagsTable(this);
  late final $KAssigneesTable kAssignees = $KAssigneesTable(this);
  late final $KWatchesTable kWatches = $KWatchesTable(this);
  late final $KPinsTable kPins = $KPinsTable(this);
  late final $KFilesTable kFiles = $KFilesTable(this);
  late final $KEventsTable kEvents = $KEventsTable(this);
  late final $KPlannersTable kPlanners = $KPlannersTable(this);
  late final $KPlannerPeopleTable kPlannerPeople = $KPlannerPeopleTable(this);
  late final $KTodosTable kTodos = $KTodosTable(this);
  late final $KTodoMarksTable kTodoMarks = $KTodoMarksTable(this);
  late final $KTodoStepsTable kTodoSteps = $KTodoStepsTable(this);
  late final $KTodoFilesTable kTodoFiles = $KTodoFilesTable(this);
  late final $KRemindersTable kReminders = $KRemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    kBoards,
    kColumns,
    kCards,
    kPeople,
    kSettings,
    kOutbox,
    kSteps,
    kComments,
    kReactions,
    kTags,
    kAssignees,
    kWatches,
    kPins,
    kFiles,
    kEvents,
    kPlanners,
    kPlannerPeople,
    kTodos,
    kTodoMarks,
    kTodoSteps,
    kTodoFiles,
    kReminders,
  ];
}

typedef $$KBoardsTableCreateCompanionBuilder = KBoardsCompanion Function({
  required String id,
  required String name,
  Value<int?> tidyDays,
  Value<bool> allAccess,
  Value<int?> creatorId,
  Value<String> members,
  Value<bool> canManage,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KBoardsTableUpdateCompanionBuilder = KBoardsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> tidyDays,
  Value<bool> allAccess,
  Value<int?> creatorId,
  Value<String> members,
  Value<bool> canManage,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KBoardsTableFilterComposer extends Composer<_$KolumnDb, $KBoardsTable> {
  $$KBoardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tidyDays => $composableBuilder(
    column: $table.tidyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allAccess => $composableBuilder(
    column: $table.allAccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get members => $composableBuilder(
    column: $table.members,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManage => $composableBuilder(
    column: $table.canManage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KBoardsTableOrderingComposer
    extends Composer<_$KolumnDb, $KBoardsTable> {
  $$KBoardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tidyDays => $composableBuilder(
    column: $table.tidyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allAccess => $composableBuilder(
    column: $table.allAccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get members => $composableBuilder(
    column: $table.members,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManage => $composableBuilder(
    column: $table.canManage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KBoardsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KBoardsTable> {
  $$KBoardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get tidyDays =>
      $composableBuilder(column: $table.tidyDays, builder: (column) => column);

  GeneratedColumn<bool> get allAccess =>
      $composableBuilder(column: $table.allAccess, builder: (column) => column);

  GeneratedColumn<int> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<String> get members =>
      $composableBuilder(column: $table.members, builder: (column) => column);

  GeneratedColumn<bool> get canManage =>
      $composableBuilder(column: $table.canManage, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KBoardsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KBoardsTable,
          KBoard,
          $$KBoardsTableFilterComposer,
          $$KBoardsTableOrderingComposer,
          $$KBoardsTableAnnotationComposer,
          $$KBoardsTableCreateCompanionBuilder,
          $$KBoardsTableUpdateCompanionBuilder,
          (KBoard, BaseReferences<_$KolumnDb, $KBoardsTable, KBoard>),
          KBoard,
          PrefetchHooks Function()
        > {
  $$KBoardsTableTableManager(_$KolumnDb db, $KBoardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KBoardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KBoardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KBoardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> tidyDays = const Value.absent(),
                Value<bool> allAccess = const Value.absent(),
                Value<int?> creatorId = const Value.absent(),
                Value<String> members = const Value.absent(),
                Value<bool> canManage = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KBoardsCompanion(
                id: id,
                name: name,
                tidyDays: tidyDays,
                allAccess: allAccess,
                creatorId: creatorId,
                members: members,
                canManage: canManage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int?> tidyDays = const Value.absent(),
                Value<bool> allAccess = const Value.absent(),
                Value<int?> creatorId = const Value.absent(),
                Value<String> members = const Value.absent(),
                Value<bool> canManage = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KBoardsCompanion.insert(
                id: id,
                name: name,
                tidyDays: tidyDays,
                allAccess: allAccess,
                creatorId: creatorId,
                members: members,
                canManage: canManage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KBoardsTable, KBoard>(table),
                  BaseReferences<_$KolumnDb, $KBoardsTable, KBoard>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KBoardsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KBoardsTable,
      KBoard,
      $$KBoardsTableFilterComposer,
      $$KBoardsTableOrderingComposer,
      $$KBoardsTableAnnotationComposer,
      $$KBoardsTableCreateCompanionBuilder,
      $$KBoardsTableUpdateCompanionBuilder,
      (KBoard, BaseReferences<_$KolumnDb, $KBoardsTable, KBoard>),
      KBoard,
      PrefetchHooks Function()
    >;
typedef $$KColumnsTableCreateCompanionBuilder = KColumnsCompanion Function({
  required String id,
  required String boardId,
  required String name,
  Value<int> color,
  required double position,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KColumnsTableUpdateCompanionBuilder = KColumnsCompanion Function({
  Value<String> id,
  Value<String> boardId,
  Value<String> name,
  Value<int> color,
  Value<double> position,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KColumnsTableFilterComposer
    extends Composer<_$KolumnDb, $KColumnsTable> {
  $$KColumnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KColumnsTableOrderingComposer
    extends Composer<_$KolumnDb, $KColumnsTable> {
  $$KColumnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KColumnsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KColumnsTable> {
  $$KColumnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KColumnsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KColumnsTable,
          KColumn,
          $$KColumnsTableFilterComposer,
          $$KColumnsTableOrderingComposer,
          $$KColumnsTableAnnotationComposer,
          $$KColumnsTableCreateCompanionBuilder,
          $$KColumnsTableUpdateCompanionBuilder,
          (KColumn, BaseReferences<_$KolumnDb, $KColumnsTable, KColumn>),
          KColumn,
          PrefetchHooks Function()
        > {
  $$KColumnsTableTableManager(_$KolumnDb db, $KColumnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KColumnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KColumnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KColumnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> boardId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KColumnsCompanion(
                id: id,
                boardId: boardId,
                name: name,
                color: color,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String boardId,
                required String name,
                Value<int> color = const Value.absent(),
                required double position,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KColumnsCompanion.insert(
                id: id,
                boardId: boardId,
                name: name,
                color: color,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KColumnsTable, KColumn>(table),
                  BaseReferences<_$KolumnDb, $KColumnsTable, KColumn>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KColumnsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KColumnsTable,
      KColumn,
      $$KColumnsTableFilterComposer,
      $$KColumnsTableOrderingComposer,
      $$KColumnsTableAnnotationComposer,
      $$KColumnsTableCreateCompanionBuilder,
      $$KColumnsTableUpdateCompanionBuilder,
      (KColumn, BaseReferences<_$KolumnDb, $KColumnsTable, KColumn>),
      KColumn,
      PrefetchHooks Function()
    >;
typedef $$KCardsTableCreateCompanionBuilder = KCardsCompanion Function({
  required String id,
  required String boardId,
  required int number,
  required String title,
  Value<String> description,
  Value<String?> columnId,
  Value<int?> closedAt,
  Value<int?> laterAt,
  Value<String?> laterReason,
  Value<int?> priorityAt,
  Value<int?> dueAt,
  Value<bool> dueHasTime,
  required int lastActiveAt,
  Value<int> rev,
  Value<bool> synced,
  Value<int?> creatorId,
  Value<String> status,
  Value<String?> coverId,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KCardsTableUpdateCompanionBuilder = KCardsCompanion Function({
  Value<String> id,
  Value<String> boardId,
  Value<int> number,
  Value<String> title,
  Value<String> description,
  Value<String?> columnId,
  Value<int?> closedAt,
  Value<int?> laterAt,
  Value<String?> laterReason,
  Value<int?> priorityAt,
  Value<int?> dueAt,
  Value<bool> dueHasTime,
  Value<int> lastActiveAt,
  Value<int> rev,
  Value<bool> synced,
  Value<int?> creatorId,
  Value<String> status,
  Value<String?> coverId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KCardsTableFilterComposer extends Composer<_$KolumnDb, $KCardsTable> {
  $$KCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get columnId => $composableBuilder(
    column: $table.columnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get laterAt => $composableBuilder(
    column: $table.laterAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get laterReason => $composableBuilder(
    column: $table.laterReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priorityAt => $composableBuilder(
    column: $table.priorityAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dueHasTime => $composableBuilder(
    column: $table.dueHasTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverId => $composableBuilder(
    column: $table.coverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KCardsTableOrderingComposer extends Composer<_$KolumnDb, $KCardsTable> {
  $$KCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get columnId => $composableBuilder(
    column: $table.columnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get laterAt => $composableBuilder(
    column: $table.laterAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get laterReason => $composableBuilder(
    column: $table.laterReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priorityAt => $composableBuilder(
    column: $table.priorityAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dueHasTime => $composableBuilder(
    column: $table.dueHasTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverId => $composableBuilder(
    column: $table.coverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KCardsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KCardsTable> {
  $$KCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get columnId =>
      $composableBuilder(column: $table.columnId, builder: (column) => column);

  GeneratedColumn<int> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get laterAt =>
      $composableBuilder(column: $table.laterAt, builder: (column) => column);

  GeneratedColumn<String> get laterReason => $composableBuilder(
    column: $table.laterReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priorityAt => $composableBuilder(
    column: $table.priorityAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<bool> get dueHasTime => $composableBuilder(
    column: $table.dueHasTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<int> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get coverId =>
      $composableBuilder(column: $table.coverId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KCardsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KCardsTable,
          KCard,
          $$KCardsTableFilterComposer,
          $$KCardsTableOrderingComposer,
          $$KCardsTableAnnotationComposer,
          $$KCardsTableCreateCompanionBuilder,
          $$KCardsTableUpdateCompanionBuilder,
          (KCard, BaseReferences<_$KolumnDb, $KCardsTable, KCard>),
          KCard,
          PrefetchHooks Function()
        > {
  $$KCardsTableTableManager(_$KolumnDb db, $KCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> boardId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> columnId = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<int?> laterAt = const Value.absent(),
                Value<String?> laterReason = const Value.absent(),
                Value<int?> priorityAt = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<bool> dueHasTime = const Value.absent(),
                Value<int> lastActiveAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int?> creatorId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> coverId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KCardsCompanion(
                id: id,
                boardId: boardId,
                number: number,
                title: title,
                description: description,
                columnId: columnId,
                closedAt: closedAt,
                laterAt: laterAt,
                laterReason: laterReason,
                priorityAt: priorityAt,
                dueAt: dueAt,
                dueHasTime: dueHasTime,
                lastActiveAt: lastActiveAt,
                rev: rev,
                synced: synced,
                creatorId: creatorId,
                status: status,
                coverId: coverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String boardId,
                required int number,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String?> columnId = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<int?> laterAt = const Value.absent(),
                Value<String?> laterReason = const Value.absent(),
                Value<int?> priorityAt = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<bool> dueHasTime = const Value.absent(),
                required int lastActiveAt,
                Value<int> rev = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int?> creatorId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> coverId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KCardsCompanion.insert(
                id: id,
                boardId: boardId,
                number: number,
                title: title,
                description: description,
                columnId: columnId,
                closedAt: closedAt,
                laterAt: laterAt,
                laterReason: laterReason,
                priorityAt: priorityAt,
                dueAt: dueAt,
                dueHasTime: dueHasTime,
                lastActiveAt: lastActiveAt,
                rev: rev,
                synced: synced,
                creatorId: creatorId,
                status: status,
                coverId: coverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KCardsTable, KCard>(table),
                  BaseReferences<_$KolumnDb, $KCardsTable, KCard>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KCardsTable,
      KCard,
      $$KCardsTableFilterComposer,
      $$KCardsTableOrderingComposer,
      $$KCardsTableAnnotationComposer,
      $$KCardsTableCreateCompanionBuilder,
      $$KCardsTableUpdateCompanionBuilder,
      (KCard, BaseReferences<_$KolumnDb, $KCardsTable, KCard>),
      KCard,
      PrefetchHooks Function()
    >;
typedef $$KPeopleTableCreateCompanionBuilder = KPeopleCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$KPeopleTableUpdateCompanionBuilder = KPeopleCompanion Function({
  Value<int> id,
  Value<String> name,
});

class $$KPeopleTableFilterComposer extends Composer<_$KolumnDb, $KPeopleTable> {
  $$KPeopleTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KPeopleTableOrderingComposer
    extends Composer<_$KolumnDb, $KPeopleTable> {
  $$KPeopleTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KPeopleTableAnnotationComposer
    extends Composer<_$KolumnDb, $KPeopleTable> {
  $$KPeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$KPeopleTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KPeopleTable,
          KPerson,
          $$KPeopleTableFilterComposer,
          $$KPeopleTableOrderingComposer,
          $$KPeopleTableAnnotationComposer,
          $$KPeopleTableCreateCompanionBuilder,
          $$KPeopleTableUpdateCompanionBuilder,
          (KPerson, BaseReferences<_$KolumnDb, $KPeopleTable, KPerson>),
          KPerson,
          PrefetchHooks Function()
        > {
  $$KPeopleTableTableManager(_$KolumnDb db, $KPeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KPeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KPeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KPeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => KPeopleCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => KPeopleCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KPeopleTable, KPerson>(table),
                  BaseReferences<_$KolumnDb, $KPeopleTable, KPerson>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KPeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KPeopleTable,
      KPerson,
      $$KPeopleTableFilterComposer,
      $$KPeopleTableOrderingComposer,
      $$KPeopleTableAnnotationComposer,
      $$KPeopleTableCreateCompanionBuilder,
      $$KPeopleTableUpdateCompanionBuilder,
      (KPerson, BaseReferences<_$KolumnDb, $KPeopleTable, KPerson>),
      KPerson,
      PrefetchHooks Function()
    >;
typedef $$KSettingsTableCreateCompanionBuilder = KSettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$KSettingsTableUpdateCompanionBuilder = KSettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$KSettingsTableFilterComposer
    extends Composer<_$KolumnDb, $KSettingsTable> {
  $$KSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KSettingsTableOrderingComposer
    extends Composer<_$KolumnDb, $KSettingsTable> {
  $$KSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KSettingsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KSettingsTable> {
  $$KSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KSettingsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KSettingsTable,
          KSetting,
          $$KSettingsTableFilterComposer,
          $$KSettingsTableOrderingComposer,
          $$KSettingsTableAnnotationComposer,
          $$KSettingsTableCreateCompanionBuilder,
          $$KSettingsTableUpdateCompanionBuilder,
          (KSetting, BaseReferences<_$KolumnDb, $KSettingsTable, KSetting>),
          KSetting,
          PrefetchHooks Function()
        > {
  $$KSettingsTableTableManager(_$KolumnDb db, $KSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => KSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => KSettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KSettingsTable, KSetting>(table),
                  BaseReferences<_$KolumnDb, $KSettingsTable, KSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KSettingsTable,
      KSetting,
      $$KSettingsTableFilterComposer,
      $$KSettingsTableOrderingComposer,
      $$KSettingsTableAnnotationComposer,
      $$KSettingsTableCreateCompanionBuilder,
      $$KSettingsTableUpdateCompanionBuilder,
      (KSetting, BaseReferences<_$KolumnDb, $KSettingsTable, KSetting>),
      KSetting,
      PrefetchHooks Function()
    >;
typedef $$KOutboxTableCreateCompanionBuilder = KOutboxCompanion Function({
  Value<int> id,
  required String mutationId,
  required String name,
  required String args,
  required int clientTs,
});
typedef $$KOutboxTableUpdateCompanionBuilder = KOutboxCompanion Function({
  Value<int> id,
  Value<String> mutationId,
  Value<String> name,
  Value<String> args,
  Value<int> clientTs,
});

class $$KOutboxTableFilterComposer extends Composer<_$KolumnDb, $KOutboxTable> {
  $$KOutboxTableFilterComposer({
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

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get args => $composableBuilder(
    column: $table.args,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KOutboxTableOrderingComposer
    extends Composer<_$KolumnDb, $KOutboxTable> {
  $$KOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get args => $composableBuilder(
    column: $table.args,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KOutboxTableAnnotationComposer
    extends Composer<_$KolumnDb, $KOutboxTable> {
  $$KOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get args =>
      $composableBuilder(column: $table.args, builder: (column) => column);

  GeneratedColumn<int> get clientTs =>
      $composableBuilder(column: $table.clientTs, builder: (column) => column);
}

class $$KOutboxTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KOutboxTable,
          KOutboxEntry,
          $$KOutboxTableFilterComposer,
          $$KOutboxTableOrderingComposer,
          $$KOutboxTableAnnotationComposer,
          $$KOutboxTableCreateCompanionBuilder,
          $$KOutboxTableUpdateCompanionBuilder,
          (
            KOutboxEntry,
            BaseReferences<_$KolumnDb, $KOutboxTable, KOutboxEntry>,
          ),
          KOutboxEntry,
          PrefetchHooks Function()
        > {
  $$KOutboxTableTableManager(_$KolumnDb db, $KOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> args = const Value.absent(),
                Value<int> clientTs = const Value.absent(),
              }) => KOutboxCompanion(
                id: id,
                mutationId: mutationId,
                name: name,
                args: args,
                clientTs: clientTs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mutationId,
                required String name,
                required String args,
                required int clientTs,
              }) => KOutboxCompanion.insert(
                id: id,
                mutationId: mutationId,
                name: name,
                args: args,
                clientTs: clientTs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KOutboxTable, KOutboxEntry>(table),
                  BaseReferences<_$KolumnDb, $KOutboxTable, KOutboxEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KOutboxTable,
      KOutboxEntry,
      $$KOutboxTableFilterComposer,
      $$KOutboxTableOrderingComposer,
      $$KOutboxTableAnnotationComposer,
      $$KOutboxTableCreateCompanionBuilder,
      $$KOutboxTableUpdateCompanionBuilder,
      (KOutboxEntry, BaseReferences<_$KolumnDb, $KOutboxTable, KOutboxEntry>),
      KOutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$KStepsTableCreateCompanionBuilder = KStepsCompanion Function({
  required String id,
  required String cardId,
  required String content,
  Value<bool> done,
  Value<double> position,
  required int createdAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KStepsTableUpdateCompanionBuilder = KStepsCompanion Function({
  Value<String> id,
  Value<String> cardId,
  Value<String> content,
  Value<bool> done,
  Value<double> position,
  Value<int> createdAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KStepsTableFilterComposer extends Composer<_$KolumnDb, $KStepsTable> {
  $$KStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KStepsTableOrderingComposer extends Composer<_$KolumnDb, $KStepsTable> {
  $$KStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KStepsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KStepsTable> {
  $$KStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KStepsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KStepsTable,
          KStep,
          $$KStepsTableFilterComposer,
          $$KStepsTableOrderingComposer,
          $$KStepsTableAnnotationComposer,
          $$KStepsTableCreateCompanionBuilder,
          $$KStepsTableUpdateCompanionBuilder,
          (KStep, BaseReferences<_$KolumnDb, $KStepsTable, KStep>),
          KStep,
          PrefetchHooks Function()
        > {
  $$KStepsTableTableManager(_$KolumnDb db, $KStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KStepsCompanion(
                id: id,
                cardId: cardId,
                content: content,
                done: done,
                position: position,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                required String content,
                Value<bool> done = const Value.absent(),
                Value<double> position = const Value.absent(),
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KStepsCompanion.insert(
                id: id,
                cardId: cardId,
                content: content,
                done: done,
                position: position,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KStepsTable, KStep>(table),
                  BaseReferences<_$KolumnDb, $KStepsTable, KStep>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KStepsTable,
      KStep,
      $$KStepsTableFilterComposer,
      $$KStepsTableOrderingComposer,
      $$KStepsTableAnnotationComposer,
      $$KStepsTableCreateCompanionBuilder,
      $$KStepsTableUpdateCompanionBuilder,
      (KStep, BaseReferences<_$KolumnDb, $KStepsTable, KStep>),
      KStep,
      PrefetchHooks Function()
    >;
typedef $$KCommentsTableCreateCompanionBuilder = KCommentsCompanion Function({
  required String id,
  required String cardId,
  required int userId,
  required String body,
  required int createdAt,
  Value<int?> editedAt,
  Value<int?> deletedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$KCommentsTableUpdateCompanionBuilder = KCommentsCompanion Function({
  Value<String> id,
  Value<String> cardId,
  Value<int> userId,
  Value<String> body,
  Value<int> createdAt,
  Value<int?> editedAt,
  Value<int?> deletedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$KCommentsTableFilterComposer
    extends Composer<_$KolumnDb, $KCommentsTable> {
  $$KCommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KCommentsTableOrderingComposer
    extends Composer<_$KolumnDb, $KCommentsTable> {
  $$KCommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KCommentsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KCommentsTable> {
  $$KCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$KCommentsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KCommentsTable,
          KComment,
          $$KCommentsTableFilterComposer,
          $$KCommentsTableOrderingComposer,
          $$KCommentsTableAnnotationComposer,
          $$KCommentsTableCreateCompanionBuilder,
          $$KCommentsTableUpdateCompanionBuilder,
          (KComment, BaseReferences<_$KolumnDb, $KCommentsTable, KComment>),
          KComment,
          PrefetchHooks Function()
        > {
  $$KCommentsTableTableManager(_$KolumnDb db, $KCommentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> editedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KCommentsCompanion(
                id: id,
                cardId: cardId,
                userId: userId,
                body: body,
                createdAt: createdAt,
                editedAt: editedAt,
                deletedAt: deletedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                required int userId,
                required String body,
                required int createdAt,
                Value<int?> editedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KCommentsCompanion.insert(
                id: id,
                cardId: cardId,
                userId: userId,
                body: body,
                createdAt: createdAt,
                editedAt: editedAt,
                deletedAt: deletedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KCommentsTable, KComment>(table),
                  BaseReferences<_$KolumnDb, $KCommentsTable, KComment>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KCommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KCommentsTable,
      KComment,
      $$KCommentsTableFilterComposer,
      $$KCommentsTableOrderingComposer,
      $$KCommentsTableAnnotationComposer,
      $$KCommentsTableCreateCompanionBuilder,
      $$KCommentsTableUpdateCompanionBuilder,
      (KComment, BaseReferences<_$KolumnDb, $KCommentsTable, KComment>),
      KComment,
      PrefetchHooks Function()
    >;
typedef $$KReactionsTableCreateCompanionBuilder = KReactionsCompanion Function({
  required String id,
  required String cardId,
  Value<String?> commentId,
  required int userId,
  required String emoji,
  required int createdAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KReactionsTableUpdateCompanionBuilder = KReactionsCompanion Function({
  Value<String> id,
  Value<String> cardId,
  Value<String?> commentId,
  Value<int> userId,
  Value<String> emoji,
  Value<int> createdAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KReactionsTableFilterComposer
    extends Composer<_$KolumnDb, $KReactionsTable> {
  $$KReactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentId => $composableBuilder(
    column: $table.commentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KReactionsTableOrderingComposer
    extends Composer<_$KolumnDb, $KReactionsTable> {
  $$KReactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentId => $composableBuilder(
    column: $table.commentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KReactionsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KReactionsTable> {
  $$KReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get commentId =>
      $composableBuilder(column: $table.commentId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KReactionsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KReactionsTable,
          KReaction,
          $$KReactionsTableFilterComposer,
          $$KReactionsTableOrderingComposer,
          $$KReactionsTableAnnotationComposer,
          $$KReactionsTableCreateCompanionBuilder,
          $$KReactionsTableUpdateCompanionBuilder,
          (KReaction, BaseReferences<_$KolumnDb, $KReactionsTable, KReaction>),
          KReaction,
          PrefetchHooks Function()
        > {
  $$KReactionsTableTableManager(_$KolumnDb db, $KReactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String?> commentId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KReactionsCompanion(
                id: id,
                cardId: cardId,
                commentId: commentId,
                userId: userId,
                emoji: emoji,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                Value<String?> commentId = const Value.absent(),
                required int userId,
                required String emoji,
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KReactionsCompanion.insert(
                id: id,
                cardId: cardId,
                commentId: commentId,
                userId: userId,
                emoji: emoji,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KReactionsTable, KReaction>(table),
                  BaseReferences<_$KolumnDb, $KReactionsTable, KReaction>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KReactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KReactionsTable,
      KReaction,
      $$KReactionsTableFilterComposer,
      $$KReactionsTableOrderingComposer,
      $$KReactionsTableAnnotationComposer,
      $$KReactionsTableCreateCompanionBuilder,
      $$KReactionsTableUpdateCompanionBuilder,
      (KReaction, BaseReferences<_$KolumnDb, $KReactionsTable, KReaction>),
      KReaction,
      PrefetchHooks Function()
    >;
typedef $$KTagsTableCreateCompanionBuilder = KTagsCompanion Function({
  required String cardId,
  required String tag,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KTagsTableUpdateCompanionBuilder = KTagsCompanion Function({
  Value<String> cardId,
  Value<String> tag,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KTagsTableFilterComposer extends Composer<_$KolumnDb, $KTagsTable> {
  $$KTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KTagsTableOrderingComposer extends Composer<_$KolumnDb, $KTagsTable> {
  $$KTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KTagsTableAnnotationComposer extends Composer<_$KolumnDb, $KTagsTable> {
  $$KTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KTagsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KTagsTable,
          KTag,
          $$KTagsTableFilterComposer,
          $$KTagsTableOrderingComposer,
          $$KTagsTableAnnotationComposer,
          $$KTagsTableCreateCompanionBuilder,
          $$KTagsTableUpdateCompanionBuilder,
          (KTag, BaseReferences<_$KolumnDb, $KTagsTable, KTag>),
          KTag,
          PrefetchHooks Function()
        > {
  $$KTagsTableTableManager(_$KolumnDb db, $KTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTagsCompanion(
                cardId: cardId,
                tag: tag,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String tag,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTagsCompanion.insert(
                cardId: cardId,
                tag: tag,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KTagsTable, KTag>(table),
                  BaseReferences<_$KolumnDb, $KTagsTable, KTag>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KTagsTable,
      KTag,
      $$KTagsTableFilterComposer,
      $$KTagsTableOrderingComposer,
      $$KTagsTableAnnotationComposer,
      $$KTagsTableCreateCompanionBuilder,
      $$KTagsTableUpdateCompanionBuilder,
      (KTag, BaseReferences<_$KolumnDb, $KTagsTable, KTag>),
      KTag,
      PrefetchHooks Function()
    >;
typedef $$KAssigneesTableCreateCompanionBuilder = KAssigneesCompanion Function({
  required String cardId,
  required int userId,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KAssigneesTableUpdateCompanionBuilder = KAssigneesCompanion Function({
  Value<String> cardId,
  Value<int> userId,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KAssigneesTableFilterComposer
    extends Composer<_$KolumnDb, $KAssigneesTable> {
  $$KAssigneesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KAssigneesTableOrderingComposer
    extends Composer<_$KolumnDb, $KAssigneesTable> {
  $$KAssigneesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KAssigneesTableAnnotationComposer
    extends Composer<_$KolumnDb, $KAssigneesTable> {
  $$KAssigneesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KAssigneesTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KAssigneesTable,
          KAssignee,
          $$KAssigneesTableFilterComposer,
          $$KAssigneesTableOrderingComposer,
          $$KAssigneesTableAnnotationComposer,
          $$KAssigneesTableCreateCompanionBuilder,
          $$KAssigneesTableUpdateCompanionBuilder,
          (KAssignee, BaseReferences<_$KolumnDb, $KAssigneesTable, KAssignee>),
          KAssignee,
          PrefetchHooks Function()
        > {
  $$KAssigneesTableTableManager(_$KolumnDb db, $KAssigneesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KAssigneesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KAssigneesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KAssigneesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KAssigneesCompanion(
                cardId: cardId,
                userId: userId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required int userId,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KAssigneesCompanion.insert(
                cardId: cardId,
                userId: userId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KAssigneesTable, KAssignee>(table),
                  BaseReferences<_$KolumnDb, $KAssigneesTable, KAssignee>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KAssigneesTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KAssigneesTable,
      KAssignee,
      $$KAssigneesTableFilterComposer,
      $$KAssigneesTableOrderingComposer,
      $$KAssigneesTableAnnotationComposer,
      $$KAssigneesTableCreateCompanionBuilder,
      $$KAssigneesTableUpdateCompanionBuilder,
      (KAssignee, BaseReferences<_$KolumnDb, $KAssigneesTable, KAssignee>),
      KAssignee,
      PrefetchHooks Function()
    >;
typedef $$KWatchesTableCreateCompanionBuilder = KWatchesCompanion Function({
  required String cardId,
  required bool watching,
  Value<int> rowid,
});
typedef $$KWatchesTableUpdateCompanionBuilder = KWatchesCompanion Function({
  Value<String> cardId,
  Value<bool> watching,
  Value<int> rowid,
});

class $$KWatchesTableFilterComposer
    extends Composer<_$KolumnDb, $KWatchesTable> {
  $$KWatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get watching => $composableBuilder(
    column: $table.watching,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KWatchesTableOrderingComposer
    extends Composer<_$KolumnDb, $KWatchesTable> {
  $$KWatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get watching => $composableBuilder(
    column: $table.watching,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KWatchesTableAnnotationComposer
    extends Composer<_$KolumnDb, $KWatchesTable> {
  $$KWatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<bool> get watching =>
      $composableBuilder(column: $table.watching, builder: (column) => column);
}

class $$KWatchesTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KWatchesTable,
          KWatch,
          $$KWatchesTableFilterComposer,
          $$KWatchesTableOrderingComposer,
          $$KWatchesTableAnnotationComposer,
          $$KWatchesTableCreateCompanionBuilder,
          $$KWatchesTableUpdateCompanionBuilder,
          (KWatch, BaseReferences<_$KolumnDb, $KWatchesTable, KWatch>),
          KWatch,
          PrefetchHooks Function()
        > {
  $$KWatchesTableTableManager(_$KolumnDb db, $KWatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KWatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KWatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KWatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<bool> watching = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KWatchesCompanion(
                cardId: cardId,
                watching: watching,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required bool watching,
                Value<int> rowid = const Value.absent(),
              }) => KWatchesCompanion.insert(
                cardId: cardId,
                watching: watching,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KWatchesTable, KWatch>(table),
                  BaseReferences<_$KolumnDb, $KWatchesTable, KWatch>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KWatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KWatchesTable,
      KWatch,
      $$KWatchesTableFilterComposer,
      $$KWatchesTableOrderingComposer,
      $$KWatchesTableAnnotationComposer,
      $$KWatchesTableCreateCompanionBuilder,
      $$KWatchesTableUpdateCompanionBuilder,
      (KWatch, BaseReferences<_$KolumnDb, $KWatchesTable, KWatch>),
      KWatch,
      PrefetchHooks Function()
    >;
typedef $$KPinsTableCreateCompanionBuilder = KPinsCompanion Function({
  required String cardId,
  required int pinnedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KPinsTableUpdateCompanionBuilder = KPinsCompanion Function({
  Value<String> cardId,
  Value<int> pinnedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KPinsTableFilterComposer extends Composer<_$KolumnDb, $KPinsTable> {
  $$KPinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KPinsTableOrderingComposer extends Composer<_$KolumnDb, $KPinsTable> {
  $$KPinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KPinsTableAnnotationComposer extends Composer<_$KolumnDb, $KPinsTable> {
  $$KPinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get pinnedAt =>
      $composableBuilder(column: $table.pinnedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KPinsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KPinsTable,
          KPin,
          $$KPinsTableFilterComposer,
          $$KPinsTableOrderingComposer,
          $$KPinsTableAnnotationComposer,
          $$KPinsTableCreateCompanionBuilder,
          $$KPinsTableUpdateCompanionBuilder,
          (KPin, BaseReferences<_$KolumnDb, $KPinsTable, KPin>),
          KPin,
          PrefetchHooks Function()
        > {
  $$KPinsTableTableManager(_$KolumnDb db, $KPinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KPinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KPinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KPinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<int> pinnedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KPinsCompanion(
                cardId: cardId,
                pinnedAt: pinnedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required int pinnedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KPinsCompanion.insert(
                cardId: cardId,
                pinnedAt: pinnedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KPinsTable, KPin>(table),
                  BaseReferences<_$KolumnDb, $KPinsTable, KPin>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KPinsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KPinsTable,
      KPin,
      $$KPinsTableFilterComposer,
      $$KPinsTableOrderingComposer,
      $$KPinsTableAnnotationComposer,
      $$KPinsTableCreateCompanionBuilder,
      $$KPinsTableUpdateCompanionBuilder,
      (KPin, BaseReferences<_$KolumnDb, $KPinsTable, KPin>),
      KPin,
      PrefetchHooks Function()
    >;
typedef $$KFilesTableCreateCompanionBuilder = KFilesCompanion Function({
  required String id,
  required String cardId,
  Value<String?> commentId,
  Value<int> userId,
  required String filename,
  Value<String> mime,
  Value<int> size,
  Value<int?> width,
  Value<int?> height,
  Value<bool> hasThumb,
  required int createdAt,
  Value<int?> deletedAt,
  Value<String?> localPath,
  Value<bool> uploaded,
  Value<int> rowid,
});
typedef $$KFilesTableUpdateCompanionBuilder = KFilesCompanion Function({
  Value<String> id,
  Value<String> cardId,
  Value<String?> commentId,
  Value<int> userId,
  Value<String> filename,
  Value<String> mime,
  Value<int> size,
  Value<int?> width,
  Value<int?> height,
  Value<bool> hasThumb,
  Value<int> createdAt,
  Value<int?> deletedAt,
  Value<String?> localPath,
  Value<bool> uploaded,
  Value<int> rowid,
});

class $$KFilesTableFilterComposer extends Composer<_$KolumnDb, $KFilesTable> {
  $$KFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentId => $composableBuilder(
    column: $table.commentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasThumb => $composableBuilder(
    column: $table.hasThumb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KFilesTableOrderingComposer extends Composer<_$KolumnDb, $KFilesTable> {
  $$KFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentId => $composableBuilder(
    column: $table.commentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasThumb => $composableBuilder(
    column: $table.hasThumb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KFilesTableAnnotationComposer
    extends Composer<_$KolumnDb, $KFilesTable> {
  $$KFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get commentId =>
      $composableBuilder(column: $table.commentId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<bool> get hasThumb =>
      $composableBuilder(column: $table.hasThumb, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);
}

class $$KFilesTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KFilesTable,
          KFile,
          $$KFilesTableFilterComposer,
          $$KFilesTableOrderingComposer,
          $$KFilesTableAnnotationComposer,
          $$KFilesTableCreateCompanionBuilder,
          $$KFilesTableUpdateCompanionBuilder,
          (KFile, BaseReferences<_$KolumnDb, $KFilesTable, KFile>),
          KFile,
          PrefetchHooks Function()
        > {
  $$KFilesTableTableManager(_$KolumnDb db, $KFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String?> commentId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<bool> hasThumb = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KFilesCompanion(
                id: id,
                cardId: cardId,
                commentId: commentId,
                userId: userId,
                filename: filename,
                mime: mime,
                size: size,
                width: width,
                height: height,
                hasThumb: hasThumb,
                createdAt: createdAt,
                deletedAt: deletedAt,
                localPath: localPath,
                uploaded: uploaded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                Value<String?> commentId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                required String filename,
                Value<String> mime = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<bool> hasThumb = const Value.absent(),
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KFilesCompanion.insert(
                id: id,
                cardId: cardId,
                commentId: commentId,
                userId: userId,
                filename: filename,
                mime: mime,
                size: size,
                width: width,
                height: height,
                hasThumb: hasThumb,
                createdAt: createdAt,
                deletedAt: deletedAt,
                localPath: localPath,
                uploaded: uploaded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KFilesTable, KFile>(table),
                  BaseReferences<_$KolumnDb, $KFilesTable, KFile>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KFilesTable,
      KFile,
      $$KFilesTableFilterComposer,
      $$KFilesTableOrderingComposer,
      $$KFilesTableAnnotationComposer,
      $$KFilesTableCreateCompanionBuilder,
      $$KFilesTableUpdateCompanionBuilder,
      (KFile, BaseReferences<_$KolumnDb, $KFilesTable, KFile>),
      KFile,
      PrefetchHooks Function()
    >;
typedef $$KEventsTableCreateCompanionBuilder = KEventsCompanion Function({
  Value<int> id,
  required String cardId,
  required int userId,
  required String action,
  Value<String> particulars,
  required int createdAt,
});
typedef $$KEventsTableUpdateCompanionBuilder = KEventsCompanion Function({
  Value<int> id,
  Value<String> cardId,
  Value<int> userId,
  Value<String> action,
  Value<String> particulars,
  Value<int> createdAt,
});

class $$KEventsTableFilterComposer extends Composer<_$KolumnDb, $KEventsTable> {
  $$KEventsTableFilterComposer({
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

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get particulars => $composableBuilder(
    column: $table.particulars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KEventsTableOrderingComposer
    extends Composer<_$KolumnDb, $KEventsTable> {
  $$KEventsTableOrderingComposer({
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

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get particulars => $composableBuilder(
    column: $table.particulars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KEventsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KEventsTable> {
  $$KEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get particulars => $composableBuilder(
    column: $table.particulars,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$KEventsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KEventsTable,
          KEvent,
          $$KEventsTableFilterComposer,
          $$KEventsTableOrderingComposer,
          $$KEventsTableAnnotationComposer,
          $$KEventsTableCreateCompanionBuilder,
          $$KEventsTableUpdateCompanionBuilder,
          (KEvent, BaseReferences<_$KolumnDb, $KEventsTable, KEvent>),
          KEvent,
          PrefetchHooks Function()
        > {
  $$KEventsTableTableManager(_$KolumnDb db, $KEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> particulars = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => KEventsCompanion(
                id: id,
                cardId: cardId,
                userId: userId,
                action: action,
                particulars: particulars,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardId,
                required int userId,
                required String action,
                Value<String> particulars = const Value.absent(),
                required int createdAt,
              }) => KEventsCompanion.insert(
                id: id,
                cardId: cardId,
                userId: userId,
                action: action,
                particulars: particulars,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KEventsTable, KEvent>(table),
                  BaseReferences<_$KolumnDb, $KEventsTable, KEvent>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KEventsTable,
      KEvent,
      $$KEventsTableFilterComposer,
      $$KEventsTableOrderingComposer,
      $$KEventsTableAnnotationComposer,
      $$KEventsTableCreateCompanionBuilder,
      $$KEventsTableUpdateCompanionBuilder,
      (KEvent, BaseReferences<_$KolumnDb, $KEventsTable, KEvent>),
      KEvent,
      PrefetchHooks Function()
    >;
typedef $$KPlannersTableCreateCompanionBuilder = KPlannersCompanion Function({
  required String id,
  required String name,
  Value<int?> creatorId,
  Value<bool> rollOver,
  Value<bool> sinkDone,
  Value<bool> hideDone,
  Value<String> boardIds,
  Value<bool> canManage,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KPlannersTableUpdateCompanionBuilder = KPlannersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> creatorId,
  Value<bool> rollOver,
  Value<bool> sinkDone,
  Value<bool> hideDone,
  Value<String> boardIds,
  Value<bool> canManage,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KPlannersTableFilterComposer
    extends Composer<_$KolumnDb, $KPlannersTable> {
  $$KPlannersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rollOver => $composableBuilder(
    column: $table.rollOver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sinkDone => $composableBuilder(
    column: $table.sinkDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hideDone => $composableBuilder(
    column: $table.hideDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardIds => $composableBuilder(
    column: $table.boardIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManage => $composableBuilder(
    column: $table.canManage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KPlannersTableOrderingComposer
    extends Composer<_$KolumnDb, $KPlannersTable> {
  $$KPlannersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rollOver => $composableBuilder(
    column: $table.rollOver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sinkDone => $composableBuilder(
    column: $table.sinkDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hideDone => $composableBuilder(
    column: $table.hideDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardIds => $composableBuilder(
    column: $table.boardIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManage => $composableBuilder(
    column: $table.canManage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KPlannersTableAnnotationComposer
    extends Composer<_$KolumnDb, $KPlannersTable> {
  $$KPlannersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<bool> get rollOver =>
      $composableBuilder(column: $table.rollOver, builder: (column) => column);

  GeneratedColumn<bool> get sinkDone =>
      $composableBuilder(column: $table.sinkDone, builder: (column) => column);

  GeneratedColumn<bool> get hideDone =>
      $composableBuilder(column: $table.hideDone, builder: (column) => column);

  GeneratedColumn<String> get boardIds =>
      $composableBuilder(column: $table.boardIds, builder: (column) => column);

  GeneratedColumn<bool> get canManage =>
      $composableBuilder(column: $table.canManage, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KPlannersTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KPlannersTable,
          KPlanner,
          $$KPlannersTableFilterComposer,
          $$KPlannersTableOrderingComposer,
          $$KPlannersTableAnnotationComposer,
          $$KPlannersTableCreateCompanionBuilder,
          $$KPlannersTableUpdateCompanionBuilder,
          (KPlanner, BaseReferences<_$KolumnDb, $KPlannersTable, KPlanner>),
          KPlanner,
          PrefetchHooks Function()
        > {
  $$KPlannersTableTableManager(_$KolumnDb db, $KPlannersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KPlannersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KPlannersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KPlannersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> creatorId = const Value.absent(),
                Value<bool> rollOver = const Value.absent(),
                Value<bool> sinkDone = const Value.absent(),
                Value<bool> hideDone = const Value.absent(),
                Value<String> boardIds = const Value.absent(),
                Value<bool> canManage = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KPlannersCompanion(
                id: id,
                name: name,
                creatorId: creatorId,
                rollOver: rollOver,
                sinkDone: sinkDone,
                hideDone: hideDone,
                boardIds: boardIds,
                canManage: canManage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int?> creatorId = const Value.absent(),
                Value<bool> rollOver = const Value.absent(),
                Value<bool> sinkDone = const Value.absent(),
                Value<bool> hideDone = const Value.absent(),
                Value<String> boardIds = const Value.absent(),
                Value<bool> canManage = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KPlannersCompanion.insert(
                id: id,
                name: name,
                creatorId: creatorId,
                rollOver: rollOver,
                sinkDone: sinkDone,
                hideDone: hideDone,
                boardIds: boardIds,
                canManage: canManage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KPlannersTable, KPlanner>(table),
                  BaseReferences<_$KolumnDb, $KPlannersTable, KPlanner>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KPlannersTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KPlannersTable,
      KPlanner,
      $$KPlannersTableFilterComposer,
      $$KPlannersTableOrderingComposer,
      $$KPlannersTableAnnotationComposer,
      $$KPlannersTableCreateCompanionBuilder,
      $$KPlannersTableUpdateCompanionBuilder,
      (KPlanner, BaseReferences<_$KolumnDb, $KPlannersTable, KPlanner>),
      KPlanner,
      PrefetchHooks Function()
    >;
typedef $$KPlannerPeopleTableCreateCompanionBuilder =
    KPlannerPeopleCompanion Function({
      required String plannerId,
      required int userId,
      Value<String> role,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$KPlannerPeopleTableUpdateCompanionBuilder =
    KPlannerPeopleCompanion Function({
      Value<String> plannerId,
      Value<int> userId,
      Value<String> role,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$KPlannerPeopleTableFilterComposer
    extends Composer<_$KolumnDb, $KPlannerPeopleTable> {
  $$KPlannerPeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get plannerId => $composableBuilder(
    column: $table.plannerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KPlannerPeopleTableOrderingComposer
    extends Composer<_$KolumnDb, $KPlannerPeopleTable> {
  $$KPlannerPeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get plannerId => $composableBuilder(
    column: $table.plannerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KPlannerPeopleTableAnnotationComposer
    extends Composer<_$KolumnDb, $KPlannerPeopleTable> {
  $$KPlannerPeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get plannerId =>
      $composableBuilder(column: $table.plannerId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KPlannerPeopleTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KPlannerPeopleTable,
          KPlannerPerson,
          $$KPlannerPeopleTableFilterComposer,
          $$KPlannerPeopleTableOrderingComposer,
          $$KPlannerPeopleTableAnnotationComposer,
          $$KPlannerPeopleTableCreateCompanionBuilder,
          $$KPlannerPeopleTableUpdateCompanionBuilder,
          (
            KPlannerPerson,
            BaseReferences<_$KolumnDb, $KPlannerPeopleTable, KPlannerPerson>,
          ),
          KPlannerPerson,
          PrefetchHooks Function()
        > {
  $$KPlannerPeopleTableTableManager(_$KolumnDb db, $KPlannerPeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KPlannerPeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KPlannerPeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KPlannerPeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> plannerId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KPlannerPeopleCompanion(
                plannerId: plannerId,
                userId: userId,
                role: role,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String plannerId,
                required int userId,
                Value<String> role = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KPlannerPeopleCompanion.insert(
                plannerId: plannerId,
                userId: userId,
                role: role,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KPlannerPeopleTable, KPlannerPerson>(table),
                  BaseReferences<
                    _$KolumnDb,
                    $KPlannerPeopleTable,
                    KPlannerPerson
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KPlannerPeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KPlannerPeopleTable,
      KPlannerPerson,
      $$KPlannerPeopleTableFilterComposer,
      $$KPlannerPeopleTableOrderingComposer,
      $$KPlannerPeopleTableAnnotationComposer,
      $$KPlannerPeopleTableCreateCompanionBuilder,
      $$KPlannerPeopleTableUpdateCompanionBuilder,
      (
        KPlannerPerson,
        BaseReferences<_$KolumnDb, $KPlannerPeopleTable, KPlannerPerson>,
      ),
      KPlannerPerson,
      PrefetchHooks Function()
    >;
typedef $$KTodosTableCreateCompanionBuilder = KTodosCompanion Function({
  required String id,
  required String plannerId,
  Value<String?> day,
  Value<int?> list,
  required String title,
  Value<String> note,
  Value<int?> doneAt,
  Value<double> position,
  Value<String?> repeat,
  Value<int?> assigneeId,
  Value<int?> creatorId,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KTodosTableUpdateCompanionBuilder = KTodosCompanion Function({
  Value<String> id,
  Value<String> plannerId,
  Value<String?> day,
  Value<int?> list,
  Value<String> title,
  Value<String> note,
  Value<int?> doneAt,
  Value<double> position,
  Value<String?> repeat,
  Value<int?> assigneeId,
  Value<int?> creatorId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KTodosTableFilterComposer extends Composer<_$KolumnDb, $KTodosTable> {
  $$KTodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannerId => $composableBuilder(
    column: $table.plannerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get list => $composableBuilder(
    column: $table.list,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KTodosTableOrderingComposer extends Composer<_$KolumnDb, $KTodosTable> {
  $$KTodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannerId => $composableBuilder(
    column: $table.plannerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get list => $composableBuilder(
    column: $table.list,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KTodosTableAnnotationComposer
    extends Composer<_$KolumnDb, $KTodosTable> {
  $$KTodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plannerId =>
      $composableBuilder(column: $table.plannerId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get list =>
      $composableBuilder(column: $table.list, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<int> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KTodosTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KTodosTable,
          KTodo,
          $$KTodosTableFilterComposer,
          $$KTodosTableOrderingComposer,
          $$KTodosTableAnnotationComposer,
          $$KTodosTableCreateCompanionBuilder,
          $$KTodosTableUpdateCompanionBuilder,
          (KTodo, BaseReferences<_$KolumnDb, $KTodosTable, KTodo>),
          KTodo,
          PrefetchHooks Function()
        > {
  $$KTodosTableTableManager(_$KolumnDb db, $KTodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KTodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KTodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KTodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plannerId = const Value.absent(),
                Value<String?> day = const Value.absent(),
                Value<int?> list = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<String?> repeat = const Value.absent(),
                Value<int?> assigneeId = const Value.absent(),
                Value<int?> creatorId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTodosCompanion(
                id: id,
                plannerId: plannerId,
                day: day,
                list: list,
                title: title,
                note: note,
                doneAt: doneAt,
                position: position,
                repeat: repeat,
                assigneeId: assigneeId,
                creatorId: creatorId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plannerId,
                Value<String?> day = const Value.absent(),
                Value<int?> list = const Value.absent(),
                required String title,
                Value<String> note = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<String?> repeat = const Value.absent(),
                Value<int?> assigneeId = const Value.absent(),
                Value<int?> creatorId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTodosCompanion.insert(
                id: id,
                plannerId: plannerId,
                day: day,
                list: list,
                title: title,
                note: note,
                doneAt: doneAt,
                position: position,
                repeat: repeat,
                assigneeId: assigneeId,
                creatorId: creatorId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KTodosTable, KTodo>(table),
                  BaseReferences<_$KolumnDb, $KTodosTable, KTodo>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KTodosTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KTodosTable,
      KTodo,
      $$KTodosTableFilterComposer,
      $$KTodosTableOrderingComposer,
      $$KTodosTableAnnotationComposer,
      $$KTodosTableCreateCompanionBuilder,
      $$KTodosTableUpdateCompanionBuilder,
      (KTodo, BaseReferences<_$KolumnDb, $KTodosTable, KTodo>),
      KTodo,
      PrefetchHooks Function()
    >;
typedef $$KTodoMarksTableCreateCompanionBuilder = KTodoMarksCompanion Function({
  required String todoId,
  required String day,
  required String mark,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KTodoMarksTableUpdateCompanionBuilder = KTodoMarksCompanion Function({
  Value<String> todoId,
  Value<String> day,
  Value<String> mark,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KTodoMarksTableFilterComposer
    extends Composer<_$KolumnDb, $KTodoMarksTable> {
  $$KTodoMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mark => $composableBuilder(
    column: $table.mark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KTodoMarksTableOrderingComposer
    extends Composer<_$KolumnDb, $KTodoMarksTable> {
  $$KTodoMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mark => $composableBuilder(
    column: $table.mark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KTodoMarksTableAnnotationComposer
    extends Composer<_$KolumnDb, $KTodoMarksTable> {
  $$KTodoMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get mark =>
      $composableBuilder(column: $table.mark, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KTodoMarksTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KTodoMarksTable,
          KTodoMark,
          $$KTodoMarksTableFilterComposer,
          $$KTodoMarksTableOrderingComposer,
          $$KTodoMarksTableAnnotationComposer,
          $$KTodoMarksTableCreateCompanionBuilder,
          $$KTodoMarksTableUpdateCompanionBuilder,
          (KTodoMark, BaseReferences<_$KolumnDb, $KTodoMarksTable, KTodoMark>),
          KTodoMark,
          PrefetchHooks Function()
        > {
  $$KTodoMarksTableTableManager(_$KolumnDb db, $KTodoMarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KTodoMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KTodoMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KTodoMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> todoId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> mark = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTodoMarksCompanion(
                todoId: todoId,
                day: day,
                mark: mark,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String todoId,
                required String day,
                required String mark,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTodoMarksCompanion.insert(
                todoId: todoId,
                day: day,
                mark: mark,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KTodoMarksTable, KTodoMark>(table),
                  BaseReferences<_$KolumnDb, $KTodoMarksTable, KTodoMark>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KTodoMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KTodoMarksTable,
      KTodoMark,
      $$KTodoMarksTableFilterComposer,
      $$KTodoMarksTableOrderingComposer,
      $$KTodoMarksTableAnnotationComposer,
      $$KTodoMarksTableCreateCompanionBuilder,
      $$KTodoMarksTableUpdateCompanionBuilder,
      (KTodoMark, BaseReferences<_$KolumnDb, $KTodoMarksTable, KTodoMark>),
      KTodoMark,
      PrefetchHooks Function()
    >;
typedef $$KTodoStepsTableCreateCompanionBuilder = KTodoStepsCompanion Function({
  required String id,
  required String todoId,
  required String content,
  Value<bool> done,
  Value<bool> heading,
  Value<int> indent,
  Value<bool> star,
  Value<double> position,
  required int createdAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$KTodoStepsTableUpdateCompanionBuilder = KTodoStepsCompanion Function({
  Value<String> id,
  Value<String> todoId,
  Value<String> content,
  Value<bool> done,
  Value<bool> heading,
  Value<int> indent,
  Value<bool> star,
  Value<double> position,
  Value<int> createdAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$KTodoStepsTableFilterComposer
    extends Composer<_$KolumnDb, $KTodoStepsTable> {
  $$KTodoStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indent => $composableBuilder(
    column: $table.indent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get star => $composableBuilder(
    column: $table.star,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KTodoStepsTableOrderingComposer
    extends Composer<_$KolumnDb, $KTodoStepsTable> {
  $$KTodoStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indent => $composableBuilder(
    column: $table.indent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get star => $composableBuilder(
    column: $table.star,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KTodoStepsTableAnnotationComposer
    extends Composer<_$KolumnDb, $KTodoStepsTable> {
  $$KTodoStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<bool> get heading =>
      $composableBuilder(column: $table.heading, builder: (column) => column);

  GeneratedColumn<int> get indent =>
      $composableBuilder(column: $table.indent, builder: (column) => column);

  GeneratedColumn<bool> get star =>
      $composableBuilder(column: $table.star, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$KTodoStepsTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KTodoStepsTable,
          KTodoStep,
          $$KTodoStepsTableFilterComposer,
          $$KTodoStepsTableOrderingComposer,
          $$KTodoStepsTableAnnotationComposer,
          $$KTodoStepsTableCreateCompanionBuilder,
          $$KTodoStepsTableUpdateCompanionBuilder,
          (KTodoStep, BaseReferences<_$KolumnDb, $KTodoStepsTable, KTodoStep>),
          KTodoStep,
          PrefetchHooks Function()
        > {
  $$KTodoStepsTableTableManager(_$KolumnDb db, $KTodoStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KTodoStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KTodoStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KTodoStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> todoId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<bool> heading = const Value.absent(),
                Value<int> indent = const Value.absent(),
                Value<bool> star = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTodoStepsCompanion(
                id: id,
                todoId: todoId,
                content: content,
                done: done,
                heading: heading,
                indent: indent,
                star: star,
                position: position,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String todoId,
                required String content,
                Value<bool> done = const Value.absent(),
                Value<bool> heading = const Value.absent(),
                Value<int> indent = const Value.absent(),
                Value<bool> star = const Value.absent(),
                Value<double> position = const Value.absent(),
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTodoStepsCompanion.insert(
                id: id,
                todoId: todoId,
                content: content,
                done: done,
                heading: heading,
                indent: indent,
                star: star,
                position: position,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KTodoStepsTable, KTodoStep>(table),
                  BaseReferences<_$KolumnDb, $KTodoStepsTable, KTodoStep>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KTodoStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KTodoStepsTable,
      KTodoStep,
      $$KTodoStepsTableFilterComposer,
      $$KTodoStepsTableOrderingComposer,
      $$KTodoStepsTableAnnotationComposer,
      $$KTodoStepsTableCreateCompanionBuilder,
      $$KTodoStepsTableUpdateCompanionBuilder,
      (KTodoStep, BaseReferences<_$KolumnDb, $KTodoStepsTable, KTodoStep>),
      KTodoStep,
      PrefetchHooks Function()
    >;
typedef $$KTodoFilesTableCreateCompanionBuilder = KTodoFilesCompanion Function({
  required String id,
  required String todoId,
  Value<int> userId,
  required String filename,
  Value<String> mime,
  Value<int> size,
  Value<int?> width,
  Value<int?> height,
  Value<bool> hasThumb,
  required int createdAt,
  Value<int?> deletedAt,
  Value<String?> localPath,
  Value<bool> uploaded,
  Value<int> rowid,
});
typedef $$KTodoFilesTableUpdateCompanionBuilder = KTodoFilesCompanion Function({
  Value<String> id,
  Value<String> todoId,
  Value<int> userId,
  Value<String> filename,
  Value<String> mime,
  Value<int> size,
  Value<int?> width,
  Value<int?> height,
  Value<bool> hasThumb,
  Value<int> createdAt,
  Value<int?> deletedAt,
  Value<String?> localPath,
  Value<bool> uploaded,
  Value<int> rowid,
});

class $$KTodoFilesTableFilterComposer
    extends Composer<_$KolumnDb, $KTodoFilesTable> {
  $$KTodoFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasThumb => $composableBuilder(
    column: $table.hasThumb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KTodoFilesTableOrderingComposer
    extends Composer<_$KolumnDb, $KTodoFilesTable> {
  $$KTodoFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasThumb => $composableBuilder(
    column: $table.hasThumb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KTodoFilesTableAnnotationComposer
    extends Composer<_$KolumnDb, $KTodoFilesTable> {
  $$KTodoFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<bool> get hasThumb =>
      $composableBuilder(column: $table.hasThumb, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);
}

class $$KTodoFilesTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KTodoFilesTable,
          KTodoFile,
          $$KTodoFilesTableFilterComposer,
          $$KTodoFilesTableOrderingComposer,
          $$KTodoFilesTableAnnotationComposer,
          $$KTodoFilesTableCreateCompanionBuilder,
          $$KTodoFilesTableUpdateCompanionBuilder,
          (KTodoFile, BaseReferences<_$KolumnDb, $KTodoFilesTable, KTodoFile>),
          KTodoFile,
          PrefetchHooks Function()
        > {
  $$KTodoFilesTableTableManager(_$KolumnDb db, $KTodoFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KTodoFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KTodoFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KTodoFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> todoId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<bool> hasThumb = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTodoFilesCompanion(
                id: id,
                todoId: todoId,
                userId: userId,
                filename: filename,
                mime: mime,
                size: size,
                width: width,
                height: height,
                hasThumb: hasThumb,
                createdAt: createdAt,
                deletedAt: deletedAt,
                localPath: localPath,
                uploaded: uploaded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String todoId,
                Value<int> userId = const Value.absent(),
                required String filename,
                Value<String> mime = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<bool> hasThumb = const Value.absent(),
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KTodoFilesCompanion.insert(
                id: id,
                todoId: todoId,
                userId: userId,
                filename: filename,
                mime: mime,
                size: size,
                width: width,
                height: height,
                hasThumb: hasThumb,
                createdAt: createdAt,
                deletedAt: deletedAt,
                localPath: localPath,
                uploaded: uploaded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KTodoFilesTable, KTodoFile>(table),
                  BaseReferences<_$KolumnDb, $KTodoFilesTable, KTodoFile>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KTodoFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KTodoFilesTable,
      KTodoFile,
      $$KTodoFilesTableFilterComposer,
      $$KTodoFilesTableOrderingComposer,
      $$KTodoFilesTableAnnotationComposer,
      $$KTodoFilesTableCreateCompanionBuilder,
      $$KTodoFilesTableUpdateCompanionBuilder,
      (KTodoFile, BaseReferences<_$KolumnDb, $KTodoFilesTable, KTodoFile>),
      KTodoFile,
      PrefetchHooks Function()
    >;
typedef $$KRemindersTableCreateCompanionBuilder = KRemindersCompanion Function({
  required String itemId,
  required String kind,
  Value<int?> at,
  Value<int> rowid,
});
typedef $$KRemindersTableUpdateCompanionBuilder = KRemindersCompanion Function({
  Value<String> itemId,
  Value<String> kind,
  Value<int?> at,
  Value<int> rowid,
});

class $$KRemindersTableFilterComposer
    extends Composer<_$KolumnDb, $KRemindersTable> {
  $$KRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KRemindersTableOrderingComposer
    extends Composer<_$KolumnDb, $KRemindersTable> {
  $$KRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KRemindersTableAnnotationComposer
    extends Composer<_$KolumnDb, $KRemindersTable> {
  $$KRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$KRemindersTableTableManager
    extends
        RootTableManager<
          _$KolumnDb,
          $KRemindersTable,
          KReminder,
          $$KRemindersTableFilterComposer,
          $$KRemindersTableOrderingComposer,
          $$KRemindersTableAnnotationComposer,
          $$KRemindersTableCreateCompanionBuilder,
          $$KRemindersTableUpdateCompanionBuilder,
          (KReminder, BaseReferences<_$KolumnDb, $KRemindersTable, KReminder>),
          KReminder,
          PrefetchHooks Function()
        > {
  $$KRemindersTableTableManager(_$KolumnDb db, $KRemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KRemindersCompanion(
                itemId: itemId,
                kind: kind,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required String kind,
                Value<int?> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KRemindersCompanion.insert(
                itemId: itemId,
                kind: kind,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KRemindersTable, KReminder>(table),
                  BaseReferences<_$KolumnDb, $KRemindersTable, KReminder>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$KolumnDb,
      $KRemindersTable,
      KReminder,
      $$KRemindersTableFilterComposer,
      $$KRemindersTableOrderingComposer,
      $$KRemindersTableAnnotationComposer,
      $$KRemindersTableCreateCompanionBuilder,
      $$KRemindersTableUpdateCompanionBuilder,
      (KReminder, BaseReferences<_$KolumnDb, $KRemindersTable, KReminder>),
      KReminder,
      PrefetchHooks Function()
    >;

class $KolumnDbManager {
  final _$KolumnDb _db;
  $KolumnDbManager(this._db);
  $$KBoardsTableTableManager get kBoards =>
      $$KBoardsTableTableManager(_db, _db.kBoards);
  $$KColumnsTableTableManager get kColumns =>
      $$KColumnsTableTableManager(_db, _db.kColumns);
  $$KCardsTableTableManager get kCards =>
      $$KCardsTableTableManager(_db, _db.kCards);
  $$KPeopleTableTableManager get kPeople =>
      $$KPeopleTableTableManager(_db, _db.kPeople);
  $$KSettingsTableTableManager get kSettings =>
      $$KSettingsTableTableManager(_db, _db.kSettings);
  $$KOutboxTableTableManager get kOutbox =>
      $$KOutboxTableTableManager(_db, _db.kOutbox);
  $$KStepsTableTableManager get kSteps =>
      $$KStepsTableTableManager(_db, _db.kSteps);
  $$KCommentsTableTableManager get kComments =>
      $$KCommentsTableTableManager(_db, _db.kComments);
  $$KReactionsTableTableManager get kReactions =>
      $$KReactionsTableTableManager(_db, _db.kReactions);
  $$KTagsTableTableManager get kTags =>
      $$KTagsTableTableManager(_db, _db.kTags);
  $$KAssigneesTableTableManager get kAssignees =>
      $$KAssigneesTableTableManager(_db, _db.kAssignees);
  $$KWatchesTableTableManager get kWatches =>
      $$KWatchesTableTableManager(_db, _db.kWatches);
  $$KPinsTableTableManager get kPins =>
      $$KPinsTableTableManager(_db, _db.kPins);
  $$KFilesTableTableManager get kFiles =>
      $$KFilesTableTableManager(_db, _db.kFiles);
  $$KEventsTableTableManager get kEvents =>
      $$KEventsTableTableManager(_db, _db.kEvents);
  $$KPlannersTableTableManager get kPlanners =>
      $$KPlannersTableTableManager(_db, _db.kPlanners);
  $$KPlannerPeopleTableTableManager get kPlannerPeople =>
      $$KPlannerPeopleTableTableManager(_db, _db.kPlannerPeople);
  $$KTodosTableTableManager get kTodos =>
      $$KTodosTableTableManager(_db, _db.kTodos);
  $$KTodoMarksTableTableManager get kTodoMarks =>
      $$KTodoMarksTableTableManager(_db, _db.kTodoMarks);
  $$KTodoStepsTableTableManager get kTodoSteps =>
      $$KTodoStepsTableTableManager(_db, _db.kTodoSteps);
  $$KTodoFilesTableTableManager get kTodoFiles =>
      $$KTodoFilesTableTableManager(_db, _db.kTodoFiles);
  $$KRemindersTableTableManager get kReminders =>
      $$KRemindersTableTableManager(_db, _db.kReminders);
}
