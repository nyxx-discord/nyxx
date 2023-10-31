import 'dart:convert';

import 'package:nyxx/src/builders/guild/scheduled_event.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A [Manager] for [ScheduledEvent]s.
class ScheduledEventManager extends Manager<ScheduledEvent> {
  final Snowflake guildId;

  /// Create a new [ScheduledEventManager].
  ScheduledEventManager(super.config, super.client, {required this.guildId}) : super(identifier: '$guildId.scheduledEvents');

  @override
  PartialScheduledEvent operator [](Snowflake id) => PartialScheduledEvent(id: id, manager: this);

  @override
  ScheduledEvent parse(Map<String, Object?> raw) {
    return ScheduledEvent(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      channelId: maybeParse(raw['channel_id'], Snowflake.parse),
      creatorId: maybeParse(raw['creator_id'], Snowflake.parse),
      name: raw['name'] as String,
      description: raw['description'] as String?,
      scheduledStartTime: DateTime.parse(raw['scheduled_start_time'] as String),
      scheduledEndTime: maybeParse(raw['scheduled_end_time'], DateTime.parse),
      privacyLevel: PrivacyLevel.parse(raw['privacy_level'] as int),
      status: EventStatus.parse(raw['status'] as int),
      type: ScheduledEntityType.parse(raw['entity_type'] as int),
      entityId: maybeParse(raw['entity_id'], Snowflake.parse),
      metadata: maybeParse(raw['entity_metadata'], parseEntityMetadata),
      creator: maybeParse(raw['creator'], client.users.parse),
      userCount: raw['user_count'] as int?,
      coverImageHash: raw['image'] as String?,
    );
  }

  EntityMetadata parseEntityMetadata(Map<String, Object?> raw) {
    return EntityMetadata(
      location: raw['location'] as String?,
    );
  }

  ScheduledEventUser parseScheduledEventUser(Map<String, Object?> raw) {
    final user = client.users.parse(raw['user'] as Map<String, Object?>);

    return ScheduledEventUser(
      manager: this,
      scheduledEventId: Snowflake.parse(raw['guild_scheduled_event_id']!),
      user: user,
      member: maybeParse(raw['member'], (Map<String, Object?> raw) => client.guilds[guildId].members.parse(raw, userId: user.id)),
    );
  }

  @override
  Future<ScheduledEvent> fetch(Snowflake id, {bool? withUserCount}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..scheduledEvents(id: id.toString());
    final request = BasicRequest(route, queryParameters: {if (withUserCount != null) 'with_user_count': withUserCount.toString()});

    final response = await client.httpHandler.executeSafe(request);
    final event = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(event);
    return event;
  }

  /// List the [ScheduledEvent]s in the guild.
  Future<List<ScheduledEvent>> list({bool? withUserCounts}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..scheduledEvents();
    final request = BasicRequest(route, queryParameters: {if (withUserCounts != null) 'with_user_count': withUserCounts.toString()});

    final response = await client.httpHandler.executeSafe(request);
    final events = parseMany(response.jsonBody as List<Object?>, parse);

    events.forEach(client.updateCacheWith);
    return events;
  }

  @override
  Future<ScheduledEvent> create(ScheduledEventBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..scheduledEvents();
    final request = BasicRequest(route, method: 'POST', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final event = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(event);
    return event;
  }

  @override
  Future<ScheduledEvent> update(Snowflake id, ScheduledEventUpdateBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..scheduledEvents(id: id.toString());
    final request = BasicRequest(route, method: 'PATCH', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final event = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(event);
    return event;
  }

  @override
  Future<void> delete(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..scheduledEvents(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);

    cache.remove(id);
  }

  /// List the users that have followed an event.
  Future<List<ScheduledEventUser>> listEventUsers(Snowflake id, {int? limit, bool? withMembers, Snowflake? before, Snowflake? after}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..scheduledEvents(id: id.toString())
      ..users();
    final request = BasicRequest(route, queryParameters: {
      if (limit != null) 'limit': limit.toString(),
      if (withMembers != null) 'with_member': withMembers.toString(),
      if (before != null) 'before': before.toString(),
      if (after != null) 'after': after.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List<Object?>, parseScheduledEventUser);
  }
}
