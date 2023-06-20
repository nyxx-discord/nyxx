import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';
import '../../../test_manager.dart';
import 'invite_manager_test.dart';
import 'member_manager_test.dart';

final sampleGuildText = {
  "id": "41771983423143937",
  "guild_id": "41771983423143937",
  "name": "general",
  "type": 0,
  "position": 6,
  "permission_overwrites": [],
  "rate_limit_per_user": 2,
  "nsfw": true,
  "topic": "24/7 chat about how to gank Mike #2",
  "last_message_id": "155117677105512449",
  "parent_id": "399942396007890945",
  "default_auto_archive_duration": 60
};

void checkGuildText(Channel channel) {
  expect(channel, isA<GuildTextChannel>());

  channel as GuildTextChannel;

  expect(channel.id, equals(Snowflake(41771983423143937)));
  expect(channel.topic, equals('24/7 chat about how to gank Mike #2'));
  expect(channel.defaultAutoArchiveDuration, equals(Duration(minutes: 60)));
  expect(channel.defaultThreadRateLimitPerUser, isNull);
  expect(channel.guildId, equals(Snowflake(41771983423143937)));
  expect(channel.isNsfw, isTrue);
  expect(channel.lastMessageId, equals(Snowflake(155117677105512449)));
  expect(channel.lastPinTimestamp, isNull);
  expect(channel.name, equals('general'));
  expect(channel.parentId, equals(Snowflake(399942396007890945)));
  expect(channel.permissionOverwrites, equals([]));
  expect(channel.position, equals(6));
  expect(channel.rateLimitPerUser, equals(Duration(seconds: 2)));
}

final sampleGuildAnnouncement = {
  "id": "41771983423143937",
  "guild_id": "41771983423143937",
  "name": "important-news",
  "type": 5,
  "position": 6,
  "permission_overwrites": [],
  "nsfw": true,
  "topic": "Rumors about Half Life 3",
  "last_message_id": "155117677105512449",
  "parent_id": "399942396007890945",
  "default_auto_archive_duration": 60
};

void checkGuildAnnouncement(Channel channel) {
  expect(channel, isA<GuildAnnouncementChannel>());

  channel as GuildAnnouncementChannel;

  expect(channel.id, equals(Snowflake(41771983423143937)));
  expect(channel.topic, equals('Rumors about Half Life 3'));
  expect(channel.defaultAutoArchiveDuration, equals(Duration(minutes: 60)));
  expect(channel.defaultThreadRateLimitPerUser, isNull);
  expect(channel.guildId, equals(Snowflake(41771983423143937)));
  expect(channel.isNsfw, isTrue);
  expect(channel.lastMessageId, equals(Snowflake(155117677105512449)));
  expect(channel.lastPinTimestamp, isNull);
  expect(channel.name, equals('important-news'));
  expect(channel.parentId, equals(Snowflake(399942396007890945)));
  expect(channel.permissionOverwrites, equals([]));
  expect(channel.position, equals(6));
  expect(channel.rateLimitPerUser, isNull);
}

final sampleGuildVoice = {
  "id": "155101607195836416",
  "last_message_id": "174629835082649376",
  "type": 2,
  "name": "ROCKET CHEESE",
  "position": 5,
  "parent_id": null,
  "bitrate": 64000,
  "user_limit": 0,
  "rtc_region": null,
  "guild_id": "41771983423143937",
  "permission_overwrites": [],
  "rate_limit_per_user": 0,
  "nsfw": false,
};

void checkGuildVoice(Channel channel) {
  expect(channel, isA<GuildVoiceChannel>());

  channel as GuildVoiceChannel;

  expect(channel.id, equals(Snowflake(155101607195836416)));
  expect(channel.bitrate, equals(64000));
  expect(channel.guildId, equals(Snowflake(41771983423143937)));
  expect(channel.isNsfw, isFalse);
  expect(channel.lastMessageId, equals(Snowflake(174629835082649376)));
  expect(channel.lastPinTimestamp, isNull);
  expect(channel.name, equals('ROCKET CHEESE'));
  expect(channel.parentId, isNull);
  expect(channel.permissionOverwrites, equals([]));
  expect(channel.position, equals(5));
  expect(channel.rateLimitPerUser, isNull);
  expect(channel.rtcRegion, isNull);
  expect(channel.userLimit, isNull);
  expect(channel.videoQualityMode, VideoQualityMode.auto);
}

final sampleDm = {
  "last_message_id": "3343820033257021450",
  "type": 1,
  "id": "319674150115610528",
  "recipients": [
    {"username": "test", "discriminator": "9999", "id": "82198898841029460", "avatar": "33ecab261d4681afa4d85a04691c4a01"}
  ]
};

void checkDm(Channel channel) {
  expect(channel, isA<DmChannel>());

  channel as DmChannel;

  expect(channel.id, equals(Snowflake(319674150115610528)));
  expect(channel.recipient.id, equals(Snowflake(82198898841029460)));
  expect(channel.lastMessageId, equals(Snowflake(3343820033257021450)));
  expect(channel.lastPinTimestamp, isNull);
  expect(channel.rateLimitPerUser, isNull);
}

final sampleGroupDm = {
  "name": "Some test channel",
  "icon": null,
  "recipients": [
    {"username": "test", "discriminator": "9999", "id": "82198898841029460", "avatar": "33ecab261d4681afa4d85a04691c4a01"},
    {"username": "test2", "discriminator": "9999", "id": "82198810841029460", "avatar": "33ecab261d4681afa4d85a10691c4a01"}
  ],
  "last_message_id": "3343820033257021450",
  "type": 3,
  "id": "319674150115710528",
  "owner_id": "82198810841029460"
};

void checkGroupDm(Channel channel) {
  expect(channel, isA<GroupDmChannel>());

  channel as GroupDmChannel;

  expect(channel.id, equals(Snowflake(319674150115710528)));
  expect(channel.name, equals('Some test channel'));
  expect(channel.recipients, hasLength(2));
  expect(channel.iconHash, isNull);
  expect(channel.ownerId, equals(Snowflake(82198810841029460)));
  expect(channel.applicationId, isNull);
  expect(channel.isManaged, isFalse);
  expect(channel.lastMessageId, equals(Snowflake(3343820033257021450)));
  expect(channel.lastPinTimestamp, isNull);
  expect(channel.rateLimitPerUser, isNull);
}

final sampleCategory = {
  "permission_overwrites": [],
  "name": "Test",
  "parent_id": null,
  "nsfw": false,
  "position": 0,
  "guild_id": "290926798629997250",
  "type": 4,
  "id": "399942396007890945"
};

void checkCategory(Channel channel) {
  expect(channel, isA<GuildCategory>());

  channel as GuildCategory;

  expect(channel.id, equals(Snowflake(399942396007890945)));
  expect(channel.guildId, equals(Snowflake(290926798629997250)));
  expect(channel.isNsfw, isFalse);
  expect(channel.name, equals('Test'));
  expect(channel.parentId, isNull);
  expect(channel.permissionOverwrites, equals([]));
  expect(channel.position, equals(0));
}

final sampleThread = {
  "id": "41771983423143937",
  "guild_id": "41771983423143937",
  "parent_id": "41771983423143937",
  "owner_id": "41771983423143937",
  "name": "don't buy dota-2",
  "type": 11,
  "last_message_id": "155117677105512449",
  "message_count": 1,
  "member_count": 5,
  "rate_limit_per_user": 2,
  "thread_metadata": {"archived": false, "auto_archive_duration": 1440, "archive_timestamp": "2021-04-12T23:40:39.855793+00:00", "locked": false},
  "total_message_sent": 1
};

void checkThread(Channel channel) {
  expect(channel, isA<PublicThread>());

  channel as PublicThread;

  expect(channel.id, equals(Snowflake(41771983423143937)));
  expect(channel.appliedTags, isNull);
  expect(channel.approximateMemberCount, equals(5));
  expect(channel.archiveTimestamp, equals(DateTime.utc(2021, 04, 12, 23, 40, 39, 855, 793)));
  expect(channel.autoArchiveDuration, equals(Duration(minutes: 1440)));
  expect(channel.createdAt, equals(DateTime(2022, 01, 09)));
  expect(channel.guildId, equals(Snowflake(41771983423143937)));
  expect(channel.isArchived, isFalse);
  expect(channel.isLocked, isFalse);
  expect(channel.isNsfw, isFalse);
  expect(channel.lastMessageId, equals(Snowflake(155117677105512449)));
  expect(channel.lastPinTimestamp, isNull);
  expect(channel.messageCount, equals(1));
  expect(channel.name, equals("don't buy dota-2"));
  expect(channel.ownerId, equals(Snowflake(41771983423143937)));
  expect(channel.parentId, equals(Snowflake(41771983423143937)));
  expect(channel.permissionOverwrites, equals([]));
  expect(channel.position, equals(-1));
  expect(channel.rateLimitPerUser, equals(Duration(seconds: 2)));
  expect(channel.totalMessagesSent, equals(1));
  expect(channel.flags, isNull);
}

final sampleAnnouncementThread = {
  "id": "1093553602909442119",
  "guild_id": "1033681997136146462",
  "parent_id": "1093553555270545438",
  "owner_id": "506759329068613643",
  "type": 10,
  "name": "Wow, such announcement",
  "last_message_id": "1093553605472170094",
  "thread_metadata": {
    "archived": false,
    "archive_timestamp": "2023-04-06T15:11:36.177000+00:00",
    "auto_archive_duration": 4320,
    "locked": false,
    "create_timestamp": "2023-04-06T15:11:36.177000+00:00"
  },
  "message_count": 1,
  "member_count": 1,
  "rate_limit_per_user": 0,
  "flags": 0,
  "total_message_sent": 1,
};

void checkAnnouncementThread(Channel channel) {
  expect(channel, isA<AnnouncementThread>());

  channel as AnnouncementThread;

  expect(channel.id, equals(Snowflake(1093553602909442119)));
  expect(channel.appliedTags, isNull);
  expect(channel.approximateMemberCount, equals(1));
  expect(channel.archiveTimestamp, equals(DateTime.utc(2023, 04, 06, 15, 11, 36, 177)));
  expect(channel.autoArchiveDuration, equals(Duration(minutes: 4320)));
  expect(channel.createdAt, equals(DateTime.utc(2023, 04, 06, 15, 11, 36, 177)));
  expect(channel.guildId, equals(Snowflake(1033681997136146462)));
  expect(channel.isArchived, isFalse);
  expect(channel.isLocked, isFalse);
  expect(channel.isNsfw, isFalse);
  expect(channel.lastMessageId, equals(Snowflake(1093553605472170094)));
  expect(channel.lastPinTimestamp, isNull);
  expect(channel.messageCount, equals(1));
  expect(channel.name, equals('Wow, such announcement'));
  expect(channel.ownerId, equals(Snowflake(506759329068613643)));
  expect(channel.parentId, equals(Snowflake(1093553555270545438)));
  expect(channel.permissionOverwrites, equals([]));
  expect(channel.position, equals(-1));
  expect(channel.rateLimitPerUser, isNull);
  expect(channel.totalMessagesSent, equals(1));
  expect(channel.flags, equals(ChannelFlags(0)));
}

final samplePrivateThread = {
  "id": "1093556383640715314",
  "guild_id": "1033681997136146462",
  "parent_id": "1038831656682930227",
  "owner_id": "506759329068613643",
  "type": 12,
  "name": "blah",
  "last_message_id": "1093556580290670633",
  "thread_metadata": {
    "archived": false,
    "archive_timestamp": "2023-04-06T15:22:39.155000+00:00",
    "auto_archive_duration": 4320,
    "locked": false,
    "create_timestamp": "2023-04-06T15:22:39.155000+00:00",
    "invitable": true
  },
  "message_count": 2,
  "member_count": 2,
  "rate_limit_per_user": 0,
  "flags": 0,
  "total_message_sent": 2,
  "member": {
    "id": "1093556383640715314",
    "flags": 0,
    "join_timestamp": "2023-04-06T15:23:26.010000+00:00",
    "user_id": "1033681843708510238",
    "muted": false,
    "mute_config": null
  },
};

void checkPrivateThread(Channel channel) {
  expect(channel, isA<PrivateThread>());

  channel as PrivateThread;

  expect(channel.id, equals(Snowflake(1093556383640715314)));
  expect(channel.isInvitable, isTrue);
  expect(channel.appliedTags, isNull);
  expect(channel.approximateMemberCount, equals(2));
  expect(channel.archiveTimestamp, equals(DateTime.utc(2023, 04, 06, 15, 22, 39, 155)));
  expect(channel.autoArchiveDuration, equals(Duration(minutes: 4320)));
  expect(channel.createdAt, equals(DateTime.utc(2023, 04, 06, 15, 22, 39, 155)));
  expect(channel.guildId, equals(Snowflake(1033681997136146462)));
  expect(channel.isArchived, isFalse);
  expect(channel.isLocked, isFalse);
  expect(channel.isNsfw, isFalse);
  expect(channel.lastMessageId, equals(Snowflake(1093556580290670633)));
  expect(channel.lastPinTimestamp, isNull);
  expect(channel.messageCount, equals(2));
  expect(channel.name, equals('blah'));
  expect(channel.ownerId, equals(Snowflake(506759329068613643)));
  expect(channel.parentId, equals(Snowflake(1038831656682930227)));
  expect(channel.permissionOverwrites, equals([]));
  expect(channel.position, equals(-1));
  expect(channel.rateLimitPerUser, isNull);
  expect(channel.totalMessagesSent, equals(2));
  expect(channel.flags, equals(ChannelFlags(0)));
}

final samplePermissionOverwrite = {
  'id': '0',
  'type': 1,
  'allow': '100',
  'deny': '11',
};

void checkPermissionOverwrite(PermissionOverwrite overwrite) {
  expect(overwrite.id, equals(Snowflake.zero));
  expect(overwrite.type, equals(PermissionOverwriteType.member));
  expect(overwrite.allow, equals(Permissions(100)));
  expect(overwrite.deny, equals(Permissions(11)));
}

final sampleForumTag = {
  'id': '0',
  'name': 'test tag',
  'moderated': false,
  'emoji_id': null,
  'emoji_name': 'slight_smile',
};

void checkForumTag(ForumTag tag) {
  expect(tag.id, equals(Snowflake.zero));
  expect(tag.name, equals('test tag'));
  expect(tag.isModerated, isFalse);
  expect(tag.emojiId, isNull);
  expect(tag.emojiName, equals('slight_smile'));
}

final sampleDefaultReaction = {
  'emoji_id': '0',
  'emoji_name': null,
};

void checkDefaultReaction(DefaultReaction reaction) {
  expect(reaction.emojiId, equals(Snowflake.zero));
  expect(reaction.emojiName, isNull);
}

final sampleFollowedChannel = {
  'channel_id': '0',
  'webhook_id': '1',
};

void checkFollowedChannel(FollowedChannel followedChannel) {
  expect(followedChannel.channelId, equals(Snowflake.zero));
  expect(followedChannel.webhookId, equals(Snowflake(1)));
}

final sampleThreadMember = {
  'id': '0',
  'user_id': '1',
  'join_timestamp': '2023-04-03T10:49:41+00:00',
  'flags': 17,
  'member': sampleMember,
};

void checkThreadMember(ThreadMember member) {
  expect(member.threadId, equals(Snowflake.zero));
  expect(member.userId, equals(Snowflake(1)));
  expect(member.flags.value, equals(17));
  expect(member.joinTimestamp, equals(DateTime.utc(2023, 04, 03, 10, 49, 41)));
  checkMember(member.member!);
}

final sampleThreadList = {
  'threads': [sampleThread],
  'members': [sampleThreadMember],
  'has_more': false,
};

void checkThreadList(ThreadList list) {
  expect(list.threads, hasLength(1));
  checkThread(list.threads.single);

  expect(list.members, hasLength(1));
  checkThreadMember(list.members.single);

  expect(list.hasMore, isFalse);
}

final sampleStageInstance = {
  "id": "840647391636226060",
  "guild_id": "197038439483310086",
  "channel_id": "733488538393510049",
  "topic": "Testing Testing, 123",
  "privacy_level": 1,
  "discoverable_disabled": false,
  "guild_scheduled_event_id": "947656305244532806"
};

void checkStageInstance(StageInstance instance) {
  expect(instance.id, equals(Snowflake(840647391636226060)));
  expect(instance.guildId, equals(Snowflake(197038439483310086)));
  expect(instance.channelId, equals(Snowflake(733488538393510049)));
  expect(instance.topic, equals('Testing Testing, 123'));
  expect(instance.privacyLevel, equals(PrivacyLevel.public));
  expect(instance.scheduledEventId, equals(Snowflake(947656305244532806)));
}

void main() {
  testReadOnlyManager<Channel, ChannelManager>(
    'ChannelManager',
    (config, client) => ChannelManager(config, client, stageInstanceConfig: CacheConfig()),
    RegExp(r'/channels/\d+'),
    sampleObject: sampleGuildText,
    sampleMatches: checkGuildText,
    additionalSampleObjects: [
      sampleGuildAnnouncement,
      sampleGuildVoice,
      sampleDm,
      sampleGroupDm,
      sampleCategory,
      sampleThread,
      sampleAnnouncementThread,
      samplePrivateThread,
    ],
    additionalSampleMatchers: [
      checkGuildAnnouncement,
      checkGuildVoice,
      checkDm,
      checkGroupDm,
      checkCategory,
      checkThread,
      checkAnnouncementThread,
      checkPrivateThread,
    ],
    additionalParsingTests: [
      ParsingTest<ChannelManager, PermissionOverwrite, Map<String, Object?>>(
        name: 'parsePermissionOverwrite',
        source: samplePermissionOverwrite,
        parse: (manager) => manager.parsePermissionOverwrite,
        check: checkPermissionOverwrite,
      ),
      ParsingTest<ChannelManager, ForumTag, Map<String, Object?>>(
        name: 'parseForumTag',
        source: sampleForumTag,
        parse: (manager) => manager.parseForumTag,
        check: checkForumTag,
      ),
      ParsingTest<ChannelManager, DefaultReaction, Map<String, Object?>>(
        name: 'parseDefaultReaction',
        source: sampleDefaultReaction,
        parse: (manager) => manager.parseDefaultReaction,
        check: checkDefaultReaction,
      ),
      ParsingTest<ChannelManager, FollowedChannel, Map<String, Object?>>(
        name: 'parseFollowedChannel',
        source: sampleFollowedChannel,
        parse: (manager) => manager.parseFollowedChannel,
        check: checkFollowedChannel,
      ),
      ParsingTest<ChannelManager, ThreadMember, Map<String, Object?>>(
        name: 'parseThreadMember',
        source: sampleThreadMember,
        parse: (manager) => manager.parseThreadMember,
        check: checkThreadMember,
      ),
      ParsingTest<ChannelManager, ThreadList, Map<String, Object?>>(
        name: 'parseThreadList',
        source: sampleThreadList,
        parse: (manager) => manager.parseThreadList,
        check: checkThreadList,
      ),
      ParsingTest<ChannelManager, StageInstance, Map<String, Object?>>(
        name: 'parseStageInstance',
        source: sampleStageInstance,
        parse: (manager) => manager.parseStageInstance,
        check: checkStageInstance,
      ),
    ],
    additionalEndpointTests: [
      EndpointTest<ChannelManager, Channel, Map<String, Object?>>(
        name: 'update',
        method: 'patch',
        source: sampleGuildText,
        urlMatcher: '/channels/0',
        execute: (manager) => manager.update(Snowflake.zero, GuildTextChannelUpdateBuilder()),
        check: checkGuildText,
      ),
      EndpointTest<ChannelManager, Channel, Map<String, Object?>>(
        name: 'delete',
        method: 'delete',
        source: sampleGuildText,
        urlMatcher: '/channels/0',
        execute: (manager) => manager.delete(Snowflake.zero),
        check: checkGuildText,
      ),
      EndpointTest<ChannelManager, void, void>(
        name: 'updatePermissionOverwrite',
        method: 'put',
        source: null,
        urlMatcher: '/channels/0/permissions/1',
        execute: (manager) =>
            manager.updatePermissionOverwrite(Snowflake.zero, PermissionOverwriteBuilder(id: Snowflake(1), type: PermissionOverwriteType.role)),
        check: (_) {},
      ),
      EndpointTest<ChannelManager, void, void>(
        name: 'deletePermissionOverwrite',
        method: 'delete',
        source: null,
        urlMatcher: '/channels/0/permissions/1',
        execute: (manager) => manager.deletePermissionOverwrite(Snowflake.zero, Snowflake(1)),
        check: (_) {},
      ),
      EndpointTest<ChannelManager, List<InviteWithMetadata>, List<Object?>>(
        name: 'listInvites',
        source: [sampleInviteWithMetadata],
        urlMatcher: '/channels/0/invites',
        execute: (manager) => manager.listInvites(Snowflake.zero),
        check: (list) {
          expect(list, hasLength(1));

          checkInviteWithMetadata(list.single);
        },
      ),
      EndpointTest<ChannelManager, Invite, Map<String, Object?>>(
        name: 'createInvite',
        method: 'POST',
        source: sampleInvite,
        urlMatcher: '/channels/0/invites',
        execute: (manager) => manager.createInvite(Snowflake.zero, InviteBuilder()),
        check: checkInvite,
      ),
      EndpointTest<ChannelManager, FollowedChannel, Map<String, Object?>>(
        name: 'followChannel',
        method: 'post',
        source: sampleFollowedChannel,
        urlMatcher: '/channels/0/followers',
        execute: (manager) => manager.followChannel(Snowflake(1), Snowflake.zero),
        check: checkFollowedChannel,
      ),
      EndpointTest<ChannelManager, void, void>(
        name: 'triggerTyping',
        method: 'post',
        source: null,
        urlMatcher: '/channels/0/typing',
        execute: (manager) => manager.triggerTyping(Snowflake.zero),
        check: (_) {},
      ),
      EndpointTest<ChannelManager, Thread, Map<String, Object?>>(
        name: 'createThreadFromMessage',
        method: 'post',
        source: sampleThread,
        urlMatcher: '/channels/0/messages/1/threads',
        execute: (manager) => manager.createThreadFromMessage(Snowflake.zero, Snowflake(1), ThreadFromMessageBuilder(name: 'test')),
        check: checkThread,
      ),
      EndpointTest<ChannelManager, Thread, Map<String, Object?>>(
        name: 'createThread',
        method: 'post',
        source: sampleThread,
        urlMatcher: '/channels/0/threads',
        execute: (manager) => manager.createThread(Snowflake.zero, ThreadBuilder(name: 'test', type: ChannelType.publicThread)),
        check: checkThread,
      ),
      EndpointTest<ChannelManager, Thread, Map<String, Object?>>(
        name: 'createForumThread',
        method: 'post',
        source: sampleThread,
        urlMatcher: '/channels/0/threads',
        execute: (manager) => manager.createForumThread(Snowflake.zero, ForumThreadBuilder(name: 'test', message: MessageBuilder())),
        check: checkThread,
      ),
      EndpointTest<ChannelManager, void, void>(
        name: 'joinThread',
        method: 'put',
        source: null,
        urlMatcher: '/channels/0/thread-members/@me',
        execute: (manager) => manager.joinThread(Snowflake.zero),
        check: (_) {},
      ),
      EndpointTest<ChannelManager, void, void>(
        name: 'addThreadMember',
        method: 'put',
        source: null,
        urlMatcher: '/channels/0/thread-members/1',
        execute: (manager) => manager.addThreadMember(Snowflake.zero, Snowflake(1)),
        check: (_) {},
      ),
      EndpointTest<ChannelManager, void, void>(
        name: 'leaveThread',
        method: 'delete',
        source: null,
        urlMatcher: '/channels/0/thread-members/@me',
        execute: (manager) => manager.leaveThread(Snowflake.zero),
        check: (_) {},
      ),
      EndpointTest<ChannelManager, void, void>(
        name: 'removeThreadMember',
        method: 'delete',
        source: null,
        urlMatcher: '/channels/0/thread-members/1',
        execute: (manager) => manager.removeThreadMember(Snowflake.zero, Snowflake(1)),
        check: (_) {},
      ),
      EndpointTest<ChannelManager, ThreadMember, Map<String, Object?>>(
        name: 'fetchThreadMember',
        source: sampleThreadMember,
        urlMatcher: '/channels/0/thread-members/1',
        execute: (manager) => manager.fetchThreadMember(Snowflake.zero, Snowflake(1)),
        check: checkThreadMember,
      ),
      EndpointTest<ChannelManager, List<ThreadMember>, List<Object?>>(
        name: 'listThreadMembers',
        source: [sampleThreadMember],
        urlMatcher: '/channels/0/thread-members',
        execute: (manager) => manager.listThreadMembers(Snowflake.zero),
        check: (list) {
          expect(list, hasLength(1));
          checkThreadMember(list.single);
        },
      ),
      EndpointTest<ChannelManager, ThreadList, Map<String, Object?>>(
        name: 'listPublicArchivedThreads',
        source: sampleThreadList,
        urlMatcher: '/channels/0/threads/archived/public',
        execute: (manager) => manager.listPublicArchivedThreads(Snowflake.zero),
        check: checkThreadList,
      ),
      EndpointTest<ChannelManager, ThreadList, Map<String, Object?>>(
        name: 'listPrivateArchivedThreads',
        source: sampleThreadList,
        urlMatcher: '/channels/0/threads/archived/private',
        execute: (manager) => manager.listPrivateArchivedThreads(Snowflake.zero),
        check: checkThreadList,
      ),
      EndpointTest<ChannelManager, ThreadList, Map<String, Object?>>(
        name: 'listJoinedPrivateArchivedThreads',
        source: sampleThreadList,
        urlMatcher: '/channels/0/users/@me/threads/archived/private',
        execute: (manager) => manager.listJoinedPrivateArchivedThreads(Snowflake.zero),
        check: checkThreadList,
      ),
      EndpointTest<ChannelManager, StageInstance, Map<String, Object?>>(
        name: 'createStageInstance',
        method: 'POST',
        source: sampleStageInstance,
        urlMatcher: '/stage-instances',
        execute: (manager) => manager.createStageInstance(Snowflake.zero, StageInstanceBuilder(topic: 'test')),
        check: checkStageInstance,
      ),
      EndpointTest<ChannelManager, StageInstance, Map<String, Object?>>(
        name: 'fetchStageInstance',
        source: sampleStageInstance,
        urlMatcher: '/stage-instances/0',
        execute: (manager) => manager.fetchStageInstance(Snowflake.zero),
        check: checkStageInstance,
      ),
      EndpointTest<ChannelManager, StageInstance, Map<String, Object?>>(
        name: 'updateStageInstance',
        method: 'PATCH',
        source: sampleStageInstance,
        urlMatcher: '/stage-instances/0',
        execute: (manager) => manager.updateStageInstance(Snowflake.zero, StageInstanceUpdateBuilder()),
        check: checkStageInstance,
      ),
      EndpointTest<ChannelManager, void, void>(
        name: 'deleteStageInstance',
        method: 'DELETE',
        source: null,
        urlMatcher: '/stage-instances/0',
        execute: (manager) => manager.deleteStageInstance(Snowflake.zero),
        check: (_) {},
      ),
    ],
    extraRun: () {
      test('[] returns PartialTextChannel', () {
        final manager = ChannelManager(const CacheConfig(), MockNyxx(), stageInstanceConfig: const CacheConfig());

        expect(manager[Snowflake.zero], isA<PartialTextChannel>());
      });
    },
  );
}
