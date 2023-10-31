import 'dart:convert';

import 'package:http/http.dart' show MultipartFile;
import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/channel/stage_instance.dart';
import 'package:nyxx/src/builders/channel/thread.dart';
import 'package:nyxx/src/builders/invite.dart';
import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/followed_channel.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/channel/types/announcement_thread.dart';
import 'package:nyxx/src/models/channel/types/directory.dart';
import 'package:nyxx/src/models/channel/types/dm.dart';
import 'package:nyxx/src/models/channel/types/forum.dart';
import 'package:nyxx/src/models/channel/types/group_dm.dart';
import 'package:nyxx/src/models/channel/types/guild_announcement.dart';
import 'package:nyxx/src/models/channel/types/guild_category.dart';
import 'package:nyxx/src/models/channel/types/guild_media.dart';
import 'package:nyxx/src/models/channel/types/guild_stage.dart';
import 'package:nyxx/src/models/channel/types/guild_text.dart';
import 'package:nyxx/src/models/channel/types/guild_voice.dart';
import 'package:nyxx/src/models/channel/types/private_thread.dart';
import 'package:nyxx/src/models/channel/types/public_thread.dart';
import 'package:nyxx/src/models/channel/voice_channel.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A manager for [Channel]s.
class ChannelManager extends ReadOnlyManager<Channel> {
  final Cache<StageInstance> stageInstanceCache;

  /// Create a new [ChannelManager].
  ChannelManager(super.config, super.client, {required CacheConfig<StageInstance> stageInstanceConfig})
      : stageInstanceCache = Cache(client, 'channels.stageInstances', stageInstanceConfig),
        super(identifier: 'channels');

  /// Return a partial instance of the entity with ID [id] containing no data.
  ///
  /// This allows performing API operations without fetching an instance from the API.
  ///
  /// Because this method doesn't perform any API checks, there might be no real entity with the
  /// correct [id]. In this case, the object returned may not work with the API correctly.
  ///
  /// While this method's return type is [PartialChannel], a [PartialTextChannel] is always returned.
  /// If you are sure the channel you are requesting is a text channel, the returned value can safely
  /// be cast to a [PartialTextChannel] to access the channel's messages.
  @override
  PartialChannel operator [](Snowflake id) => PartialTextChannel(id: id, manager: this);

  @override
  Channel parse(Map<String, Object?> raw, {Snowflake? guildId}) {
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
      ChannelType.guildForum: parseForumChannel,
      ChannelType.guildMedia: parseGuildMediaChannel,
    };

    return parsers[type]!(raw, guildId: guildId);
  }

  GuildTextChannel parseGuildTextChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.guildText.value, 'Invalid type for GuildTextChannel');

    return GuildTextChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      topic: raw['topic'] as String?,
      // Discord doesn't seem to include this field if the default 3 day expiration is used (3 days = 4320 minutes)
      defaultAutoArchiveDuration: Duration(minutes: raw['default_auto_archive_duration'] as int? ?? 4320),
      defaultThreadRateLimitPerUser:
          maybeParse<Duration?, int>(raw['default_thread_rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: raw['position'] as int,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
    );
  }

  DmChannel parseDmChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.dm.value, 'Invalid type for DmChannel');

    return DmChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      recipient: client.users.parse((raw['recipients'] as List).single as Map<String, Object?>),
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
    );
  }

  GuildVoiceChannel parseGuildVoiceChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.guildVoice.value, 'Invalid type for GuildVoiceChannel');

    return GuildVoiceChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      bitrate: raw['bitrate'] as int,
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: raw['position'] as int,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      rtcRegion: raw['rtc_region'] as String?,
      userLimit: raw['user_limit'] == 0 ? null : raw['user_limit'] as int?,
      videoQualityMode: maybeParse(raw['video_quality_mode'], VideoQualityMode.parse) ?? VideoQualityMode.auto,
    );
  }

  GroupDmChannel parseGroupDmChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.groupDm.value, 'Invalid type for GroupDmChannel');

    return GroupDmChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      name: raw['name'] as String,
      recipients: parseMany(raw['recipients'] as List, client.users.parse),
      iconHash: raw['icon'] as String?,
      ownerId: Snowflake.parse(raw['owner_id']!),
      applicationId: maybeParse(raw['application_id'], Snowflake.parse),
      isManaged: raw['managed'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
    );
  }

  GuildCategory parseGuildCategory(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.guildCategory.value, 'Invalid type for GuildCategory');

    return GuildCategory(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isNsfw: raw['nsfw'] as bool? ?? false,
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: raw['position'] as int,
    );
  }

  GuildAnnouncementChannel parseGuildAnnouncementChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.guildAnnouncement.value, 'Invalid type for GuildAnnouncementChannel');

    return GuildAnnouncementChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      topic: raw['topic'] as String?,
      // Discord doesn't seem to include this field if the default 3 day expiration is used (3 days = 4320 minutes)
      defaultAutoArchiveDuration: Duration(minutes: raw['default_auto_archive_duration'] as int? ?? 4320),
      defaultThreadRateLimitPerUser:
          maybeParse<Duration?, int>(raw['default_thread_rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: raw['position'] as int,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
    );
  }

  AnnouncementThread parseAnnouncementThread(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.announcementThread.value, 'Invalid type for AnnouncementThread');

    return AnnouncementThread(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      appliedTags: maybeParse<List<Snowflake>, List<dynamic>>(raw['applied_tags'], (tags) => parseMany(tags, Snowflake.parse)),
      approximateMemberCount: raw['member_count'] as int,
      archiveTimestamp: DateTime.parse((raw['thread_metadata'] as Map)['archive_timestamp'] as String),
      autoArchiveDuration: Duration(minutes: (raw['thread_metadata'] as Map)['auto_archive_duration'] as int),
      createdAt: maybeParse((raw['thread_metadata'] as Map)['create_timestamp'], DateTime.parse) ?? DateTime(2022, 1, 9),
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isArchived: (raw['thread_metadata'] as Map)['archived'] as bool,
      isLocked: (raw['thread_metadata'] as Map)['locked'] as bool,
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      messageCount: raw['message_count'] as int,
      name: raw['name'] as String,
      ownerId: Snowflake.parse(raw['owner_id']!),
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: -1,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      totalMessagesSent: raw['total_message_sent'] as int,
      flags: maybeParse(raw['flags'], ChannelFlags.new),
    );
  }

  PublicThread parsePublicThread(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.publicThread.value, 'Invalid type for PublicThread');

    return PublicThread(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      appliedTags: maybeParse<List<Snowflake>, List<dynamic>>(raw['applied_tags'], (tags) => parseMany(tags, Snowflake.parse)),
      approximateMemberCount: raw['member_count'] as int,
      archiveTimestamp: DateTime.parse((raw['thread_metadata'] as Map)['archive_timestamp'] as String),
      autoArchiveDuration: Duration(minutes: (raw['thread_metadata'] as Map)['auto_archive_duration'] as int),
      createdAt: maybeParse((raw['thread_metadata'] as Map)['create_timestamp'], DateTime.parse) ?? DateTime(2022, 1, 9),
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isArchived: (raw['thread_metadata'] as Map)['archived'] as bool,
      isLocked: (raw['thread_metadata'] as Map)['locked'] as bool,
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      messageCount: raw['message_count'] as int,
      name: raw['name'] as String,
      ownerId: Snowflake.parse(raw['owner_id']!),
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: -1,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      totalMessagesSent: raw['total_message_sent'] as int,
      flags: maybeParse(raw['flags'], ChannelFlags.new),
    );
  }

  PrivateThread parsePrivateThread(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.privateThread.value, 'Invalid type for PrivateThread');

    return PrivateThread(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      isInvitable: (raw['thread_metadata'] as Map)['invitable'] as bool,
      appliedTags: maybeParse<List<Snowflake>, List<dynamic>>(raw['applied_tags'], (tags) => parseMany(tags, Snowflake.parse)),
      approximateMemberCount: raw['member_count'] as int,
      archiveTimestamp: DateTime.parse((raw['thread_metadata'] as Map)['archive_timestamp'] as String),
      autoArchiveDuration: Duration(minutes: (raw['thread_metadata'] as Map)['auto_archive_duration'] as int),
      createdAt: maybeParse((raw['thread_metadata'] as Map)['create_timestamp'], DateTime.parse) ?? DateTime(2022, 1, 9),
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isArchived: (raw['thread_metadata'] as Map)['archived'] as bool,
      isLocked: (raw['thread_metadata'] as Map)['locked'] as bool,
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      messageCount: raw['message_count'] as int,
      name: raw['name'] as String,
      ownerId: Snowflake.parse(raw['owner_id']!),
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: -1,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      totalMessagesSent: raw['total_message_sent'] as int,
      flags: maybeParse(raw['flags'], ChannelFlags.new),
    );
  }

  GuildStageChannel parseGuildStageChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.guildStageVoice.value, 'Invalid type for GuildStageChannel');

    return GuildStageChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      bitrate: raw['bitrate'] as int,
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isNsfw: raw['nsfw'] as bool? ?? false,
      lastMessageId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: raw['position'] as int,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      rtcRegion: raw['rtc_region'] as String?,
      userLimit: raw['user_limit'] == 0 ? null : raw['user_limit'] as int?,
      videoQualityMode: maybeParse(raw['video_quality_mode'], VideoQualityMode.parse) ?? VideoQualityMode.auto,
    );
  }

  DirectoryChannel parseDirectoryChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.guildDirectory.value, 'Invalid type for DirectoryChannel');

    return DirectoryChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
    );
  }

  ForumChannel parseForumChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.guildForum.value, 'Invalid type for ForumChannel');

    return ForumChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      defaultLayout: maybeParse(raw['default_forum_layout'], ForumLayout.parse),
      topic: raw['topic'] as String?,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      lastThreadId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      flags: ChannelFlags(raw['flags'] as int),
      availableTags: parseMany(raw['available_tags'] as List, parseForumTag),
      defaultReaction: maybeParse(raw['default_reaction_emoji'], parseDefaultReaction),
      defaultSortOrder: maybeParse(raw['default_sort_order'], ForumSort.parse),
      // Discord doesn't seem to include this field if the default 3 day expiration is used (3 days = 4320 minutes)
      defaultAutoArchiveDuration: Duration(minutes: raw['default_auto_archive_duration'] as int? ?? 4320),
      defaultThreadRateLimitPerUser:
          maybeParse<Duration?, int>(raw['default_thread_rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isNsfw: raw['nsfw'] as bool? ?? false,
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: raw['position'] as int,
    );
  }

  GuildMediaChannel parseGuildMediaChannel(Map<String, Object?> raw, {Snowflake? guildId}) {
    assert(raw['type'] == ChannelType.guildMedia.value, 'Invalid type for GuildMediaChannel');

    return GuildMediaChannel(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      topic: raw['topic'] as String?,
      rateLimitPerUser: maybeParse<Duration?, int>(raw['rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      lastThreadId: maybeParse(raw['last_message_id'], Snowflake.parse),
      lastPinTimestamp: maybeParse(raw['last_pin_timestamp'], DateTime.parse),
      flags: ChannelFlags(raw['flags'] as int),
      availableTags: parseMany(raw['available_tags'] as List, parseForumTag),
      defaultReaction: maybeParse(raw['default_reaction_emoji'], parseDefaultReaction),
      defaultSortOrder: maybeParse(raw['default_sort_order'], ForumSort.parse),
      // Discord doesn't seem to include this field if the default 3 day expiration is used (3 days = 4320 minutes)
      defaultAutoArchiveDuration: Duration(minutes: raw['default_auto_archive_duration'] as int? ?? 4320),
      defaultThreadRateLimitPerUser:
          maybeParse<Duration?, int>(raw['default_thread_rate_limit_per_user'], (value) => value == 0 ? null : Duration(seconds: value)),
      guildId: guildId ?? Snowflake.parse(raw['guild_id']!),
      isNsfw: raw['nsfw'] as bool? ?? false,
      name: raw['name'] as String,
      parentId: maybeParse(raw['parent_id'], Snowflake.parse),
      permissionOverwrites: maybeParseMany(raw['permission_overwrites'], parsePermissionOverwrite) ?? [],
      position: raw['position'] as int,
    );
  }

  PermissionOverwrite parsePermissionOverwrite(Map<String, Object?> raw) {
    return PermissionOverwrite(
      id: Snowflake.parse(raw['id']!),
      type: PermissionOverwriteType.parse(raw['type'] as int),
      allow: Permissions(int.parse(raw['allow'] as String)),
      deny: Permissions(int.parse(raw['deny'] as String)),
    );
  }

  ForumTag parseForumTag(Map<String, Object?> raw) {
    return ForumTag(
      id: Snowflake.parse(raw['id']!),
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

  FollowedChannel parseFollowedChannel(Map<String, Object?> raw) {
    return FollowedChannel(
      manager: this,
      channelId: Snowflake.parse(raw['channel_id']!),
      webhookId: Snowflake.parse(raw['webhook_id']!),
    );
  }

  ThreadMember parseThreadMember(Map<String, Object?> raw) {
    return ThreadMember(
      manager: this,
      joinTimestamp: DateTime.parse(raw['join_timestamp'] as String),
      flags: Flags<Never>(raw['flags'] as int),
      threadId: Snowflake.parse(raw['id']!),
      userId: Snowflake.parse(raw['user_id']!),
      member: maybeParse(raw['member'], client.guilds[Snowflake.zero].members.parse),
    );
  }

  ThreadList parseThreadList(Map<String, Object?> raw) {
    return ThreadList(
      threads: parseMany(raw['threads'] as List, parse).cast<Thread>(),
      members: parseMany(raw['members'] as List, parseThreadMember),
      hasMore: raw['has_more'] as bool? ?? false,
    );
  }

  StageInstance parseStageInstance(Map<String, Object?> raw) {
    return StageInstance(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      guildId: Snowflake.parse(raw['guild_id']!),
      channelId: Snowflake.parse(raw['channel_id']!),
      topic: raw['topic'] as String,
      privacyLevel: PrivacyLevel.parse(raw['privacy_level'] as int),
      scheduledEventId: maybeParse(raw['guild_scheduled_event_id'], Snowflake.parse),
    );
  }

  @override
  Future<Channel> fetch(Snowflake id) async {
    final route = HttpRoute()..channels(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final channel = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(channel);
    return channel;
  }

  /// Update a channel using the provided [builder].
  Future<Channel> update(Snowflake id, UpdateBuilder<Channel> builder, {String? auditLogReason}) async {
    final route = HttpRoute()..channels(id: id.toString());
    final request = BasicRequest(
      route,
      method: 'PATCH',
      body: jsonEncode(builder.build()),
      auditLogReason: auditLogReason,
    );

    final response = await client.httpHandler.executeSafe(request);
    final channel = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(channel);
    return channel;
  }

  /// Delete a guild channel or close a DM channel.
  Future<Channel> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()..channels(id: id.toString());
    final request = BasicRequest(
      route,
      method: 'DELETE',
      auditLogReason: auditLogReason,
    );

    final response = await client.httpHandler.executeSafe(request);
    final channel = parse(response.jsonBody as Map<String, Object?>);

    cache.remove(channel.id);
    return channel;
  }

  /// Update a permission overwrite in a channel.
  Future<void> updatePermissionOverwrite(Snowflake id, PermissionOverwriteBuilder builder) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..permissions(id: builder.id.toString());
    final request = BasicRequest(route, method: 'PUT', body: jsonEncode(builder.build()));

    await client.httpHandler.executeSafe(request);
  }

  /// Delete a permission overwrite in a channel.
  Future<void> deletePermissionOverwrite(Snowflake id, Snowflake permissionId) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..permissions(id: permissionId.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
  }

  /// List the invites in a guild channel.
  Future<List<InviteWithMetadata>> listInvites(Snowflake id) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..invites();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List<Object?>, client.invites.parseWithMetadata);
  }

  /// Create an invite in a guild channel.
  Future<Invite> createInvite(Snowflake id, InviteBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..invites();
    final request = BasicRequest(route, method: 'POST', auditLogReason: auditLogReason, body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    return client.invites.parse(response.jsonBody as Map<String, Object?>);
  }

  /// Add a channel to another channel's followers.
  Future<FollowedChannel> followChannel(Snowflake id, Snowflake toFollow) async {
    final route = HttpRoute()
      ..channels(id: toFollow.toString())
      ..followers();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode({'webhook_channel_id': id.toString()}));

    final response = await client.httpHandler.executeSafe(request);

    return parseFollowedChannel(response.jsonBody as Map<String, Object?>);
  }

  /// Trigger the typing indicator for the current user in a channel.
  Future<void> triggerTyping(Snowflake channelId) async {
    final route = HttpRoute()
      ..channels(id: channelId.toString())
      ..typing();
    final request = BasicRequest(route, method: 'POST');

    await client.httpHandler.executeSafe(request);
  }

  /// Create a thread from a message in a channel.
  Future<Thread> createThreadFromMessage(Snowflake id, Snowflake messageId, ThreadFromMessageBuilder builder) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..messages(id: messageId.toString())
      ..threads();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final thread = parse(response.jsonBody as Map<String, Object?>) as Thread;

    client.updateCacheWith(thread);
    return thread;
  }

  /// Create a thread in a channel.
  Future<Thread> createThread(Snowflake id, ThreadBuilder builder) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threads();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final thread = parse(response.jsonBody as Map<String, Object?>) as Thread;

    client.updateCacheWith(thread);
    return thread;
  }

  /// Create a thread in a forum channel.
  Future<Thread> createForumThread(Snowflake id, ForumThreadBuilder builder) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threads();

    final HttpRequest request;
    if (builder.message.attachments?.isNotEmpty == true) {
      final attachments = builder.message.attachments!;
      final payload = builder.build();

      final files = <MultipartFile>[];
      for (int i = 0; i < attachments.length; i++) {
        files.add(MultipartFile.fromBytes(
          'files[$i]',
          attachments[i].data,
          filename: attachments[i].fileName,
        ));

        (((payload['message'] as Map)['attachments'] as List)[i] as Map)['id'] = i.toString();
      }

      request = MultipartRequest(
        route,
        method: 'PATCH',
        jsonPayload: jsonEncode(payload),
        files: files,
      );
    } else {
      request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));
    }

    final response = await client.httpHandler.executeSafe(request);
    final thread = parse(response.jsonBody as Map<String, Object?>) as Thread;

    client.updateCacheWith(thread);
    return thread;
  }

  /// Add the current user to a thread.
  Future<void> joinThread(Snowflake id) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threadMembers(id: '@me');
    final request = BasicRequest(route, method: 'PUT');

    await client.httpHandler.executeSafe(request);
  }

  /// Add a member to a thread.
  Future<void> addThreadMember(Snowflake id, Snowflake memberId) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threadMembers(id: memberId.toString());
    final request = BasicRequest(route, method: 'PUT');

    await client.httpHandler.executeSafe(request);
  }

  /// Remove the current user from a thread.
  Future<void> leaveThread(Snowflake id) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threadMembers(id: '@me');
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
  }

  /// Remove a member from a thread.
  Future<void> removeThreadMember(Snowflake id, Snowflake memberId) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threadMembers(id: memberId.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
  }

  /// Fetch information about a member in a thread.
  Future<ThreadMember> fetchThreadMember(Snowflake id, Snowflake memberId, {bool? withMember}) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threadMembers(id: memberId.toString());
    final request = BasicRequest(
      route,
      queryParameters: {
        if (withMember != null) 'with_member': withMember.toString(),
      },
    );

    final response = await client.httpHandler.executeSafe(request);
    return parseThreadMember(response.jsonBody as Map<String, Object?>);
  }

  /// List the members of a thread.
  Future<List<ThreadMember>> listThreadMembers(Snowflake id, {bool? withMembers, Snowflake? after, int? limit}) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threadMembers();
    final request = BasicRequest(
      route,
      queryParameters: {
        if (withMembers != null) 'with_member': withMembers.toString(),
        if (after != null) 'after': after.toString(),
        if (limit != null) 'limit': limit.toString(),
      },
    );

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List, parseThreadMember);
  }

  /// List the public archived threads in a channel.
  Future<ThreadList> listPublicArchivedThreads(Snowflake id, {DateTime? before, int? limit}) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threads()
      ..archived()
      ..public();
    final request = BasicRequest(
      route,
      queryParameters: {
        if (before != null) 'before': before.toIso8601String(),
        if (limit != null) 'limit': limit.toString(),
      },
    );

    final response = await client.httpHandler.executeSafe(request);
    return parseThreadList(response.jsonBody as Map<String, Object?>);
  }

  /// List the private archived threads in a channel.
  Future<ThreadList> listPrivateArchivedThreads(Snowflake id, {DateTime? before, int? limit}) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..threads()
      ..archived()
      ..private();
    final request = BasicRequest(
      route,
      queryParameters: {
        if (before != null) 'before': before.toIso8601String(),
        if (limit != null) 'limit': limit.toString(),
      },
    );

    final response = await client.httpHandler.executeSafe(request);
    return parseThreadList(response.jsonBody as Map<String, Object?>);
  }

  /// List the private archived threads the current user has joined in a channel.
  Future<ThreadList> listJoinedPrivateArchivedThreads(Snowflake id, {DateTime? before, int? limit}) async {
    final route = HttpRoute()
      ..channels(id: id.toString())
      ..users(id: '@me')
      ..threads()
      ..archived()
      ..private();
    final request = BasicRequest(
      route,
      queryParameters: {
        if (before != null) 'before': before.toIso8601String(),
        if (limit != null) 'limit': limit.toString(),
      },
    );

    final response = await client.httpHandler.executeSafe(request);
    return parseThreadList(response.jsonBody as Map<String, Object?>);
  }

  /// Start a stage instance in a channel.
  Future<StageInstance> createStageInstance(Snowflake channelId, StageInstanceBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()..stageInstances();
    final request = BasicRequest(
      route,
      method: 'POST',
      body: jsonEncode({'channel_id': channelId.toString(), ...builder.build()}),
      auditLogReason: auditLogReason,
    );

    final response = await client.httpHandler.executeSafe(request);
    final stageInstance = parseStageInstance(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(stageInstance);
    return stageInstance;
  }

  /// Fetch the current stage instance for a channel.
  Future<StageInstance> fetchStageInstance(Snowflake channelId) async {
    final route = HttpRoute()..stageInstances(id: channelId.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final stageInstance = parseStageInstance(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(stageInstance);
    return stageInstance;
  }

  /// Update the stage instance for a channel.
  Future<StageInstance> updateStageInstance(Snowflake channelId, StageInstanceUpdateBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()..stageInstances(id: channelId.toString());
    final request = BasicRequest(
      route,
      method: 'PATCH',
      body: jsonEncode(builder.build()),
      auditLogReason: auditLogReason,
    );

    final response = await client.httpHandler.executeSafe(request);
    final stageInstance = parseStageInstance(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(stageInstance);
    return stageInstance;
  }

  /// Delete the stage instance for a channel.
  Future<void> deleteStageInstance(Snowflake channelId, {String? auditLogReason}) async {
    final route = HttpRoute()..stageInstances(id: channelId.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);

    stageInstanceCache.remove(channelId);
  }
}
