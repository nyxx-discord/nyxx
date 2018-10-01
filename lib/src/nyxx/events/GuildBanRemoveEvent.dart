part of nyxx;

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent {
  /// The guild that the member was unbanned from.
  Guild guild;

  /// The user that was unbanned.
  User user;

  GuildBanRemoveEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.user = User._new(json['d']['user'] as Map<String, dynamic>);
      client._events.onGuildBanRemove.add(this);
    }
  }
}
