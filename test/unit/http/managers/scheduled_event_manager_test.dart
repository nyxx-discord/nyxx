import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';
import 'member_manager_test.dart';
import 'user_manager_test.dart';

final sampleScheduledEvent = {
  'id': '0',
  'guild_id': '1',
  'channel_id': '2',
  'creator_id': '3',
  'name': 'test',
  'description': 'a test event',
  'scheduled_start_time': '2023-06-10T16:37:18Z',
  'scheduled_end_time': '2023-06-10T16:37:18Z',
  'privacy_level': 2,
  'status': 1,
  'entity_type': 1,
  'entity_id': '2',
  'creator': sampleUser,
  'user_count': null,
  'image': null,
};

final sampleScheduledEvent2 = {
  'id': '0',
  'guild_id': '1',
  'creator_id': '3',
  'name': 'test',
  'description': 'a test event',
  'scheduled_start_time': '2023-06-10T16:37:18Z',
  'scheduled_end_time': '2023-06-10T16:37:18Z',
  'privacy_level': 2,
  'status': 1,
  'entity_type': 1,
  'entity_id': '2',
  'creator': sampleUser,
  'user_count': null,
  'image': null,
};

void checkScheduledEvent(ScheduledEvent event) {
  expect(event.id, equals(Snowflake.zero));
  expect(event.guildId, equals(Snowflake(1)));
  expect(event.channelId, equals(Snowflake(2)));
  expect(event.creatorId, equals(Snowflake(3)));
  expect(event.name, equals('test'));
  expect(event.description, equals('a test event'));
  expect(event.scheduledStartTime, equals(DateTime.utc(2023, 06, 10, 16, 37, 18)));
  expect(event.scheduledEndTime, equals(DateTime.utc(2023, 06, 10, 16, 37, 18)));
  expect(event.privacyLevel, equals(PrivacyLevel.guildOnly));
  expect(event.status, equals(EventStatus.scheduled));
  expect(event.type, equals(ScheduledEntityType.stageInstance));
  expect(event.entityId, equals(Snowflake(2)));
  expect(event.metadata, isNull);
  checkSampleUser(event.creator!);
  expect(event.userCount, isNull);
  expect(event.coverImageHash, isNull);
}

void checkScheduledEvent2(ScheduledEvent event) {
  expect(event.id, equals(Snowflake.zero));
  expect(event.guildId, equals(Snowflake(1)));
  expect(event.channelId, isNull);
  expect(event.creatorId, equals(Snowflake(3)));
  expect(event.name, equals('test'));
  expect(event.description, equals('a test event'));
  expect(event.scheduledStartTime, equals(DateTime.utc(2023, 06, 10, 16, 37, 18)));
  expect(event.scheduledEndTime, equals(DateTime.utc(2023, 06, 10, 16, 37, 18)));
  expect(event.privacyLevel, equals(PrivacyLevel.guildOnly));
  expect(event.status, equals(EventStatus.scheduled));
  expect(event.type, equals(ScheduledEntityType.stageInstance));
  expect(event.entityId, equals(Snowflake(2)));
  expect(event.metadata, isNull);
  checkSampleUser(event.creator!);
  expect(event.userCount, isNull);
  expect(event.coverImageHash, isNull);
}

final sampleScheduledEventUser = {
  'guild_scheduled_event_id': '0',
  'user': sampleUser,
  'member': sampleMember,
};

void checkScheduledEventUser(ScheduledEventUser user) {
  expect(user.scheduledEventId, equals(Snowflake.zero));
  checkSampleUser(user.user);
  checkMember(user.member!);
}

void main() {
  testManager<ScheduledEvent, ScheduledEventManager>(
    'ScheduledEventManager',
    (config, client) => ScheduledEventManager(config, client, guildId: Snowflake.zero),
    RegExp(r'/guilds/0/scheduled-events/\d+'),
    '/guilds/0/scheduled-events',
    sampleObject: sampleScheduledEvent,
    sampleMatches: checkScheduledEvent,
    additionalSampleObjects: [sampleScheduledEvent2],
    additionalSampleMatchers: [checkScheduledEvent2],
    additionalParsingTests: [
      ParsingTest<ScheduledEventManager, ScheduledEventUser, Map<String, Object?>>(
        name: 'parseScheduledEventUser',
        source: sampleScheduledEventUser,
        parse: (manager) => manager.parseScheduledEventUser,
        check: checkScheduledEventUser,
      ),
    ],
    additionalEndpointTests: [
      EndpointTest<ScheduledEventManager, List<ScheduledEvent>, List<Object?>>(
        name: 'list',
        source: [sampleScheduledEvent],
        urlMatcher: '/guilds/0/scheduled-events',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));
          checkScheduledEvent(list.single);
        },
      ),
      EndpointTest<ScheduledEventManager, List<ScheduledEventUser>, List<Object?>>(
        name: 'listEventUsers',
        source: [sampleScheduledEventUser],
        urlMatcher: '/guilds/0/scheduled-events/1/users',
        execute: (manager) => manager.listEventUsers(Snowflake(1)),
        check: (list) {
          expect(list, hasLength(1));
          checkScheduledEventUser(list.single);
        },
      ),
    ],
    createBuilder: ScheduledEventBuilder(
      channelId: Snowflake.zero,
      name: 'test',
      privacyLevel: PrivacyLevel.guildOnly,
      scheduledStartTime: DateTime(2023),
      scheduledEndTime: DateTime(2023),
      type: ScheduledEntityType.stageInstance,
    ),
    updateBuilder: ScheduledEventUpdateBuilder(),
  );
}
