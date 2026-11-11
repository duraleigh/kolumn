import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/data/tidy.dart';
import 'package:kolumn/planner/days.dart';
import 'package:kolumn/planner/planner_model.dart';
import 'package:kolumn/planner/repeat.dart';
import 'package:kolumn/sync/reminders.dart';

void main() {
  group('days', () {
    test('day steps never drift across the clock change (Nov 1 2026)', () {
      expect(addDays('2026-10-31', 1), '2026-11-01');
      expect(addDays('2026-11-01', 1), '2026-11-02');
      expect(addDays('2026-03-07', 1), '2026-03-08');
      expect(addDays('2026-03-08', 1), '2026-03-09');
      expect(daysBetween('2026-10-30', '2026-11-03'), 4);
      expect(addDays('2026-12-31', 1), '2027-01-01');
    });

    test('weeks start on Monday', () {
      expect(mondayOf('2026-11-11'), '2026-11-09');
      expect(mondayOf('2026-11-15'), '2026-11-09');
      expect(mondayOf('2026-11-09'), '2026-11-09');
    });

    test('a due day goes to the hub as noon UTC and comes back as the same day', () {
      for (final d in ['2026-01-01', '2026-11-11', '2026-03-08', '2027-02-28']) {
        expect(dueDayOf(dueMsOf(d)), d);
      }
      expect(dueMsOf('2026-11-09'), DateTime.utc(2026, 11, 9, 12).millisecondsSinceEpoch);
    });

    test('plain words for days', () {
      expect(dayHeading('2026-11-11'), '11 Nov');
      expect(friendlyDay('2026-11-11', today: '2026-11-11'), 'Today');
      expect(friendlyDay('2026-11-12', today: '2026-11-11'), 'Tomorrow');
      expect(friendlyDay('2026-11-10', today: '2026-11-11'), 'Yesterday');
      expect(friendlyDay('2026-11-13', today: '2026-11-11'), 'Fri, 13 Nov');
      expect(friendlyDay('2027-01-05', today: '2026-11-11'), 'Tue, 5 Jan 2027');
    });
  });

  group('repeats', () {
    test('every 2 days', () {
      const r = RepeatRule(every: 2);
      expect(r.daysBetweenIncl('2026-11-09', '2026-11-09', '2026-11-15'), ['2026-11-09', '2026-11-11', '2026-11-13', '2026-11-15']);
      expect(r.occursOn('2026-11-09', '2026-11-08'), isFalse, reason: 'never before it starts');
    });

    test('every 2 weeks on Monday and Wednesday', () {
      const r = RepeatRule(every: 2, unit: RepeatUnit.week, weekdays: [1, 3]);
      expect(r.daysBetweenIncl('2026-11-09', '2026-11-09', '2026-11-30'), ['2026-11-09', '2026-11-11', '2026-11-23', '2026-11-25']);
      expect(r.describe('2026-11-09'), 'Every 2 weeks on Mon, Wed');
    });

    test('weekly with no days picked uses the start day', () {
      const r = RepeatRule(unit: RepeatUnit.week);
      expect(r.daysBetweenIncl('2026-11-11', '2026-11-01', '2026-11-30'), ['2026-11-11', '2026-11-18', '2026-11-25']);
    });

    test('monthly on the 31st lands on the last day of shorter months', () {
      const r = RepeatRule(unit: RepeatUnit.month);
      expect(r.occursOn('2026-01-31', '2026-02-28'), isTrue);
      expect(r.occursOn('2026-01-31', '2026-04-30'), isTrue);
      expect(r.occursOn('2026-01-31', '2026-03-31'), isTrue);
      expect(r.occursOn('2026-01-31', '2026-03-30'), isFalse);
      expect(r.describe('2026-01-31'), 'Every month on the 31st');
    });

    test('monthly on the second Wednesday', () {
      const r = RepeatRule(unit: RepeatUnit.month, monthlyByWeekday: true);
      expect(r.occursOn('2026-11-11', '2026-12-09'), isTrue);
      expect(r.occursOn('2026-11-11', '2026-12-16'), isFalse);
      expect(r.occursOn('2026-11-11', '2027-01-13'), isTrue);
      expect(r.describe('2026-11-11'), 'Every month on the second Wednesday');
    });

    test('a fifth weekday means "the last" one', () {
      const r = RepeatRule(unit: RepeatUnit.month, monthlyByWeekday: true);
      // Friday 30 Oct 2026 is the fifth Friday; November's last Friday is the 27th.
      expect(r.occursOn('2026-10-30', '2026-11-27'), isTrue);
      expect(r.occursOn('2026-10-30', '2026-11-20'), isFalse);
    });

    test('yearly, and ending on a day', () {
      const r = RepeatRule(unit: RepeatUnit.year, until: '2028-12-31');
      expect(r.occursOn('2026-11-11', '2027-11-11'), isTrue);
      expect(r.occursOn('2026-11-11', '2029-11-11'), isFalse);
      expect(r.describe('2026-11-11'), startsWith('Every year on 11 Nov, until'));
    });

    test('the rule goes to the hub and back unchanged', () {
      const r = RepeatRule(every: 3, unit: RepeatUnit.week, weekdays: [2, 5], until: '2027-01-01');
      final back = RepeatRule.fromJson(r.encode())!;
      expect(back.toJson(), r.toJson());
      expect(RepeatRule.fromJson({'unit': 'fortnight'}), isNull);
    });
  });

  group('the Planner on the phone', () {
    late KolumnDb db;
    late KolumnRepository repo;
    var now = 1000;

    setUp(() async {
      now = DateTime(2026, 11, 11, 10).millisecondsSinceEpoch;
      db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
      repo = KolumnRepository(db, clock: () => now += 10);
      await repo.setSetting('me.id', '7');
    });

    tearDown(() => db.close());

    Future<List<Map<String, dynamic>>> sent([String? name]) async => [
      for (final e in await repo.pendingOutbox())
        if (name == null || e.name == name) {'name': e.name, ...(jsonDecode(e.args) as Map<String, dynamic>)},
    ];

    Future<PlannerData> data(String plannerId, {String today = '2026-11-11'}) async {
      final marks = <String, Map<String, String>>{};
      for (final m in await repo.watchTodoMarks().first) {
        marks.putIfAbsent(m.todoId, () => {})[m.day] = m.mark;
      }
      final planner = (await repo.watchPlanners().first).firstWhere((p) => p.id == plannerId);
      return PlannerData(planner: planner, todos: await repo.watchTodos(plannerId).first, marks: marks, cards: await repo.watchAllCards().first, today: today);
    }

    test('everyone starts with "My planner", showing the Kolumns they can see', () async {
      final b = await repo.createBoard('Tour');
      final id = await repo.ensureStarterPlanner();
      expect(await repo.ensureStarterPlanner(), id, reason: 'only once');
      final p = (await repo.watchPlanners().first).single;
      expect(p.name, 'My planner');
      expect(jsonDecode(p.boardIds), [b]);
      expect(p.rollOver && p.sinkDone && !p.hideDone, isTrue);
      expect((await sent('planner.create')).single['boardIds'], [b]);
    });

    test('to-dos go on a day or a Someday list, each to the end of its lines', () async {
      final p = await repo.createPlanner('Tour');
      final a = await repo.addTodo(p, const TodoSlot.day('2026-11-11'), ' Vocal warm-up ');
      final b = await repo.addTodo(p, const TodoSlot.day('2026-11-11'), 'Radio prep');
      final s = await repo.addTodo(p, const TodoSlot.someday(2), 'New merch designs');
      final d = await data(p);
      expect(d.entries('2026-11-11').map((e) => e.todo!.id), [a, b]);
      expect(d.entries('someday-2').single.todo!.id, s);
      expect(d.entries('someday-1'), isEmpty);
      final c = (await sent('todo.create')).first;
      expect(c['title'], 'Vocal warm-up');
      expect(c['day'], '2026-11-11');
      expect(c['list'], isNull);
      expect((await sent('todo.create')).last['list'], 2);
    });

    test('moving a to-do to another day, and to Someday', () async {
      final p = await repo.createPlanner('Tour');
      final t = await repo.addTodo(p, const TodoSlot.day('2026-11-11'), 'Pack the gear');
      await repo.updateTodo(t, slot: const TodoSlot.day('2026-11-14'));
      expect((await repo.todo(t))!.day, '2026-11-14');
      await repo.updateTodo(t, slot: const TodoSlot.someday(3));
      final x = (await repo.todo(t))!;
      expect([x.day, x.list], [null, 3]);
      final last = (await sent('todo.update')).last;
      expect(last.containsKey('day') && last['day'] == null && last['list'] == 3, isTrue, reason: 'the hub is told it has no day');
    });

    test('finished to-dos sink to the bottom, or hide, by the switches', () async {
      final p = await repo.createPlanner('Tour');
      final a = await repo.addTodo(p, const TodoSlot.day('2026-11-11'), 'A');
      await repo.addTodo(p, const TodoSlot.day('2026-11-11'), 'B');
      await repo.setTodoDone((await repo.todo(a))!, true);
      expect((await data(p)).entries('2026-11-11').map((e) => e.title), ['B', 'A']);
      await repo.updatePlanner(p, sinkDone: false);
      expect((await data(p)).entries('2026-11-11').map((e) => e.title), ['A', 'B']);
      await repo.updatePlanner(p, hideDone: true);
      expect((await data(p)).entries('2026-11-11').map((e) => e.title), ['B']);
      expect((await sent('planner.update')).last['hideDone'], isTrue);
    });

    test('a repeating to-do shows on its days; each day is ticked or deleted on its own', () async {
      final p = await repo.createPlanner('Tour');
      final t = await repo.addTodo(p, const TodoSlot.day('2026-11-09'), 'Vocal warm-up');
      await repo.updateTodo(t, repeat: const RepeatRule());
      final todo = (await repo.todo(t))!;
      await repo.setTodoDone(todo, true, day: '2026-11-10');
      await repo.skipTodoDay(todo, '2026-11-12');
      final d = await data(p);
      expect(d.entries('2026-11-08'), isEmpty);
      expect(d.entries('2026-11-09').single.done, isFalse);
      expect(d.entries('2026-11-10').single.done, isTrue);
      expect(d.entries('2026-11-11').single.repeats, isTrue);
      expect(d.entries('2026-11-12'), isEmpty, reason: 'that day was deleted');
      expect(d.entries('2026-11-13'), hasLength(1));
      final done = (await sent('todo.done')).single;
      expect([done['on'], done['day']], [true, '2026-11-10']);
      expect((await sent('todo.skip')).single['day'], '2026-11-12');
      expect((await sent('todo.update')).last['repeat'], {'every': 1, 'unit': 'day'});
    });

    test('"move unfinished to the next day": late to-dos roll to today; finished, repeating and switched-off ones stay', () async {
      final p = await repo.createPlanner('Tour');
      final off = await repo.createPlanner('Family');
      await repo.updatePlanner(off, rollOver: false);
      final late = await repo.addTodo(p, const TodoSlot.day('2026-11-09'), 'Book flights');
      final done = await repo.addTodo(p, const TodoSlot.day('2026-11-09'), 'Call the venue');
      await repo.setTodoDone((await repo.todo(done))!, true);
      final rep = await repo.addTodo(p, const TodoSlot.day('2026-11-09'), 'Warm-up');
      await repo.updateTodo(rep, repeat: const RepeatRule());
      final future = await repo.addTodo(p, const TodoSlot.day('2026-11-20'), 'Charlotte');
      final someday = await repo.addTodo(p, const TodoSlot.someday(1), 'Ideas');
      final other = await repo.addTodo(off, const TodoSlot.day('2026-11-09'), 'Dentist');
      expect(await repo.rollOver('2026-11-11'), 1);
      expect((await repo.todo(late))!.day, '2026-11-11');
      expect((await repo.todo(done))!.day, '2026-11-09');
      expect((await repo.todo(rep))!.day, '2026-11-09');
      expect((await repo.todo(future))!.day, '2026-11-20');
      expect((await repo.todo(someday))!.day, isNull);
      expect((await repo.todo(other))!.day, '2026-11-09');
      expect(await repo.rollOver('2026-11-11'), 0, reason: 'nothing left to move');
    });

    test('dated cards show on their day from ticked Kolumns only; late ones are red and never move', () async {
      final tour = await repo.createBoard('Tour');
      final studio = await repo.createBoard('Studio');
      final p = await repo.createPlanner('Tour', boardIds: [tour]);
      final late = await repo.addCard(tour, 'Confirm hotel block');
      final soon = await repo.addCard(tour, 'Finalize setlist');
      final hidden = await repo.addCard(studio, 'Mix notes');
      final draft = await repo.addCard(tour, 'Secret', draft: true);
      await repo.setCardDue(late, '2026-11-09');
      await repo.setCardDue(soon, '2026-11-12');
      await repo.setCardDue(hidden, '2026-11-12');
      await repo.setCardDue(draft, '2026-11-12');
      await repo.addTodo(p, const TodoSlot.day('2026-11-09'), 'Old to-do');
      expect(await repo.rollOver('2026-11-11'), 1);
      final d = await data(p);
      final mon = d.entries('2026-11-09');
      expect(mon.single.card!.id, late, reason: 'the card stayed; the to-do rolled on');
      expect(mon.single.late, isTrue);
      expect(d.entries('2026-11-12').map((e) => e.title), ['Finalize setlist']);
      expect((await repo.card(late))!.dueAt, DateTime.utc(2026, 11, 9, 12).millisecondsSinceEpoch);
      expect((await sent('card.due')).first, {'name': 'card.due', 'id': late, 'day': '2026-11-09'});
      await repo.moveCard(late, const Lane.done());
      expect((await data(p)).entries('2026-11-09').single.late, isFalse, reason: 'a finished card is not late');
    });

    test('searching finds to-dos by title or note, and cards', () async {
      final b = await repo.createBoard('Tour');
      final p = await repo.createPlanner('Tour', boardIds: [b]);
      final t = await repo.addTodo(p, const TodoSlot.day('2026-11-11'), 'Plan the load-in');
      await repo.updateTodo(t, note: 'Truck arrives at 2');
      await repo.addTodo(p, const TodoSlot.someday(1), 'Fan Q&A ideas');
      final c = await repo.addCard(b, 'Truck rental');
      await repo.setCardDue(c, '2026-11-13');
      final d = await data(p);
      expect(d.search('truck').map((e) => e.title), ['Plan the load-in', 'Truck rental']);
      expect(d.search('ideas').single.slotKey, 'someday-1');
      expect(d.search('  '), isEmpty);
    });

    test('checklist steps: headings, stars, indents', () async {
      final p = await repo.createPlanner('Tour');
      final t = await repo.addTodo(p, const TodoSlot.day('2026-11-11'), 'Load-in');
      await repo.addTodoStep(t, 'Before we leave', heading: true);
      final s = await repo.addTodoStep(t, 'Confirm the dock height');
      final step = (await repo.watchTodoSteps(t).first).firstWhere((x) => x.id == s);
      await repo.updateTodoStep(step, star: true, indent: 1);
      final steps = await repo.watchTodoSteps(t).first;
      expect(steps.map((x) => x.content), ['Before we leave', 'Confirm the dock height']);
      expect(steps.first.heading, isTrue);
      expect([steps.last.star, steps.last.indent], [true, 1]);
      expect((await sent('todostep.update')).single, {'name': 'todostep.update', 'id': s, 'star': true, 'indent': 1});
    });

    test('sharing a planner, and its settings', () async {
      final p = await repo.createPlanner('Family');
      await repo.setPlannerPeople(p, {8: 'edit', 9: 'owner'});
      expect((await repo.watchPlannerPeople(p).first).map((x) => '${x.userId}:${x.role}').toSet(), {'8:edit', '9:owner'});
      await repo.setPlannerPeople(p, {8: 'edit'});
      expect((await repo.watchPlannerPeople(p).first).map((x) => x.userId), [8]);
      expect((await sent('planner.people')).last['people'], [
        {'userId': 8, 'role': 'edit'},
      ]);
    });

    test('taking in a pull: planners, to-dos, ticks, steps and reminders; a planner I left goes', () async {
      final mine = await repo.createPlanner('Old');
      await repo.removeOutbox((await repo.pendingOutbox()).map((e) => e.mutationId));
      await repo.applyPull({
        'cursor': 50,
        'boardIds': <String>[],
        'plannerIds': ['p1'],
        'planners': [
          {'id': 'p1', 'name': 'Tour', 'creatorId': 9, 'rollOver': false, 'sinkDone': true, 'hideDone': false, 'boardIds': <String>[], 'canManage': false, 'createdAt': 1, 'updatedAt': 2},
        ],
        'plannerPeople': [
          {'plannerId': 'p1', 'userId': 7, 'role': 'edit'},
        ],
        'todos': [
          {'id': 't1', 'plannerId': 'p1', 'day': '2026-11-09', 'title': 'Warm-up', 'note': '', 'position': 1, 'repeat': {'every': 1, 'unit': 'day'}, 'createdAt': 1, 'updatedAt': 1},
          {'id': 't2', 'plannerId': 'p1', 'day': null, 'list': 2, 'title': 'Ideas', 'note': 'n', 'position': 1, 'createdAt': 1, 'updatedAt': 1},
        ],
        'todoMarks': [
          {'todoId': 't1', 'day': '2026-11-10', 'mark': 'done'},
        ],
        'todoSteps': [
          {'id': 's1', 'todoId': 't2', 'content': 'One', 'done': false, 'heading': false, 'indent': 2, 'star': true, 'position': 1, 'createdAt': 1},
        ],
        'todoFiles': <Object>[],
        'reminders': [
          {'itemId': 't2', 'kind': 'todo', 'at': 1790000000000},
        ],
      });
      final planners = await repo.watchPlanners().first;
      expect(planners.map((p) => p.id), ['p1'], reason: '"$mine" is not one the hub lists any more');
      expect(planners.single.rollOver, isFalse);
      expect(await repo.setting('planner.current'), 'p1');
      final d = await data('p1');
      expect(d.entries('2026-11-10').single.done, isTrue);
      expect(d.entries('someday-2').single.title, 'Ideas');
      expect((await repo.watchTodoSteps('t2').first).single.indent, 2);
      expect((await repo.watchReminders().first).single.at, 1790000000000);
      expect(await repo.knownPlannerIds(), ['p1']);
    });

    test('a change waiting to be sent is not overwritten by the hub', () async {
      await repo.applyPull({
        'cursor': 1,
        'boardIds': <String>[],
        'plannerIds': ['p1'],
        'planners': [
          {'id': 'p1', 'name': 'Tour', 'creatorId': 7, 'boardIds': <String>[], 'createdAt': 1, 'updatedAt': 1},
        ],
        'todos': [
          {'id': 't1', 'plannerId': 'p1', 'day': '2026-11-11', 'title': 'Old title', 'position': 1, 'createdAt': 1, 'updatedAt': 1},
        ],
      });
      await repo.updateTodo('t1', title: 'New title');
      await repo.applyPull({
        'cursor': 2,
        'boardIds': <String>[],
        'plannerIds': ['p1'],
        'todos': [
          {'id': 't1', 'plannerId': 'p1', 'day': '2026-11-11', 'title': 'Old title', 'position': 1, 'createdAt': 1, 'updatedAt': 1},
        ],
      });
      expect((await repo.todo('t1'))!.title, 'New title');
    });

    test('signing out clears the Planner too', () async {
      final p = await repo.createPlanner('Tour');
      await repo.addTodo(p, const TodoSlot.day('2026-11-11'), 'X');
      await repo.setReminder('x', 'todo', 5);
      await repo.forgetSharedData();
      expect(await repo.watchPlanners().first, isEmpty);
      expect(await repo.watchAllTodos().first, isEmpty);
      expect(await db.select(db.kReminders).get(), isEmpty);
    });
  });

  group('reminders on the phone', () {
    KTodo todo(String id, {String? day = '2026-11-11', String? repeat, int? doneAt}) => KTodo(
      id: id,
      plannerId: 'p',
      day: day,
      title: 'To-do $id',
      note: '',
      doneAt: doneAt,
      position: 1,
      repeat: repeat,
      createdAt: 0,
      updatedAt: 0,
    );
    KCard card(String id, {int? closedAt}) =>
        KCard(id: id, boardId: 'b', number: 4, title: 'Card $id', description: '', closedAt: closedAt, dueHasTime: false, lastActiveAt: 0, rev: 0, synced: true, status: 'published', createdAt: 0, updatedAt: 0);
    final now = DateTime(2026, 11, 11, 10);
    int at(int day, int hour) => DateTime(2026, 11, day, hour).millisecondsSinceEpoch;

    test('only coming ones, and not for finished things', () {
      final list = upcomingReminders(
        reminders: [
          KReminder(itemId: 'a', kind: 'todo', at: at(11, 14)),
          KReminder(itemId: 'b', kind: 'todo', at: at(11, 8)),
          KReminder(itemId: 'c', kind: 'todo', at: at(12, 9)),
          KReminder(itemId: 'k', kind: 'card', at: at(13, 9)),
          KReminder(itemId: 'k2', kind: 'card', at: at(13, 9)),
        ],
        todos: {'a': todo('a'), 'b': todo('b'), 'c': todo('c', doneAt: 1)},
        cards: {'k': card('k'), 'k2': card('k2', closedAt: 1)},
        marks: const {},
        now: now,
      );
      expect(list.map((r) => r.key), ['todo:a', 'card:k']);
    });

    test('a repeating to-do reminds at the same time on each of its days, skipping ticked ones', () {
      final list = upcomingReminders(
        reminders: [KReminder(itemId: 'r', kind: 'todo', at: at(9, 9))],
        todos: {'r': todo('r', day: '2026-11-09', repeat: const RepeatRule().encode())},
        cards: const {},
        marks: const {
          'r': {'2026-11-13': 'done'},
        },
        now: now,
        perRepeat: 4,
      );
      expect(list.map((r) => r.key), ['todo:r@2026-11-12', 'todo:r@2026-11-14', 'todo:r@2026-11-15', 'todo:r@2026-11-16']);
      expect(list.first.at, DateTime(2026, 11, 12, 9));
    });
  });

  group('tidy-up', () {
    const day = 86400000;
    KCard card({int? dueAt, int lastActive = 0, int? laterAt, String status = 'published'}) => KCard(
      id: 'c',
      boardId: 'b',
      number: 1,
      title: 'x',
      description: '',
      dueAt: dueAt,
      laterAt: laterAt,
      dueHasTime: false,
      lastActiveAt: lastActive,
      rev: 0,
      synced: true,
      status: status,
      createdAt: 0,
      updatedAt: 0,
    );
    KBoard board(int? days) => KBoard(id: 'b', name: 'B', tidyDays: days, allAccess: true, members: '[]', canManage: true, createdAt: 0, updatedAt: 0);

    test('counts down from the Kolumn\'s tidy-up time, and warns near the end', () {
      expect(tidyDaysLeft(card(), board(null), 10 * day), 20);
      expect(tidyWarning(card(), board(null), 10 * day), isFalse);
      expect(tidyWarning(card(), board(null), 24 * day), isTrue);
      expect(tidyDaysLeft(card(), board(3), 2 * day + 1), 1);
      expect(tidyWarning(card(), board(3), 2 * day + 1), isTrue);
    });

    test('a card with a due day, a draft, or one already in Later never counts down', () {
      expect(tidyDaysLeft(card(dueAt: 5), board(3), 30 * day), isNull);
      expect(tidyDaysLeft(card(status: 'draft'), board(3), 30 * day), isNull);
      expect(tidyDaysLeft(card(laterAt: 1), board(3), 30 * day), isNull);
    });
  });
}
