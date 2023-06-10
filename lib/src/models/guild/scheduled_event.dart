import 'package:nyxx/src/http/managers/scheduled_event_manager.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class PartialScheduledEvent extends WritableSnowflakeEntity<ScheduledEvent> {
  @override
  final ScheduledEventManager manager;

  PartialScheduledEvent({required super.id, required this.manager});

  Future<List<ScheduledEventUser>> listUsers({int? limit, bool? withMembers, Snowflake? before, Snowflake? after}) =>
      manager.listEventUsers(id, withMembers: withMembers, after: after, before: before, limit: limit);
}

class ScheduledEvent extends PartialScheduledEvent {
  final Snowflake guildId;

  final Snowflake? channelId;

  final Snowflake? creatorId;

  final String name;

  final String? description;

  final DateTime scheduledStartTime;

  final DateTime? scheduledEndTime;

  final PrivacyLevel privacyLevel;

  final EventStatus status;

  final ScheduledEntityType type;

  final Snowflake? entityId;

  final EntityMetadata? metadata;

  final User? creator;

  final int? userCount;

  final String? coverImageHash;

  ScheduledEvent({
    required super.id,
    required super.manager,
    required this.guildId,
    required this.channelId,
    required this.creatorId,
    required this.name,
    required this.description,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.privacyLevel,
    required this.status,
    required this.type,
    required this.entityId,
    required this.metadata,
    required this.creator,
    required this.userCount,
    required this.coverImageHash,
  });
}

enum EventStatus {
  scheduled._(1),
  active._(2),
  completed._(3),
  cancelled._(4);

  final int value;

  const EventStatus._(this.value);

  factory EventStatus.parse(int value) => EventStatus.values.firstWhere(
        (status) => status.value == value,
        orElse: () => throw FormatException('Unknown event status', value),
      );

  @override
  String toString() => 'EventStatus($value)';
}

enum ScheduledEntityType {
  stageInstance._(1),
  voice._(2),
  external._(3);

  final int value;

  const ScheduledEntityType._(this.value);

  factory ScheduledEntityType.parse(int value) => ScheduledEntityType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown scheduled entity type', value),
      );

  @override
  String toString() => 'ScheduledEntityType($value)';
}

class EntityMetadata with ToStringHelper {
  final String? location;

  EntityMetadata({required this.location});
}

class ScheduledEventUser with ToStringHelper {
  final Snowflake scheduledEventId;

  final User user;

  final Member? member;

  ScheduledEventUser({
    required this.scheduledEventId,
    required this.user,
    required this.member,
  });
}
