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

      if(oldMember != null && guild != null) {
        this.newMember = oldMember;

        if(oldMember.nickname != json['d']['nick'])
          newMember.nickname = json['d']['nick'] as String;

        var tmpRoles = (json['d']['roles'].cast<String>() as List<String>).map((r) => guild.roles[Snowflake(r)]).toList();
        if(oldMember.roles != tmpRoles)
          newMember.roles = tmpRoles;

        guild.members[oldMember.id] = newMember;
        client.users[oldMember.id] = newMember;
      }

      client._events.onGuildMemberUpdate.add(this);
    }
  }
}
