import 'package:nyxx/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

main() {
  test(".createdAt", () {
    final testSnowflake = Snowflake.fromNow();
    final testSnowflakeEntity = SnowflakeEntity(testSnowflake);

    expect(testSnowflake.timestamp, equals(testSnowflakeEntity.createdAt));
  });

  test(".toString", () {
    final testSnowflake = Snowflake(123);
    final testSnowflakeEntity = SnowflakeEntity(testSnowflake);

    expect(testSnowflakeEntity.toString(), equals('123'));
  });

  test(".==", () {
    final testSnowflake = Snowflake(123);
    final testSnowflakeEntity = SnowflakeEntity(testSnowflake);

    expect(testSnowflakeEntity, equals(testSnowflakeEntity));
    expect(testSnowflakeEntity, equals(testSnowflake));
    expect(123, equals(testSnowflakeEntity));
    expect('123', equals(testSnowflakeEntity));

    expect(DateTime.now(), isNot(equals(testSnowflakeEntity)));
    expect('random-stuff', isNot(equals(testSnowflakeEntity)));
  });

  test(".hashCode", () {
    final snowflakeValue = 123;
    final testSnowflake = Snowflake(123);
    final testSnowflakeEntity = SnowflakeEntity(testSnowflake);

    expect(snowflakeValue.hashCode, equals(testSnowflake.hashCode));
    expect(snowflakeValue.hashCode, equals(testSnowflakeEntity.hashCode));
  });
}
