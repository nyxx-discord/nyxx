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

  /// The role's guild.
  @override
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
    this.mentionable = raw['mentionable'] as bool;
    this.permissions = Permissions.fromInt(raw['permissions'] as int);
    this.color = DiscordColor.fromInt(raw['color'] as int);
  }

  /// Edits the role.
  Future<Role> edit(RoleBuilder role, {String? auditReason}) async {
    var response = await client._http._execute(
        JsonRequest._new("/guilds/${this.guild.id}/roles/$id", method: "PATCH", body: role._build(), auditLog: auditReason));

    if(response is HttpResponseSuccess) {
      return Role._new(response.jsonBody as Map<String, dynamic>, this.guild, client);
    }

    return Future.error(response);
  }

  /// Deletes the role.
  Future<void> delete({String? auditReason}) {
    return client._http._execute(JsonRequest._new("/guilds/${this.guild.id}/roles/$id", method: "DELETE", auditLog: auditReason));
  }

  /// Adds role to user.
  Future<void> addToUser(User user, {String? auditReason}) {
    return client._http._execute(JsonRequest._new('/guilds/${guild.id}/members/${user.id}/roles/$id', method: "PUT", auditLog: auditReason));
  }

  /// Returns a mention of role. If role cannot be mentioned it returns name of role.
  @override
  String toString() => mention;
}
