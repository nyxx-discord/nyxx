import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';
import 'member_manager_test.dart';
import 'user_manager_test.dart';

final sampleScheduledEvent = {
  "id": "1278775959230611487",
  "guild_id": "1033681997136146462",
  "name": "test event",
  "description": null,
  "channel_id": null,
  "creator_id": "1033681843708510238",
  "image": null,
  "scheduled_start_time": "2024-08-29T19:59:07.045563+00:00",
  "scheduled_end_time": "2024-08-29T19:59:17.045564+00:00",
  "status": 1,
  "entity_type": 3,
  "entity_id": null,
  "recurrence_rule": {
    "start": "2024-08-29T19:59:07.045594+00:00",
    "end": null,
    "frequency": 2,
    "interval": 1,
    "by_weekday": [2],
    "by_n_weekday": null,
    "by_month": null,
    "by_month_day": null,
    "by_year_day": null,
    "count": null
  },
  "privacy_level": 2,
  "sku_ids": [],
  "guild_scheduled_event_exceptions": [],
  "entity_metadata": {"location": "test location"}
};

void checkScheduledEvent(ScheduledEvent event) {
  expect(event.id, equals(Snowflake(1278775959230611487)));
  expect(event.guildId, equals(Snowflake(1033681997136146462)));
  expect(event.channelId, isNull);
  expect(event.creatorId, equals(Snowflake(1033681843708510238)));
  expect(event.name, equals('test event'));
  expect(event.description, isNull);
  expect(event.scheduledStartTime, equals(DateTime.utc(2024, 08, 29, 19, 59, 07, 45, 563)));
  expect(event.scheduledEndTime, equals(DateTime.utc(2024, 08, 29, 19, 59, 17, 45, 564)));
  expect(event.privacyLevel, equals(PrivacyLevel.guildOnly));
  expect(event.status, equals(EventStatus.scheduled));
  expect(event.type, equals(ScheduledEntityType.external));
  expect(event.entityId, isNull);
  expect(event.metadata?.location, equals('test location'));
  expect(event.userCount, isNull);
  expect(event.coverImageHash, isNull);
  expect(event.recurrenceRule, isNotNull);
  expect(event.recurrenceRule, (RecurrenceRule rule) {
    expect(rule.byMonth, isNull);
    expect(rule.byMonthDay, isNull);
    expect(rule.byNWeekday, isNull);
    expect(rule.byWeekday, equals([RecurrenceRuleWeekday.wednesday]));
    expect(rule.byYearDay, isNull);
    expect(rule.count, isNull);
    expect(rule.end, isNull);
    expect(rule.frequency, equals(RecurrenceRuleFrequency.weekly));
    expect(rule.interval, equals(1));
    expect(rule.start, equals(DateTime.utc(2024, 08, 29, 19, 59, 07, 045, 594)));
    return true;
  });
}

final sampleScheduledEvent2 = {
  "id": "1278778514790944793",
  "guild_id": "1033681997136146462",
  "name": "test event",
  "description": "",
  "channel_id": "1105193130237632574",
  "creator_id": "506759329068613643",
  "creator": sampleUser,
  "image": null,
  "scheduled_start_time": "2024-08-29T19:00:00.859000+00:00",
  "scheduled_end_time": null,
  "status": 1,
  "entity_type": 2,
  "entity_id": null,
  "recurrence_rule": null,
  "privacy_level": 2,
  "sku_ids": [],
  "guild_scheduled_event_exceptions": [],
  "entity_metadata": <String, Object?>{},
};

void checkScheduledEvent2(ScheduledEvent event) {
  expect(event.id, equals(Snowflake(1278778514790944793)));
  expect(event.guildId, equals(Snowflake(1033681997136146462)));
  expect(event.channelId, equals(Snowflake(1105193130237632574)));
  expect(event.creatorId, equals(Snowflake(506759329068613643)));
  expect(event.name, equals('test event'));
  expect(event.description, equals(''));
  expect(event.scheduledStartTime, equals(DateTime.utc(2024, 08, 29, 19, 00, 00, 859)));
  expect(event.scheduledEndTime, isNull);
  expect(event.privacyLevel, equals(PrivacyLevel.guildOnly));
  expect(event.status, equals(EventStatus.scheduled));
  expect(event.type, equals(ScheduledEntityType.voice));
  expect(event.entityId, isNull);
  expect(event.metadata, isNotNull);
  expect(event.metadata!.location, isNull);
  checkSampleUser(event.creator!);
  expect(event.userCount, isNull);
  expect(event.coverImageHash, isNull);
}

final sampleScheduledEventUser = {
  'guild_scheduled_event_id': '0',
  'user': sampleUser,
  'member': sampleMemberNoUser,
};

void checkScheduledEventUser(ScheduledEventUser user) {
  expect(user.scheduledEventId, equals(Snowflake.zero));
  checkSampleUser(user.user);
  checkMemberNoUser(user.member!);
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
      scheduledStartTime: DateTime.utc(2023),
      scheduledEndTime: DateTime.utc(2023),
      type: ScheduledEntityType.stageInstance,
    ),
    updateBuilder: ScheduledEventUpdateBuilder(),
  );
}
