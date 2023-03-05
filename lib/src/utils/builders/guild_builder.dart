import 'package:nyxx/src/core/discord_color.dart';
import 'package:nyxx/src/core/guild/system_channel_flags.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/builder.dart';
import 'package:nyxx/src/utils/builders/channel_builder.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';

/// Allows to build guild object for creating new one or modifying existing
class GuildBuilder extends Builder {
  /// Name of Guild
  final String name;

  /// The 128x128 icon for the guild
  AttachmentBuilder? icon;

  /// Verification level
  int? verificationLevel;

  /// Default message notification level
  int? defaultMessageNotifications;

  /// Explicit content filter level
  int? explicitContentFilter;

  /// List of roles to create at guild creation.
  /// When using this parameter, the first member of the list is the `@everyone` role - So all the permissions that you give to this role will be applied to all the members of the guild.
  List<RoleBuilder>? roles;

  /// List of channel to create at guild creation
  /// When using this field, the `position` field of the channel is ignored.
  /// And none of the default channels are created.
  List<ChannelBuilder>? channels;

  /// The channel id to use for the afk channel
  /// The id provided sould be the same of a given id in [channels].
  Snowflake? afkChannelId;

  /// The afk timeout in seconds
  int? afkTimeout;

  /// The id of the system channel
  /// The id provided sould be the same of a given id in [channels].
  Snowflake? systemChannelId;

  /// The [SystemChannelFlags] to apply
  SystemChannelFlags? systemChannelFlags;

  /// Create new instance of [GuildBuilder]
  GuildBuilder(
    this.name, {
    this.afkChannelId,
    this.afkTimeout,
    this.channels,
    this.defaultMessageNotifications,
    this.explicitContentFilter,
    this.icon,
    this.roles,
    this.systemChannelFlags,
    this.systemChannelId,
    this.verificationLevel,
  });

  @override
  RawApiMap build() => <String, dynamic>{
        "name": name,
        if (icon != null) "icon": icon!.getBase64(),
        if (verificationLevel != null) "verification_level": verificationLevel,
        if (defaultMessageNotifications != null) "default_message_notifications": defaultMessageNotifications,
        if (explicitContentFilter != null) "explicit_content_filter": explicitContentFilter,
        if (roles != null) "roles": _genIterable(roles!).toList(),
        if (channels != null) "channels": _genIterable(channels!).toList(),
        if (afkChannelId != null) "afk_channel_id": afkChannelId!.toString(),
        if (afkTimeout != null) "afk_timeout": afkTimeout,
        if (systemChannelId != null) "system_channel_id": systemChannelId.toString(),
        if (systemChannelFlags != null) "system_channel_flags": systemChannelFlags!.value,
      };

  Iterable<RawApiMap> _genIterable(List<Builder> list) sync* {
    for (final e in list) {
      yield e.build();
    }
  }
}

/// Creates role
class RoleBuilder extends Builder {
  /// Name of role
  String name;

  /// When using the `roles` parameter in [GuildBuilder], this field is required. It is a [Snowflake] placeholder for the role and will be replaced by the API consumption.
  ///
  /// Its purpose is to allow overwrite a role's permission in a channel when also passing the `channels` list.
  Snowflake? id;

  /// Integer representation of hexadecimal color code
  DiscordColor? color;

  /// If this role is pinned in the user listing
  bool? hoist;

  /// Position of role
  int? position;

  /// Permission object for role
  PermissionsBuilder? permission;

  /// Whether role is mentionable
  bool? mentionable;

  /// Role icon attachment
  AttachmentBuilder? roleIcon;

  /// Role icon emoji
  String? roleIconEmoji;

  /// Creates role
  RoleBuilder(
    this.name, {
    this.color,
    this.hoist,
    this.id,
    this.mentionable,
    this.permission,
    this.position,
    this.roleIcon,
    this.roleIconEmoji,
  });

  @override
  RawApiMap build() => <String, dynamic>{
        "name": name,
        if (color != null) "color": color!.value,
        if (hoist != null) "hoist": hoist,
        if (position != null) "position": position,
        if (permission != null) "permissions": permission!.calculatePermissionValue().toString(),
        if (mentionable != null) "mentionable": mentionable,
        if (roleIcon != null) "icon": roleIcon!.getBase64(),
        if (roleIconEmoji != null) "unicode_emoji": roleIconEmoji,
        if (id != null) "id": id!.id,
      };
}
