import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  final testToken = Platform.environment['TEST_TOKEN'];

  test(
    'NyxxRest.connect',
    skip: testToken != null ? false : 'No test token provided',
    () async {
      expect(Nyxx.connectRest(testToken!), completes);
    },
  );

  group(
    'NyxxRest',
    skip: testToken != null ? false : 'No test token provided',
    () {
      late final NyxxRest client;

      setUp(() async {
        client = await Nyxx.connectRest(testToken!);
      });

      group('users', () {
        test('fetchCurrentUser', () => expect(client.users.fetchCurrentUser(), completes));
        test('fetchCurrentUserConnections', () => expect(client.users.fetchCurrentUserConnections(), completes));
      });
    },
  );
}
