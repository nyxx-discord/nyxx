import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/channel/invite.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/guild/activity_types.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/exceptions/invalid_shard_exception.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';

abstract class IVoiceGuildChannel implements IGuildChannel {
  /// Connects client to channel
  void connect({bool selfMute = false, bool selfDeafen = false});

  /// Disconnects use from channel.
  void disconnect();

  /// Creates activity invite. Currently in beta
  Future<IInvite> createActivityInvite(VoiceActivityType type, {int? maxAge, int? maxUses});
}

class VoiceGuildChannel extends GuildChannel {
  /// The channel's bitrate.
  late final int? bitrate;

  /// The channel's user limit.
  late final int? userLimit;

  /// Creates an instance of [VoiceGuildChannel]
  VoiceGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId) {
    bitrate = raw["bitrate"] as int?;
    userLimit = raw["user_limit"] as int?;
  }

  /// Connects client to channel
  void connect({bool selfMute = false, bool selfDeafen = false}) {
    if (client is! NyxxWebsocket) {
      throw UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (client as NyxxWebsocket).shardManager.shards.firstWhere((element) => element.guilds.contains(guild.id));

      shard.changeVoiceState(guild.id, id, selfMute: selfMute, selfDeafen: selfDeafen);
    } on Error {
      throw InvalidShardException("Cannot find shard for this channel!");
    }
  }

  /// Disconnects use from channel.
  void disconnect() {
    if (client is! NyxxWebsocket) {
      throw UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (client as NyxxWebsocket).shardManager.shards.firstWhere((element) => element.guilds.contains(guild.id));

      shard.changeVoiceState(guild.id, null);
    } on Error {
      throw InvalidShardException("Cannot find shard for this channel!");
    }
  }

  Future<IInvite> createActivityInvite(VoiceActivityType type, {int? maxAge, int? maxUses}) =>
      client.httpEndpoints.createVoiceActivityInvite(Snowflake(type.value), id, maxAge: maxAge, maxUses: maxUses);
}

abstract class IStageVoiceGuildChannel implements IVoiceGuildChannel {
  /// Gets the stage instance associated with the Stage channel, if it exists.
  Future<IStageChannelInstance> getStageChannelInstance();

  /// Deletes the Stage instance.
  Future<void> deleteStageChannelInstance();

  /// Creates a new Stage instance associated to a Stage channel.
  Future<IStageChannelInstance> createStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel});

  /// Updates fields of an existing Stage instance.
  Future<IStageChannelInstance> updateStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel});
}

class StageVoiceGuildChannel extends VoiceGuildChannel {
  StageVoiceGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId);

  /// Gets the stage instance associated with the Stage channel, if it exists.
  Future<IStageChannelInstance> getStageChannelInstance() => client.httpEndpoints.getStageChannelInstance(id);

  /// Deletes the Stage instance.
  Future<void> deleteStageChannelInstance() => client.httpEndpoints.deleteStageChannelInstance(id);

  /// Creates a new Stage instance associated to a Stage channel.
  Future<IStageChannelInstance> createStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) =>
      client.httpEndpoints.createStageChannelInstance(id, topic, privacyLevel: privacyLevel);

  /// Updates fields of an existing Stage instance.
  Future<IStageChannelInstance> updateStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) =>
      client.httpEndpoints.updateStageChannelInstance(id, topic, privacyLevel: privacyLevel);
}

abstract class IStageChannelInstance implements SnowflakeEntity {
  /// The guild id of the associated Stage channel
  Cacheable<Snowflake, IGuild> get guild;

  /// The id of the associated Stage channel
  Cacheable<Snowflake, IStageVoiceGuildChannel> get channel;

  /// The topic of the Stage instance
  String get topic;

  /// The privacy level of the Stage instance
  StageChannelInstancePrivacyLevel get privacyLevel;

  /// Whether or not Stage discovery is disabled
  bool get disoverableDisabled;
}

/// A [StageChannelInstance] holds information about a live stage.
class StageChannelInstance extends SnowflakeEntity implements IStageChannelInstance {
  /// The guild id of the associated Stage channel
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The id of the associated Stage channel
  @override
  late final Cacheable<Snowflake, IStageVoiceGuildChannel> channel;

  /// The topic of the Stage instance
  @override
  late final String topic;

  /// The privacy level of the Stage instance
  @override
  late final StageChannelInstancePrivacyLevel privacyLevel;

  /// Whether or not Stage discovery is disabled
  @override
  late final bool disoverableDisabled;

  /// Creates an instance of [StageChannelInstance]
  StageChannelInstance(INyxx client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    channel = ChannelCacheable(client, Snowflake(raw["channel_id"]));
    topic = raw["topic"] as String;
    privacyLevel = StageChannelInstancePrivacyLevel.from(raw["privacy_level"] as int);
    disoverableDisabled = raw["discoverable_disabled"] as bool;
  }
}

/// The privacy level of the Stage instance
class StageChannelInstancePrivacyLevel extends IEnum<int> {
  /// The Stage instance is visible publicly, such as on Stage discovery.
  static const StageChannelInstancePrivacyLevel public = StageChannelInstancePrivacyLevel(1);

  /// The Stage instance is visible to only guild members.
  static const StageChannelInstancePrivacyLevel guildOnly = StageChannelInstancePrivacyLevel(2);

  /// Creates an instance of [StageChannelInstancePrivacyLevel]
  const StageChannelInstancePrivacyLevel(int value) : super(value);

  /// Create [StageChannelInstancePrivacyLevel] from [value]
  StageChannelInstancePrivacyLevel.from(int value) : super(value);
}
