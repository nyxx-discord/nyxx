part of nyxx;

class VoiceGuildChannel extends GuildChannel {
  /// The channel's bitrate.
  late final int? bitrate;

  /// The channel's user limit.
  late final int? userLimit;

  VoiceGuildChannel._new(INyxx client, Map<String, dynamic> raw, [Snowflake? guildId]) : super._new(client, raw, guildId) {
    this.bitrate = raw["bitrate"] as int?;
    this.userLimit = raw["user_limit"] as int?;
  }

  /// Edits channel properties
  Future<VoiceGuildChannel> edit({String? name, int? bitrate, int? position, int? userLimit, String? auditReason}) =>
      client._httpEndpoints.editVoiceChannel(this.id, name: name, bitrate: bitrate, position: position, userLimit: userLimit, auditReason: auditReason);

  /// Connects client to channel
  void connect({bool selfMute = false, bool selfDeafen = false}) {
    if (this.client is! Nyxx) {
      throw new UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (this.client as Nyxx).shardManager.shards.firstWhere((element) => element.guilds.contains(this.guild.id));

      shard.changeVoiceState(this.guild.id, this.id, selfMute: selfMute, selfDeafen: selfDeafen);
    } on Error {
      throw InvalidShardException._new("Cannot find shard for this channel!");
    }
  }

  /// Disconnects use from channel.
  void disconnect() {
    if (this.client is! Nyxx) {
      throw new UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (this.client as Nyxx).shardManager.shards.firstWhere((element) => element.guilds.contains(this.guild.id));

      shard.changeVoiceState(this.guild.id, null);
    } on Error {
      throw InvalidShardException._new("Cannot find shard for this channel!");
    }
  }
}

class StageVoiceGuildChannel extends VoiceGuildChannel {
  StageVoiceGuildChannel._new(INyxx client, Map<String, dynamic> raw, [Snowflake? guildId]) : super._new(client, raw, guildId);

  /// Gets the stage instance associated with the Stage channel, if it exists.
  Future<StageChannelInstance> getStageChannelInstance() =>
      this.client.httpEndpoints.getStageChannelInstance(this.id);

  /// Deletes the Stage instance.
  Future<void> deleteStageChannelInstance() =>
      this.client.httpEndpoints.deleteStageChannelInstance(this.id);

  /// Creates a new Stage instance associated to a Stage channel.
  Future<StageChannelInstance> createStageChannelInstance(String topic) =>
      this.client.httpEndpoints.createStageChannelInstance(this.id, topic);

  /// Updates fields of an existing Stage instance.
  Future<StageChannelInstance> updateStageChannelInstance(String topic) =>
      this.client.httpEndpoints.updateStageChannelInstance(this.id, topic);
}

/// A [StageChannelInstance] holds information about a live stage.
class StageChannelInstance extends SnowflakeEntity {
  /// The guild id of the associated Stage channel
  late final Cacheable<Snowflake, Guild> guild;

  /// The id of the associated Stage channel
  late final Cacheable<Snowflake, StageVoiceGuildChannel> channel;

  /// The topic of the Stage instance
  late final String topic;

  StageChannelInstance._new(INyxx client, Map<String, dynamic> raw): super(Snowflake(raw["id"])) {
    this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"]));
    this.channel = _ChannelCacheable(client, Snowflake(raw["channel_id"]));
    this.topic = raw["topic"] as String;
  }
}
