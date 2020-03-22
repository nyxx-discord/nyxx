part of nyxx;

/// Represents a Discord guild role, which is used to assign priority, permissions, and a color to guild members
class Role extends SnowflakeEntity implements Mentionable, GuildEntity {
  /// The role's name.
  late final String name;

  /// The role's color, 0 if no color.
  late final DiscordColor color;

  /// The role's position.
  late final int position;

  /// If the role is pinned in the user listing.
  late final bool hoist;

  /// Whether or not the role is managed by an integration.
  late final bool managed;

  /// Whether or not the role is mentionable.
  late final bool mentionable;

  @override

  /// The role's guild.
  late final Guild guild;

  /// The role's permissions.
  late final Permissions permissions;

  /// Returns all members which have this role assigned
  Iterable<Member> get members =>
      guild.members.find((m) => m.roles.contains(this));

  @override

  /// Mention of role. If role cannot be mentioned it returns name of role (@name)
  String get mention => mentionable ? "<@&${this.id}>" : "@$name";

  Nyxx client;

  Role._new(Map<String, dynamic> raw, this.guild, this.client)
      : super(Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.hoist = raw['hoist'] as bool;
    this.managed = raw['managed'] as bool;
    this.mentionable = raw['mentionable'] as bool ?? false;
    this.permissions = Permissions.fromInt(raw['permissions'] as int);
    this.color = DiscordColor.fromInt(raw['color'] as int);
  }

  /// Edits the role.
  Future<Role> edit(RoleBuilder role, {String auditReason = ""}) async {
    HttpResponse r = await client._http.send(
        'PATCH', "/guilds/${this.guild.id}/roles/$id",
        body: role._build(), reason: auditReason);
    return Role._new(r.body as Map<String, dynamic>, this.guild, client);
  }

  /// Deletes the role.
  Future<void> delete({String auditReason = ""}) {
    return client._http.send('DELETE', "/guilds/${this.guild.id}/roles/$id",
        reason: auditReason);
  }

  /// Adds role to user.
  Future<void> addToUser(User user, {String auditReason = ""}) {
    return client._http.send(
        'PUT', '/guilds/${guild.id}/members/${user.id}/roles/$id',
        reason: auditReason);
  }

  /// Returns a mention of role. If role cannot be mentioned it returns name of role.
  @override
  String toString() => mention;
}
