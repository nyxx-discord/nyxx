import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleUser = {
  "id": "80351110224678912",
  "username": "Nelly",
  "discriminator": "1337",
  "avatar": "8342729096ea3675442027381ff50dfe",
  "verified": true,
  "email": "nelly@discord.com",
  "flags": 64,
  "banner": "06c16474723fe537c283b8efa61a30c8",
  "accent_color": 16711680,
  "premium_type": 1,
  "public_flags": 64,
};

void checkSampleUser(User user) {
  expect(user.id, equals(Snowflake(80351110224678912)));
  expect(user.username, equals('Nelly'));
  expect(user.discriminator, equals('1337'));
  expect(user.avatarHash, equals('8342729096ea3675442027381ff50dfe'));
  expect(user.isBot, isFalse);
  expect(user.isSystem, isFalse);
  expect(user.hasMfaEnabled, isFalse);
  expect(user.bannerHash, equals('06c16474723fe537c283b8efa61a30c8'));
  expect(user.accentColor, equals(DiscordColor(16711680)));
  expect(user.locale, isNull);
  expect(user.flags, equals(UserFlags(64)));
  expect(user.nitroType, equals(NitroType.classic));
  expect(user.publicFlags, equals(UserFlags(64)));
}

final sampleConnection = {
  'id': '1234567890abcdef',
  'name': 'MyUsername',
  'type': 'battlenet',
  'verified': false,
  'friend_sync': true,
  'show_activity': true,
  'two_way_link': false,
  'visibility': 0,
};

void checkSampleConnection(connection) {
  expect(connection.id, equals('1234567890abcdef'));
  expect(connection.name, equals('MyUsername'));
  expect(connection.type, equals(ConnectionType.battleNet));
  expect(connection.isRevoked, isNull);
  expect(connection.isVerified, isFalse);
  expect(connection.isFriendSyncEnabled, isTrue);
  expect(connection.showActivity, isTrue);
  expect(connection.isTwoWayLink, isFalse);
  expect(connection.visibility, ConnectionVisibility.none);
}

void main() {
  testReadOnlyManager<User, UserManager>(
    'UserManager',
    UserManager.new,
    RegExp(r'/users/\d+'),
    sampleObject: sampleUser,
    sampleMatches: checkSampleUser,
    additionalParsingTests: [
      ParsingTest<UserManager, Connection, Map<String, Object?>>(
        name: 'parseConnection',
        source: sampleConnection,
        parse: (manager) => manager.parseConnection,
        check: checkSampleConnection,
      ),
    ],
    additionalEndpointTests: [
      EndpointTest<UserManager, User, Map<String, Object?>>(
        name: 'fetchCurrentUser',
        source: sampleUser,
        urlMatcher: '/users/@me',
        execute: (manager) => manager.fetchCurrentUser(),
        check: checkSampleUser,
      ),
      EndpointTest<UserManager, User, Map<String, Object?>>(
        name: 'updateCurrentUser',
        source: sampleUser,
        urlMatcher: '/users/@me',
        method: 'patch',
        execute: (manager) => manager.updateCurrentUser(UserUpdateBuilder()),
        check: checkSampleUser,
      ),
      EndpointTest<UserManager, List<Connection>, List<Map<String, Object?>>>(
        name: 'fetchCurrentUserConnections',
        source: [sampleConnection],
        urlMatcher: '/users/@me/connections',
        execute: (manager) => manager.fetchCurrentUserConnections(),
        check: (connections) {
          expect(connections, hasLength(1));
          checkSampleConnection(connections.single);
        },
      ),
    ],
  );
}
