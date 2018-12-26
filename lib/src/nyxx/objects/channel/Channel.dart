part of nyxx;

/// A channel.
/// Abstract base class that defines the base methods and/or properties for all Discord channel types.
abstract class Channel extends SnowflakeEntity implements Debugable {
  /// The channel's type.
  /// https://discordapp.com/developers/docs/resources/channel#channel-object-channel-types
  int type;

  Nyxx client;

  Channel._new(Map<String, dynamic> raw, this.type, this.client)
      : super(Snowflake(raw['id'] as String));

  /// Deletes the channel.
  /// Throws if bot cannot perform operation
  Future<void> delete({String auditReason = ""}) async {
    await client._http
        .send('DELETE', "/channels/${this.id}", reason: auditReason);
  }

  @override
  String toString() => this.id.toString();
}
