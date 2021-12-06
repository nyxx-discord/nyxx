import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';

/// A representation of a scheduled event in a guild.
abstract class IGuildEvent implements SnowflakeEntity {
  /// The guild id which the scheduled event belongs to
  Cacheable<Snowflake, Guild> get guild;

  ///	The id of the user that created the scheduled event
  Cacheable<Snowflake, User>? get creatorId;

  /// The user that created the scheduled event
  User? get creator;

  /// The name of the scheduled event
  String get name;

  /// The description of the scheduled event
  String? get description;

  /// The time the scheduled event will start
  DateTime get startDate;

  /// The privacy level of the scheduled event
  GuildEventPrivacyLevel get privacyLevel;

  /// The status of the scheduled event
  GuildEventStatus get status;

  /// The type of the scheduled event
  GuildEventType get type;

  /// The id of an entity associated with a guild scheduled event
  Snowflake? get entityId;

  /// The number of users subscribed to the scheduled event
  int get userCount;
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
