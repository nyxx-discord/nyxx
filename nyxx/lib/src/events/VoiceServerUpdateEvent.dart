part of nyxx;

/// Emitted when guild's voice server changes
class VoiceServerUpdateEvent {

  /// Raw websocket event payload
  final Map<String, dynamic> raw;

  /// Voice connection token
  late final String token;

  /// The voice server host
  late final String endpoint;

  /// The guild this voice server update is for
  Guild? guild;

  /// Id of the guild this voice server update is for
  late final Snowflake guildId;

  VoiceServerUpdateEvent._new(this.raw, Nyxx client) {
    this.token = raw["d"]["token"] as String;
    this.endpoint = raw["d"]["endpoint"] as String;

    this.guildId = Snowflake(raw["d"]["guild_id"]);
    this.guild = client.guilds[this.guildId];
  }
}
