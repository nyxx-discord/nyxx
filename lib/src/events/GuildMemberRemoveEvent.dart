part of discord;

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent {
  /// The guild the user left.
  Guild guild;

  ///The user that left.
  User user;

  GuildMemberRemoveEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds.map[json['d']['guild_id']];
      this.user =
          new User._new(client, json['d']['user'] as Map<String, dynamic>);
      guild.members.map.remove(user.id);
      client.users.map[user.id] = user;
      client._events.onGuildMemberRemove.add(this);
    }
  }
}
