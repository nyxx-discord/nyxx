import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IMessageReference {
  /// Original message
  late final Cacheable<Snowflake, IMessage>? message;

  /// Original channel
  late final CacheableTextChannel<ITextChannel> channel;

  /// Original guild
  late final Cacheable<Snowflake, IGuild>? guild;
}

/// Reference data to cross posted message
class MessageReference implements IMessageReference {
  /// Original message
  @override
  late final Cacheable<Snowflake, IMessage>? message;

  /// Original channel
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// Original guild
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Creates an instance of [MessageReference]
  MessageReference(RawApiMap raw, INyxx client) {
    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["channel_id"]));

    if (raw["message_id"] != null) {
      this.message = MessageCacheable(client, Snowflake(raw["message_id"]), this.channel);
    } else {
      this.message = null;
    }

    if (raw["guild_id"] != null) {
      this.guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    } else {
      this.guild = null;
    }
  }
}
