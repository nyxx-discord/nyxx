part of discord;

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  Member member;

  GuildMemberAddEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[json['d']['guild_id']];
      guild.memberCount++;
      this.member =
          new Member._new(client, json['d'] as Map<String, dynamic>, guild);
      client._events.onGuildMemberAdd.add(this);
    }
  }
}
