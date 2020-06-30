part of nyxx;

/// A channel.
/// Abstract base class that defines the base methods and/or properties for all Discord channel types.
class Channel extends SnowflakeEntity {
  /// The channel's type.
  /// https://discordapp.com/developers/docs/resources/channel#channel-object-channel-types
  final ChannelType type;

  /// Reference to client instance
  final Nyxx client;

  Channel._new(Map<String, dynamic> raw, int type, this.client)
      : this.type = ChannelType._create(type),
        super(Snowflake(raw["id"]));

  factory Channel._deserialize(Map<String, dynamic> raw, Nyxx client, [Guild? guild]) {
    final type = raw["type"] as int;

    Guild? channelGuild;

    if(guild != null) {
      channelGuild = guild;
    } else if(raw["guild_id"] != null) {
      channelGuild = client.guilds[Snowflake(raw["guild_id"])];
    }

    switch (type) {
      case 1:
        return DMChannel._new(raw, client);
        break;
      case 3:
        return GroupDMChannel._new(raw, client);
        break;
      case 0:
        if(channelGuild == null) {
          return CachelessTextChannel._new(raw, Snowflake(raw["guild_id"]), client);
        }

        return CacheTextChannel._new(raw, channelGuild, client);
        break;
      case 2:
        if(channelGuild == null) {
          return CachelessVoiceChannel._new(raw, Snowflake(raw["guild_id"]), client);
        }

        return CacheVoiceChannel._new(raw, channelGuild, client);
        break;
      case 4:
        return CategoryChannel._new(raw, channelGuild == null ? Snowflake(raw["guild_id"]) : channelGuild.id, client);
        break;
      default:
        return _InternalChannel._new(raw, type, client);
    }
  }

  /// Deletes the channel.
  /// Throws if bot cannot perform operation
  Future<void> delete({String? auditReason}) =>
    client._http._execute(BasicRequest._new("/channels/${this.id}", method: "DELETE", auditLog: auditReason));

  @override
  String toString() => this.id.toString();
}

class _InternalChannel extends Channel {
  _InternalChannel._new(Map<String, dynamic> raw, int type, Nyxx client) : super._new(raw, type, client);
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
