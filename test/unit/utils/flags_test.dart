import 'package:nyxx/src/utils/flags.dart';
import 'package:test/test.dart';

void main() {
  group('Flag', () {
    test('fromOffset gives the correct value', () {
      expect(Flag<Never>.fromOffset(0).value, equals(1 << 0));
      expect(Flag<Never>.fromOffset(1).value, equals(1 << 1));
      expect(Flag<Never>.fromOffset(10).value, equals(1 << 10));
    });
  });

  group('Flags', () {
    test('has checks for flags correctly', () {
      final zeroFlag = Flag<Never>.fromOffset(0);
      final oneFlag = Flag<Never>.fromOffset(1);

      final flags = Flags<Never>(1);

      expect(flags.has(zeroFlag), isTrue);
      expect(flags.has(oneFlag), isFalse);
    });

    test('equality', () {
      expect(Flags<Never>(1), equals(Flags<Never>(1)));
    });

    test('|', () {
      final flags = Flags<Never>(3) | Flag<Never>.fromOffset(2) | Flags<Never>(0xff00);

      expect(flags, equals(Flags<Never>(0xff07)));
    });

    test('iterator', () {
      final flags = Flag<Never>.fromOffset(3) | Flag<Never>.fromOffset(2) | Flag<Never>.fromOffset(10);

      expect(flags, hasLength(3));
      expect(flags.first, equals(Flag<Never>.fromOffset(2)));
      expect(flags.last, equals(Flag<Never>.fromOffset(10)));
    });
  });
}
