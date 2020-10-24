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
  late final Cacheable<Snowflake, Guild> guild;

  VoiceServerUpdateEvent._new(this.raw, Nyxx client) {
    this.token = raw["d"]["token"] as String;
    this.endpoint = raw["d"]["endpoint"] as String;
    this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
  }
}
