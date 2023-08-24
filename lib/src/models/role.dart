import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/role_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A partial [Role].
class PartialRole extends WritableSnowflakeEntity<Role> {
  @override
  final RoleManager manager;

  /// Create a new [PartialRole].
  PartialRole({required super.id, required this.manager});
}

/// {@template role}
/// A role in a [Guild].
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/topics/permissions#role-object
/// {@endtemplate}
class Role extends PartialRole implements CommandOptionMentionable<Role> {
  /// The name of this role.
  final String name;

  /// The color of this role.
  ///
  /// If the value of this color is `0`, this role does not have a visible color.
  final DiscordColor color;

  /// Whether this role is displayed separately from others in the member list.
  final bool isHoisted;

  /// The hash string of this role's icon.
  final String? iconHash;

  /// The unicode emoji for this role.
  final String? unicodeEmoji;

  /// The position of this role.
  final int position;

  /// The permissions granted to this role at a guild level.
  final Permissions permissions;

  /// Whether this role is mentionable.
  final bool isMentionable;

  /// The tags associated with this role.
  final RoleTags? tags;

  /// {@macro role}
  Role({
    required super.id,
    required super.manager,
    required this.name,
    required this.color,
    required this.isHoisted,
    required this.iconHash,
    required this.unicodeEmoji,
    required this.position,
    required this.permissions,
    required this.isMentionable,
    required this.tags,
  });

  /// This role's icon.
  CdnAsset? get icon => iconHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..roleIcons(id: id.toString()),
          hash: iconHash!,
        );
}

/// {@template role_tags}
/// Additional metadata associated with a role.
/// {@endtemplate}
class RoleTags with ToStringHelper {
  /// The ID of the bot this role belongs to.
  final Snowflake? botId;

  /// The ID of the integration this role belongs to.
  final Snowflake? integrationId;

  /// The ID of this role's subscription sku and listing.
  final Snowflake? subscriptionListingId;

  /// {@macro role_tags}
  RoleTags({
    required this.botId,
    required this.integrationId,
    required this.subscriptionListingId,
  });
}
