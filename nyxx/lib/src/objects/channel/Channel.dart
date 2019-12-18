part of nyxx;

/// A channel.
/// Abstract base class that defines the base methods and/or properties for all Discord channel types.
abstract class Channel extends SnowflakeEntity {
  /// The channel's type.
  /// https://discordapp.com/developers/docs/resources/channel#channel-object-channel-types
  ChannelType type;

  /// Reference to client instance
  Nyxx client;

  Channel._new(Map<String, dynamic> raw, int type, this.client)
      : this.type = ChannelType(type),
        super(Snowflake(raw['id'] as String));

  /// Deletes the channel.
  /// Throws if bot cannot perform operation
  Future<void> delete({String auditReason = ""}) {
    return client._http
        .send('DELETE', "/channels/${this.id}", reason: auditReason);
  }

  @override
  String toString() => this.id.toString();
}

/// Enum for possible channel types
class ChannelType {
  final int _value;

  ChannelType(this._value);
  const ChannelType._create(this._value);

  @override
  String toString() => _value.toString();

  @override
  bool operator ==(other) =>
      (other is ChannelType && other._value == this._value) ||
      (other is int && other == this._value);

  @override
  int get hashCode => _value.hashCode;

  static const ChannelType text = ChannelType._create(0);
  static const ChannelType voice = ChannelType._create(2);
  static const ChannelType category = ChannelType._create(4);

  static const ChannelType dm = ChannelType._create(1);
  static const ChannelType groupDm = ChannelType._create(3);
}
