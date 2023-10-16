import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  group('ImageBuilder', () {
    test('build', () {
      final builder = ImageBuilder(
        format: 'png',
        data: [0, 0, 0, 255, 255, 255],
      );

      expect(builder.buildDataString(), equals('data:image/png;base64,AAAA////'));
    });
  });
}
