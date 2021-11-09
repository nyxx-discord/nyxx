import 'package:nyxx/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/enum.mock.dart';

void main() {
  group("Utils", () {
    final inputData = [1, 2, 3, 4];

    test(".firstWhereSafe has element", () {
      final result = inputData.firstWhereSafe((element) => element == 2);

      expect(result, equals(2));
    });

    test(".firstWhereSafe missing element no else", () {
      final result = inputData.firstWhereSafe((element) => element == 10);

      expect(result, isNull);
    });

    test(".firstWhereSafe missing element has else", () {
      final result = inputData.firstWhereSafe((element) => element == 10, orElse: () => -1);

      expect(result, equals(-1));
    });

    test(".firstWhereSafe missing element has else returns null", () {
      final result = inputData.firstWhereSafe((element) => element == 10, orElse: () => null);

      expect(result, isNull);
    });

    test('chunk', () {
      final result = Utils.chunk([1, 2, 3, 4], 2);

      expect(
          result,
          emitsInOrder([
            [1, 2],
            [3, 4]
          ]));
    });
  });

  test('extensions', () {
    final intExtensionResult = 123.toSnowflakeEntity();
    expect(intExtensionResult.id.id, equals(123));

    final stringToSnowflakeResult = "456".toSnowflake();
    expect(stringToSnowflakeResult.id, equals(456));

    final stringToSnowflakeEntityResult = "789".toSnowflakeEntity();
    expect(stringToSnowflakeEntityResult.id.id, equals(789));

    final snowflakeEntityListExtensionsResult = [intExtensionResult, stringToSnowflakeEntityResult].asSnowflakes();
    expect(snowflakeEntityListExtensionsResult, [intExtensionResult.id, stringToSnowflakeEntityResult.id]);
  });

  test("IEnum", () {
    final fistEnum = EnumMock('test');
    final secondEnum = EnumMock("test2");

    expect(fistEnum, isNot(equals(secondEnum)));

    expect(fistEnum.toString(), 'test');
    expect(fistEnum.hashCode, 'test'.hashCode);
  });
}
