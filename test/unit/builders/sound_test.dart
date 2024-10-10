import 'package:nyxx/src/builders/sound.dart';
import 'package:test/test.dart';

void main() {
  group('SoundBuilder', () {
    test('build', () {
      final builder = SoundBuilder(
        format: 'mp3',
        data: [0, 0, 0, 255, 255, 255],
      );

      expect(builder.buildDataString(), equals('data:audio/mp3;base64,AAAA////'));
    });
  });
}