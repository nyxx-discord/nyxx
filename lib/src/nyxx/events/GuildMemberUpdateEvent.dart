part of nyxx;

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member prior to the update.
  Member oldMember;

  /// The member after the update.
  Member newMember;

  GuildMemberUpdateEvent._new( Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.oldMember =
          guild.members[Snowflake(json['d']['user']['id'] as String)];
      this.newMember =
          Member._new(json['d'] as Map<String, dynamic>, guild);

      guild.members[oldMember.id] = newMember;
      client.users[oldMember.id] = newMember;
      client._events.onGuildMemberUpdate.add(this);
    }
  }
}
