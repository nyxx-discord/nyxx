part of nyxx;

/// Sent when a role is updated.
class RoleUpdateEvent {
  /// The role prior to the update.
  Role oldRole;

  /// The role after the update.
  Role newRole;

  RoleUpdateEvent._new(Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.oldRole = guild.roles[Snowflake(json['d']['role']['id'] as String)];
      this.newRole =
          Role._new(json['d']['role'] as Map<String, dynamic>, guild);

      oldRole.guild.roles[oldRole.id] = newRole;
      client._events.onRoleUpdate.add(this);
    }
  }
}
