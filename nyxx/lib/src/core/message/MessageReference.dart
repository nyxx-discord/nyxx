part of nyxx;

/// Reference data to cross posted message
class MessageReference {
  /// Original message
  late final Cacheable<Snowflake, Message>? message;

  /// Original channel
  late final Cacheable<Snowflake, TextChannel> channel;

  /// Original guild
  late final Cacheable<Snowflake, Guild>? guild;

  MessageReference._new(Map<String, dynamic> raw, INyxx client) {
    this.channel = _ChannelCacheable(client, Snowflake(raw["channel_id"]));

    if (raw["message_id"] != null) {
      this.message = _MessageCacheable(client, Snowflake(raw["message_id"]), this.channel);
    } else {
      this.message = null;
    }

    if (raw["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"]));
    } else {
      this.guild = null;
    }
  }
}
