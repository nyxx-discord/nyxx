import 'package:nyxx/src/core/DiscordColor.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/channel/Channel.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/AttachmentBuilder.dart';
import 'package:nyxx/src/utils/builders/Builder.dart';
import 'package:nyxx/src/utils/builders/PermissionsBuilder.dart';
import 'package:nyxx/src/utils/builders/ThreadBuilder.dart';

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

/// Builder for creating mini channel instance
class ChannelBuilder extends Builder {
  /// Name of channel
  String? name;

  /// Type of channel
  ChannelType? type;

  /// Channel topic (0-1024 characters)
  String? topic;

  /// The bitrate (in bits) of the voice channel (voice only)
  int? bitrate;

  /// The user limit of the voice channel (voice only)
  int? userLimit;

  /// Amount of seconds a user has to wait before sending another message (0-21600);
  /// bots, as well as users with the permission manage_messages or manage_channel, are unaffected
  int? rateLimitPerUser;

  /// Sorting position of the channel
  int? position;

  /// Id of the parent category for a channel
  SnowflakeEntity? parentChannel;

  /// The channel's permission overwrites
  List<PermissionOverrideBuilder>? overrides;

  /// Whether the channel is nsfw
  bool? nsfw;

  /// Channel voice region id, automatic when set to null
  String? rtcRegion = "";

  /// The default duration for newly created threads in the channel
  /// to automatically archive the thread after recent activity
  ThreadArchiveTime? defaultAutoArchiveDuration;

  /// Builder for editing channel
  ChannelBuilder();

  /// Builder for creating channel
  ChannelBuilder.create({required this.name, required this.type});

  @override
  RawApiMap build() => {
        if (name != null) "name": name,
        if (type != null) "type": type!.value,
        if (topic != null) "topic": topic,
        if (bitrate != null) "bitrate": bitrate,
        if (userLimit != null) "user_limit": userLimit,
        if (rateLimitPerUser != null) "rate_limit_per_user": rateLimitPerUser,
        if (position != null) "position": position,
        if (parentChannel != null) "parent_id": parentChannel!.id,
        if (nsfw != null) "nsfw": nsfw,
        if (overrides != null) "permission_overwrites": overrides!.map((e) => e.build()),
        if (rtcRegion != "") "rtc_region": rtcRegion,
      };
}
