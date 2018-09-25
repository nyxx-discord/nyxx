part of nyxx;

/// Sent when a member joins a guild.
class GuildMemberAddEvent {
  /// The member that joined.
  Member member;

  GuildMemberAddEvent._new(Map<String, dynamic> json) {
    if (_client.ready) {
      final Guild guild =
          _client.guilds[Snowflake(json['d']['guild_id'] as String)];
      guild.memberCount++;

      this.member = Member._new(json['d'] as Map<String, dynamic>, guild);
      guild.members[member.id] = member;
      client.users[member.id] = member;
      _client._events.onGuildMemberAdd.add(this);
    }
  }
}
