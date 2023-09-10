import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  test('ThreadFromMessageBuilder', () {
    final builder = ThreadFromMessageBuilder(
      name: 'test',
      autoArchiveDuration: Duration(minutes: 1),
      rateLimitPerUser: Duration(seconds: 2),
    );

    expect(
      builder.build(),
      equals({
        'name': 'test',
        'auto_archive_duration': 1,
        'rate_limit_per_user': 2,
      }),
    );
  });

  test('ThreadBuilder', () {
    final builder = ThreadBuilder(
      name: 'test',
      type: ChannelType.publicThread,
      autoArchiveDuration: Duration(minutes: 1),
      rateLimitPerUser: Duration(seconds: 2),
      invitable: false,
    );

    expect(
      builder.build(),
      equals({
        'name': 'test',
        'auto_archive_duration': 1,
        'type': 11,
        'invitable': false,
        'rate_limit_per_user': 2,
      }),
    );
  });

  test('ForumThreadBuilder', () {
    final builder = ForumThreadBuilder(
      name: 'test',
      message: MessageBuilder(),
      appliedTags: [Snowflake.zero],
      autoArchiveDuration: Duration(minutes: 1),
      rateLimitPerUser: Duration(seconds: 2),
    );

    expect(
      builder.build(),
      equals({
        'name': 'test',
        'message': {},
        'applied_tags': ['0'],
        'auto_archive_duration': 1,
        'rate_limit_per_user': 2,
      }),
    );
  });

  test('ThreadUpdateBuilder', () {
    final builder = ThreadUpdateBuilder(
      name: 'test',
      isArchived: true,
      autoArchiveDuration: Duration.zero,
      isLocked: false,
      isInvitable: true,
      rateLimitPerUser: null,
      flags: ChannelFlags.pinned,
      appliedTags: [Snowflake.zero],
    );

    expect(
      builder.build(),
      equals({
        'name': 'test',
        'archived': true,
        'auto_archive_duration': 0,
        'locked': false,
        'invitable': true,
        'rate_limit_per_user': null,
        'flags': 2,
        'applied_tags': ['0'],
      }),
    );
  });
}
