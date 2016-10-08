part of discord;

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  Member member;

  GuildMemberAddEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds.map[json['d']['guild_id']];
      this.member =
          new Member._new(client, json['d'] as Map<String, dynamic>, guild);
      guild.members.map[member.id] = member;
      client.users.map[member.id] = member.toUser();
      client._events.onGuildMemberAdd.add(this);
    }
  }
}
