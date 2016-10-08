part of discord;

/// Sent when a member is banned.
class GuildBanAddEvent {
  /// The guild that the member was banned from.
  Guild guild;

  /// The user that was banned.
  User user;

  /// Constructs a new [GuildBanAddEvent].
  GuildBanAddEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds.map[json['d']['guild_id']];
      this.user = new User(client, json['d']['user'] as Map<String, dynamic>);
      client.users.map[user.id] = user;
      client._events.onGuildBanAdd.add(this);
    }
  }
}
