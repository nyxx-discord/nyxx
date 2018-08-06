part of nyxx;

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member prior to the update.
  Member oldMember;

  /// The member after the update.
  Member newMember;

  GuildMemberUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[new Snowflake(json['d']['guild_id'] as String)];
      this.oldMember = guild.members[new Snowflake(json['d']['user']['id'] as String)];
      this.newMember =
          new Member._new(client, json['d'] as Map<String, dynamic>, guild);
      client._events.onGuildMemberUpdate.add(this);
    }
  }
}
