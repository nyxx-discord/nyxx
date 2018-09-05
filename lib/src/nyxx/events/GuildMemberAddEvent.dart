part of nyxx;

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  Member member;

  GuildMemberAddEvent._new(Nyxx client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];
      guild.memberCount++;
      this.member =
          Member._new(client, json['d'] as Map<String, dynamic>, guild);
      client._events.onGuildMemberAdd.add(this);
    }
  }
}
