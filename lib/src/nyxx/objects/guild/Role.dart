part of nyxx;

void _let<T>(T value, bool checker(T value),
    {onTrue(T value), onFalse(T value)}) {
  if (checker(value)) if (onTrue != null)
    onTrue(value);
  else if (onFalse != null) onFalse(value);
}

/// Represents a Discord guild role, which is used to assign priority, permissions, and a color to guild members
class Role extends SnowflakeEntity
    implements IMentionable, GuildEntity, Nameable {
  /// The role's name.
  String name;

  /// The role's color, 0 if no color.
  DiscordColor color;

  /// The role's position.
  int position;

  /// If the role is pinned in the user listing.
  bool hoist;

  /// Whether or not the role is managed by an integration.
  bool managed;

  /// Whether or not the role is mentionable.
  bool mentionable;

  @override

  /// The role's guild.
  Guild guild;

  /// The role's permissions.
  Permissions permissions;

  /// Returns all members which have this role assigned
  Iterable<Member> get members =>
      guild.members.values.where((m) => m.roles.contains(this));

  @override

  /// Mention of role. If role cannot be mentioned it returns name of role.
  String get mention => mentionable ? "<@&${this.id}>" : "@$name";

  Role._new(Map<String, dynamic> raw, this.guild)
      : super(Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.hoist = raw['hoist'] as bool;
    this.managed = raw['managed'] as bool;
    this.mentionable = raw['mentionable'] as bool;
    this.permissions = Permissions.fromInt(raw['permissions'] as int);

    _let<int>(raw['color'] as int, (v) => v != 0,
        onTrue: (v) => this.color = DiscordColor.fromInt(v),
        onFalse: (v) => this.color = DiscordColor.fromInt(null));

    this.guild.roles[this.id] = this;
  }

  /// Edits the role.
  Future<Role> edit({RoleBuilder role, String auditReason = ""}) async {
    HttpResponse r = await _client._http.send(
        'PATCH', "/guilds/${this.guild.id}/roles/$id",
        body: role._build(), reason: auditReason);
    return Role._new(r.body as Map<String, dynamic>, this.guild);
  }

  /// Deletes the role.
  Future<void> delete({String auditReason = ""}) async {
    await _client._http.send('DELETE', "/guilds/${this.guild.id}/roles/$id",
        reason: auditReason);
  }

  /// Adds role to user.
  Future<void> addToUser(User user, {String auditReason = ""}) async {
    await _client._http.send(
        'PUT', '/guilds/${guild.id}/members/${user.id}/roles/$id',
        reason: auditReason);
  }

  /// Returns a mention of role. If role cannot be mentioned it returns name of role.
  @override
  String toString() => mention;

  @override
  String get nameString =>
      "Role ${this.name} [${this.guild.name}] [${this.id}]";
}
