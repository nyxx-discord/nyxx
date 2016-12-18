part of discord;

/// Sent when a role is updated.
class RoleUpdateEvent {
  /// The role prior to the update.
  Role oldRole;

  /// The role after the update.
  Role newRole;

  RoleUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[json['d']['guild_id']];
      this.oldRole = guild.roles[json['d']['role']['id']];
      this.newRole = new Role._new(
          client, json['d']['role'] as Map<String, dynamic>, guild);
      client._events.onRoleUpdate.add(this);
    }
  }
}
