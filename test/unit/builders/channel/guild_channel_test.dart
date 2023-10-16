import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  test('GuildTextChannelUpdateBuilder', () {
    final builder = GuildTextChannelUpdateBuilder(
      name: 'test',
      position: 10,
      permissionOverwrites: [],
      type: ChannelType.guildAnnouncement,
      topic: 'foobar',
      isNsfw: false,
      rateLimitPerUser: Duration.zero,
      parentId: Snowflake.zero,
      defaultAutoArchiveDuration: Duration.zero,
      defaultThreadRateLimitPerUser: Duration.zero,
    );

    expect(
      builder.build(),
      equals({
        'name': 'test',
        'position': 10,
        'permission_overwrites': [],
        'type': 5,
        'topic': 'foobar',
        'nsfw': false,
        'rate_limit_per_user': 0,
        'parent_id': '0',
        'default_auto_archive_duration': 0,
        'default_thread_rate_limit_per_user': 0,
      }),
    );
  });

  test('GuildAnnouncementChannelUpdateBuilder', () {
    final builder = GuildAnnouncementChannelUpdateBuilder(
      name: 'test',
      position: 10,
      permissionOverwrites: [],
      type: ChannelType.guildText,
      topic: 'foobar',
      isNsfw: false,
      parentId: Snowflake.zero,
      defaultAutoArchiveDuration: Duration.zero,
    );

    expect(
      builder.build(),
      equals({
        'name': 'test',
        'position': 10,
        'permission_overwrites': [],
        'type': 0,
        'topic': 'foobar',
        'nsfw': false,
        'parent_id': '0',
        'default_auto_archive_duration': 0,
      }),
    );
  });

  test('ForumChannelUpdateBuilder', () {
    final builder = ForumChannelUpdateBuilder(
      name: 'test',
      position: 10,
      permissionOverwrites: [],
      topic: 'foobar',
      isNsfw: false,
      rateLimitPerUser: Duration.zero,
      parentId: Snowflake.zero,
      defaultAutoArchiveDuration: Duration.zero,
      flags: ChannelFlags.requireTag,
      tags: [],
      defaultReaction: null,
      defaultThreadRateLimitPerUser: Duration.zero,
      defaultSortOrder: ForumSort.creationDate,
      defaultLayout: ForumLayout.galleryView,
    );

    expect(
      builder.build(),
      equals({
        'name': 'test',
        'position': 10,
        'permission_overwrites': [],
        'topic': 'foobar',
        'nsfw': false,
        'rate_limit_per_user': 0,
        'parent_id': '0',
        'default_auto_archive_duration': 0,
        'flags': 1 << 4,
        'available_tags': [],
        'default_reaction_emoji': null,
        'default_thread_rate_limit_per_user': 0,
        'default_sort_order': 1,
        'default_forum_layout': 2,
      }),
    );
  });

  test('GuildVoiceChannelUpdateBuilder', () {
    final builder = GuildVoiceChannelUpdateBuilder(
      name: 'test',
      position: 10,
      permissionOverwrites: [],
      isNsfw: false,
      bitRate: 100,
      userLimit: 10,
      parentId: Snowflake.zero,
      rtcRegion: null,
      videoQualityMode: VideoQualityMode.auto,
    );

    expect(
      builder.build(),
      equals({
        'name': 'test',
        'position': 10,
        'permission_overwrites': [],
        'nsfw': false,
        'bitrate': 100,
        'user_limit': 10,
        'parent_id': '0',
        'rtc_region': null,
        'video_quality_mode': 1,
      }),
    );
  });
}
