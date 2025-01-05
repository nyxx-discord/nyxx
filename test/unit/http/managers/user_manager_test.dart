import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_manager.dart';
import 'channel_manager_test.dart';
import 'member_manager_test.dart';

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
    "avatar_decoration_data": {
    "sku_id": "1144058844004233369",
    "asset": "a_fed43ab12698df65902ba06727e20c0e"
  },
  "clan": {
    "identity_guild_id": "80351110224678912",
    "identity_enabled": true,
    "tag": "CUTE",
    "badge": "0fcf9a436df1a4b0de5644d3d42188e2"
  }
};

void checkSampleUser(User user) {
  expect(user.id, equals(Snowflake(80351110224678912)));
  expect(user.username, equals('Nelly'));
  expect(user.discriminator, equals('1337'));
  expect(user.globalName, isNull);
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
  expect(user.avatarDecorationHash, equals('a_fed43ab12698df65902ba06727e20c0e'));
  expect(user.avatarDecorationData!.skuId, equals(Snowflake(1144058844004233369)));
  expect(user.clan!.identityGuildId, equals(Snowflake(80351110224678912)));
  expect(user.clan!.isIdentityEnabled, isTrue);
  expect(user.clan!.tag, equals('CUTE'));
  expect(user.clan!.badgeHash, equals('0fcf9a436df1a4b0de5644d3d42188e2'));
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

final sampleApplicationRoleConnection = {
  'platform_name': 'test',
  'platform_username': 'user',
  'metadata': {},
};

void checkApplicationRoleConnection(ApplicationRoleConnection connection) {
  expect(connection.platformName, equals('test'));
  expect(connection.platformUsername, equals('user'));
  expect(connection.metadata, equals({}));
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
      EndpointTest<UserManager, List<UserGuild>, List<Object?>>(
        name: 'listCurrentUserGuilds',
        source: [
          {
            'id': '1',
            'name': 'nyxx',
            'icon': null,
            'owner': false,
            'permissions': '533130099674816',
            'features': ['COMMUNITY', 'INVITE_SPLASH', 'DISCOVERABLE', 'WELCOME_SCREEN_ENABLED', 'VERIFIED', 'VANITY_URL', 'NEWS']
          }
        ],
        urlMatcher: '/users/@me/guilds',
        execute: (manager) => manager.listCurrentUserGuilds(),
        check: (list) {
          expect(list, hasLength(1));
          final guild = list.single;
          expect(guild.id, equals(Snowflake(1)));
          expect(guild.name, 'nyxx');
          expect(guild.icon, isNull);
          expect(guild.isOwnedByCurrentUser, isFalse);
          expect(guild.currentUserPermissions, isNotNull);
          final features = guild.features;
          expect(features.hasCommunity, isTrue);
          expect(features.hasInviteSplash, isTrue);
          expect(features.isDiscoverable, isTrue);
          expect(features.hasWelcomeScreenEnabled, isTrue);
          expect(features.isVerified, isTrue);
          expect(features.hasVanityUrl, isTrue);
          expect(features.hasNews, isTrue);
        },
      ),
      EndpointTest<UserManager, Member, Map<String, Object?>>(
        name: 'fetchCurrentUserMember',
        source: sampleMemberNoUser,
        urlMatcher: '/users/@me/guilds/0/member',
        execute: (manager) => manager.fetchCurrentUserMember(Snowflake.zero),
        check: (member) {
          final client = MockNyxx();
          when(() => client.options).thenReturn(RestClientOptions());

          checkMemberNoUser(member, expectedUserId: client.user.id);
        },
      ),
      EndpointTest<UserManager, void, void>(
        name: 'leaveGuild',
        method: 'DELETE',
        source: null,
        urlMatcher: '/users/@me/guilds/0',
        execute: (manager) => manager.leaveGuild(Snowflake.zero),
        check: (_) {},
      ),
      EndpointTest<UserManager, DmChannel, Map<String, Object?>>(
        name: 'createDm',
        source: sampleDm,
        method: 'POST',
        urlMatcher: '/users/@me/channels',
        execute: (manager) => manager.createDm(Snowflake.zero),
        check: checkDm,
      ),
      EndpointTest<UserManager, GroupDmChannel, Map<String, Object?>>(
        name: 'createGroupDm',
        source: sampleGroupDm,
        method: 'POST',
        urlMatcher: '/users/@me/channels',
        execute: (manager) => manager.createGroupDm([], {}),
        check: checkGroupDm,
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
      EndpointTest<UserManager, ApplicationRoleConnection, Map<String, Object?>>(
        name: 'fetchCurrentUserApplicationRoleConnection',
        source: sampleApplicationRoleConnection,
        urlMatcher: '/users/@me/applications/0/role-connection',
        execute: (manager) => manager.fetchCurrentUserApplicationRoleConnection(Snowflake.zero),
        check: checkApplicationRoleConnection,
      ),
      EndpointTest<UserManager, ApplicationRoleConnection, Map<String, Object?>>(
        name: 'updateCurrentUserApplicationRoleConnection',
        method: 'PUT',
        source: sampleApplicationRoleConnection,
        urlMatcher: '/users/@me/applications/0/role-connection',
        execute: (manager) => manager.updateCurrentUserApplicationRoleConnection(Snowflake.zero, ApplicationRoleConnectionUpdateBuilder()),
        check: checkApplicationRoleConnection,
      ),
    ],
  );
}
