part of nyxx;

/// Represents a Discord guild role, which is used to assign priority, permissions, and a color to guild members
class Role extends SnowflakeEntity {
  /// The [Nyxx] object.
  Nyxx client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The role's name.
  String name;

  /// The role's color, 0 if no color.
  int color;

  /// The role's position.
  int position;

  /// If the role is pinned in the user listing.
  bool hoist;

  /// Whether or not the role is managed by an integration.
  bool managed;

  /// Whether or not the role is mentionable.
  bool mentionable;

  /// The role's guild.
  Guild guild;

  /// The role's permissions.
  Permissions permissions;

  /// Mention of role. If role cannot be mentioned it returns name of role.
  String get mention => mentionable ? "<@&${this.id}>" : name;

  Role._new(this.client, this.raw, this.guild)
      : super(Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.hoist = raw['hoist'] as bool;
    this.managed = raw['managed'] as bool;
    this.mentionable = raw['mentionable'] as bool;
    this.permissions = Permissions.fromInt(raw['permissions'] as int);
    this.color = raw['color'] as int ?? 0;

    this.guild.roles[this.id] = this;
  }

  /// Edits the role.
  Future<Role> edit({RoleBuilder role, String auditReason = ""}) async {
    HttpResponse r = await this.client.http.send(
        'PATCH', "/guilds/${this.guild.id}/roles/$id",
        body: role._build(), reason: auditReason);
    return Role._new(this.client, r.body as Map<String, dynamic>, this.guild);
  }

  /// Deletes the role.
  Future<void> delete({String auditReason = ""}) async {
    await this.client.http.send('DELETE', "/guilds/${this.guild.id}/roles/$id",
        reason: auditReason);
  }

  /// Adds role to user.
  Future<void> addToUser(User user, {String auditReason = ""}) async {
    await this.client.http.send(
        'PUT', '/guilds/${guild.id}/members/${user.id}/roles/$id',
        reason: auditReason);
  }

  /// Returns a mention of role. If role cannot be mentioned it returns name of role.
  @override
  String toString() => mention;
}
