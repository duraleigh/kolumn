// Two phones against the PRACTICE site (stage5230ca), never the live site.
// Skipped unless run on purpose with stand-in logins:
//   KOLUMN_PRACTICE_A=user:pass KOLUMN_PRACTICE_B=user:pass flutter test test/practice_sync_test.dart
@Tags(['practice'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/planner/repeat.dart';
import 'package:kolumn/sync/hub_client.dart';
import 'package:kolumn/sync/sync_service.dart';

const practice = 'https://stage5230ca.clayaiken.com';

class Phone {
  Phone(String name) : db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true)), label = name;
  final String label;
  final KolumnDb db;
  late final repo = KolumnRepository(db);
  late final sync = SyncService(
    repo: repo,
    hub: HubClient(credentials: MemoryCredentialStore(), server: practice),
  );
}

void main() {
  final a = Platform.environment['KOLUMN_PRACTICE_A'];
  final b = Platform.environment['KOLUMN_PRACTICE_B'];
  final skip = (a == null || b == null) ? 'needs KOLUMN_PRACTICE_A and KOLUMN_PRACTICE_B' : null;

  test(
    'two phones share a board through the practice hub',
    () async {
      final pa = Phone('A'), pb = Phone('B');
      final (ua, wa) = (a!.split(':')[0], a.split(':').sublist(1).join(':'));
      final (ub, wb) = (b!.split(':')[0], b.split(':').sublist(1).join(':'));

      expect(await pa.sync.signIn(ua, wa), isNull, reason: 'phone A signs in with a hub login');
      expect(await pb.sync.signIn(ub, wb), isNull, reason: 'phone B signs in with a different hub login');

      // A makes a board with a column and a card.
      final board = await pa.repo.createBoard('Two-phone test ${DateTime.now().millisecondsSinceEpoch}');
      final col = await pa.repo.addColumn(board, 'In progress', 0);
      final card = await pa.repo.addCard(board, 'Book the van');
      await pa.sync.syncNow();
      expect(await pa.repo.pendingCount(), 0, reason: 'everything reached the hub');
      final numbered = await pa.repo.card(card);
      expect(numbered!.synced, isTrue);
      expect(numbered.number, greaterThan(0), reason: 'the hub gave the card its number');

      // B sees it at the next check.
      await pb.sync.syncNow();
      final seen = await pb.repo.card(card);
      expect(seen?.title, 'Book the van');
      expect(seen?.number, numbered.number);

      // B moves it while "offline" (no check in between); A renames it meanwhile.
      await pb.repo.moveCard(card, Lane.column(col));
      await pa.repo.editCard(card, title: 'Book the van for Raleigh');
      await pa.sync.syncNow();
      await pb.sync.syncNow();
      await pa.sync.syncNow();
      for (final p in [pa, pb]) {
        final c = await p.repo.card(card);
        expect(c?.title, 'Book the van for Raleigh', reason: 'phone ${p.label} has the new name');
        expect(c?.columnId, col, reason: 'phone ${p.label} has it in In progress');
      }

      // Phase 4: B adds a step, a tag, a comment mentioning A, and a photo; A sees all of it.
    final me0 = int.parse((await pa.repo.setting('me.id'))!);
    await pb.repo.addStep(card, 'Check the dock height');
    await pb.repo.setTag(card, 'venue', true);
    await pb.repo.addComment(card, 'Can @[A]($me0) confirm?');
    final photo = File('${Directory.systemTemp.path}/kolumn-practice-${DateTime.now().microsecondsSinceEpoch}.png')
      ..writeAsBytesSync(base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAFklEQVR4nGP8z8DAwMDAxMDAwMDAAAANHQEDK+mmyAAAAABJRU5ErkJggg=='));
    final fileId = await pb.repo.addFile(card, localPath: photo.path, filename: 'dock.png', mime: 'image/png', size: photo.lengthSync(), cover: true);
    await pb.sync.syncNow();
    expect(await pb.repo.pendingCount(), 0, reason: 'the photo went up');
    await pa.sync.syncNow();
    expect((await pa.repo.watchSteps(card).first).single.content, 'Check the dock height');
    expect((await pa.repo.watchTags().first).map((t) => t.tag), contains('venue'));
    expect((await pa.repo.watchComments(card).first).single.body, contains('@[A]('));
    expect((await pa.repo.card(card))!.coverId, fileId, reason: 'the photo became the cover');
    expect((await pa.repo.watchWatch(card).first)?.watching, isTrue, reason: 'A was mentioned, so A follows the card');
    final bytes = await pa.sync.hub.downloadFile(fileId);
    expect(bytes, photo.readAsBytesSync(), reason: 'A downloads exactly the photo B sent');
    final events = (await pa.repo.watchEvents(card).first).map((e) => e.action).toList();
    expect(events, containsAll(['card_published', 'card_moved', 'card_renamed', 'comment_created']));
    photo.deleteSync();

    // Phase 5: a due day, and a shared planner.
    await pa.repo.setCardDue(card, '2026-11-13');
    final planner = await pa.repo.createPlanner('Two-phone planner', boardIds: [board]);
    final meB = int.parse((await pb.repo.setting('me.id'))!);
    await pa.repo.setPlannerPeople(planner, {meB: 'edit'});
    final todo = await pa.repo.addTodo(planner, const TodoSlot.day('2026-11-11'), 'Plan the load-in');
    await pa.repo.updateTodo(todo, note: 'Truck at 2');
    await pa.repo.addTodoStep(todo, 'Print the stage plot');
    final warm = await pa.repo.addTodo(planner, const TodoSlot.day('2026-11-09'), 'Vocal warm-up');
    await pa.repo.updateTodo(warm, repeat: const RepeatRule());
    await pa.repo.addTodo(planner, const TodoSlot.someday(2), 'New merch designs');
    await pa.repo.setReminder(todo, 'todo', DateTime(2026, 11, 11, 9, 30).millisecondsSinceEpoch);
    final plot = File('${Directory.systemTemp.path}/kolumn-plot-${DateTime.now().microsecondsSinceEpoch}.png')
      ..writeAsBytesSync(base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAFklEQVR4nGP8z8DAwMDAxMDAwMDAAAANHQEDK+mmyAAAAABJRU5ErkJggg=='));
    final plotId = await pa.repo.addTodoFile(todo, localPath: plot.path, filename: 'plot.png', mime: 'image/png', size: plot.lengthSync());
    await pa.sync.syncNow();
    expect(await pa.repo.pendingCount(), 0, reason: 'the planner, its to-dos and the picture all went up');
    await pb.sync.syncNow();
    expect((await pb.repo.watchPlanners().first).map((p) => p.id), contains(planner), reason: 'B was added, so B gets the planner');
    final bTodos = await pb.repo.watchTodos(planner).first;
    expect(bTodos.map((t) => t.title).toSet(), {'Plan the load-in', 'Vocal warm-up', 'New merch designs'});
    expect(bTodos.firstWhere((t) => t.id == todo).note, 'Truck at 2');
    expect((await pb.repo.watchTodoSteps(todo).first).single.content, 'Print the stage plot');
    expect(await pb.sync.hub.downloadFile(plotId), plot.readAsBytesSync(), reason: 'B fetches exactly the picture A added to the to-do');
    expect((await pb.repo.card(card))!.dueAt, DateTime.utc(2026, 11, 13, 12).millisecondsSinceEpoch, reason: 'the due day reached B');
    expect((await pb.repo.watchReminders().first).where((r) => r.itemId == todo), isEmpty, reason: 'A\'s reminder is A\'s alone');
    plot.deleteSync();

    // B ticks the to-do and one day of the repeat; A sees both.
    await pb.repo.setTodoDone(bTodos.firstWhere((t) => t.id == todo), true);
    await pb.repo.setTodoDone(bTodos.firstWhere((t) => t.id == warm), true, day: '2026-11-10');
    await pb.sync.syncNow();
    await pa.sync.syncNow();
    expect((await pa.repo.todo(todo))!.doneAt, isNotNull);
    expect((await pa.repo.watchTodoMarks().first).where((m) => m.todoId == warm && m.day == '2026-11-10' && m.mark == 'done'), hasLength(1));

    // A takes B out: the planner leaves B's phone.
    await pa.repo.setPlannerPeople(planner, {});
    await pa.sync.syncNow();
    await pb.sync.syncNow();
    expect((await pb.repo.watchPlanners().first).map((p) => p.id), isNot(contains(planner)));
    expect(await pb.repo.todo(todo), isNull);
    await pa.repo.deletePlanner(planner);
    await pa.sync.syncNow();

    // Phase 6: alerts. A assigns B; B is told. B mentions A; A is told, and reads it.
    final meB6 = int.parse((await pb.repo.setting('me.id'))!);
    await pa.repo.setAssigned(card, meB6, true);
    await pa.sync.syncNow();
    await pb.sync.syncNow();
    final bAlert = (await pb.repo.watchNotifications().first).where((n) => n.cardId == card).single;
    expect(bAlert.action, 'card_assigned', reason: 'B hears about being assigned');
    expect(bAlert.readAt, isNull);
    await pb.repo.addComment(card, 'Done, @[A]($me0) — dock is 4 ft');
    await pb.sync.syncNow();
    await pa.sync.syncNow();
    final aAlert = (await pa.repo.watchNotifications().first).where((n) => n.cardId == card).single;
    expect(aAlert.action, 'mentioned', reason: 'A hears about the @mention');
    await pa.repo.setAlertRead(card, true);
    await pa.repo.saveView('Two-phone view', {'status': 'all'});
    await pa.sync.syncNow();
    final pa2 = Phone('A2');
    expect(await pa2.sync.signIn(ua, wa), isNull, reason: 'A signs in on a second phone');
    expect((await pa2.repo.watchNotifications().first).where((n) => n.cardId == card).single.readAt, isNotNull, reason: 'read on one phone, read on the other');
    expect((await pa2.repo.watchViews().first).map((v) => v.name), contains('Two-phone view'), reason: 'saved views follow the person');
    await pa2.sync.signOut();
    await pa2.db.close();

    // A makes the board private to themselves: it leaves B's phone.
      final meA = int.parse((await pa.repo.setting('me.id'))!);
      await pa.repo.setBoardAccess(board, allAccess: false, members: [meA]);
      await pa.sync.syncNow();
      await pb.sync.syncNow();
      expect(await pb.repo.card(card), isNull, reason: 'B can no longer see the private board');

      // Tidy up: A deletes the board; both sign out.
      await pa.repo.deleteBoard(board);
      await pa.sync.syncNow();
      expect(await pa.repo.pendingCount(), 0);
      await pa.sync.signOut();
      await pb.sync.signOut();
      await pa.db.close();
      await pb.db.close();
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
