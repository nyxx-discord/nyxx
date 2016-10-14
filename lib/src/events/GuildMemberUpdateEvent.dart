part of discord;

/// Sent when a member is updated.
class GuildMemberUpdateEvent {
  /// The member prior to the update.
  Member oldMember;

  /// The member after the update.
  Member newMember;

  GuildMemberUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[json['d']['guild_id']];
      this.oldMember = guild.members[json['d']['user']['id']];
      this.newMember =
          new Member._new(client, json['d'] as Map<String, dynamic>, guild);
      client._events.onGuildMemberUpdate.add(this);
    }
  }
}
