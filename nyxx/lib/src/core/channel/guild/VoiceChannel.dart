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
