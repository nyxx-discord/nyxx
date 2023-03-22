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
  });
}
