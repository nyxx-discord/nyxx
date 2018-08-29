part of nyxx;

/// A channel.
/// Abstract base class that defines the base methods and/or properties for all Discord channel types.
class Channel extends SnowflakeEntity {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The channel's type.
  /// https://discordapp.com/developers/docs/resources/channel#channel-object-channel-types
  int type;

  Channel._new(this.client, this.raw, this.type)
      : super(new Snowflake(raw['id'] as String)) {
    client.channels[id] = this;
  }

  /// Deletes the channel.
  /// Throws if bot cannot perform operation
  Future<void> delete({String auditReason: ""}) async {
    await this
        .client
        .http
        .send('DELETE', "/channels/${this.id}", reason: auditReason);
  }
}
