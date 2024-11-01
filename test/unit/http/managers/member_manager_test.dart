import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';
import 'user_manager_test.dart';

final sampleMemberNoUser = {
  "user": null,
  "nick": "NOT API SUPPORT",
  "avatar": null,
  "roles": [],
  "joined_at": "2015-04-26T06:26:56.936000+00:00",
  "deaf": false,
  "mute": false,
  "banner": "a_coolHashDude",

  // These fields are documented as always present but are not in the provided sample
  "flags": 0,
};

final sampleMember = {
  ...sampleMemberNoUser,
  "user": sampleUser,
};

void checkMemberNoUser(Member member, {Snowflake expectedUserId = const Snowflake(80351110224678912)}) {
  expect(member.id, equals(expectedUserId));
  expect(member.nick, equals('NOT API SUPPORT'));
  expect(member.avatarHash, isNull);
  expect(member.roleIds, equals([]));
  expect(member.joinedAt, equals(DateTime.utc(2015, 04, 26, 06, 26, 56, 936)));
  expect(member.premiumSince, isNull);
  expect(member.isDeaf, isFalse);
  expect(member.isMute, isFalse);
  expect(member.flags, equals(MemberFlags(0)));
  expect(member.isPending, isFalse);
  expect(member.permissions, isNull);
  expect(member.communicationDisabledUntil, isNull);
  expect(member.bannerHash, equals('a_coolHashDude'));
}

void checkMember(Member member, {Snowflake expectedUserId = const Snowflake(80351110224678912)}) {
  checkMemberNoUser(member, expectedUserId: expectedUserId);

  expect(member.user, isNotNull);
  checkSampleUser(member.user!);
}

void main() {
  testManager<Member, MemberManager>(
    'MemberManager',
    (client, config) => MemberManager(client, config, guildId: Snowflake.zero),
    RegExp(r'/guilds/0/members/\d+'),
    RegExp(r'/guilds/0/members/\d+'),
    createMethod: 'PUT',
    sampleObject: sampleMember,
    sampleMatches: checkMember,
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<MemberManager, List<Member>, List<Object?>>(
        name: 'listMembers',
        source: [sampleMember],
        urlMatcher: '/guilds/0/members',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));

          checkMember(list.first);
        },
      ),
      EndpointTest<MemberManager, List<Member>, List<Object?>>(
        name: 'searchMembers',
        source: [sampleMember],
        urlMatcher: '/guilds/0/members/search?query=test',
        execute: (manager) => manager.search('test'),
        check: (list) {
          expect(list, hasLength(1));

          checkMember(list.first);
        },
      ),
      EndpointTest<MemberManager, Member, Map<String, Object?>>(
        name: 'updateCurrentMember',
        method: 'PATCH',
        source: sampleMember,
        urlMatcher: '/guilds/0/members/@me',
        execute: (manager) => manager.updateCurrentMember(CurrentMemberUpdateBuilder()),
        check: checkMember,
      ),
      EndpointTest<MemberManager, void, void>(
        name: 'addRole',
        method: 'PUT',
        source: null,
        urlMatcher: '/guilds/0/members/0/roles/0',
        execute: (manager) => manager.addRole(Snowflake.zero, Snowflake.zero),
        check: (_) {},
      ),
      EndpointTest<MemberManager, void, void>(
        name: 'addRole',
        method: 'DELETE',
        source: null,
        urlMatcher: '/guilds/0/members/0/roles/0',
        execute: (manager) => manager.removeRole(Snowflake.zero, Snowflake.zero),
        check: (_) {},
      ),
    ],
    createBuilder: MemberBuilder(accessToken: 'TEST_ACCESS_TOKEN', userId: Snowflake.zero),
    updateBuilder: MemberUpdateBuilder(),
  );
}
