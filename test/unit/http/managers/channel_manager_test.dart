import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

void main() {
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

  testReadOnlyManager<Channel, ChannelManager>(
    'ChannelManager',
    ChannelManager.new,
    RegExp(r'/channels/\d+'),
    sampleObject: sampleGuildText,
    sampleMatches: checkGuildText,
    additionalSampleObjects: [sampleGuildAnnouncement, sampleGuildVoice, sampleDm, sampleGroupDm, sampleCategory, sampleThread],
    additionalSampleMatchers: [checkGuildAnnouncement, checkGuildVoice, checkDm, checkGroupDm, checkCategory, checkThread],
    additionalParsingTests: [],
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
    ],
  );
}
