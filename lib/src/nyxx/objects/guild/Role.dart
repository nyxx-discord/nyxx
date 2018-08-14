part of nyxx;

/// A role.
class Role extends SnowflakeEntity {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The role's name.
  String name;

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

  Role._new(this.client, this.raw, this.guild)
      : super(new Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.hoist = raw['hoist'] as bool;
    this.managed = raw['managed'] as bool;
    this.mentionable = raw['mentionable'] as bool;
    this.permissions = new Permissions.fromInt(raw['permissions'] as int);

    if (raw['color'] == 0)
      this.color = null;
    else
      this.color = raw['color'] as int;

    if (mentionable) this.mention = "<@&${this.id}>";
    this.guild.roles[this.id] = this;
  }

  /// Edits the role.
  Future<Role> edit(
      {RoleBuilder role,
      String auditReason: ""}) async {
    HttpResponse r = await this.client.http.send(
        'PATCH', "/guilds/${this.guild.id}/roles/$id",
        body: role._build(),
        reason: auditReason);
    return new Role._new(
        this.client, r.body.asJson() as Map<String, dynamic>, this.guild);
  }

  /// Deletes the role.
  Future<void> delete({String auditReason: ""}) async {
    await this.client.http.send('DELETE', "/guilds/${this.guild.id}/roles/$id",
        reason: auditReason);
  }

  Future<void> addToUser(User user, {String auditReason: ""}) async {
    await this.client.http.send(
        'PUT', '/guilds/${guild.id}/members/${user.id}/roles/$id',
        reason: auditReason);
  }

  /// Returns a mention of role. Empty string if role inn't mentionable
  @override
  String toString() => mentionable ? this.mention : "@$name";
}
