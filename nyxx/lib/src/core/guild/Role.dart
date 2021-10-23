import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/DiscordColor.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/permissions/Permissions.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/internal/interfaces/Mentionable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/GuildBuilder.dart';

abstract class IRole implements SnowflakeEntity, Mentionable {
  /// Reference to client
  INyxx get client;

  /// Cacheable or guild attached to this role instance
  Cacheable<Snowflake, IGuild> get guild;

  /// The role's name.
  String get name;

  /// The role's color, 0 if no color.
  DiscordColor get color;

  /// The role's position.
  int get position;

  /// If the role is pinned in the user listing.
  bool get hoist;

  /// Whether or not the role is managed by an integration.
  bool get managed;

  /// Whether or not the role is mentionable.
  bool get mentionable;

  /// The role's permissions.
  IPermissions get permissions;

  /// Additional role data like if role is managed by integration or role is from server boosting.
  IRoleTags? get roleTags;

  /// Hash of role icon
  String? get iconHash;

  /// Emoji that represents role.
  /// For now emoji data is not validated and this can be any arbitrary string
  String? get iconEmoji;

  /// Mention of role. If role cannot be mentioned it returns name of role (@name)
  @override
  String get mention => mentionable ? "<@&${this.id}>" : "@$name";

  /// Returns url to role icon
  String? iconURL({String format = "webp", int size = 128});

  /// Edits the role.
  Future<IRole> edit(RoleBuilder role, {String? auditReason});

  /// Deletes the role.
  Future<void> delete();
}

class Role extends SnowflakeEntity implements IRole {
  /// Reference to client
  @override
  final INyxx client;

  /// Cacheable or guild attached to this role instance
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The role's name.
  @override
  late final String name;

  /// The role's color, 0 if no color.
  @override
  late final DiscordColor color;

  /// The role's position.
  @override
  late final int position;

  /// If the role is pinned in the user listing.
  @override
  late final bool hoist;

  /// Whether or not the role is managed by an integration.
  @override
  late final bool managed;

  /// Whether or not the role is mentionable.
  @override
  late final bool mentionable;

  /// The role's permissions.
  @override
  late final IPermissions permissions;

  /// Additional role data like if role is managed by integration or role is from server boosting.
  @override
  late final IRoleTags? roleTags;

  /// Hash of role icon
  @override
  late final String? iconHash;

  /// Emoji that represents role.
  /// For now emoji data is not validated and this can be any arbitrary string
  @override
  late final String? iconEmoji;

  /// Mention of role. If role cannot be mentioned it returns name of role (@name)
  @override
  String get mention => mentionable ? "<@&${this.id}>" : "@$name";

  /// Creates an instance of [Role]
  Role(this.client, RawApiMap raw, Snowflake guildId) : super(Snowflake(raw["id"])) {
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
      this.roleTags = RoleTags(raw["tags"] as RawApiMap);
    } else {
      this.roleTags = null;
    }
  }

  /// Returns url to role icon
  @override
  String? iconURL({String format = "webp", int size = 128}) {
    if (this.iconHash == null) {
      return null;
    }

    return this.client.httpEndpoints.getRoleIconUrl(this.id, this.iconHash!, format, size);
  }

  /// Edits the role.
  @override
  Future<IRole> edit(RoleBuilder role, {String? auditReason}) async =>
      client.httpEndpoints.editRole(this.guild.id, this.id, role, auditReason: auditReason);

  /// Deletes the role.
  @override
  Future<void> delete() async =>
      client.httpEndpoints.deleteRole(guild.id, this.id);
}

abstract class IRoleTags {
  /// Holds [Snowflake] of bot id if role is for bot user
  Snowflake? get botId;

  /// True if role is for server nitro boosting
  bool get nitroRole;

  /// Holds [Snowflake] of integration if role is part of twitch/other integration
  Snowflake? get integrationId;

  /// Returns true if role is for bot.
  bool get isBotRole;
}

/// Additional [Role] role tags which hold optional data about role
class RoleTags implements IRoleTags {
  /// Holds [Snowflake] of bot id if role is for bot user
  @override
  late final Snowflake? botId;

  /// True if role is for server nitro boosting
  @override
  late final bool nitroRole;

  /// Holds [Snowflake] of integration if role is part of twitch/other integration
  @override
  late final Snowflake? integrationId;

  /// Returns true if role is for bot.
  @override
  bool get isBotRole => botId != null;

  /// Creates an instance of [RoleTags]
  RoleTags(RawApiMap raw) {
    this.botId = raw["bot_id"] != null ? Snowflake(raw["bot_id"]) : null;
    this.nitroRole = raw["premium_subscriber"] != null ? raw["premium_subscriber"] as bool : false;
    this.integrationId = raw["integration_id"] != null ? Snowflake(raw["integration_id"]) : null;
  }
}
