part of nyxx;

/// Fired when a thread is created
class ThreadDeletedEvent implements IThreadDeletedEvent {
  /// Thread that was deleted
  late final CacheableTextChannel<ThreadChannel> thread;

  /// Channel where thread was located
  late final CacheableTextChannel<TextGuildChannel> parent;

  /// Guild where event was generated
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates na instance of [ThreadDeletedEvent]
  ThreadDeletedEvent(RawApiMap raw, INyxx client) {
    final data = raw["d"] as RawApiMap;

    this.thread = CacheableTextChannel(client, Snowflake(data["id"]));
    this.parent = CacheableTextChannel(client, Snowflake(data["parent_id"]));
    this.guild = GuildCacheable(client, Snowflake(data["guild_id"]));
  }
}
