import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleRole = {
  // Changed to 1 so tests find the role with ID 1
  "id": "1",
  "name": "WE DEM BOYZZ!!!!!!",
  "color": 3447003,
  "colors": {"primary_color": 3447003, "secondary_color": null, "tertiary_color": null},
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
  // ignore: deprecated_member_use_from_same_package
  expect(role.color, equals(DiscordColor(3447003)));
  expect(role.isHoisted, isTrue);
  expect(role.iconHash, equals('cf3ced8600b777c9486c6d8d84fb4327'));
  expect(role.unicodeEmoji, isNull);
  expect(role.position, equals(1));
  expect(role.permissions, equals(Permissions(66321471)));
  expect(role.isMentionable, isFalse);
  expect(role.tags, isNull);
  expect(role.colors.primary, equals(DiscordColor(3447003)));
}

final sampleRoleCounts = {"613425648685547541": 1337, "1409696176629878905": 2, "697138785317814292": 67};

void checkRoleCounts(Map<PartialRole, int> counts) {
  expect(counts.length, equals(sampleRoleCounts.length));
  for (final MapEntry(:key, :value) in counts.entries) {
    expect(value, equals(sampleRoleCounts[key.id.toString()]));
  }
}

void main() {
  testManager<Role, RoleManager>(
    'RoleManager',
    (config, client) => RoleManager(config, client, guildId: Snowflake.zero),
    RegExp(r'/guilds/0/roles(/\d+)?'),
    '/guilds/0/roles',
    sampleObject: sampleRole,
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
      EndpointTest<RoleManager, Map<PartialRole, int>, Map<String, Object?>>(
        name: 'fetchRoleCounts',
        source: sampleRoleCounts,
        urlMatcher: '/guilds/0/roles/member-counts',
        execute: (manager) => manager.fetchMemberCounts(),
        check: checkRoleCounts,
      ),
    ],
    createBuilder: RoleBuilder(),
    updateBuilder: RoleUpdateBuilder(),
  );
}
