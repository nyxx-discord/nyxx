import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/channel/voice_channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

class GuildChannelUpdateBuilder extends UpdateBuilder<GuildChannel> {
  final String? name;

  final int? position;

  final List<CreateBuilder<PermissionOverwrite>>? permissionOverwrites;

  GuildChannelUpdateBuilder({this.name, this.position = sentinelInteger, this.permissionOverwrites});

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (!identical(position, sentinelInteger)) 'position': position,
        if (permissionOverwrites != null) 'permission_overwrites': permissionOverwrites!.map((e) => e.build()).toList(),
      };
}

class GuildTextChannelUpdateBuilder extends GuildChannelUpdateBuilder {
  final ChannelType? type;

  final String? topic;

  final bool? isNsfw;

  final Duration? rateLimitPerUser;

  final Snowflake? parentId;

  final Duration? defaultAutoArchiveDuration;

  final Duration? defaultThreadRateLimitPerUser;

  GuildTextChannelUpdateBuilder({
    super.name,
    super.position,
    super.permissionOverwrites,
    this.type,
    this.topic = sentinelString,
    this.isNsfw,
    this.rateLimitPerUser = sentinelDuration,
    this.parentId = sentinelSnowflake,
    this.defaultAutoArchiveDuration = sentinelDuration,
    this.defaultThreadRateLimitPerUser,
  });

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (type != null) 'type': type!.value,
        if (!identical(topic, sentinelString)) 'topic': topic,
        if (isNsfw != null) 'nsfw': isNsfw,
        if (!identical(rateLimitPerUser, sentinelDuration)) 'rate_limit_per_user': rateLimitPerUser?.inSeconds,
        if (!identical(parentId, sentinelSnowflake)) 'parent_id': parentId?.toString(),
        if (!identical(defaultAutoArchiveDuration, sentinelDuration)) 'default_auto_archive_duration': defaultAutoArchiveDuration?.inMinutes,
        if (defaultThreadRateLimitPerUser != null) 'default_thread_rate_limit_per_user': defaultThreadRateLimitPerUser!.inSeconds,
      };
}

class GuildAnnouncementChannelUpdateBuilder extends GuildChannelUpdateBuilder {
  final ChannelType? type;

  final String? topic;

  final bool? isNsfw;

  final Snowflake? parentId;

  final Duration? defaultAutoArchiveDuration;

  GuildAnnouncementChannelUpdateBuilder({
    super.name,
    super.position,
    super.permissionOverwrites,
    this.type,
    this.topic = sentinelString,
    this.isNsfw,
    this.parentId = sentinelSnowflake,
    this.defaultAutoArchiveDuration = sentinelDuration,
  });

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (type != null) 'type': type!.value,
        if (!identical(topic, sentinelString)) 'topic': topic,
        if (isNsfw != null) 'nsfw': isNsfw,
        if (!identical(parentId, sentinelSnowflake)) 'parent_id': parentId?.toString(),
        if (!identical(defaultAutoArchiveDuration, sentinelDuration)) 'default_auto_archive_duration': defaultAutoArchiveDuration?.inMinutes,
      };
}

class ForumChannelUpdateBuilder extends GuildChannelUpdateBuilder {
  final String? topic;

  final bool? isNsfw;

  final Duration? rateLimitPerUser;

  final Snowflake? parentId;

  final Duration? defaultAutoArchiveDuration;

  final Flags<ChannelFlags>? flags;

  final List<CreateBuilder<ForumTag>>? tags;

  final DefaultReaction? defaultReaction;

  final Duration? defaultThreadRateLimitPerUser;

  final ForumSort? defaultSortOrder;

  final ForumLayout? defaultLayout;

  ForumChannelUpdateBuilder({
    super.name,
    super.position,
    super.permissionOverwrites,
    this.topic,
    this.isNsfw,
    this.rateLimitPerUser = sentinelDuration,
    this.parentId = sentinelSnowflake,
    this.defaultAutoArchiveDuration = sentinelDuration,
    this.flags,
    this.tags,
    this.defaultReaction = sentinelDefaultReaction,
    this.defaultThreadRateLimitPerUser,
    this.defaultSortOrder,
    this.defaultLayout,
  });

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (topic != null) 'topic': topic,
        if (isNsfw != null) 'nsfw': isNsfw,
        if (!identical(rateLimitPerUser, sentinelDuration)) 'rate_limit_per_user': rateLimitPerUser?.inSeconds,
        if (!identical(parentId, sentinelSnowflake)) 'parent_id': parentId?.toString(),
        if (!identical(defaultAutoArchiveDuration, sentinelDuration)) 'default_auto_archive_duration': defaultAutoArchiveDuration?.inMinutes,
        if (flags != null) 'flags': flags!.value,
        if (tags != null) 'tags': tags!.map((e) => e.build()).toList(),
        if (!identical(defaultReaction, sentinelDefaultReaction))
          'default_reaction_emoji': defaultReaction == null
              ? null
              : {
                  if (defaultReaction!.emojiId != null) 'emoji_id': defaultReaction!.emojiId!.toString(),
                  if (defaultReaction!.emojiName != null) 'emoji_name': defaultReaction!.emojiName,
                },
        if (defaultThreadRateLimitPerUser != null) 'default_thread_rate_limit_per_user': defaultThreadRateLimitPerUser!.inSeconds,
        if (defaultSortOrder != null) 'default_sort_order': defaultSortOrder!.value,
        if (defaultLayout != null) 'default_forum_layout': defaultLayout!.value,
      };
}

class GuildVoiceChannelUpdateBuilder extends GuildChannelUpdateBuilder {
  final bool? isNsfw;

  final int? bitRate;

  final int? userLimit;

  final Snowflake? parentId;

  final String? rtcRegion;

  final VideoQualityMode? videoQualityMode;

  GuildVoiceChannelUpdateBuilder({
    super.name,
    super.position,
    super.permissionOverwrites,
    this.isNsfw,
    this.bitRate,
    this.userLimit,
    this.parentId = sentinelSnowflake,
    this.rtcRegion = sentinelString,
    this.videoQualityMode,
  });

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (isNsfw != null) 'nsfw': isNsfw,
        if (bitRate != null) 'bitrate': bitRate,
        if (userLimit != null) 'user_limit': userLimit,
        if (!identical(parentId, sentinelSnowflake)) 'parent_id': parentId?.toString(),
        if (!identical(rtcRegion, sentinelString)) 'rtc_region': rtcRegion,
        if (videoQualityMode != null) 'video_quality_mode': videoQualityMode!.value,
      };
}

// For now, these two are identical. This might change in the future though, so we reserve the name for the stage channel update builder.
// Also helps to avoid confusion as every other guild channel type gets its own UpdateBuilder.
typedef GuildStageChannelUpdateBuilder = GuildVoiceChannelUpdateBuilder;
