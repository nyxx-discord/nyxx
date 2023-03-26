import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
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
        'flags': 1,
        'applied_tags': ['0'],
      }),
    );
  });
}
