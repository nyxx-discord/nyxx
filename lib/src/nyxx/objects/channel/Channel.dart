part of nyxx;

/// A channel.
class Channel extends SnowflakeEntity {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The channel's type.
  String type;

  Channel._new(this.client, this.raw, this.type)
      : super(new Snowflake(raw['id'] as String)) {
    client.channels[id] = this;
  }

  /// Deletes the channel.
  Future<Null> delete({String auditReason: ""}) async {
    await this
        .client
        .http
        .send('DELETE', "/channels/${this.id}", reason: auditReason);
    return null;
  }
}
