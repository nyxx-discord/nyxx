import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_endpoint.dart';
import '../../../test_manager.dart';

final sampleInvite = {
  "type": 0,
  "code": "0vCdhLbwjZZTWZLD",
  "guild": {
    "id": "165176875973476352",
    "name": "CS:GO Fraggers Only",
    "splash": null,
    "banner": null,
    "description": "Very good description",
    "icon": null,
    "features": ["NEWS", "DISCOVERABLE"],
    "verification_level": 2,
    "vanity_url_code": null,
    "nsfw_level": 0,
    "premium_subscription_count": 5
  },
  "channel": {"id": "165176875973476352", "name": "illuminati", "type": 0},
  "inviter": {"id": "115590097100865541", "username": "speed", "avatar": "deadbeef", "discriminator": "7653", "public_flags": 131328},
  "target_type": 1,
  "target_user": {"id": "165176875973476352", "username": "bob", "avatar": "deadbeef", "discriminator": "1234", "public_flags": 64},
  "roles": [
    {"id": "165176875973476352"}
  ],
};

void checkInvite(Invite invite) {
  expect(invite.type, equals(InviteType.guild));
  expect(invite.code, equals('0vCdhLbwjZZTWZLD'));
  expect(invite.guild?.id, equals(Snowflake(165176875973476352)));
  expect(invite.channel.id, equals(Snowflake(165176875973476352)));
  expect(invite.inviter?.id, equals(Snowflake(115590097100865541)));
  expect(invite.targetType, equals(TargetType.stream));
  expect(invite.expiresAt, isNull);
  expect(invite.roles, hasLength(1));
  expect(invite.roles![0].id, equals(Snowflake(165176875973476352)));
}

final sampleInviteWithMetadata = {
  ...sampleInvite,
  "uses": 0,
  "max_uses": 0,
  "max_age": 0,
  "temporary": false,
  "created_at": "2016-03-31T19:15:39.954000+00:00",
};

void checkInviteWithMetadata(InviteWithMetadata invite) {
  checkInvite(invite);

  expect(invite.uses, equals(0));
  expect(invite.maxUses, equals(0));
  expect(invite.maxAge, equals(Duration.zero));
  expect(invite.isTemporary, isFalse);
  expect(invite.createdAt, equals(DateTime.utc(2016, 3, 31, 19, 15, 39, 954)));
}

final sampleJobStatus = {
  "status": 3,
  "total_users": 100,
  "processed_users": 41,
  "created_at": "2025-01-08T12:00:00.000000+00:00",
  "completed_at": null,
  "error_message": "Failed to parse CSV file"
};

void checkJobStatus(InviteTargetsJobStatus status) {
  expect(status.status, equals(InviteTargetsJobStatusType.failed));
  expect(status.totalUsers, equals(100));
  expect(status.processedUsers, equals(41));
  expect(status.createdAt, equals(DateTime.utc(2025, 01, 08, 12, 00, 00)));
  expect(status.completedAt, isNull);
  expect(status.errorMessage, equals('Failed to parse CSV file'));
}

void main() {
  group('InviteManager', () {
    late MockNyxx client;
    late InviteManager manager;

    setUp(() {
      client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      manager = InviteManager(client);
    });

    test('parse', () {
      ParsingTest<InviteManager, Invite, Map<String, Object?>>(
        name: 'parse',
        check: checkInvite,
        parse: (m) => m.parse,
        source: sampleInvite,
      ).runWithManager(manager);
    });

    test('parseWithMetadata', () {
      ParsingTest<InviteManager, InviteWithMetadata, Map<String, Object?>>(
        name: 'parseWithMetadata',
        check: checkInviteWithMetadata,
        parse: (m) => m.parseWithMetadata,
        source: sampleInviteWithMetadata,
      ).runWithManager(manager);
    });

    test('parseInviteTargetsJobStatus', () {
      ParsingTest<InviteManager, InviteTargetsJobStatus, Map<String, Object?>>(
        name: 'parseInviteTargetsJobStatus',
        check: checkJobStatus,
        parse: (m) => m.parseInviteTargetsJobStatus,
        source: sampleJobStatus,
      ).runWithManager(manager);
    });

    testEndpoint(
      '/invites/0vCdhLbwjZZTWZLD',
      name: 'fetch',
      (client) => client.invites.fetch('0vCdhLbwjZZTWZLD'),
      response: sampleInvite,
    );

    testEndpoint(
      '/invites/0vCdhLbwjZZTWZLD',
      name: 'delete',
      method: 'DELETE',
      (client) => client.invites.delete('0vCdhLbwjZZTWZLD'),
      response: sampleInvite,
    );

    testEndpoint(
      '/invites/0vCdhLbwjZZTWZLD/target-users/job-status',
      name: 'fetchTargetUsersJobStatus',
      (client) => client.invites.fetchTargetUsersJobStatus('0vCdhLbwjZZTWZLD'),
      response: sampleJobStatus,
    );
  });
}
