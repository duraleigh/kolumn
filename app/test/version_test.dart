import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/version.dart';

void main() {
  test('the version in Settings matches the app\'s real version', () {
    final line = File('pubspec.yaml').readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    final real = line.split(':')[1].trim().split('+').first;
    expect(kolumnVersion, real, reason: 'Settings said "Kolumn 0.7" long after 0.8 (found 2026-11-13)');
  });
}
