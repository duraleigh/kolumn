import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('the phone build may use the internet (it must, to reach the hub)', () {
    expect(manifest, contains('android.permission.INTERNET'));
  });

  test('reminders can show, on time, and survive a restart', () {
    for (final p in ['POST_NOTIFICATIONS', 'RECEIVE_BOOT_COMPLETED', 'USE_EXACT_ALARM']) {
      expect(manifest, contains('android.permission.$p'));
    }
    expect(manifest, contains('ScheduledNotificationReceiver'));
    expect(manifest, contains('ScheduledNotificationBootReceiver'));
    expect(File('android/app/src/main/res/drawable/ic_stat_kolumn.xml').existsSync(), isTrue);
  });
}
