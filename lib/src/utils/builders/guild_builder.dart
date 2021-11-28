import 'package:nyxx/src/core/discord_color.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/builder.dart';
import 'package:nyxx/src/utils/builders/channel_builder.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';

/// Allows to build guild object for creating new one or modifying existing
class GuildBuilder extends Builder {
  /// Name of Guild
  String? name;

  /// Voice region id
  String? region;

  /// Base64 encoded 128x128 image
  String? icon;

  /// Verification level
  int? verificationLevel;

  /// Default message notification level
  int? defaultMessageNotifications;

  /// Explicit content filter level
  int? explicitContentFilter;

  /// List of roles to create at guild creation
  List<RoleBuilder>? roles;

  /// List of channel to create at guild creation
  List<ChannelBuilder>? channels;

  @override
  RawApiMap build() => <String, dynamic>{
        if (name != null) "name": name,
        if (region != null) "region": region,
        if (icon != null) "icon": icon,
        if (verificationLevel != null) "verification_level": verificationLevel,
        if (defaultMessageNotifications != null) "default_message_notifications": defaultMessageNotifications,
        if (explicitContentFilter != null) "explicit_content_filter": explicitContentFilter,
        if (roles != null) "roles": _genIterable(roles!),
        if (channels != null) "channels": _genIterable(channels!)
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

  /// ole icon attachment
  AttachmentBuilder? roleIcon;

  /// Role icon emoji
  String? roleIconEmoji;

  /// Creates role
  RoleBuilder(this.name);

  @override
  RawApiMap build() => <String, dynamic>{
        "name": name,
        if (color != null) "color": color!.value,
        if (hoist != null) "hoist": hoist,
        if (position != null) "position": position,
        if (permission != null) "permission": permission!.build().build(),
        if (mentionable != null) "mentionable": mentionable,
        if (roleIcon != null) "icon": roleIcon!.getBase64(),
        if (roleIconEmoji != null) "unicode_emoji": roleIconEmoji
      };
}
