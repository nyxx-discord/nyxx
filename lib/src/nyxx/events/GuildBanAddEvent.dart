part of nyxx;

/// Sent when a member is banned.
class GuildBanAddEvent {
  /// The guild that the member was banned from.
  Guild guild;

  /// The user that was banned.
  User user;

  GuildBanAddEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.user = User._new(json['d']['user'] as Map<String, dynamic>);

      guild.members.remove(user.id);
      client.users.remove(user.id);
      client._events.onGuildBanAdd.add(this);
    }
  }
}
