part of nyxx;

/// Sent when a member is banned.
class GuildBanAddEvent {
  /// The guild that the member was banned from.
  Guild guild;

  /// The user that was banned.
  User user;

  GuildBanAddEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds[json['d']['guild_id']];
      this.user =
          new User._new(client, json['d']['user'] as Map<String, dynamic>);
      client._events.onGuildBanAdd.add(this);
    }
  }
}
