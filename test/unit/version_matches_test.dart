import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  test('package version matches ApiOptions.nyxxVersion', () {
    final pubspecFile = File('pubspec.yaml');

    expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml should exist');

    final versionFromPubspec = RegExp(r'version: (.+)\n').firstMatch(pubspecFile.readAsStringSync())?.group(1);

    expect(versionFromPubspec, isNotNull, reason: 'version should be parsed from pubspec');

    expect(versionFromPubspec, equals(ApiOptions.nyxxVersion));
  });
}
