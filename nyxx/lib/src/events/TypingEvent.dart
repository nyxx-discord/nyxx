part of nyxx;

/// Sent when a user starts typing.
class TypingEvent {
  /// The channel that the user is typing in.
  late final CacheableTextChannel<TextChannel> channel;

  /// The user that is typing.
  late final Cacheable<Snowflake, User> user;

  /// The member who started typing if this happened in a guild
  late final Member? member;

  /// Timestamp when the user started typing
  late final DateTime timestamp;

  /// Reference to guild where typing occurred
  late final Cacheable<Snowflake, Guild>? guild;

  TypingEvent._new(RawApiMap raw, Nyxx client) {
    this.channel = CacheableTextChannel._new(client, Snowflake(raw["d"]["channel_id"]), ChannelType.unknown);
    this.user = _UserCacheable(client, Snowflake(raw["d"]["user_id"]));
    this.timestamp = DateTime.fromMillisecondsSinceEpoch(raw["d"]["timestamp"] as int);

    if (raw["d"]["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      this.guild = null;
    }

    if (raw["d"]["member"] == null) {
      this.member = null;
      return;
    }

    this.member = Member._new(client, raw["d"]["member"] as RawApiMap, this.guild!.id);
    if (client._cacheOptions.memberCachePolicyLocation.event && client._cacheOptions.memberCachePolicy.canCache(this.member!)) {
      member!.guild.getFromCache()?.members[this.member!.id] = member!;
    }
  }
}
