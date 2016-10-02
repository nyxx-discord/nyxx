import '../../discord.dart';

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent {
  /// The guild that the member was unbanned from.
  Guild guild;

  /// The user that was unbanned.
  User user;

  /// Constructs a new [GuildBanRemoveEvent].
  GuildBanRemoveEvent(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      this.guild = client.guilds.map[json['d']['guild_id']];
      this.user = new User(client, json['d']['user'] as Map<String, dynamic>);
      client.users.map[user.id] = user;
      client.internal.events.onGuildBanRemove.add(this);
    }
  }
}
