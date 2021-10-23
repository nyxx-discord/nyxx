part of nyxx;

/// Reference data to cross posted message
class MessageReference implements IMessageReference {
  /// Original message
  late final Cacheable<Snowflake, IMessage>? message;

  /// Original channel
  late final CacheableTextChannel<ITextChannel> channel;

  /// Original guild
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
