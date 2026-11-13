import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/activity/activity_model.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/find/card_filter.dart';

void main() {
  late KolumnDb db;
  late KolumnRepository repo;
  var now = 0;

  setUp(() async {
    now = DateTime(2026, 11, 11, 10).millisecondsSinceEpoch;
    db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = KolumnRepository(db, clock: () => now += 10);
    await repo.setSetting('me.id', '7');
  });
  tearDown(() => db.close());

  Future<List<Map<String, dynamic>>> sent(String name) async => [
    for (final e in await repo.pendingOutbox())
      if (e.name == name) jsonDecode(e.args) as Map<String, dynamic>,
  ];

  KEvent ev(int id, String card, String action, DateTime at, {Map<String, Object?> p = const {}, int user = 8}) =>
      KEvent(id: id, cardId: card, userId: user, action: action, particulars: jsonEncode(p), createdAt: at.millisecondsSinceEpoch);

  group('Activity', () {
    test('a day\'s history in three groups, newest first; other days, deleted cards and drafts left out', () async {
      final b = await repo.createBoard('Tour');
      final c1 = await repo.addCard(b, 'Finalize setlist');
      final c2 = await repo.addCard(b, 'Gone');
      final c3 = await repo.addCard(b, 'Secret', draft: true);
      await repo.deleteCard(c2);
      final cards = {for (final c in await repo.watchAllCards().first) c.id: c};
      final gone = (await repo.card(c2))!;
      cards[c2] = gone;
      final events = [
        ev(1, c1, 'card_published', DateTime(2026, 11, 11, 9)),
        ev(2, c1, 'comment_created', DateTime(2026, 11, 11, 10)),
        ev(3, c1, 'card_moved', DateTime(2026, 11, 11, 11), p: {'to': 'done'}),
        ev(4, c1, 'card_moved', DateTime(2026, 11, 11, 12), p: {'to': 'col:x', 'column': 'In progress'}),
        ev(5, c1, 'card_priority', DateTime(2026, 11, 10, 9)),
        ev(6, c2, 'card_published', DateTime(2026, 11, 11, 9)),
        ev(7, c3, 'card_published', DateTime(2026, 11, 11, 9)),
      ];
      final day = activityOn('2026-11-11', events, cards);
      expect(day.of(ActivityGroup.added).map((e) => e.id), [1]);
      expect(day.of(ActivityGroup.updated).map((e) => e.id), [4, 2]);
      expect(day.of(ActivityGroup.done).map((e) => e.id), [3]);
      expect(previousActiveDay('2026-11-11', events, cards), '2026-11-10');
      expect(previousActiveDay('2026-11-10', events, cards), isNull);
      expect(activityOn('2026-11-11', events, cards, boards: {'other'}).events, isEmpty);
    });

    test('plain words that name the card and the people', () {
      expect(activityLine('card_moved', {'to': 'col:x', 'column': 'In progress'}, who: 'Riley', title: 'Merch list', me: 7), 'Riley moved Merch list to In progress');
      expect(activityLine('card_moved', {'to': 'done'}, who: 'You', title: 'Merch list', me: 7), 'You moved Merch list to Done');
      expect(activityLine('card_assigned', {'userId': 7, 'name': 'Clay'}, who: 'Jamie', title: 'Plot', me: 7), 'Jamie assigned you to Plot');
      expect(activityLine('card_assigned', {'userId': 9, 'name': 'Riley'}, who: 'Jamie', title: 'Plot', me: 7), 'Jamie assigned Riley to Plot');
      expect(activityLine('card_due_set', {'day': '2026-11-13'}, who: 'Jamie', title: 'Plot', me: 7), 'Jamie set Plot due Fri, 13 Nov');
      expect(activityLine('card_auto_later', {'days': 30}, who: '', title: 'Old idea', me: 7), 'Old idea moved to Later on its own after 30 days untouched');
      final n = KNotification(cardId: 'c', boardId: 'b', kind: 'card', creatorId: 8, action: 'mentioned', particulars: '{}', unreadCount: 1, updatedAt: 1);
      expect(alertLine(n, who: 'Riley', title: 'Finalize setlist', me: 7), 'Riley mentioned you on Finalize setlist');
    });
  });

  group('alerts on the phone', () {
    Map<String, dynamic> pull(List<Map<String, Object?>> alerts, {List<String> boards = const ['b1'], int cursor = 5}) => {
      'cursor': cursor,
      'boardIds': boards,
      'notifications': alerts,
      'boardWatches': [
        {'boardId': 'b1', 'watching': false},
      ],
      'views': [
        {'id': 'v1', 'name': 'Mine', 'params': {'status': 'priority'}, 'createdAt': 1},
      ],
    };
    Map<String, Object?> alert(String card, {String board = 'b1', int? readAt, int unread = 1}) => {
      'cardId': card,
      'boardId': board,
      'creatorId': 8,
      'action': 'comment_created',
      'particulars': {'comment': 'x'},
      'unreadCount': unread,
      'readAt': readAt,
      'updatedAt': 100,
    };

    test('taking in alerts, Kolumn follows and saved views', () async {
      await repo.applyPull(pull([alert('c1'), alert('c2', readAt: 50, unread: 0)]));
      final list = await repo.watchNotifications().first;
      expect(list.map((n) => n.cardId).toSet(), {'c1', 'c2'});
      expect(list.where((n) => n.readAt == null).single.cardId, 'c1');
      expect((await repo.watchBoardWatches().first).single.watching, isFalse);
      expect((await repo.watchViews().first).single.name, 'Mine');
    });

    test('alerts about a Kolumn that is no longer visible leave the phone', () async {
      await repo.applyPull(pull([alert('c1'), alert('c9', board: 'b2')], boards: ['b1', 'b2']));
      await repo.applyPull(pull([], boards: ['b1']));
      expect((await repo.watchNotifications().first).map((n) => n.cardId), ['c1']);
    });

    test('marking read, unread and all read goes to the hub', () async {
      await repo.applyPull(pull([alert('c1'), alert('c2')]));
      await repo.setAlertRead('c1', true);
      expect((await repo.watchNotifications().first).firstWhere((n) => n.cardId == 'c1').readAt, isNotNull);
      await repo.setAlertRead('c1', false);
      await repo.readAllAlerts();
      expect((await repo.watchNotifications().first).where((n) => n.readAt == null), isEmpty);
      expect((await sent('notification.read')).single['id'], 'c1');
      expect(await sent('notification.unread'), hasLength(1));
      expect(await sent('notification.readall'), hasLength(1));
    });

    test('a read waiting to be sent is not undone by the hub', () async {
      await repo.applyPull(pull([alert('c1')]));
      await repo.setAlertRead('c1', true);
      await repo.applyPull(pull([alert('c1')], cursor: 6));
      expect((await repo.watchNotifications().first).single.readAt, isNotNull);
    });

    test('following a Kolumn, and saving, renaming and deleting a view', () async {
      await repo.setBoardFollow('b1', true);
      expect((await sent('board.watch')).single, {'id': 'b1', 'on': true});
      final v = await repo.saveView('Priority', const CardFilter(status: 'priority').toJson());
      await repo.saveView('Priority, mine', const CardFilter(status: 'priority', assignees: {'me'}).toJson(), id: v);
      expect((await repo.watchViews().first).single.name, 'Priority, mine');
      await repo.deleteView(v);
      expect(await repo.watchViews().first, isEmpty);
      expect((await sent('view.save')).last['params'], {
        'status': 'priority',
        'assignees': ['me'],
        'sort': 'latest',
      });
    });
  });

  group('finding cards', () {
    late String tour, studio;
    late Map<String, KBoard> boards;
    Future<List<String>> find(CardFilter f, {Map<String, CardText> text = const {}, DateTime? at}) async => applyFilter(
      f,
      cards: await repo.watchAllCards().first,
      text: text,
      boards: boards,
      me: 7,
      now: at ?? DateTime(2026, 11, 11, 12),
    ).map((x) => x.card.title).toList();

    setUp(() async {
      tour = await repo.createBoard('Tour');
      studio = await repo.createBoard('Studio');
      boards = {for (final b in await repo.watchBoards().first) b.id: b};
    });

    test('words in the title, notes, a comment, a checklist, a tag, or the card number', () async {
      final a = await repo.addCard(tour, 'Book the van');
      final b = await repo.addCard(tour, 'Load-in');
      await repo.editCard(b, description: 'Ask the venue for the van dock');
      final c = await repo.addCard(studio, 'Mix notes');
      final d = await repo.addCard(studio, 'Merch');
      final e = await repo.addCard(studio, 'Hotel');
      final text = {
        c: CardText(comments: ['Can @[Clay](7) bring the van keys?']),
        d: CardText(steps: ['Count the VAN stock']),
        e: CardText(tags: ['vanlife']),
      };
      // Title first, then a tag, then notes and checklists (latest first), then comments.
      expect(await find(const CardFilter(terms: 'van'), text: text), ['Book the van', 'Hotel', 'Merch', 'Load-in', 'Mix notes']);
      final found = applyFilter(const CardFilter(terms: 'van'), cards: await repo.watchAllCards().first, text: text, boards: boards, me: 7, now: DateTime(2026, 11, 11));
      expect(found.first.card.id, a, reason: 'a title match comes first');
      expect(found.firstWhere((x) => x.card.id == c).snippet, contains('@Clay bring the van'), reason: 'mentions read as names');
      expect(found.firstWhere((x) => x.card.id == b).where, 'notes');
      expect(await find(const CardFilter(terms: 'nothing like this'), text: text), isEmpty);
    });

    test('where the card is: open, Priority, Later, Done, everything', () async {
      await repo.addCard(tour, 'Open one');
      final p = await repo.addCard(tour, 'Priority one', priority: true);
      final l = await repo.addCard(tour, 'Later one', lane: const Lane.later());
      final d = await repo.addCard(tour, 'Done one', lane: const Lane.done());
      expect(p.isNotEmpty && l.isNotEmpty && d.isNotEmpty, isTrue);
      expect((await find(const CardFilter())).toSet(), {'Open one', 'Priority one'});
      expect(await find(const CardFilter(status: 'priority')), ['Priority one']);
      expect(await find(const CardFilter(status: 'later')), ['Later one']);
      expect(await find(const CardFilter(status: 'done')), ['Done one']);
      expect(await find(const CardFilter(status: 'all')), hasLength(4));
    });

    test('Kolumns, people, who added it, tags; drafts are only their maker\'s', () async {
      final a = await repo.addCard(tour, 'Tour card');
      await repo.addCard(studio, 'Studio card');
      await repo.addCard(tour, 'My draft', draft: true);
      await (db.update(db.kCards)..where((c) => c.id.equals(a))).write(const KCardsCompanion(creatorId: Value(9)));
      final text = {a: CardText(assignees: [7], tags: ['venue'])};
      expect(await find(CardFilter(boards: {studio})), ['Studio card']);
      expect(await find(const CardFilter(assignees: {'me'}), text: text), ['Tour card']);
      expect((await find(const CardFilter(assignees: {'none'}), text: text)).toSet(), {'Studio card', 'My draft'});
      expect(await find(const CardFilter(creators: {9})), ['Tour card']);
      expect(await find(const CardFilter(tags: {'venue'}), text: text), ['Tour card']);
      final others = applyFilter(const CardFilter(), cards: await repo.watchAllCards().first, text: const {}, boards: boards, me: 99, now: DateTime(2026, 11, 11));
      expect(others.map((x) => x.card.title), isNot(contains('My draft')));
    });

    test('added in a time window, and the order', () async {
      final old = await repo.addCard(tour, 'Last month');
      await (db.update(db.kCards)..where((c) => c.id.equals(old))).write(KCardsCompanion(createdAt: Value(DateTime(2026, 10, 20).millisecondsSinceEpoch)));
      await repo.addCard(tour, 'Today');
      expect(await find(const CardFilter(added: 'today'), at: DateTime(2026, 11, 11, 12)), ['Today']);
      expect(await find(const CardFilter(added: 'lastmonth'), at: DateTime(2026, 11, 11, 12)), ['Last month']);
      expect(await find(const CardFilter(sort: 'oldest')), ['Last month', 'Today']);
      expect(await find(const CardFilter(sort: 'newest')), ['Today', 'Last month']);
    });

    test('a filter goes into a saved view and comes back the same', () {
      const f = CardFilter(terms: 'van', boards: {'b2', 'b1'}, status: 'done', assignees: {'me'}, creators: {9}, tags: {'venue'}, added: 'thisweek', done: 'today', sort: 'oldest');
      final back = CardFilter.fromJson(jsonDecode(jsonEncode(f.toJson())) as Map<String, dynamic>);
      expect(back.toJson(), f.toJson());
      expect(const CardFilter().isPlain, isTrue);
      expect(f.isPlain, isFalse);
      final w = CardFilter.window('lastweek', DateTime(2026, 11, 11, 12))!;
      expect([w.$1, w.$2], [DateTime(2026, 11, 2), DateTime(2026, 11, 9)]);
    });
  });
}
