part of nyxx;

/// Sent when a role is created.
class RoleCreateEvent {
  /// The role that was created.
  Role role;

  RoleCreateEvent._new( Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.role =
          Role._new(json['d']['role'] as Map<String, dynamic>, guild);

      guild.roles[role.id] = role;
      client._events.onRoleCreate.add(this);
    }
  }
}
