part of nyxx;

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent {
  /// The guild the user left.
  Guild guild;

  ///The user that left.
  User user;

  GuildMemberRemoveEvent._new(Map<String, dynamic> json) {
    if (client.ready && json['d']['user']['id'] != client.self.id) {
      this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];

      if (guild != null) {
        guild.memberCount--;
        this.user = User._new(json['d']['user'] as Map<String, dynamic>);
        guild.members.remove(user.id);
        client.users.remove(user.id);
        client._events.onGuildMemberRemove.add(this);
      }
    }
  }
}
