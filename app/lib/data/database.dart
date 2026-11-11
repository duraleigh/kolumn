import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Kolumn's on-device store. Every change is also written to [KOutbox] so the
/// Phase 3 sync can send it to the hub; nothing reads the outbox yet.
///
/// Times are milliseconds since the epoch, UTC. Rows are soft-deleted
/// (`deletedAt`) so a later sync can tell other devices about deletions.

@DataClassName('KBoard')
class KBoards extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get tidyDays => integer().nullable()();
  // Sharing, as the hub last reported it (schema 2).
  BoolColumn get allAccess => boolean().withDefault(const Constant(true))();
  IntColumn get creatorId => integer().nullable()();
  TextColumn get members => text().withDefault(const Constant('[]'))();
  BoolColumn get canManage => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KColumn')
class KColumns extends Table {
  TextColumn get id => text()();
  TextColumn get boardId => text()();
  TextColumn get name => text()();
  IntColumn get color => integer().withDefault(const Constant(0))();
  RealColumn get position => real()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KCard')
class KCards extends Table {
  TextColumn get id => text()();
  TextColumn get boardId => text()();
  IntColumn get number => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get columnId => text().nullable()();
  IntColumn get closedAt => integer().nullable()();
  IntColumn get laterAt => integer().nullable()();
  TextColumn get laterReason => text().nullable()();
  IntColumn get priorityAt => integer().nullable()();
  IntColumn get dueAt => integer().nullable()();
  BoolColumn get dueHasTime => boolean().withDefault(const Constant(false))();
  IntColumn get lastActiveAt => integer()();
  // Schema 2: the hub's revision of this card, whether the hub has it yet,
  // and who made it.
  IntColumn get rev => integer().withDefault(const Constant(0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  IntColumn get creatorId => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The team: everyone who may use To-Dos, as the hub last reported.
@DataClassName('KPerson')
class KPeople extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KSetting')
class KSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('KOutboxEntry')
class KOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mutationId => text().unique()();
  TextColumn get name => text()();
  TextColumn get args => text()();
  IntColumn get clientTs => integer()();
}

@DriftDatabase(tables: [KBoards, KColumns, KCards, KPeople, KSettings, KOutbox])
class KolumnDb extends _$KolumnDb {
  KolumnDb() : super(driftDatabase(name: 'kolumn'));

  KolumnDb.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(kBoards, kBoards.allAccess);
        await m.addColumn(kBoards, kBoards.creatorId);
        await m.addColumn(kBoards, kBoards.members);
        await m.addColumn(kBoards, kBoards.canManage);
        await m.addColumn(kCards, kCards.rev);
        await m.addColumn(kCards, kCards.synced);
        await m.addColumn(kCards, kCards.creatorId);
        await m.createTable(kPeople);
      }
    },
  );
}
