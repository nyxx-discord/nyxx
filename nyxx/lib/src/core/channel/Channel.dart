part of nyxx;

/// A channel.
/// Abstract base class that defines the base methods and/or properties for all Discord channel types.
/// Generic interface for all channels
abstract class IChannel extends SnowflakeEntity implements Disposable {
  /// Type of this channel
  late final ChannelType channelType;

  /// Reference to client
  final Nyxx client;

  IChannel._new(this.client, Map<String, dynamic> raw): super(Snowflake(raw["id"])){
    this.channelType = ChannelType.from(raw["type"] as int);
  }

  factory IChannel._deserialize(Nyxx client, Map<String, dynamic> raw, [Snowflake? guildId]) {
    final type = raw["type"] as int;

    switch (type) {
      case 1:
      case 3:
        return DMChannel._new(client, raw);
      case 0:
      case 5:
        return TextGuildChannel._new(client, raw, guildId);
      case 2:
        return VoiceGuildChannel._new(client, raw, guildId);
      case 4:
        return CategoryGuildChannel._new(client, raw, guildId);
      default:
        return _InternalChannel._new(client, raw, guildId);
    }
  }

  /// Deletes channel if guild channel or closes DM if DM channel
  Future<void> delete() => this.client.httpEndpoints.deleteChannel(this.id);

  @override
  Future<void> dispose() async {
    // Empty body
  }
}

class _InternalChannel extends GuildChannel {
  _InternalChannel._new(Nyxx client, Map<String, dynamic> raw, [Snowflake? guildId]): super._new(client, raw, guildId);
}

/// Enum for possible channel types
class ChannelType extends IEnum<int> {
  static const ChannelType text = ChannelType._create(0);
  static const ChannelType voice = ChannelType._create(2);
  static const ChannelType category = ChannelType._create(4);

  static const ChannelType dm = ChannelType._create(1);
  static const ChannelType groupDm = ChannelType._create(3);

  static const ChannelType guildNews = ChannelType._create(5);
  static const ChannelType guildStore = ChannelType._create(6);

  ChannelType.from(int value) : super(value);
  const ChannelType._create(int value) : super(value);

  @override
  bool operator ==(other) {
    if (other is int) {
      return this._value == other;
    }

    return super == other;
  }
}
