part of nyxx;

/// Sent when a user starts typing.
class TypingEvent {
  /// The channel that the user is typing in.
  late final Cacheable<Snowflake, TextChannel> channel;

  /// The user that is typing.
  late final Cacheable<Snowflake, User> user;

  /// The member who started typing if this happened in a guild
  late final Member? member;

  /// Timestamp when the user started typing
  late final DateTime timestamp;

  /// Refernce to guild where typing occured
  late final Cacheable<Snowflake, GuildNew>? guild;

  TypingEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.channel = _ChannelCacheable(client, Snowflake(raw["d"]["channel_id"]));
    this.user = _UserCacheable(client, Snowflake(raw["d"]["user_id"]));
    this.timestamp = DateTime.fromMillisecondsSinceEpoch(raw["d"]["timestamp"] as int);

    if (raw["d"]["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      this.guild = null;
    }
    
    if (raw["d"]["member"] != null) {
      this.member = Member._new(client, raw["d"]["member"] as Map<String, dynamic>, this.guild!.id);
    } else {
      this.member = null;
    }
  }
}
