part of nyxx;

/// Emitted when guild's voice server changes
class VoiceServerUpdateEvent implements IVoiceServerUpdateEvent {
  /// Raw websocket event payload
  final RawApiMap raw;

  /// Voice connection token
  late final String token;

  /// The voice server host
  late final String endpoint;

  /// The guild this voice server update is for
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates na instance of [VoiceServerUpdateEvent]
  VoiceServerUpdateEvent(this.raw, INyxx client) {
    this.token = raw["d"]["token"] as String;
    this.endpoint = raw["d"]["endpoint"] as String;
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
  }
}
