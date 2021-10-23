part of nyxx;

/// Sent when a user starts typing.
class TypingEvent implements ITypingEvent {
  /// The channel that the user is typing in.
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// The user that is typing.
  @override
  late final Cacheable<Snowflake, IUser> user;

  /// The member who started typing if this happened in a guild
  @override
  late final IMember? member;

  /// Timestamp when the user started typing
  @override
  late final DateTime timestamp;

  /// Reference to guild where typing occurred
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Creates an instance of [TypingEvent]
  TypingEvent(RawApiMap raw, INyxx client) {
    this.channel = CacheableTextChannel(client, Snowflake(raw["d"]["channel_id"]));
    this.user = UserCacheable(client, Snowflake(raw["d"]["user_id"]));
    this.timestamp = DateTime.fromMillisecondsSinceEpoch(raw["d"]["timestamp"] as int);

    if (raw["d"]["guild_id"] != null) {
      this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      this.guild = null;
    }

    if (raw["d"]["member"] == null) {
      this.member = null;
      return;
    }

    this.member = Member(client, raw["d"]["member"] as RawApiMap, this.guild!.id);
    if (client.cacheOptions.memberCachePolicyLocation.event && client.cacheOptions.memberCachePolicy.canCache(this.member!)) {
      member!.guild.getFromCache()?.members[this.member!.id] = member!;
    }
  }
}
