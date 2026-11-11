import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the phone build may use the internet (it must, to reach the hub)', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android.permission.INTERNET'));
  });
}
