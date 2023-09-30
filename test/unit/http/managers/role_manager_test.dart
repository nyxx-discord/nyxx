import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleRole = {
  // Changed to 1 so tests find the role with ID 1
  "id": "1",
  "name": "WE DEM BOYZZ!!!!!!",
  "color": 3447003,
  "hoist": true,
  "icon": "cf3ced8600b777c9486c6d8d84fb4327",
  "unicode_emoji": null,
  "position": 1,
  "permissions": "66321471",
  "managed": false,
  "mentionable": false,
  "flags": 0,
};

void checkRole(Role role) {
  expect(role.id, equals(Snowflake(1)));
  expect(role.name, equals('WE DEM BOYZZ!!!!!!'));
  expect(role.color, equals(DiscordColor(3447003)));
  expect(role.isHoisted, isTrue);
  expect(role.iconHash, equals('cf3ced8600b777c9486c6d8d84fb4327'));
  expect(role.unicodeEmoji, isNull);
  expect(role.position, equals(1));
  expect(role.permissions, equals(Permissions(66321471)));
  expect(role.isMentionable, isFalse);
  expect(role.tags, isNull);
}

void main() {
  testManager<Role, RoleManager>(
    'RoleManager',
    (config, client) => RoleManager(config, client, guildId: Snowflake.zero),
    RegExp(r'/guilds/0/roles(/\d+)?'),
    '/guilds/0/roles',
    sampleObject: sampleRole,
    // Fetch implementation internally uses `list()`, so we return a list
    fetchObjectOverride: [sampleRole],
    sampleMatches: checkRole,
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<RoleManager, List<Role>, List<Object?>>(
        name: 'list',
        source: [sampleRole],
        urlMatcher: '/guilds/0/roles',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));

          checkRole(list.first);
        },
      ),
      EndpointTest<RoleManager, List<Role>, List<Object?>>(
        name: 'updatePositions',
        method: 'PATCH',
        source: [sampleRole],
        urlMatcher: '/guilds/0/roles',
        execute: (manager) => manager.updatePositions({}),
        check: (list) {
          expect(list, hasLength(1));

          checkRole(list.first);
        },
      ),
    ],
    createBuilder: RoleBuilder(),
    updateBuilder: RoleUpdateBuilder(),
  );
}
