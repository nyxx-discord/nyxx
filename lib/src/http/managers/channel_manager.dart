import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/types/announcement_thread.dart';
import 'package:nyxx/src/models/channel/types/directory.dart';
import 'package:nyxx/src/models/channel/types/dm.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/channel/types/group_dm.dart';
import 'package:nyxx/src/models/channel/types/guild_announcement.dart';
import 'package:nyxx/src/models/channel/types/guild_category.dart';
import 'package:nyxx/src/models/channel/types/guild_stage.dart';
import 'package:nyxx/src/models/channel/types/guild_text.dart';
import 'package:nyxx/src/models/channel/types/guild_voice.dart';
import 'package:nyxx/src/models/channel/types/private_thread.dart';
import 'package:nyxx/src/models/channel/types/public_thread.dart';
import 'package:nyxx/src/models/channel/voice_channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

class ChannelManager extends ReadOnlyManager<Channel> {
  ChannelManager(super.config, super.client);

  @override
  PartialChannel operator [](Snowflake id) => PartialChannel(id: id, manager: this);

  @override
  Channel parse(Map<String, Object?> raw) {
    final type = ChannelType.parse(raw['type'] as int);

    final parsers = {
      ChannelType.guildText: parseGuildTextChannel,
      ChannelType.dm: parseDmChannel,
      ChannelType.guildVoice: parseGuildVoiceChannel,
      ChannelType.groupDm: parseGroupDmChannel,
      ChannelType.guildCategory: parseGuildCategory,
      ChannelType.guildAnnouncement: parseGuildAnnouncementChannel,
      ChannelType.announcementThread: parseAnnouncementThread,
      ChannelType.publicThread: parsePublicThread,
      ChannelType.privateThread: parsePrivateThread,
      ChannelType.guildStageVoice: parseGuildStageChannel,
      ChannelType.guildDirectory: parseDirectoryChannel,
      ChannelType.guildForum: parseForumChanel,
    };

    return parsers[type]!(raw);
  }

  GuildTextChannel parseGuildTextChannel(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.guildText.value, 'Invalid type for GuildTextChannel');

    return GuildTextChannel(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      topic: raw['topic'] as String,
      defaultAutoArchiveDuration: Duration(minutes: raw['default_auto_archive_duration'] as int),
      defaultThreadRateLimitPerUser:
          maybeParse<Duration?, int>(raw['default_thread_rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: raw['position'] as int,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
    );
  }

  DmChannel parseDmChannel(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.dm.value, 'Invalid type for DmChannel');

    return DmChannel(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      recipient: client.users.parse((raw['recipients'] as List).single as Map<String, Object?>),
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
    );
  }

  GuildVoiceChannel parseGuildVoiceChannel(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.guildVoice.value, 'Invalid type for GuildVoiceChannel');

    return GuildVoiceChannel(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      bitrate: raw['bitrate'] as int,
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: raw['position'] as int,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      rtcRegion: raw['rtc_region'] as String?,
      userLimit: raw['user_limit'] == 0 ? null : raw['user_limit'] as int?,
      videoQualityMode: maybeParse(raw['video_quality_mode'], VideoQualityMode.parse) ?? VideoQualityMode.auto,
    );
  }

  GroupDmChannel parseGroupDmChannel(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.groupDm.value, 'Invalid type for GroupDmChannel');

    return GroupDmChannel(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      name: raw['name'] as String,
      recipients: parseMany(raw['recipients'] as List, client.users.parse),
      iconHash: raw['icon'] as String?,
      ownerId: Snowflake.parse(raw['owner_id'] as String),
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      isManaged: raw['managed'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
    );
  }

  GuildCategory parseGuildCategory(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.guildCategory.value, 'Invalid type for GuildCategory');

    return GuildCategory(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isNsfw: raw['nsfw'] as bool? ?? false,
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: raw['position'] as int,
    );
  }

  GuildAnnouncementChannel parseGuildAnnouncementChannel(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.guildAnnouncement.value, 'Invalid type for GuildAnnouncementChannel');

    return GuildAnnouncementChannel(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      topic: raw['topic'] as String,
      defaultAutoArchiveDuration: Duration(minutes: raw['default_auto_archive_duration'] as int),
      defaultThreadRateLimitPerUser:
          maybeParse<Duration?, int>(raw['default_thread_rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: raw['position'] as int,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
    );
  }

  AnnouncementThread parseAnnouncementThread(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.announcementThread.value, 'Invalid type for AnnouncementThread');

    return AnnouncementThread(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      appliedTags: maybeParse<List<Snowflake>, List<dynamic>>(raw['applied_tags'], (tags) => parseMany(tags, Snowflake.parse)),
      approximateMemberCount: raw['member_count'] as int,
      archiveTimestamp: DateTime.parse((raw['thread_metadata'] as Map)['archive_timestamp'] as String),
      autoArchiveDuration: Duration(minutes: (raw['thread_metadata'] as Map)['auto_archive_duration'] as int),
      createdAt: maybeParse((raw['thread_metadata'] as Map)['create_timestamp'], DateTime.parse) ?? DateTime(2022, 1, 9),
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isArchived: (raw['thread_metadata'] as Map)['archived'] as bool,
      isLocked: (raw['thread_metadata'] as Map)['locked'] as bool,
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      messageCount: raw['message_count'] as int,
      name: raw['name'] as String,
      ownerId: Snowflake.parse(raw['owner_id'] as String),
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: -1,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      totalMessagesSent: raw['total_message_sent'] as int,
    );
  }

  PublicThread parsePublicThread(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.publicThread.value, 'Invalid type for PublicThread');

    return PublicThread(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      appliedTags: maybeParse<List<Snowflake>, List<dynamic>>(raw['applied_tags'], (tags) => parseMany(tags, Snowflake.parse)),
      approximateMemberCount: raw['member_count'] as int,
      archiveTimestamp: DateTime.parse((raw['thread_metadata'] as Map)['archive_timestamp'] as String),
      autoArchiveDuration: Duration(minutes: (raw['thread_metadata'] as Map)['auto_archive_duration'] as int),
      createdAt: maybeParse((raw['thread_metadata'] as Map)['create_timestamp'], DateTime.parse) ?? DateTime(2022, 1, 9),
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isArchived: (raw['thread_metadata'] as Map)['archived'] as bool,
      isLocked: (raw['thread_metadata'] as Map)['locked'] as bool,
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      messageCount: raw['message_count'] as int,
      name: raw['name'] as String,
      ownerId: Snowflake.parse(raw['owner_id'] as String),
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: -1,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      totalMessagesSent: raw['total_message_sent'] as int,
    );
  }

  PrivateThread parsePrivateThread(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.privateThread.value, 'Invalid type for PrivateThread');

    return PrivateThread(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      isInvitable: (raw['thread_metadata'] as Map)['invitable'] as bool,
      appliedTags: maybeParse<List<Snowflake>, List<dynamic>>(raw['applied_tags'], (tags) => parseMany(tags, Snowflake.parse)),
      approximateMemberCount: raw['member_count'] as int,
      archiveTimestamp: DateTime.parse((raw['thread_metadata'] as Map)['archive_timestamp'] as String),
      autoArchiveDuration: Duration(minutes: (raw['thread_metadata'] as Map)['auto_archive_duration'] as int),
      createdAt: maybeParse((raw['thread_metadata'] as Map)['create_timestamp'], DateTime.parse) ?? DateTime(2022, 1, 9),
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isArchived: (raw['thread_metadata'] as Map)['archived'] as bool,
      isLocked: (raw['thread_metadata'] as Map)['locked'] as bool,
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      messageCount: raw['message_count'] as int,
      name: raw['name'] as String,
      ownerId: Snowflake.parse(raw['owner_id'] as String),
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: -1,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      totalMessagesSent: raw['total_message_sent'] as int,
    );
  }

  GuildStageChannel parseGuildStageChannel(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.guildStageVoice.value, 'Invalid type for GuildStageChannel');

    return GuildStageChannel(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      bitrate: raw['bitrate'] as int,
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: raw['position'] as int,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      rtcRegion: raw['rtc_region'] as String?,
      userLimit: raw['user_limit'] == 0 ? null : raw['user_limit'] as int?,
      videoQualityMode: maybeParse(raw['video_quality_mode'], VideoQualityMode.parse) ?? VideoQualityMode.auto,
    );
  }

  DirectoryChannel parseDirectoryChannel(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.guildDirectory.value, 'Invalid type for DirectoryChannel');

    return DirectoryChannel(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
    );
  }

  ForumChannel parseForumChanel(Map<String, Object?> raw) {
    assert(raw['type'] == ChannelType.guildForum.value, 'Invalid type for ForumChanel');

    return ForumChannel(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      topic: raw['topic'] as String,
      lastThreadId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      flags: ChannelFlags(raw['flags'] as int),
      availableTags: parseMany(raw['available_tags'] as List, parseForumTag),
      defaultReaction: maybeParse(raw['default_reaction_emoji'], parseDefaultReaction),
      defaultAutoArchiveDuration: Duration(minutes: raw['default_auto_archive_duration'] as int),
      defaultThreadRateLimitPerUser:
          maybeParse<Duration?, int>(raw['default_thread_rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      guildId: Snowflake.parse(raw['guild_id'] as String),
      isNsfw: raw['nsfw'] as bool? ?? false,
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites:
          maybeParse<List<PermissionOverwrite>, List<dynamic>>(raw['permission_overwrites'], (overwrites) => parseMany(overwrites, parsePermissionOverwrite)) ??
              [],
      position: raw['position'] as int,
    );
  }

  PermissionOverwrite parsePermissionOverwrite(Map<String, Object?> raw) {
    return PermissionOverwrite(
      id: Snowflake.parse(raw['id'] as String),
      type: PermissionOverwriteType.parse(raw['type'] as int),
      allow: Permissions(int.parse(raw['allow'] as String)),
      deny: Permissions(int.parse(raw['deny'] as String)),
    );
  }

  ForumTag parseForumTag(Map<String, Object?> raw) {
    return ForumTag(
      id: Snowflake.parse(raw['id'] as String),
      name: raw['name'] as String,
      isModerated: raw['moderated'] as bool,
      emojiId: maybeParse(raw['emoji_id'], Snowflake.parse),
      emojiName: raw['emoji_name'] as String?,
    );
  }

  DefaultReaction parseDefaultReaction(Map<String, Object?> raw) {
    return DefaultReaction(
      emojiId: maybeParse(raw['emoji_id'], Snowflake.parse),
      emojiName: raw['emoji_name'] as String?,
    );
  }

  @override
  Future<Channel> fetch(Snowflake id) async {
    final route = HttpRoute()..channels(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final channel = parse(response.jsonBody as Map<String, Object?>);

    cache[channel.id] = channel;
    return channel;
  }
}
