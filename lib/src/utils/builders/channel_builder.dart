import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/guild/forum/forum_channel.dart';
import 'package:nyxx/src/core/channel/guild/voice_channel.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/unicode_emoji.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';
import 'package:nyxx/src/utils/builders/forum_thread_builder.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';

/// Builder for creating mini channel instance
abstract class ChannelBuilder implements Builder {
  /// Name of the channel (1-100 characters)
  String? name;

  /// Id of the channel.
  /// When using the `channels` parameter on [GuildBuilder], this field within each channel object may be set to an integer placeholder, and will be replaced by the API upon consumption.
  /// Its purpose is to allow you to create `GUILD_CATEGORY` channels by setting the [parentChannel.id] field on any children to the category's id field. Category channels must be listed before any children.
  Snowflake? id;

  /// Type of channel
  ChannelType? type;

  /// Sorting position of the channel
  int? position;

  /// Id of the parent category for a channel
  SnowflakeEntity? parentChannel;

  /// The channel's permission overwrites
  List<PermissionOverrideBuilder>? permissionOverrides;

  ChannelBuilder._({
    this.id,
    this.name,
    this.parentChannel,
    this.permissionOverrides,
    this.position,
    this.type,
  });

  @override
  RawApiMap build() => {
        if (name != null) "name": name,
        if (id != null) "id": id!.toString(),
        if (type != null) "type": type!.value,
        if (position != null) "position": position,
        if (parentChannel != null) "parent_id": parentChannel!.id.toString(),
        if (permissionOverrides != null) "permission_overwrites": permissionOverrides!.map((e) => e.build()).toList(),
      };
}

class VoiceChannelBuilder extends ChannelBuilder {
  /// Type of channel
  @override
  // ignore: overridden_fields
  ChannelType? type = ChannelType.voice;

  /// The bitrate (in bits) of the voice channel (voice only)
  int? bitrate;

  /// The user limit of the voice channel (voice only)
  int? userLimit;

  /// Amount of seconds a user has to wait before sending another message (0-21600);
  /// bots, as well as users with the permission manage_messages or manage_channel, are unaffected
  @Deprecated("Use TextChannelBuilder instead")
  int? rateLimitPerUser;

  /// Channel voice region id, automatic when set to null
  String? rtcRegion = "";

  VideoQualityMode? videoQualityMode;

  VoiceChannelBuilder({
    super.id,
    super.name,
    super.parentChannel,
    super.permissionOverrides,
    super.position,
    this.bitrate,
    this.rateLimitPerUser,
    this.rtcRegion,
    this.userLimit,
    this.videoQualityMode,
  }) : super._();

  @override
  RawApiMap build() => {
        ...super.build(),
        if (bitrate != null) "bitrate": bitrate,
        if (userLimit != null) "user_limit": userLimit,
        if (rateLimitPerUser != null) "rate_limit_per_user": rateLimitPerUser,
        if (rtcRegion != "") "rtc_region": rtcRegion,
        if (videoQualityMode != null) "video_quality_mode": videoQualityMode!.value,
      };
}

class TextChannelBuilder extends ChannelBuilder {
  /// Type of channel
  @override
  // ignore: overridden_fields
  ChannelType? type = ChannelType.text;

  /// Channel topic (0-1024 characters)
  String? topic;

  /// Whether the channel is nsfw
  bool? nsfw;

  @Deprecated("Use VoiceChannelBuilder instead")
  VideoQualityMode? videoQualityMode;

  int? rateLimitPerUser;

  TextChannelBuilder({
    super.id,
    super.name,
    super.parentChannel,
    super.permissionOverrides,
    super.position,
    this.nsfw,
    this.topic,
    this.rateLimitPerUser,
  }) : super._();
  factory TextChannelBuilder.create(String name) {
    final builder = TextChannelBuilder();
    builder.name = name;
    return builder;
  }

  @override
  RawApiMap build() => {
        ...super.build(),
        if (topic != null) "topic": topic,
        if (nsfw != null) "nsfw": nsfw,
        if (videoQualityMode != null) "video_quality_mode": videoQualityMode!.value,
        if (rateLimitPerUser != null) "rate_limit_per_user": rateLimitPerUser,
      };
}

class ForumChannelBuilder extends TextChannelBuilder {
  /// Type of channel
  @override
  // ignore: overridden_fields
  ChannelType? type = ChannelType.forumChannel;

  /// The default sort order type used to order posts in GUILD_FORUM channels.
  /// Defaults to null, which indicates a preferred sort order hasn't been set by a channel admin
  ForumSortOrder? defaultSortOrder;

  /// The emoji to show in the add reaction button on a thread in a GUILD_FORUM channel
  IEmoji? defaultReactionEmoji;

  /// Tags available to assign to forum posts
  List<AvailableTagBuilder>? availableTags;

  @override
  RawApiMap build() => {
        ...super.build(),
        if (defaultSortOrder != null) "default_sort_order": defaultSortOrder!.value,
        if (defaultReactionEmoji != null)
          "default_reaction_emoji": {
            if (defaultReactionEmoji is UnicodeEmoji) "emoji_name": defaultReactionEmoji!.encodeForAPI(),
            if (defaultReactionEmoji is BaseGuildEmoji) "emoji_id": (defaultReactionEmoji as BaseGuildEmoji).id
          },
        if (availableTags != null) "available_tags": availableTags!.map((e) => e.build()).toList()
      };
}
