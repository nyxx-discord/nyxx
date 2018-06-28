part of nyxx;

/// Sent when a role is deleted.
class RoleDeleteEvent {
  /// The role that was deleted.
  Role role;

  RoleDeleteEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[json['d']['guild_id']];
      this.role = guild.roles[json['d']['role_id']];
      guild.roles.remove(role.id);
      client._events.onRoleDelete.add(this);
    }
  }
}
