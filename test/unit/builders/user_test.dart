import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  group('UserUpdateBuilder', () {
    test('build', () {
      final builder = UserUpdateBuilder(username: 'foo', avatar: ImageBuilder.png([]));
      expect(
        builder.build(),
        equals({
          'username': 'foo',
          'avatar': 'data:image/png;base64,',
        }),
      );

      final builder2 = UserUpdateBuilder(avatar: ImageBuilder.png([]));
      expect(builder2.build(), equals({'avatar': 'data:image/png;base64,'}));

      final builder3 = UserUpdateBuilder(username: 'foo');
      expect(builder3.build(), equals({'username': 'foo'}));

      final builder4 = UserUpdateBuilder();
      expect(builder4.build(), equals({}));

      final builder5 = UserUpdateBuilder(banner: ImageBuilder.png([]));
      expect(builder5.build(), equals({'banner': 'data:image/png;base64,'}));
    });
  });
}
