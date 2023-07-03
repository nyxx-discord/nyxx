import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/scheduled_event_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A partial [ScheduledEvent].
class PartialScheduledEvent extends WritableSnowflakeEntity<ScheduledEvent> {
  @override
  final ScheduledEventManager manager;

  /// Create a new [PartialScheduledEvent].
  PartialScheduledEvent({required super.id, required this.manager});

  /// List the users that have followed this event.
  Future<List<ScheduledEventUser>> listUsers({int? limit, bool? withMembers, Snowflake? before, Snowflake? after}) =>
      manager.listEventUsers(id, withMembers: withMembers, after: after, before: before, limit: limit);
}

/// {@template scheduled_event}
/// A scheduled event in a [Guild].
/// {@endtemplate}
class ScheduledEvent extends PartialScheduledEvent {
  /// The ID of the guild this event is in.
  final Snowflake guildId;

  /// The ID of the channel this event will be hosted in.
  final Snowflake? channelId;

  /// The ID of the user that created the event,
  final Snowflake? creatorId;

  /// The name of this event.
  final String name;

  /// The description of this event.
  final String? description;

  /// The time at which this event is scheduled to start.
  final DateTime scheduledStartTime;

  /// The time at which this event is scheduled to end.
  final DateTime? scheduledEndTime;

  /// The privacy level of this event.
  ///
  /// Can currently only be [PrivacyLevel.guildOnly].
  final PrivacyLevel privacyLevel;

  /// The status of this event.
  final EventStatus status;

  /// The type of the entity associated with this event.
  final ScheduledEntityType type;

  /// The ID of the entity associated with this event.
  final Snowflake? entityId;

  /// Additional metadata about this event.
  final EntityMetadata? metadata;

  /// The user that created this event.
  final User? creator;

  /// The number of users interested in this event.
  final int? userCount;

  /// The hash of this event's cover image.
  final String? coverImageHash;

  /// {@macro scheduled_event}
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

  /// The guild this event is in.
  PartialGuild get guild => manager.client.guilds[guildId];

  /// The channel this event will be hosted in.
  PartialChannel? get channel => channelId == null ? null : manager.client.channels[channelId!];

  /// The member for the user that created this event.
  PartialMember? get creatorMember => creatorId == null ? null : guild.members[creatorId!];

  /// This scheduled event's cover image.
  CdnAsset? get coverImage => coverImageHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..guildEvents(id: id.toString()),
          hash: coverImageHash!,
        );
}

/// The status of a [ScheduledEvent].
enum EventStatus {
  scheduled._(1),
  active._(2),
  completed._(3),
  cancelled._(4);

  /// TThe value of this [EventStatus].
  final int value;

  const EventStatus._(this.value);

  /// Parse an [EventStatus] from an [int].
  ///
  /// The [value] must be a valid event status.
  factory EventStatus.parse(int value) => EventStatus.values.firstWhere(
        (status) => status.value == value,
        orElse: () => throw FormatException('Unknown event status', value),
      );

  @override
  String toString() => 'EventStatus($value)';
}

/// The type of the entity associated with a [ScheduledEvent].
enum ScheduledEntityType {
  stageInstance._(1),
  voice._(2),
  external._(3);

  /// The value of this [ScheduledEntityType].
  final int value;

  const ScheduledEntityType._(this.value);

  /// Parse a [ScheduledEntityType] from an [int].
  ///
  /// The [value] must be a valid scheduled entity type.
  factory ScheduledEntityType.parse(int value) => ScheduledEntityType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown scheduled entity type', value),
      );

  @override
  String toString() => 'ScheduledEntityType($value)';
}

/// {@template entity_metadata}
/// Additional metadata associated with a [ScheduledEvent].
/// {@endtemplate}
class EntityMetadata with ToStringHelper {
  /// The location the event will take place in.
  final String? location;

  /// {@macro entity_metadata}
  EntityMetadata({required this.location});
}

/// {@template scheduled_event_user}
/// A user that has followed a [ScheduledEvent].
/// {@endtemplate}
class ScheduledEventUser with ToStringHelper {
  final ScheduledEventManager manager;

  /// The ID of the event the user followed.
  final Snowflake scheduledEventId;

  /// The user that followed the event.
  final User user;

  /// The member associated with the user.
  final Member? member;

  /// {@macro scheduled_event_user}
  ScheduledEventUser({
    required this.manager,
    required this.scheduledEventId,
    required this.user,
    required this.member,
  });

  /// The event the user followed.
  PartialScheduledEvent get scheduledEvent => manager[scheduledEventId];
}
