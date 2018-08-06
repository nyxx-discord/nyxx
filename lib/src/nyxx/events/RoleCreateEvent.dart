part of nyxx;

/// Sent when a role is created.
class RoleCreateEvent {
  /// The role that was created.
  Role role;

  RoleCreateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[new Snowflake(json['d']['guild_id'] as String)];
      this.role = new Role._new(
          client, json['d']['role'] as Map<String, dynamic>, guild);
      client._events.onRoleCreate.add(this);
    }
  }
}
