import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  test('ForumTagBuilder', () {
    final builder = ForumTagBuilder(name: 'test');

    expect(builder.build(), equals({'name': 'test'}));

    final builder2 = ForumTagBuilder(
      name: 'test',
      emojiId: Snowflake.zero,
      emojiName: 'test2',
      isModerated: false,
    );

    expect(
      builder2.build(),
      equals({
        'name': 'test',
        'emoji_id': '0',
        'emoji_name': 'test2',
        'moderated': false,
      }),
    );
  });
}
