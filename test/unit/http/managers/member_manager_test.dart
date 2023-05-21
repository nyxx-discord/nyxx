import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';
import 'user_manager_test.dart';

final sampleMember = {
  "user": sampleUser, // TODO: Not in the provided sample - can we be sure this is always a valid user?
  "nick": "NOT API SUPPORT",
  "avatar": null,
  "roles": [],
  "joined_at": "2015-04-26T06:26:56.936000+00:00",
  "deaf": false,
  "mute": false,

  // These fields are documented as always present but are not in the provided sample
  "flags": 0,
};

void checkMember(Member member) {
  expect(member.id, equals(Snowflake(80351110224678912)));
  expect(member.user, isNotNull);
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
    additionalEndpointTests: [],
    createBuilder: MemberBuilder(accessToken: 'TEST_ACCESS_TOKEN', userId: Snowflake.zero),
    updateBuilder: MemberUpdateBuilder(),
  );
}
