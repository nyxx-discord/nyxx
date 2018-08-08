part of nyxx;

/// Sent when a role is deleted.
class RoleDeleteEvent {
  /// The role that was deleted.
  Role role;

  RoleDeleteEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
          client.guilds[new Snowflake(json['d']['guild_id'] as String)];
      this.role = guild.roles[new Snowflake(json['d']['role_id'] as String)];
      guild.roles.remove(role.id);
      client._events.onRoleDelete.add(this);
    }
  }
}
