// Two phones against the PRACTICE site (stage5230ca), never the live site.
// Skipped unless run on purpose with stand-in logins:
//   KOLUMN_PRACTICE_A=user:pass KOLUMN_PRACTICE_B=user:pass flutter test test/practice_sync_test.dart
@Tags(['practice'])
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/sync/hub_client.dart';
import 'package:kolumn/sync/sync_service.dart';

const practice = 'https://stage5230ca.clayaiken.com';

class Phone {
  Phone(String name)
      : db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true)),
        label = name;
  final String label;
  final KolumnDb db;
  late final repo = KolumnRepository(db);
  late final sync = SyncService(repo: repo, hub: HubClient(credentials: MemoryCredentialStore(), server: practice));
}

void main() {
  final a = Platform.environment['KOLUMN_PRACTICE_A'];
  final b = Platform.environment['KOLUMN_PRACTICE_B'];
  final skip = (a == null || b == null) ? 'needs KOLUMN_PRACTICE_A and KOLUMN_PRACTICE_B' : null;

  test('two phones share a board through the practice hub', () async {
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
  }, skip: skip, timeout: const Timeout(Duration(minutes: 3)));
}
