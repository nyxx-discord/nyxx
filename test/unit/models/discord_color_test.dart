import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  group('DiscordColor', () {
    test('r, g, b', () {
      final color = DiscordColor(0xffed12);

      expect(color.r, equals(0xff));
      expect(color.g, equals(0xed));
      expect(color.b, equals(0x12));
    });

    test('equality', () {
      final color1 = DiscordColor(0xffed12);
      final color2 = DiscordColor.fromRgb(0xff, 0xed, 0x12);

      expect(color1, equals(color2));
      expect(color1.hashCode, equals(color2.hashCode));
    });

    test('toHexString', () {
      expect(DiscordColor(0xffed12).toHexString(), equals('#FFED12'));
      expect(DiscordColor(0).toHexString(), equals('#000000'));
    });

    test('fromRgb', () {
      final color = DiscordColor.fromRgb(123, 213, 132);

      expect(color.r, equals(123));
      expect(color.g, equals(213));
      expect(color.b, equals(132));
    });

    test('fromScaledRgb', () {
      final color = DiscordColor.fromScaledRgb(1.0, 0.5, 0.0);

      expect(color.r, equals(255));
      expect(color.g, equals(127));
      expect(color.b, equals(0));
    });

    test('parseHexString', () {
      final color = DiscordColor.parseHexString('#ffed12');

      expect(color, equals(DiscordColor(0xffed12)));
    });

    test('max value', () {
      final color = DiscordColor(0xffffff);

      expect(color.value, equals(0xffffff));
    });
  });
}
