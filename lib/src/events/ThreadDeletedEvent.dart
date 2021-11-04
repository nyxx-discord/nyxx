part of nyxx;

/// Fired when a thread is created
class ThreadDeletedEvent {
  /// Thread that was deleted
  late final CacheableTextChannel<ThreadChannel> thread;

  /// Channel where thread was located
  late final CacheableTextChannel<TextGuildChannel> parent;

  /// Guild where event was generated
  late final Cacheable<Snowflake, Guild> guild;

  ThreadDeletedEvent._new(RawApiMap raw, Nyxx client) {
    final data = raw["d"] as RawApiMap;

    this.thread = CacheableTextChannel._new(client, Snowflake(data["id"]));
    this.parent = CacheableTextChannel._new(client, Snowflake(data["parent_id"]));
    this.guild = _GuildCacheable(client, Snowflake(data["guild_id"]));
  }
}
