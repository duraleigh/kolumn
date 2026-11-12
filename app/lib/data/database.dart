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
  // Schema 6: this Kolumn's own names and colors for Later, To-do and Done,
  // as JSON: {"later": {"name": "Parked", "color": 3}, ...}.
  TextColumn get lanes => text().withDefault(const Constant('{}'))();
  // Schema 8: the secret view-only link, as the hub gives it to whoever may manage it.
  TextColumn get shareKey => text().nullable()();
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
  // Schema 7: its own place in its kolumn, once dragged into order.
  RealColumn get position => real().nullable()();
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
  // Schema 3: drafts and the cover picture.
  TextColumn get status => text().withDefault(const Constant('published'))();
  TextColumn get coverId => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------- schema 3: everything on a card

@DataClassName('KStep')
class KSteps extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text()();
  TextColumn get content => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  RealColumn get position => real().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KComment')
class KComments extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text()();
  IntColumn get userId => integer()();
  TextColumn get body => text()();
  IntColumn get createdAt => integer()();
  IntColumn get editedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KReaction')
class KReactions extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text()();
  TextColumn get commentId => text().nullable()();
  IntColumn get userId => integer()();
  TextColumn get emoji => text()();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KTag')
class KTags extends Table {
  TextColumn get cardId => text()();
  TextColumn get tag => text()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {cardId, tag};
}

@DataClassName('KAssignee')
class KAssignees extends Table {
  TextColumn get cardId => text()();
  IntColumn get userId => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {cardId, userId};
}

/// The cards this person follows (their own list only).
@DataClassName('KWatch')
class KWatches extends Table {
  TextColumn get cardId => text()();
  BoolColumn get watching => boolean()();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// This person's own pins.
@DataClassName('KPin')
class KPins extends Table {
  TextColumn get cardId => text()();
  IntColumn get pinnedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {cardId};
}

@DataClassName('KFile')
class KFiles extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text()();
  TextColumn get commentId => text().nullable()();
  IntColumn get userId => integer().withDefault(const Constant(0))();
  TextColumn get filename => text()();
  TextColumn get mime => text().withDefault(const Constant('application/octet-stream'))();
  IntColumn get size => integer().withDefault(const Constant(0))();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  BoolColumn get hasThumb => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  // A copy on this phone: the original until it is sent, or a download.
  TextColumn get localPath => text().nullable()();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KEvent')
class KEvents extends Table {
  IntColumn get id => integer()();
  TextColumn get cardId => text()();
  IntColumn get userId => integer()();
  TextColumn get action => text()();
  TextColumn get particulars => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();

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

// ---------------------------------------------------------------- schema 4: the Planner (Phase 5)

/// A planner: to-dos for each day, Tweek style. Private to its maker until
/// shared; shows the dated cards of the Kolumns in [boardIds].
@DataClassName('KPlanner')
class KPlanners extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get creatorId => integer().nullable()();
  BoolColumn get rollOver => boolean().withDefault(const Constant(true))();
  BoolColumn get sinkDone => boolean().withDefault(const Constant(true))();
  BoolColumn get hideDone => boolean().withDefault(const Constant(false))();
  TextColumn get boardIds => text().withDefault(const Constant('[]'))();
  BoolColumn get canManage => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Who a planner is shared with (its maker is not listed: always the owner).
@DataClassName('KPlannerPerson')
class KPlannerPeople extends Table {
  TextColumn get plannerId => text()();
  IntColumn get userId => integer()();
  TextColumn get role => text().withDefault(const Constant('edit'))();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {plannerId, userId};
}

/// A to-do: on a [day] ("2026-11-11", the phone's own calendar day) or in one
/// of the Someday lists ([list] 1-3). [repeat] is the rule as JSON.
@DataClassName('KTodo')
class KTodos extends Table {
  TextColumn get id => text()();
  TextColumn get plannerId => text()();
  TextColumn get day => text().nullable()();
  IntColumn get list => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get doneAt => integer().nullable()();
  RealColumn get position => real().withDefault(const Constant(0))();
  TextColumn get repeat => text().nullable()();
  IntColumn get assigneeId => integer().nullable()();
  IntColumn get creatorId => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One day of a repeating to-do: ticked ("done") or deleted ("skip").
@DataClassName('KTodoMark')
class KTodoMarks extends Table {
  TextColumn get todoId => text()();
  TextColumn get day => text()();
  TextColumn get mark => text()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {todoId, day};
}

@DataClassName('KTodoStep')
class KTodoSteps extends Table {
  TextColumn get id => text()();
  TextColumn get todoId => text()();
  TextColumn get content => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  BoolColumn get heading => boolean().withDefault(const Constant(false))();
  IntColumn get indent => integer().withDefault(const Constant(0))();
  BoolColumn get star => boolean().withDefault(const Constant(false))();
  RealColumn get position => real().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KTodoFile')
class KTodoFiles extends Table {
  TextColumn get id => text()();
  TextColumn get todoId => text()();
  IntColumn get userId => integer().withDefault(const Constant(0))();
  TextColumn get filename => text()();
  TextColumn get mime => text().withDefault(const Constant('application/octet-stream'))();
  IntColumn get size => integer().withDefault(const Constant(0))();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  BoolColumn get hasThumb => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get localPath => text().nullable()();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// This person's own reminders, on to-dos and cards. [at] is when, in
/// milliseconds; null means cleared.
@DataClassName('KReminder')
class KReminders extends Table {
  TextColumn get itemId => text()();
  TextColumn get kind => text()();
  IntColumn get at => integer().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

// ---------------------------------------------------------------- schema 5: alerts and finding things (Phase 6)

/// This person's alerts: at most one per card (newer news replaces older).
@DataClassName('KNotification')
class KNotifications extends Table {
  TextColumn get cardId => text()();
  TextColumn get boardId => text()();
  IntColumn get creatorId => integer().withDefault(const Constant(0))();
  TextColumn get action => text()();
  TextColumn get particulars => text().withDefault(const Constant('{}'))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get readAt => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// Kolumns this person chose to follow (or stop following).
@DataClassName('KBoardWatch')
class KBoardWatches extends Table {
  TextColumn get boardId => text()();
  BoolColumn get watching => boolean()();

  @override
  Set<Column> get primaryKey => {boardId};
}

/// This person's saved views: named filters.
@DataClassName('KView')
class KViews extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get params => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    KBoards,
    KColumns,
    KCards,
    KPeople,
    KSettings,
    KOutbox,
    KSteps,
    KComments,
    KReactions,
    KTags,
    KAssignees,
    KWatches,
    KPins,
    KFiles,
    KEvents,
    KPlanners,
    KPlannerPeople,
    KTodos,
    KTodoMarks,
    KTodoSteps,
    KTodoFiles,
    KReminders,
    KNotifications,
    KBoardWatches,
    KViews,
  ],
)
class KolumnDb extends _$KolumnDb {
  KolumnDb() : super(driftDatabase(name: 'kolumn'));

  KolumnDb.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

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
      if (from < 3) {
        await m.addColumn(kCards, kCards.status);
        await m.addColumn(kCards, kCards.coverId);
        for (final t in <TableInfo>[kSteps, kComments, kReactions, kTags, kAssignees, kWatches, kPins, kFiles, kEvents]) {
          await m.createTable(t);
        }
      }
      if (from < 4) {
        for (final t in <TableInfo>[kPlanners, kPlannerPeople, kTodos, kTodoMarks, kTodoSteps, kTodoFiles, kReminders]) {
          await m.createTable(t);
        }
      }
      if (from < 5) {
        for (final t in <TableInfo>[kNotifications, kBoardWatches, kViews]) {
          await m.createTable(t);
        }
      }
      if (from < 6) {
        await m.addColumn(kBoards, kBoards.lanes);
      }
      if (from < 7) {
        await m.addColumn(kCards, kCards.position);
      }
      if (from < 8) {
        await m.addColumn(kBoards, kBoards.shareKey);
      }
    },
  );
}
