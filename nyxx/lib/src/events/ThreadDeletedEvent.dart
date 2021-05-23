part of nyxx;

/// Fired when a thread is created
class ThreadDeletedEvent {
  late final ThreadChannel? thread;
  late final _ChannelCacheable<TextGuildChannel> parent;
  late final Snowflake threadId;
  late final _GuildCacheable guild;

  ThreadDeletedEvent._new(Map<String, dynamic> raw, Nyxx client) {
    final data = raw["d"] as Map<String, dynamic>;
    this.threadId = Snowflake(data["id"]);
    this.thread = new _ChannelCacheable<ThreadChannel>(client, this.threadId).getFromCache();
    this.parent = new _ChannelCacheable(client, Snowflake(data["parent_id"]));
    this.guild = new _GuildCacheable(client, Snowflake(data["guild_id"]));
  }
}