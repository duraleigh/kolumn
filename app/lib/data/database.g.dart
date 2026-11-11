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
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tidyDaysMeta = const VerificationMeta('tidyDays');
  @override
  late final GeneratedColumn<int> tidyDays = GeneratedColumn<int>('tidy_days', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _allAccessMeta = const VerificationMeta('allAccess');
  @override
  late final GeneratedColumn<bool> allAccess = GeneratedColumn<bool>(
    'all_access',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("all_access" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta('creatorId');
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>('creator_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _membersMeta = const VerificationMeta('members');
  @override
  late final GeneratedColumn<String> members = GeneratedColumn<String>(
    'members',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _canManageMeta = const VerificationMeta('canManage');
  @override
  late final GeneratedColumn<bool> canManage = GeneratedColumn<bool>(
    'can_manage',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("can_manage" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>('created_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>('updated_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>('deleted_at', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, tidyDays, allAccess, creatorId, members, canManage, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_boards';
  @override
  VerificationContext validateIntegrity(Insertable<KBoard> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tidy_days')) {
      context.handle(_tidyDaysMeta, tidyDays.isAcceptableOrUnknown(data['tidy_days']!, _tidyDaysMeta));
    }
    if (data.containsKey('all_access')) {
      context.handle(_allAccessMeta, allAccess.isAcceptableOrUnknown(data['all_access']!, _allAccessMeta));
    }
    if (data.containsKey('creator_id')) {
      context.handle(_creatorIdMeta, creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta));
    }
    if (data.containsKey('members')) {
      context.handle(_membersMeta, members.isAcceptableOrUnknown(data['members']!, _membersMeta));
    }
    if (data.containsKey('can_manage')) {
      context.handle(_canManageMeta, canManage.isAcceptableOrUnknown(data['can_manage']!, _canManageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KBoard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KBoard(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      tidyDays: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tidy_days']),
      allAccess: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}all_access'])!,
      creatorId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}creator_id']),
      members: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}members'])!,
      canManage: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}can_manage'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
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
      tidyDays: tidyDays == null && nullToAbsent ? const Value.absent() : Value(tidyDays),
      allAccess: Value(allAccess),
      creatorId: creatorId == null && nullToAbsent ? const Value.absent() : Value(creatorId),
      members: Value(members),
      canManage: Value(canManage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory KBoard.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
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
  int get hashCode => Object.hash(id, name, tidyDays, allAccess, creatorId, members, canManage, createdAt, updatedAt, deletedAt);
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boardIdMeta = const VerificationMeta('boardId');
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>('board_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>('position', aliasedName, false, type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>('created_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>('updated_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>('deleted_at', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, boardId, name, color, position, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_columns';
  @override
  VerificationContext validateIntegrity(Insertable<KColumn> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('board_id')) {
      context.handle(_boardIdMeta, boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta));
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KColumn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KColumn(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      boardId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}board_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      position: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}position'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
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
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory KColumn.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
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
  int get hashCode => Object.hash(id, boardId, name, color, position, createdAt, updatedAt, deletedAt);
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boardIdMeta = const VerificationMeta('boardId');
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>('board_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>('number', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _columnIdMeta = const VerificationMeta('columnId');
  @override
  late final GeneratedColumn<String> columnId = GeneratedColumn<String>('column_id', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _closedAtMeta = const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<int> closedAt = GeneratedColumn<int>('closed_at', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _laterAtMeta = const VerificationMeta('laterAt');
  @override
  late final GeneratedColumn<int> laterAt = GeneratedColumn<int>('later_at', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _laterReasonMeta = const VerificationMeta('laterReason');
  @override
  late final GeneratedColumn<String> laterReason = GeneratedColumn<String>(
    'later_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityAtMeta = const VerificationMeta('priorityAt');
  @override
  late final GeneratedColumn<int> priorityAt = GeneratedColumn<int>('priority_at', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>('due_at', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dueHasTimeMeta = const VerificationMeta('dueHasTime');
  @override
  late final GeneratedColumn<bool> dueHasTime = GeneratedColumn<bool>(
    'due_has_time',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("due_has_time" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta('lastActiveAt');
  @override
  late final GeneratedColumn<int> lastActiveAt = GeneratedColumn<int>('last_active_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta('creatorId');
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>('creator_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>('created_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>('updated_at', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>('deleted_at', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
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
  VerificationContext validateIntegrity(Insertable<KCard> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('board_id')) {
      context.handle(_boardIdMeta, boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta));
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta, number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    }
    if (data.containsKey('column_id')) {
      context.handle(_columnIdMeta, columnId.isAcceptableOrUnknown(data['column_id']!, _columnIdMeta));
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta, closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('later_at')) {
      context.handle(_laterAtMeta, laterAt.isAcceptableOrUnknown(data['later_at']!, _laterAtMeta));
    }
    if (data.containsKey('later_reason')) {
      context.handle(_laterReasonMeta, laterReason.isAcceptableOrUnknown(data['later_reason']!, _laterReasonMeta));
    }
    if (data.containsKey('priority_at')) {
      context.handle(_priorityAtMeta, priorityAt.isAcceptableOrUnknown(data['priority_at']!, _priorityAtMeta));
    }
    if (data.containsKey('due_at')) {
      context.handle(_dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    }
    if (data.containsKey('due_has_time')) {
      context.handle(_dueHasTimeMeta, dueHasTime.isAcceptableOrUnknown(data['due_has_time']!, _dueHasTimeMeta));
    }
    if (data.containsKey('last_active_at')) {
      context.handle(_lastActiveAtMeta, lastActiveAt.isAcceptableOrUnknown(data['last_active_at']!, _lastActiveAtMeta));
    } else if (isInserting) {
      context.missing(_lastActiveAtMeta);
    }
    if (data.containsKey('rev')) {
      context.handle(_revMeta, rev.isAcceptableOrUnknown(data['rev']!, _revMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta, synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('creator_id')) {
      context.handle(_creatorIdMeta, creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KCard(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      boardId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}board_id'])!,
      number: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}number'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      columnId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}column_id']),
      closedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}closed_at']),
      laterAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}later_at']),
      laterReason: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}later_reason']),
      priorityAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority_at']),
      dueAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}due_at']),
      dueHasTime: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}due_has_time'])!,
      lastActiveAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_active_at'])!,
      rev: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rev'])!,
      synced: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      creatorId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}creator_id']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
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
      columnId: columnId == null && nullToAbsent ? const Value.absent() : Value(columnId),
      closedAt: closedAt == null && nullToAbsent ? const Value.absent() : Value(closedAt),
      laterAt: laterAt == null && nullToAbsent ? const Value.absent() : Value(laterAt),
      laterReason: laterReason == null && nullToAbsent ? const Value.absent() : Value(laterReason),
      priorityAt: priorityAt == null && nullToAbsent ? const Value.absent() : Value(priorityAt),
      dueAt: dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      dueHasTime: Value(dueHasTime),
      lastActiveAt: Value(lastActiveAt),
      rev: Value(rev),
      synced: Value(synced),
      creatorId: creatorId == null && nullToAbsent ? const Value.absent() : Value(creatorId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory KCard.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
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
      description: data.description.present ? data.description.value : this.description,
      columnId: data.columnId.present ? data.columnId.value : this.columnId,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      laterAt: data.laterAt.present ? data.laterAt.value : this.laterAt,
      laterReason: data.laterReason.present ? data.laterReason.value : this.laterReason,
      priorityAt: data.priorityAt.present ? data.priorityAt.value : this.priorityAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      dueHasTime: data.dueHasTime.present ? data.dueHasTime.value : this.dueHasTime,
      lastActiveAt: data.lastActiveAt.present ? data.lastActiveAt.value : this.lastActiveAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      synced: data.synced.present ? data.synced.value : this.synced,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
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
    createdAt,
    updatedAt,
    deletedAt,
  );
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
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_people';
  @override
  VerificationContext validateIntegrity(Insertable<KPerson> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
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
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
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

  factory KPerson.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KPerson(id: serializer.fromJson<int>(json['id']), name: serializer.fromJson<String>(json['name']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<int>(id), 'name': serializer.toJson<String>(name)};
  }

  KPerson copyWith({int? id, String? name}) => KPerson(id: id ?? this.id, name: name ?? this.name);
  KPerson copyWithCompanion(KPeopleCompanion data) {
    return KPerson(id: data.id.present ? data.id.value : this.id, name: data.name.present ? data.name.value : this.name);
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
  bool operator ==(Object other) => identical(this, other) || (other is KPerson && other.id == this.id && other.name == this.name);
}

class KPeopleCompanion extends UpdateCompanion<KPerson> {
  final Value<int> id;
  final Value<String> name;
  const KPeopleCompanion({this.id = const Value.absent(), this.name = const Value.absent()});
  KPeopleCompanion.insert({this.id = const Value.absent(), required String name}) : name = Value(name);
  static Insertable<KPerson> custom({Expression<int>? id, Expression<String>? name}) {
    return RawValuesInsertable({if (id != null) 'id': id, if (name != null) 'name': name});
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

class $KSettingsTable extends KSettings with TableInfo<$KSettingsTable, KSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>('key', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>('value', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_settings';
  @override
  VerificationContext validateIntegrity(Insertable<KSetting> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
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
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
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

  factory KSetting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KSetting(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  KSetting copyWith({String? key, String? value}) => KSetting(key: key ?? this.key, value: value ?? this.value);
  KSetting copyWithCompanion(KSettingsCompanion data) {
    return KSetting(key: data.key.present ? data.key.value : this.key, value: data.value.present ? data.value.value : this.value);
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
  bool operator ==(Object other) => identical(this, other) || (other is KSetting && other.key == this.key && other.value == this.value);
}

class KSettingsCompanion extends UpdateCompanion<KSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KSettingsCompanion({this.key = const Value.absent(), this.value = const Value.absent(), this.rowid = const Value.absent()});
  KSettingsCompanion.insert({required String key, required String value, this.rowid = const Value.absent()}) : key = Value(key), value = Value(value);
  static Insertable<KSetting> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({if (key != null) 'key': key, if (value != null) 'value': value, if (rowid != null) 'rowid': rowid});
  }

  KSettingsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return KSettingsCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
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

class $KOutboxTable extends KOutbox with TableInfo<$KOutboxTable, KOutboxEntry> {
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta('mutationId');
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
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _argsMeta = const VerificationMeta('args');
  @override
  late final GeneratedColumn<String> args = GeneratedColumn<String>('args', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientTsMeta = const VerificationMeta('clientTs');
  @override
  late final GeneratedColumn<int> clientTs = GeneratedColumn<int>('client_ts', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, mutationId, name, args, clientTs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'k_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<KOutboxEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mutation_id')) {
      context.handle(_mutationIdMeta, mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta));
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('args')) {
      context.handle(_argsMeta, args.isAcceptableOrUnknown(data['args']!, _argsMeta));
    } else if (isInserting) {
      context.missing(_argsMeta);
    }
    if (data.containsKey('client_ts')) {
      context.handle(_clientTsMeta, clientTs.isAcceptableOrUnknown(data['client_ts']!, _clientTsMeta));
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
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mutationId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}mutation_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      args: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}args'])!,
      clientTs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}client_ts'])!,
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
  const KOutboxEntry({required this.id, required this.mutationId, required this.name, required this.args, required this.clientTs});
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
    return KOutboxCompanion(id: Value(id), mutationId: Value(mutationId), name: Value(name), args: Value(args), clientTs: Value(clientTs));
  }

  factory KOutboxEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
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

  KOutboxEntry copyWith({int? id, String? mutationId, String? name, String? args, int? clientTs}) => KOutboxEntry(
    id: id ?? this.id,
    mutationId: mutationId ?? this.mutationId,
    name: name ?? this.name,
    args: args ?? this.args,
    clientTs: clientTs ?? this.clientTs,
  );
  KOutboxEntry copyWithCompanion(KOutboxCompanion data) {
    return KOutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      mutationId: data.mutationId.present ? data.mutationId.value : this.mutationId,
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
  KOutboxCompanion.insert({this.id = const Value.absent(), required String mutationId, required String name, required String args, required int clientTs})
    : mutationId = Value(mutationId),
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

  KOutboxCompanion copyWith({Value<int>? id, Value<String>? mutationId, Value<String>? name, Value<String>? args, Value<int>? clientTs}) {
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

abstract class _$KolumnDb extends GeneratedDatabase {
  _$KolumnDb(QueryExecutor e) : super(e);
  $KolumnDbManager get managers => $KolumnDbManager(this);
  late final $KBoardsTable kBoards = $KBoardsTable(this);
  late final $KColumnsTable kColumns = $KColumnsTable(this);
  late final $KCardsTable kCards = $KCardsTable(this);
  late final $KPeopleTable kPeople = $KPeopleTable(this);
  late final $KSettingsTable kSettings = $KSettingsTable(this);
  late final $KOutboxTable kOutbox = $KOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [kBoards, kColumns, kCards, kPeople, kSettings, kOutbox];
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
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tidyDays => $composableBuilder(column: $table.tidyDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get allAccess => $composableBuilder(column: $table.allAccess, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get creatorId => $composableBuilder(column: $table.creatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get members => $composableBuilder(column: $table.members, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canManage => $composableBuilder(column: $table.canManage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$KBoardsTableOrderingComposer extends Composer<_$KolumnDb, $KBoardsTable> {
  $$KBoardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tidyDays => $composableBuilder(column: $table.tidyDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get allAccess => $composableBuilder(column: $table.allAccess, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get creatorId => $composableBuilder(column: $table.creatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get members => $composableBuilder(column: $table.members, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canManage => $composableBuilder(column: $table.canManage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$KBoardsTableAnnotationComposer extends Composer<_$KolumnDb, $KBoardsTable> {
  $$KBoardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get tidyDays => $composableBuilder(column: $table.tidyDays, builder: (column) => column);

  GeneratedColumn<bool> get allAccess => $composableBuilder(column: $table.allAccess, builder: (column) => column);

  GeneratedColumn<int> get creatorId => $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<String> get members => $composableBuilder(column: $table.members, builder: (column) => column);

  GeneratedColumn<bool> get canManage => $composableBuilder(column: $table.canManage, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);
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
          createFilteringComposer: () => $$KBoardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KBoardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$KBoardsTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$KBoardsTable, KBoard>(table), BaseReferences<_$KolumnDb, $KBoardsTable, KBoard>(db, table, e))).toList(),
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

class $$KColumnsTableFilterComposer extends Composer<_$KolumnDb, $KColumnsTable> {
  $$KColumnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boardId => $composableBuilder(column: $table.boardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get position => $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$KColumnsTableOrderingComposer extends Composer<_$KolumnDb, $KColumnsTable> {
  $$KColumnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boardId => $composableBuilder(column: $table.boardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get position => $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$KColumnsTableAnnotationComposer extends Composer<_$KolumnDb, $KColumnsTable> {
  $$KColumnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boardId => $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get position => $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);
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
          createFilteringComposer: () => $$KColumnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KColumnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$KColumnsTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$KColumnsTable, KColumn>(table), BaseReferences<_$KolumnDb, $KColumnsTable, KColumn>(db, table, e))).toList(),
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
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boardId => $composableBuilder(column: $table.boardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get columnId => $composableBuilder(column: $table.columnId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get closedAt => $composableBuilder(column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get laterAt => $composableBuilder(column: $table.laterAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get laterReason => $composableBuilder(column: $table.laterReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priorityAt => $composableBuilder(column: $table.priorityAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueAt => $composableBuilder(column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dueHasTime => $composableBuilder(column: $table.dueHasTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastActiveAt => $composableBuilder(column: $table.lastActiveAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rev => $composableBuilder(column: $table.rev, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get creatorId => $composableBuilder(column: $table.creatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$KCardsTableOrderingComposer extends Composer<_$KolumnDb, $KCardsTable> {
  $$KCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boardId => $composableBuilder(column: $table.boardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get columnId => $composableBuilder(column: $table.columnId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get closedAt => $composableBuilder(column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get laterAt => $composableBuilder(column: $table.laterAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get laterReason => $composableBuilder(column: $table.laterReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priorityAt => $composableBuilder(column: $table.priorityAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueAt => $composableBuilder(column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dueHasTime => $composableBuilder(column: $table.dueHasTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastActiveAt => $composableBuilder(column: $table.lastActiveAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rev => $composableBuilder(column: $table.rev, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get creatorId => $composableBuilder(column: $table.creatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$KCardsTableAnnotationComposer extends Composer<_$KolumnDb, $KCardsTable> {
  $$KCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get boardId => $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<int> get number => $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get columnId => $composableBuilder(column: $table.columnId, builder: (column) => column);

  GeneratedColumn<int> get closedAt => $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get laterAt => $composableBuilder(column: $table.laterAt, builder: (column) => column);

  GeneratedColumn<String> get laterReason => $composableBuilder(column: $table.laterReason, builder: (column) => column);

  GeneratedColumn<int> get priorityAt => $composableBuilder(column: $table.priorityAt, builder: (column) => column);

  GeneratedColumn<int> get dueAt => $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<bool> get dueHasTime => $composableBuilder(column: $table.dueHasTime, builder: (column) => column);

  GeneratedColumn<int> get lastActiveAt => $composableBuilder(column: $table.lastActiveAt, builder: (column) => column);

  GeneratedColumn<int> get rev => $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get synced => $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<int> get creatorId => $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);
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
          createFilteringComposer: () => $$KCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$KCardsTableAnnotationComposer($db: db, $table: table),
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
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$KCardsTable, KCard>(table), BaseReferences<_$KolumnDb, $KCardsTable, KCard>(db, table, e))).toList(),
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
typedef $$KPeopleTableCreateCompanionBuilder = KPeopleCompanion Function({Value<int> id, required String name});
typedef $$KPeopleTableUpdateCompanionBuilder = KPeopleCompanion Function({Value<int> id, Value<String> name});

class $$KPeopleTableFilterComposer extends Composer<_$KolumnDb, $KPeopleTable> {
  $$KPeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$KPeopleTableOrderingComposer extends Composer<_$KolumnDb, $KPeopleTable> {
  $$KPeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$KPeopleTableAnnotationComposer extends Composer<_$KolumnDb, $KPeopleTable> {
  $$KPeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);
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
          createFilteringComposer: () => $$KPeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KPeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$KPeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({Value<int> id = const Value.absent(), Value<String> name = const Value.absent()}) => KPeopleCompanion(id: id, name: name),
          createCompanionCallback: ({Value<int> id = const Value.absent(), required String name}) => KPeopleCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$KPeopleTable, KPerson>(table), BaseReferences<_$KolumnDb, $KPeopleTable, KPerson>(db, table, e))).toList(),
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
typedef $$KSettingsTableCreateCompanionBuilder = KSettingsCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$KSettingsTableUpdateCompanionBuilder = KSettingsCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$KSettingsTableFilterComposer extends Composer<_$KolumnDb, $KSettingsTable> {
  $$KSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$KSettingsTableOrderingComposer extends Composer<_$KolumnDb, $KSettingsTable> {
  $$KSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$KSettingsTableAnnotationComposer extends Composer<_$KolumnDb, $KSettingsTable> {
  $$KSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
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
          createFilteringComposer: () => $$KSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$KSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => KSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({required String key, required String value, Value<int> rowid = const Value.absent()}) =>
              KSettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$KSettingsTable, KSetting>(table), BaseReferences<_$KolumnDb, $KSettingsTable, KSetting>(db, table, e))).toList(),
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
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mutationId => $composableBuilder(column: $table.mutationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get args => $composableBuilder(column: $table.args, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientTs => $composableBuilder(column: $table.clientTs, builder: (column) => ColumnFilters(column));
}

class $$KOutboxTableOrderingComposer extends Composer<_$KolumnDb, $KOutboxTable> {
  $$KOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mutationId => $composableBuilder(column: $table.mutationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get args => $composableBuilder(column: $table.args, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientTs => $composableBuilder(column: $table.clientTs, builder: (column) => ColumnOrderings(column));
}

class $$KOutboxTableAnnotationComposer extends Composer<_$KolumnDb, $KOutboxTable> {
  $$KOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mutationId => $composableBuilder(column: $table.mutationId, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get args => $composableBuilder(column: $table.args, builder: (column) => column);

  GeneratedColumn<int> get clientTs => $composableBuilder(column: $table.clientTs, builder: (column) => column);
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
          (KOutboxEntry, BaseReferences<_$KolumnDb, $KOutboxTable, KOutboxEntry>),
          KOutboxEntry,
          PrefetchHooks Function()
        > {
  $$KOutboxTableTableManager(_$KolumnDb db, $KOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$KOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$KOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> mutationId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> args = const Value.absent(),
            Value<int> clientTs = const Value.absent(),
          }) => KOutboxCompanion(id: id, mutationId: mutationId, name: name, args: args, clientTs: clientTs),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String mutationId,
            required String name,
            required String args,
            required int clientTs,
          }) => KOutboxCompanion.insert(id: id, mutationId: mutationId, name: name, args: args, clientTs: clientTs),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$KOutboxTable, KOutboxEntry>(table), BaseReferences<_$KolumnDb, $KOutboxTable, KOutboxEntry>(db, table, e))).toList(),
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

class $KolumnDbManager {
  final _$KolumnDb _db;
  $KolumnDbManager(this._db);
  $$KBoardsTableTableManager get kBoards => $$KBoardsTableTableManager(_db, _db.kBoards);
  $$KColumnsTableTableManager get kColumns => $$KColumnsTableTableManager(_db, _db.kColumns);
  $$KCardsTableTableManager get kCards => $$KCardsTableTableManager(_db, _db.kCards);
  $$KPeopleTableTableManager get kPeople => $$KPeopleTableTableManager(_db, _db.kPeople);
  $$KSettingsTableTableManager get kSettings => $$KSettingsTableTableManager(_db, _db.kSettings);
  $$KOutboxTableTableManager get kOutbox => $$KOutboxTableTableManager(_db, _db.kOutbox);
}
