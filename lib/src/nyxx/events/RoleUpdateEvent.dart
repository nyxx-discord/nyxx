part of nyxx;

/// Sent when a role is updated.
class RoleUpdateEvent {
  /// The role prior to the update.
  Role oldRole;

  /// The role after the update.
  Role newRole;

  RoleUpdateEvent._new(Nyxx client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.oldRole = guild.roles[Snowflake(json['d']['role']['id'] as String)];
      this.newRole =
          Role._new(client, json['d']['role'] as Map<String, dynamic>, guild);
      client._events.onRoleUpdate.add(this);
    }
  }
}
