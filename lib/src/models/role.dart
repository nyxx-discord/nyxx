import 'package:nyxx/src/builders/role.dart';
import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/role_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A partial [Role].
class PartialRole extends WritableSnowflakeEntity<Role> {
  @override
  final RoleManager manager;

  /// Create a new [PartialRole].
  /// @nodoc
  PartialRole({required super.id, required this.manager});

  /// Update this role, returning the updated role.
  ///
  /// External references:
  /// * [RoleManager.update]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/guild#modify-guild-role
  @override
  Future<Role> update(RoleUpdateBuilder builder, {String? auditLogReason}) => manager.update(id, builder, auditLogReason: auditLogReason);

  /// Delete this role.
  ///
  /// External references:
  /// * [RoleManager.delete]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/guild#delete-guild-role
  @override
  Future<void> delete({String? auditLogReason}) => manager.delete(id, auditLogReason: auditLogReason);
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

  /// This role's flags.
  final RoleFlags flags;

  /// {@macro role}
  /// @nodoc
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
    required this.flags,
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

  /// Whether this is the guild's Booster role.
  final bool isPremiumSubscriber;

  /// The ID of this role's subscription sku and listing.
  final Snowflake? subscriptionListingId;

  /// Whether this role is available for purchase.
  final bool isAvailableForPurchase;

  /// Whether this role is a guild's linked role
  final bool isLinkedRole;

  /// {@macro role_tags}
  /// @nodoc
  RoleTags({
    required this.botId,
    required this.integrationId,
    required this.isPremiumSubscriber,
    required this.subscriptionListingId,
    required this.isAvailableForPurchase,
    required this.isLinkedRole,
  });
}

/// The flags for a [Role].
class RoleFlags extends Flags<RoleFlags> {
  /// Whether the role is in an [Onboarding] prompt.
  static const inPrompt = Flag<RoleFlags>.fromOffset(0);

  /// Whether this set of flags has the [inPrompt] flag set.
  bool get isInPrompt => has(inPrompt);

  /// Create a new [RoleFlags].
  const RoleFlags(super.value);
}
