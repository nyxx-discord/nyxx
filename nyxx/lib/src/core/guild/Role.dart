part of nyxx;

/// Represents [Guild] role.
/// Interface allows basic operations on member but does not guarantee data to be valid or available
class IRole extends SnowflakeEntity {
  /// Reference to client
  final Nyxx client;

  /// Id of role's [Guild]
  final Snowflake guildId;

  IRole._new(Snowflake id, this.guildId, this.client) : super(id);

  /// Edits the role.
  Future<Role> edit(RoleBuilder role, {String? auditReason}) async {
    final response = await client._http._execute(BasicRequest._new("/guilds/${this.guildId}/roles/$id",
        method: "PATCH", body: role._build(), auditLog: auditReason));

    if (response is HttpResponseSuccess) {
      return Role._new(response.jsonBody as Map<String, dynamic>, this.guildId, client);
    }

    return Future.error(response);
  }

  /// Deletes the role.
  Future<void> delete({String? auditReason}) =>
      client._http
          ._execute(BasicRequest._new("/guilds/${this.guildId}/roles/$id", method: "DELETE", auditLog: auditReason));

  /// Adds role to user.
  Future<void> addToUser(User user, {String? auditReason}) =>
      client._http._execute(
          BasicRequest._new("/guilds/${this.guildId}/members/${user.id}/roles/$id", method: "PUT", auditLog: auditReason));
}

/// Represents a Discord guild role, which is used to assign priority, permissions, and a color to guild members
class Role extends IRole implements Mentionable, GuildEntity {
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
  late final Guild? guild;

  /// The role's permissions.
  late final Permissions permissions;

  /// Mention of role. If role cannot be mentioned it returns name of role (@name)
  @override
  String get mention => mentionable ? "<@&${this.id}>" : "@$name";

  /// Additional role data like if role is managed by integration or role is from server boosting.
  late final RoleTags? roleTags;

  Role._new(Map<String, dynamic> raw, Snowflake guildId, Nyxx client) : super._new(Snowflake(raw["id"]), guildId, client) {
    this.name = raw["name"] as String;
    this.position = raw["position"] as int;
    this.hoist = raw["hoist"] as bool;
    this.managed = raw["managed"] as bool;
    this.mentionable = raw["mentionable"] as bool? ?? false;
    this.permissions = Permissions.fromInt(raw["permissions"] as int);
    this.color = DiscordColor.fromInt(raw["color"] as int);

    if(raw["tags"] != null) {
      this.roleTags = RoleTags._new(raw["tags"] as Map<String, dynamic>);
    } else {
      this.roleTags = null;
    }

    this.guild = client.guilds[this.guildId];
  }

  /// Returns a mention of role. If role cannot be mentioned it returns name of role.
  @override
  String toString() => mention;
}

/// Additional [Role] role tags which hold optional data about role
class RoleTags {
  /// Holds [Snowflake] of bot id if role is for bot user
  late final Snowflake? botId;

  /// True if role is for server nitro boosting
  late final bool nitroRole;

  /// Holds [Snowflake] of integration if role is part of twitch/other integration
  late final Snowflake? integrationId;

  /// Returns true if role is for bot.
  bool get isBotRole => botId != null;

  RoleTags._new(Map<String, dynamic> raw) {
    this.botId = raw["bot_id"] != null ? Snowflake(raw["bot_id"]) : null;
    this.nitroRole = raw["premium_subscriber"] != null ? raw["premium_subscriber"] as bool : false;
    this.integrationId = raw["integration_id"] != null ? Snowflake(raw["integration_id"]) : null;
  }
}