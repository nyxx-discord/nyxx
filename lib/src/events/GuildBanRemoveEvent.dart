part of discord;

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent {
  /// The guild that the member was unbanned from.
  Guild guild;

  /// The user that was unbanned.
  User user;

  GuildBanRemoveEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds[json['d']['guild_id']];
      this.user =
          new User._new(client, json['d']['user'] as Map<String, dynamic>);
      client._events.onGuildBanRemove.add(this);
    }
  }
}
