part of nyxx;

class Role extends SnowflakeEntity implements Mentionable {
  /// Reference to client
  final INyxx client;

  /// Cacheable or guild attached to this role instance
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

  /// Additional role data like if role is managed by integration or role is from server boosting.
  late final RoleTags? roleTags;

  /// Hash of role icon
  late final String? iconHash;

  /// Emoji that represents role.
  /// For now emoji data is not validated and this can be any arbitrary string
  late final String? iconEmoji;

  /// Mention of role. If role cannot be mentioned it returns name of role (@name)
  @override
  String get mention => mentionable ? "<@&${this.id}>" : "@$name";

  Role._new(this.client, RawApiMap raw, Snowflake guildId) : super(Snowflake(raw["id"])) {
    this.name = raw["name"] as String;
    this.position = raw["position"] as int;
    this.hoist = raw["hoist"] as bool;
    this.managed = raw["managed"] as bool;
    this.mentionable = raw["mentionable"] as bool? ?? false;
    this.permissions = Permissions(int.parse(raw["permissions"] as String));
    this.color = DiscordColor.fromInt(raw["color"] as int);
    this.guild = GuildCacheable(client, guildId);
    this.iconEmoji = raw["unicode_emoji"] as String?;
    this.iconHash = raw["icon"] as String?;

    if(raw["tags"] != null) {
      this.roleTags = RoleTags._new(raw["tags"] as RawApiMap);
    } else {
      this.roleTags = null;
    }
  }

  /// Returns url to role icon
  String? iconURL({String format = "webp", int size = 128}) {
    if (this.iconHash == null) {
      return null;
    }

    return this.client.httpEndpoints.getRoleIconUrl(this.id, this.iconHash!, format, size);
  }

  /// Edits the role.
  Future<Role> edit(RoleBuilder role, {String? auditReason}) async =>
      client.httpEndpoints.editRole(this.guild.id, this.id, role, auditReason: auditReason);

  /// Deletes the role.
  Future<void> delete() async =>
      client.httpEndpoints.deleteRole(guild.id, this.id);
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

  RoleTags._new(RawApiMap raw) {
    this.botId = raw["bot_id"] != null ? Snowflake(raw["bot_id"]) : null;
    this.nitroRole = raw["premium_subscriber"] != null ? raw["premium_subscriber"] as bool : false;
    this.integrationId = raw["integration_id"] != null ? Snowflake(raw["integration_id"]) : null;
  }
}
