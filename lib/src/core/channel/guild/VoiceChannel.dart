import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Invite.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/channel/guild/ActivityTypes.dart';
import 'package:nyxx/src/core/channel/guild/GuildChannel.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/internal/exceptions/InvalidShardException.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/IEnum.dart';

abstract class IVoiceGuildChannel implements IGuildChannel {}

class VoiceGuildChannel extends GuildChannel {
  /// The channel's bitrate.
  late final int? bitrate;

  /// The channel's user limit.
  late final int? userLimit;

  /// Creates an instance of [VoiceGuildChannel]
  VoiceGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId) {
    this.bitrate = raw["bitrate"] as int?;
    this.userLimit = raw["user_limit"] as int?;
  }

  /// Connects client to channel
  void connect({bool selfMute = false, bool selfDeafen = false}) {
    if (this.client is! NyxxWebsocket) {
      throw new UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (this.client as NyxxWebsocket).shardManager.shards.firstWhere((element) => element.guilds.contains(this.guild.id));

      shard.changeVoiceState(this.guild.id, this.id, selfMute: selfMute, selfDeafen: selfDeafen);
    } on Error {
      throw InvalidShardException("Cannot find shard for this channel!");
    }
  }

  /// Disconnects use from channel.
  void disconnect() {
    if (this.client is! NyxxWebsocket) {
      throw new UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (this.client as NyxxWebsocket).shardManager.shards.firstWhere((element) => element.guilds.contains(this.guild.id));

      shard.changeVoiceState(this.guild.id, null);
    } on Error {
      throw InvalidShardException("Cannot find shard for this channel!");
    }
  }

  Future<IInvite> createActivityInvite(VoiceActivityType type, {int? maxAge, int? maxUses}) =>
      this.client.httpEndpoints.createVoiceActivityInvite(Snowflake(type.value), this.id, maxAge: maxAge, maxUses: maxUses);
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
  Future<IStageChannelInstance> getStageChannelInstance() => this.client.httpEndpoints.getStageChannelInstance(this.id);

  /// Deletes the Stage instance.
  Future<void> deleteStageChannelInstance() => this.client.httpEndpoints.deleteStageChannelInstance(this.id);

  /// Creates a new Stage instance associated to a Stage channel.
  Future<IStageChannelInstance> createStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) =>
      this.client.httpEndpoints.createStageChannelInstance(this.id, topic, privacyLevel: privacyLevel);

  /// Updates fields of an existing Stage instance.
  Future<IStageChannelInstance> updateStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) =>
      this.client.httpEndpoints.updateStageChannelInstance(this.id, topic, privacyLevel: privacyLevel);
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
    this.guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    this.channel = ChannelCacheable(client, Snowflake(raw["channel_id"]));
    this.topic = raw["topic"] as String;
    this.privacyLevel = StageChannelInstancePrivacyLevel.from(raw["privacy_level"] as int);
    this.disoverableDisabled = raw["discoverable_disabled"] as bool;
  }
}

/// The privacy level of the Stage instance
class StageChannelInstancePrivacyLevel extends IEnum<int> {
  /// The Stage instance is visible publicly, such as on Stage discovery.
  static const StageChannelInstancePrivacyLevel public = const StageChannelInstancePrivacyLevel(1);

  /// The Stage instance is visible to only guild members.
  static const StageChannelInstancePrivacyLevel guildOnly = const StageChannelInstancePrivacyLevel(2);

  /// Creates an instance of [StageChannelInstancePrivacyLevel]
  const StageChannelInstancePrivacyLevel(int value) : super(value);

  /// Create [StageChannelInstancePrivacyLevel] from [value]
  StageChannelInstancePrivacyLevel.from(int value) : super(value);
}
