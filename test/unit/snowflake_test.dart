import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/utils/extensions.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group("Snowflake", () {
    test(".toSnowflake()", () {
      const rawSnowflake = 901383075009806336;
      final snowflake = rawSnowflake.toSnowflake();

      expect(snowflake.id, rawSnowflake);
    });

    test("DateTime", () {
      final snowflake = Snowflake(901383332011593750);

      expect(snowflake.timestamp, DateTime.fromMillisecondsSinceEpoch(1634976933244).toUtc());
    });

    test(".fromNow()", () {
      final firstNowSnowflake = Snowflake.fromNow();
      final secondNowSnowflake = Snowflake.fromNow();

      expect(firstNowSnowflake.timestamp.millisecondsSinceEpoch, lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch));
      expect(firstNowSnowflake.timestamp.millisecondsSinceEpoch, lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch));

      expect(firstNowSnowflake.timestamp.millisecondsSinceEpoch, lessThanOrEqualTo(secondNowSnowflake.timestamp.millisecondsSinceEpoch));
    });

    test(".bulk()", () {
      final bulkSnowflake = Snowflake.bulk();

      expect(bulkSnowflake.timestamp.millisecondsSinceEpoch, lessThanOrEqualTo(DateTime.now().subtract(Duration(days: 14)).millisecondsSinceEpoch));
    });

    test(".fromDateTime()", () {
      final now = DateTime.now();

      final firstFromDateSnowflake = Snowflake.fromDateTime(now);
      final secondFromDateSnowflake = Snowflake.fromDateTime(now);

      expect(firstFromDateSnowflake.timestamp.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
      expect(firstFromDateSnowflake, equals(secondFromDateSnowflake));
    });

    test(".isZero", () {
      final zeroSnowflake = Snowflake(0);
      final nonZeroSnowflake = Snowflake(123);

      expect(zeroSnowflake.isZero, isTrue);
      expect(nonZeroSnowflake.isZero, isFalse);
    });

    test(".toSnowflakeEntity", () {
      final testSnowflake = Snowflake(123);

      final resultingSnowflakeEntity = testSnowflake.toSnowflakeEntity();

      expect(resultingSnowflakeEntity.id, equals(testSnowflake));
      expect(resultingSnowflakeEntity, equals(testSnowflake));
    });

    test(".isBefore", () {
      final firstSnowflake = Snowflake.fromDateTime(DateTime(2016));
      final secondSnowflake = Snowflake.fromDateTime(DateTime(2020));

      expect(firstSnowflake.isBefore(secondSnowflake), isTrue);
      expect(secondSnowflake.isBefore(firstSnowflake), isFalse);
    });

    test(".isAfter", () {
      final firstSnowflake = Snowflake.fromDateTime(DateTime(2016));
      final secondSnowflake = Snowflake.fromDateTime(DateTime(2020));

      expect(firstSnowflake.isAfter(secondSnowflake), isFalse);
      expect(secondSnowflake.isAfter(firstSnowflake), isTrue);
    });

    test(".compareDates", () {
      final firstSnowflake = Snowflake.fromDateTime(DateTime(2016));
      final secondSnowflake = Snowflake.fromDateTime(DateTime(2020));

      expect(Snowflake.compareDates(firstSnowflake, secondSnowflake), lessThan(0));
      expect(Snowflake.compareDates(secondSnowflake, firstSnowflake), greaterThan(0));
      expect(Snowflake.compareDates(secondSnowflake, secondSnowflake), equals(0));
      expect(Snowflake.compareDates(firstSnowflake, firstSnowflake), equals(0));
    });

    test(".compareTo", () {
      final firstSnowflake = Snowflake.fromDateTime(DateTime(2016));
      final secondSnowflake = Snowflake.fromDateTime(DateTime(2020));

      expect(firstSnowflake.compareTo(secondSnowflake), lessThan(0));
      expect(secondSnowflake.compareTo(firstSnowflake), greaterThan(0));
      expect(secondSnowflake.compareTo(secondSnowflake), equals(0));
      expect(firstSnowflake.compareTo(firstSnowflake), equals(0));
    });

    test(".toString", () {
      final testSnowflake = Snowflake(123);

      expect(testSnowflake.toString(), equals("123"));
    });

    test(".hashCode", () {
      final snowflakeValue = 123;
      final testSnowflake = Snowflake(snowflakeValue);

      expect(testSnowflake.hashCode, equals(snowflakeValue.hashCode));
    });

    test("InvalidSnowflakeException", () {
      expect(() => Snowflake(true), throwsA(isA<InvalidSnowflakeException>()));
      expect(() => Snowflake(1.12), throwsA(isA<InvalidSnowflakeException>()));
      expect(() => Snowflake(DateTime.now()), throwsA(isA<InvalidSnowflakeException>()));
      expect(() => Snowflake(() => "test"), throwsA(isA<InvalidSnowflakeException>()));
      expect(() => Snowflake("123test"), throwsA(isA<InvalidSnowflakeException>()));
      expect(() => Snowflake("test123"), throwsA(isA<InvalidSnowflakeException>()));
      expect(() => Snowflake("test 123"), throwsA(isA<InvalidSnowflakeException>()));
      expect(() => Snowflake("123 test"), throwsA(isA<InvalidSnowflakeException>()));
    });
  });
}
