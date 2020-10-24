part of nyxx;

/// Emitted when invite is creating
class InviteCreatedEvent {
  /// [Invite] object of created invite
  late final Invite invite;

  InviteCreatedEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.invite = Invite._new(raw["d"] as Map<String, dynamic>, client);
  }
}

/// Emitted when invite is deleted
class InviteDeletedEvent {
  /// Channel to which invite was pointing
  late final Cacheable<Snowflake, GuildChannel> channel;

  /// Guild where invite was deleted
  late final Cacheable<Snowflake, GuildNew>? guild;

  /// Code of invite
  late final String code;

  InviteDeletedEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.code = raw["d"]["code"] as String;
    this.channel = _ChannelCacheable(client, Snowflake(raw["d"]["channel_id"]));

    if (raw["d"]["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      this.guild = null;
    }
  }
}
