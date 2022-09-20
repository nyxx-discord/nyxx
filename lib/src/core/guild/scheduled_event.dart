import 'package:nyxx/src/core/channel/guild/voice_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/guild_event_builder.dart';
import 'package:nyxx/src/utils/enum.dart';

/// A representation of a scheduled event in a guild.
abstract class IGuildEvent implements SnowflakeEntity {
  /// Reference to [INyxx]
  INyxx get client;

  /// The guild id which the scheduled event belongs to
  Cacheable<Snowflake, IGuild> get guild;

  ///	The id of the user that created the scheduled event
  Cacheable<Snowflake, IUser>? get creatorId;

  /// The channel id in which the scheduled event will be hosted, or null if scheduled entity type is EXTERNAL
  Cacheable<Snowflake, IVoiceGuildChannel>? get channel;

  /// The user that created the scheduled event
  IUser? get creator;

  /// The name of the scheduled event
  String get name;

  /// The description of the scheduled event
  String? get description;

  /// The time the scheduled event will start
  DateTime get startDate;

  /// The time the scheduled event will start
  DateTime? get endDate;

  /// The privacy level of the scheduled event
  GuildEventPrivacyLevel get privacyLevel;

  /// The status of the scheduled event
  GuildEventStatus get status;

  /// The type of the scheduled event
  GuildEventType get type;

  /// The id of an entity associated with a guild scheduled event
  Snowflake? get entityId;

  /// The number of users subscribed to the scheduled event
  int? get userCount;

  /// Additional metadata for the guild scheduled event
  IEntityMetadata? get metadata;

  /// The cover image hash.
  String? get image;

  /// Deletes guild event
  Future<void> delete();

  /// Allows editing guild event details and transitioning event between states
  Future<GuildEvent> edit(GuildEventBuilder builder);

  /// Allows getting users that are taking part in event
  Stream<GuildEventUser> fetchUsers({int limit = 100, bool withMember = false, Snowflake? before, Snowflake? after});

  /// Returns URL to the cover, with given [format] and [size].
  String? coverUrl({String? format, int? size});
}

class GuildEvent extends SnowflakeEntity implements IGuildEvent {
  @override
  final INyxx client;

  @override
  late final IUser? creator;

  @override
  late final Cacheable<Snowflake, IUser>? creatorId;

  @override
  late final Cacheable<Snowflake, IVoiceGuildChannel>? channel;

  @override
  late final String? description;

  @override
  late final Snowflake? entityId;

  @override
  late final Cacheable<Snowflake, IGuild> guild;

  @override
  late final String name;

  @override
  late final GuildEventPrivacyLevel privacyLevel;

  @override
  late final DateTime startDate;

  @override
  late final DateTime? endDate;

  @override
  late final GuildEventStatus status;

  @override
  late final GuildEventType type;

  @override
  late final int? userCount;

  @override
  late final IEntityMetadata? metadata;

  @override
  late final String? image;

  GuildEvent(RawApiMap raw, this.client) : super(Snowflake(raw['id'])) {
    creator = raw['creator'] != null ? User(client, raw['creator'] as RawApiMap) : null;
    creatorId = raw['creator_id'] != null ? UserCacheable(client, Snowflake(raw['creator_id'])) : null;
    entityId = raw['entity_id'] != null ? Snowflake(raw['entity_id']) : null;
    description = raw['description'] as String?;
    guild = GuildCacheable(client, Snowflake(raw['guild_id']));
    name = raw['name'] as String;
    privacyLevel = GuildEventPrivacyLevel.from(raw['privacy_level'] as int);
    startDate = DateTime.parse(raw['scheduled_start_time'] as String);
    status = GuildEventStatus.from(raw['status'] as int);
    type = GuildEventType.from(raw['entity_type'] as int);
    userCount = raw['user_count'] as int?;

    channel = raw['channel_id'] != null ? ChannelCacheable(client, Snowflake(raw['channel_id'])) : null;

    endDate = raw['scheduled_end_time'] != null ? DateTime.parse(raw['scheduled_end_time'] as String) : null;

    metadata = raw['entity_metadata'] != null ? EntityMetadata(raw['entity_metadata'] as RawApiMap) : null;
    image = raw['image'] as String?;
  }

  @override
  Future<void> delete() => client.httpEndpoints.deleteGuildEvent(guild.id, id);

  @override
  Future<GuildEvent> edit(GuildEventBuilder builder) => client.httpEndpoints.editGuildEvent(guild.id, id, builder);

  @override
  Stream<GuildEventUser> fetchUsers({int limit = 100, bool withMember = false, Snowflake? before, Snowflake? after}) =>
      client.httpEndpoints.fetchGuildEventUsers(guild.id, id, limit: limit, withMember: withMember, before: before, after: after);

  @override
  String? coverUrl({String? format, int? size}) {
    if (image == null) {
      return null;
    }

    return client.cdnHttpEndpoints.guildEventCoverImage(id, image!, format: format, size: size);
  }
}

abstract class IEntityMetadata {
  /// Location of the event
  String get location;
}

class EntityMetadata implements IEntityMetadata {
  @override
  late final String location;

  EntityMetadata(RawApiMap raw) {
    location = raw['location'] as String;
  }
}

abstract class IGuildEventUser {
  /// The scheduled event id which the user subscribed to
  Snowflake get scheduledEventId;

  /// User which subscribed to an event
  IUser get user;

  /// Guild member data for this user for the guild which this event belongs to, if any
  IMember? get member;
}

class GuildEventUser implements IGuildEventUser {
  @override
  late final Snowflake scheduledEventId;

  @override
  late final IUser user;

  @override
  late final IMember? member;

  GuildEventUser(RawApiMap raw, INyxx client, Snowflake guildId) {
    scheduledEventId = Snowflake(raw['guild_scheduled_event_id']);
    user = User(client, raw['user'] as RawApiMap);
    member = raw['member'] != null ? Member(client, raw['member'] as RawApiMap, guildId) : null;
  }
}

class GuildEventPrivacyLevel extends IEnum<int> {
  static const guildOnly = GuildEventPrivacyLevel(2);

  const GuildEventPrivacyLevel(int value) : super(value);
  GuildEventPrivacyLevel.from(int value) : super(value);
}

class GuildEventStatus extends IEnum<int> {
  static const scheduled = GuildEventStatus(1);
  static const active = GuildEventStatus(2);
  static const completed = GuildEventStatus(3);
  static const canceled = GuildEventStatus(4);

  const GuildEventStatus(int value) : super(value);
  GuildEventStatus.from(int value) : super(value);
}

class GuildEventType extends IEnum<int> {
  static const stage = GuildEventType(1);
  static const voice = GuildEventType(2);
  static const external = GuildEventType(3);

  const GuildEventType(int value) : super(value);
  GuildEventType.from(int value) : super(value);
}
