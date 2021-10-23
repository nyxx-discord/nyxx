import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/channel/CacheableTextChannel.dart';
import 'package:nyxx/src/core/channel/ITextChannel.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/message/Message.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
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
