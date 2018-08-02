part of nyxx;

/// A role.
class Role {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The role's name.
  String name;

  /// The role's ID.
  Snowflake id;

  /// The role's color, null if no color.
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

  /// Mention of role
  String mention;

  /// A timestamp for when the channel was created.
  DateTime createdAt;

  Role._new(this.client, this.raw, this.guild) {
    this.id = new Snowflake(raw['id'] as String);
    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.hoist = raw['hoist'] as bool;
    this.managed = raw['managed'] as bool;
    this.mentionable = raw['mentionable'] as bool;
    this.permissions = new Permissions.fromInt(raw['permissions'] as int);
    this.createdAt = id.timestamp;

    if (raw['color'] == 0) {
      this.color = null;
    } else {
      this.color = raw['color'] as int;
    }

    if (mentionable) this.mention = "<@&${this.id}>";

    this.guild.roles[this.id.toString()] = this;
  }

  /// Edits the role.
  Future<Role> edit(
      {String name: null,
      PermissionsBuilder permissions,
      int position: null,
      int color: null,
      bool mentionable: null,
      bool hoist: null,
      String auditReason: ""}) async {
    HttpResponse r = await this.client.http.send(
        'PATCH', "/guilds/${this.guild.id}/roles/$id",
        body: {
          "name": name != null ? name : this.name,
          "permissions": permissions != null
              ? permissions._build()._build()
              : this.permissions.raw,
          "position": position != null ? position : this.position,
          "color": color != null ? color : this.color,
          "hoist": hoist != null ? hoist : this.hoist,
          "mentionable": mentionable != null ? mentionable : this.mentionable
        },
        reason: auditReason);
    return new Role._new(
        this.client, r.body.asJson() as Map<String, dynamic>, this.guild);
  }

  /// Deletes the role.
  Future<Null> delete({String auditReason: ""}) async {
    await this.client.http.send('DELETE', "/guilds/${this.guild.id}/roles/$id",
        reason: auditReason);
    return null;
  }

  Future<Null> addToUser(User user, {String auditReason: ""}) async {
    await this.client.http.send(
        'PUT', '/guilds/${guild.id}/members/${user.id}/roles/$id',
        reason: auditReason);
    return null;
  }

  /// Returns a mention of role. Empty string if role inn't mentionable
  @override
  String toString() => mentionable ? this.mention : "";
}
