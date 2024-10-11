import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/guild_channel.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/channel/types/guild_announcement.dart';
import 'package:nyxx/src/models/channel/types/guild_category.dart';
import 'package:nyxx/src/models/channel/types/guild_stage.dart';
import 'package:nyxx/src/models/channel/types/guild_text.dart';
import 'package:nyxx/src/models/channel/types/guild_voice.dart';
import 'package:nyxx/src/models/channel/voice_channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/building_helpers.dart';
import 'package:nyxx/src/utils/flags.dart';

class GuildChannelBuilder<T extends GuildChannel> extends CreateBuilder<T> {
  String name;

  ChannelType type;

  int? position;

  List<CreateBuilder<PermissionOverwrite>>? permissionOverwrites;

  GuildChannelBuilder({
    required this.name,
    required this.type,
    this.position,
    this.permissionOverwrites,
  });

  @override
  Map<String, Object?> build() => {
        'name': name,
        'type': type.value,
        if (position != null) 'position': position,
        if (permissionOverwrites != null) 'permission_overwrites': permissionOverwrites!.map((e) => e.build()).toList(),
      };
}

class GuildChannelUpdateBuilder<T extends GuildChannel> extends UpdateBuilder<T> {
  String? name;

  int? position;

  List<CreateBuilder<PermissionOverwrite>>? permissionOverwrites;

  GuildChannelUpdateBuilder({this.name, this.position = sentinelInteger, this.permissionOverwrites});

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (!identical(position, sentinelInteger)) 'position': position,
        if (permissionOverwrites != null) 'permission_overwrites': permissionOverwrites!.map((e) => e.build()).toList(),
      };
}

class GuildTextChannelBuilder extends GuildChannelBuilder<GuildTextChannel> {
  String? topic;

  Duration? rateLimitPerUser;

  Snowflake? parentId;

  bool? isNsfw;

  Duration? defaultAutoArchiveDuration;

  GuildTextChannelBuilder({
    required super.name,
    super.position,
    super.permissionOverwrites,
    this.topic,
    this.rateLimitPerUser,
    this.parentId,
    this.isNsfw,
    this.defaultAutoArchiveDuration,
  }) : super(type: ChannelType.guildText);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (topic != null) 'topic': topic,
        if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser!.inSeconds,
        if (parentId != null) 'parent_id': parentId!.toString(),
        if (isNsfw != null) 'nsfw': isNsfw,
        if (defaultAutoArchiveDuration != null) 'default_auto_archive_duration': defaultAutoArchiveDuration!.inMinutes,
      };
}

class GuildTextChannelUpdateBuilder extends GuildChannelUpdateBuilder<GuildTextChannel> {
  ChannelType? type;

  String? topic;

  bool? isNsfw;

  Duration? rateLimitPerUser;

  Snowflake? parentId;

  Duration? defaultAutoArchiveDuration;

  Duration? defaultThreadRateLimitPerUser;

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

class GuildAnnouncementChannelBuilder extends GuildChannelBuilder<GuildAnnouncementChannel> {
  String? topic;

  Snowflake? parentId;

  bool? isNsfw;

  Duration? defaultAutoArchiveDuration;

  GuildAnnouncementChannelBuilder({
    required super.name,
    super.position,
    super.permissionOverwrites,
    this.topic,
    this.parentId,
    this.isNsfw,
    this.defaultAutoArchiveDuration,
  }) : super(type: ChannelType.guildAnnouncement);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (topic != null) 'topic': topic,
        if (parentId != null) 'parent_id': parentId!.toString(),
        if (isNsfw != null) 'nsfw': isNsfw,
        if (defaultAutoArchiveDuration != null) 'default_auto_archive_duration': defaultAutoArchiveDuration!.inMinutes,
      };
}

class GuildAnnouncementChannelUpdateBuilder extends GuildChannelUpdateBuilder<GuildAnnouncementChannel> {
  ChannelType? type;

  String? topic;

  bool? isNsfw;

  Snowflake? parentId;

  Duration? defaultAutoArchiveDuration;

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

class ForumChannelBuilder extends GuildChannelBuilder<ForumChannel> {
  String? topic;

  Duration? rateLimitPerUser;

  Snowflake? parentId;

  bool? isNsfw;

  Duration? defaultAutoArchiveDuration;

  DefaultReaction? defaultReaction;

  List<CreateBuilder<ForumTag>>? tags;

  ForumSort? defaultSortOrder;

  ForumChannelBuilder({
    required super.name,
    super.position,
    super.permissionOverwrites,
    this.topic,
    this.rateLimitPerUser,
    this.parentId,
    this.isNsfw,
    this.defaultAutoArchiveDuration,
    this.defaultReaction,
    this.tags,
    this.defaultSortOrder,
  }) : super(type: ChannelType.guildForum);

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (topic != null) 'topic': topic,
        if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser!.inSeconds,
        if (parentId != null) 'parent_id': parentId!.toString(),
        if (isNsfw != null) 'nsfw': isNsfw,
        if (defaultAutoArchiveDuration != null) 'default_auto_archive_duration': defaultAutoArchiveDuration!.inMinutes,
        if (!identical(defaultReaction, sentinelDefaultReaction))
          'default_reaction_emoji': defaultReaction == null ? null : makeEmojiMap(emojiId: defaultReaction!.emojiId, emojiName: defaultReaction!.emojiName),
        if (tags != null) 'available_tags': tags!.map((e) => e.build()).toList(),
        if (defaultSortOrder != null) 'default_sort_order': defaultSortOrder!.value,
      };
}

class ForumChannelUpdateBuilder extends GuildChannelUpdateBuilder<ForumChannel> {
  String? topic;

  bool? isNsfw;

  Duration? rateLimitPerUser;

  Snowflake? parentId;

  Duration? defaultAutoArchiveDuration;

  Flags<ChannelFlags>? flags;

  List<CreateBuilder<ForumTag>>? tags;

  DefaultReaction? defaultReaction;

  Duration? defaultThreadRateLimitPerUser;

  ForumSort? defaultSortOrder;

  ForumLayout? defaultLayout;

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
        if (tags != null) 'available_tags': tags!.map((e) => e.build()).toList(),
        if (!identical(defaultReaction, sentinelDefaultReaction))
          'default_reaction_emoji': defaultReaction == null ? null : makeEmojiMap(emojiId: defaultReaction!.emojiId, emojiName: defaultReaction!.emojiName),
        if (defaultThreadRateLimitPerUser != null) 'default_thread_rate_limit_per_user': defaultThreadRateLimitPerUser!.inSeconds,
        if (defaultSortOrder != null) 'default_sort_order': defaultSortOrder!.value,
        if (defaultLayout != null) 'default_forum_layout': defaultLayout!.value,
      };
}

abstract class _GuildVoiceOrStageChannelBuilder<T extends GuildChannel> extends GuildChannelBuilder<T> {
  int? bitRate;

  int? userLimit;

  Snowflake? parentId;

  bool? isNsfw;

  String? rtcRegion;

  VideoQualityMode? videoQualityMode;

  _GuildVoiceOrStageChannelBuilder({
    required super.name,
    required super.type,
    super.position,
    super.permissionOverwrites,
    this.bitRate,
    this.userLimit,
    this.parentId,
    this.isNsfw,
    this.rtcRegion,
    this.videoQualityMode,
  });

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (isNsfw != null) 'nsfw': isNsfw,
        if (bitRate != null) 'bitrate': bitRate,
        if (userLimit != null) 'user_limit': userLimit,
        if (parentId != null) 'parent_id': parentId?.toString(),
        if (rtcRegion != null) 'rtc_region': rtcRegion,
        if (videoQualityMode != null) 'video_quality_mode': videoQualityMode!.value,
      };
}

class GuildVoiceChannelBuilder extends _GuildVoiceOrStageChannelBuilder<GuildVoiceChannel> {
  GuildVoiceChannelBuilder({
    required super.name,
    super.position,
    super.permissionOverwrites,
    super.bitRate,
    super.userLimit,
    super.parentId,
    super.isNsfw,
    super.rtcRegion,
    super.videoQualityMode,
  }) : super(type: ChannelType.guildVoice);
}

class GuildStageChannelBuilder extends _GuildVoiceOrStageChannelBuilder<GuildStageChannel> {
  GuildStageChannelBuilder({
    required super.name,
    super.position,
    super.permissionOverwrites,
    super.bitRate,
    super.userLimit,
    super.parentId,
    super.isNsfw,
    super.rtcRegion,
    super.videoQualityMode,
  }) : super(type: ChannelType.guildStageVoice);
}

class _GuildVoiceOrStageChannelUpdateBuilder<T extends GuildChannel> extends GuildChannelUpdateBuilder<T> {
  bool? isNsfw;

  int? bitRate;

  int? userLimit;

  Snowflake? parentId;

  String? rtcRegion;

  VideoQualityMode? videoQualityMode;

  _GuildVoiceOrStageChannelUpdateBuilder({
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

class GuildVoiceChannelUpdateBuilder extends _GuildVoiceOrStageChannelUpdateBuilder<GuildVoiceChannel> {
  GuildVoiceChannelUpdateBuilder({
    super.name,
    super.position,
    super.permissionOverwrites,
    super.isNsfw,
    super.bitRate,
    super.userLimit,
    super.parentId = sentinelSnowflake,
    super.rtcRegion = sentinelString,
    super.videoQualityMode,
  });
}

class GuildStageChannelUpdateBuilder extends _GuildVoiceOrStageChannelUpdateBuilder<GuildStageChannel> {
  GuildStageChannelUpdateBuilder({
    super.name,
    super.position,
    super.permissionOverwrites,
    super.isNsfw,
    super.bitRate,
    super.userLimit,
    super.parentId = sentinelSnowflake,
    super.rtcRegion = sentinelString,
    super.videoQualityMode,
  });
}

class GuildCategoryBuilder extends GuildChannelBuilder<GuildCategory> {
  GuildCategoryBuilder({
    required super.name,
    super.position,
    super.permissionOverwrites,
  }) : super(type: ChannelType.guildCategory);
}

class GuildCategoryUpdateBuilder extends GuildChannelUpdateBuilder<GuildCategory> {
  GuildCategoryUpdateBuilder({super.name, super.position, super.permissionOverwrites});
}
