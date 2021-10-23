import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/channel/DMChannel.dart';
import 'package:nyxx/src/core/channel/ThreadChannel.dart';
import 'package:nyxx/src/core/channel/guild/CategoryGuildChannel.dart';
import 'package:nyxx/src/core/channel/guild/GuildChannel.dart';
import 'package:nyxx/src/core/channel/guild/TextGuildChannel.dart';
import 'package:nyxx/src/core/channel/guild/VoiceChannel.dart';
import 'package:nyxx/src/internal/interfaces/Disposable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/IEnum.dart';

abstract class IChannel implements SnowflakeEntity, Disposable {
  /// Reference to client
  INyxx get client;

  /// Type of this channel
  ChannelType get channelType;

  /// Deletes channel if guild channel or closes DM if DM channel
  Future<void> delete();
}

/// A channel.
/// Abstract base class that defines the base methods and/or properties for all Discord channel types.
/// Generic interface for all channels
abstract class Channel extends SnowflakeEntity implements IChannel {
  /// Type of this channel
  @override
  late final ChannelType channelType;

  /// Reference to client
  @override
  final INyxx client;

  /// Creates instance of [Channel]
  Channel(this.client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    this.channelType = ChannelType.from(raw["type"] as int);
  }

  /// Creates instance of [Channel] as raw
  Channel.raw(this.client, Snowflake id, this.channelType) : super(id);

  /// Deserializes and matches payload to create appropriate instance of [Channel]
  factory Channel.deserialize(INyxx client, RawApiMap raw, [Snowflake? guildId]) {
    final type = raw["type"] as int;

    switch (type) {
      case 1:
      case 3:
        return DMChannel(client, raw);
      case 0:
      case 5:
        return TextGuildChannel(client, raw, guildId);
      case 2:
        return VoiceGuildChannel(client, raw, guildId);
      case 13:
        return StageVoiceGuildChannel(client, raw, guildId);
      case 4:
        return CategoryGuildChannel(client, raw, guildId);
      case 10:
      case 11:
      case 12:
        return ThreadChannel(client, raw, guildId);
      default:
        return _InternalChannel._new(client, raw, guildId);
    }
  }

  /// Deletes channel if guild channel or closes DM if DM channel
  @override
  Future<void> delete() => this.client.httpEndpoints.deleteChannel(this.id);

  @override
  Future<void> dispose() async {}
}

class _InternalChannel extends GuildChannel {
  _InternalChannel._new(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId);
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
  static const ChannelType guildStage = ChannelType._create(13);

  static const ChannelType guildNewsThread = ChannelType._create(10);
  static const ChannelType guildPublicThread = ChannelType._create(11);
  static const ChannelType guildPrivateThread = ChannelType._create(12);

  /// Channel in a Student Hub containing the listed servers
  static const ChannelType guildDirectory = ChannelType._create(14);

  /// Type of channel is unknown
  static const ChannelType unknown = ChannelType._create(1337);

  /// Creates instance of [ChannelType] from [value].
  ChannelType.from(int value) : super(value);
  const ChannelType._create(int value) : super(value);

  @override
  bool operator ==(dynamic other) {
    if (other is int) {
      return this.value == other;
    }

    return super == other;
  }

  @override
  int get hashCode => this.value.hashCode;
}
