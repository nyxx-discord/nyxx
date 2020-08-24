part of nyxx;

abstract class VoiceChannel implements Channel {
  /// The channel's bitrate.
  late final int? bitrate;

  /// The channel's user limit.
  late final int? userLimit;

  void _initialize(Map<String, dynamic> raw) {
    this.bitrate = raw["bitrate"] as int?;
    this.userLimit = raw["user_limit"] as int?;
  }

  Future<VoiceChannel> edit({String? name, int? bitrate, int? position, int? userLimit, String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (bitrate != null) "bitrate": bitrate,
      if (userLimit != null) "user_limit": userLimit,
      if (position != null) "position": position,
    };

    final response = await client._http
        ._execute(BasicRequest._new("/channels/${this.id}", method: "PATCH", body: body, auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      if(this is CacheGuildChannel) {
        return CacheVoiceChannel._new(response.jsonBody as Map<String, dynamic>, (this as CacheGuildChannel).guild, client);
      }

      return CachelessVoiceChannel._new(response.jsonBody as Map<String, dynamic>, (this as CachelessVoiceChannel).guildId, client);
    }

    return Future.error(response);
  }
}

class CachelessVoiceChannel extends CachelessGuildChannel with VoiceChannel {
  CachelessVoiceChannel._new(Map<String, dynamic> raw, Snowflake guildId, Nyxx client) : super._new(raw, 2, guildId, client) {
    _initialize(raw);
  }

  /// Connects client to channel
  void connect({bool selfMute = false, bool selfDeafen = false}) {
    try {
      final shard = this.client.shardManager.shards.firstWhere((element) => element.guilds.contains(this.guildId));

      shard.changeVoiceState(this.guildId, this.id, selfMute: selfMute, selfDeafen: selfDeafen);
    } on Error {
      throw InvalidShardException._new("Cannot find shard for this channel!");
    }
  }

  /// Disconnects use from channel.
  void disconnect() {
    try {
      final shard = this.client.shardManager.shards.firstWhere((element) => element.guilds.contains(this.guildId));

      shard.changeVoiceState(this.guildId, null);
    } on Error {
      throw InvalidShardException._new("Cannot find shard for this channel!");
    }
  }
}

/// Represents VoiceChannel within [Guild]
class CacheVoiceChannel extends CacheGuildChannel with VoiceChannel {
  /// Allows to get [VoiceState]s of users connected to this channel
  Iterable<VoiceState> get connectedUsers => this.guild.voiceStates.values.where((e) => e.channel?.id == this.id);

  CacheVoiceChannel._new(Map<String, dynamic> raw, Guild guild, Nyxx client) : super._new(raw, 2, guild, client) {
    _initialize(raw);
  }
}
