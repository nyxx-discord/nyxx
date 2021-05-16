part of nyxx;

class Role extends SnowflakeEntity implements Mentionable {
  /// Reference to client
  final INyxx client;

  /// Cachealble or guild attached to this role instance
  late final Cacheable<Snowflake, Guild> guild;

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

  /// The role's permissions.
  late final Permissions permissions;

  /// Mention of role. If role cannot be mentioned it returns name of role (@name)
  @override
  String get mention => mentionable ? "<@&${this.id}>" : "@$name";

  /// Additional role data like if role is managed by integration or role is from server boosting.
  late final RoleTags? roleTags;

  Role._new(this.client, Map<String, dynamic> raw, Snowflake guildId) : super(Snowflake(raw["id"])) {
    this.name = raw["name"] as String;
    this.position = raw["position"] as int;
    this.hoist = raw["hoist"] as bool;
    this.managed = raw["managed"] as bool;
    this.mentionable = raw["mentionable"] as bool? ?? false;
    this.permissions = Permissions.fromInt(int.parse(raw["permissions"] as String));
    this.color = DiscordColor.fromInt(raw["color"] as int);
    this.guild = _GuildCacheable(client, guildId);

    if (raw["tags"] != null) {
      this.roleTags = RoleTags._new(raw["tags"] as Map<String, dynamic>);
    } else {
      this.roleTags = null;
    }
  }

  /// Edits the role.
  Future<Role> edit(RoleBuilder role, {String? auditReason}) async =>
      client._httpEndpoints.editRole(this.guild.id, this.id, role, auditReason: auditReason);

  /// Deletes the role.
  Future<void> delete() async => client._httpEndpoints.deleteRole(guild.id, this.id);
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
