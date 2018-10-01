part of nyxx;

/// A channel.
/// Abstract base class that defines the base methods and/or properties for all Discord channel types.
class Channel extends SnowflakeEntity {
  /// The channel's type.
  /// https://discordapp.com/developers/docs/resources/channel#channel-object-channel-types
  int type;

  Channel._new(Map<String, dynamic> raw, this.type)
      : super(Snowflake(raw['id'] as String));

  /// Deletes the channel.
  /// Throws if bot cannot perform operation
  Future<void> delete({String auditReason = ""}) async {
    await _client.http
        .send('DELETE', "/channels/${this.id}", reason: auditReason);
  }
}
