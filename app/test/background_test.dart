import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/sync/background.dart';

void main() {
  test('a check while Kolumn is still running asks it to check, rather than opening a second copy', () async {
    final port = ReceivePort();
    IsolateNameServer.removePortNameMapping('kolumn_main');
    IsolateNameServer.registerPortWithName(port.sendPort, 'kolumn_main');
    final got = Completer<Object?>();
    port.listen(got.complete);
    await backgroundCheck();
    expect(await got.future.timeout(const Duration(seconds: 2)), 'check');
    IsolateNameServer.removePortNameMapping('kolumn_main');
    port.close();
  });
}
