import "dart:convert";
import "dart:io";

import "package:nyxx/nyxx.dart";
import "package:test/test.dart";

const snowflakeAYear = 2017;
const snowflakeBYear = 2018;

void main() {
  final snowflakeA = Snowflake.fromDateTime(DateTime.utc(snowflakeAYear));
  final snowflakeB = Snowflake.fromDateTime(DateTime.utc(snowflakeBYear));

  group("Snowflake tests", () {
    test("Snowflakes should have correct date", () {
      expect(snowflakeA.timestamp.year, snowflakeAYear);
      expect(snowflakeB.timestamp.year, snowflakeBYear);
    });

    test("Snowflake A should have timestamp before Snowflake B", () {
      expect(snowflakeA.isBefore(snowflakeB), true);
      expect(snowflakeB.isAfter(snowflakeA), true);
    });

    test("Snowflake.fromNow() returns valid snowflake", () {
      final snowflake = Snowflake.fromNow();
      final now = DateTime.now();

      expect(snowflake.timestamp.compareTo(now), -1);
    });

    test("Snowflake compareDates returns valid results", () {
      expect(Snowflake.compareDates(snowflakeA, snowflakeB), -1);
      expect(Snowflake.compareDates(snowflakeB, snowflakeA), 1);

      final snowflakeAClone = Snowflake.fromDateTime(DateTime.utc(snowflakeAYear));

      expect(Snowflake.compareDates(snowflakeA, snowflakeAClone), 0);
    });

    test("Snowflake equality", () {
      const snowflakeValue = 123;
      final snowflake = snowflakeValue.toSnowflake();
      final snowflake2 = snowflakeValue.toSnowflake();

      expect(snowflake.id, snowflakeValue);

      expect(snowflake == snowflakeValue, true);
      expect(snowflake2 == snowflake, true);
      expect(snowflake == snowflakeValue.toString(), true);

      expect(snowflake == 125, false);
    });
  });

  test("SnowflakeEntity equality", () {
    final snowflakeEntityA = SnowflakeEntity(snowflakeA);

    expect(snowflakeEntityA.id == snowflakeA, true);
    expect(snowflakeEntityA.createdAt == snowflakeA.timestamp, true);

    expect(snowflakeEntityA == snowflakeA, true);
  });

  group("Generic utils", () {
    test("Utils.getBase64UploadString returns valid string", () {
      final kittyFile = File("./test/kitty.webp");
      const extension = "webp";

      final encodedKitty = base64Encode(kittyFile.readAsBytesSync());

      final expectedStringFile = "data:image/$extension;base64,$encodedKitty";
      expect(Utils.getBase64UploadString(file: kittyFile, fileExtension: extension), expectedStringFile);
      expect(Utils.getBase64UploadString(fileBytes: kittyFile.readAsBytesSync(), fileExtension: extension), expectedStringFile);
      expect(Utils.getBase64UploadString(base64EncodedFile: encodedKitty, fileExtension: extension), expectedStringFile);
    }, skip: "Skipped for now because of problems with required path to file");

    test("Utils.chunk returns valid chunks", () async {
      final testList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
      final chunks = Utils.chunk(testList, 2);

      expect(chunks, emitsInOrder([
        [0, 1],
        [2, 3],
        [4, 5],
        [6, 7],
        [8, 9]
      ]));
    });
  });

  group("Permission utils", () {
    test("PermissionsUtils.apply returns valid int", () {
      final appliedPermissions = PermissionsUtils.apply(0x01, 0x10, 0x01);
      expect(appliedPermissions, 0x10);
    });

    test("PermissionsUtils.isApplied returns valid result", () {
      const permissionInt = 0x01;

      expect(PermissionsUtils.isApplied(permissionInt, 0x01), true);
      expect(PermissionsUtils.isApplied(permissionInt, 0x10), false);
    });
  });
}