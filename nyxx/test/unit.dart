import "dart:convert";
import "dart:io";

import "package:nyxx/nyxx.dart";
import "package:test/test.dart";

const snowflakeAYear = 2017;
const snowflakeBYear = 2018;

final snowflakeA = Snowflake.fromDateTime(DateTime.utc(snowflakeAYear));
final snowflakeB = Snowflake.fromDateTime(DateTime.utc(snowflakeBYear));

final sampleUserRawData = {
  "id": 123,
  "username": "Test test",
  "discriminator": "123",
  "avatar": null,
  "bot": false,
  "system": false,
  "public_flags": 1 << 0 // Discord employee
};

final sampleMemberData = {
  "user": {
    "id": 123
  },
  "nick": "This is nick",
  "deaf": false,
  "mute": false,
  "roles": [
    "1234564"
    "1234563"
  ],
  "joined_at": DateTime.now().toIso8601String()
};

final client = NyxxRest("dum", 0);

void main() {
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

  group("Cache utils", () {
    test("Cacheable User", () {
      final cacheable = CacheUtility.createCacheableUser(client, 123.toSnowflake());
      expect(123.toSnowflake(), cacheable.id);
    });

    test("Cacheable Guild", () {
      final cacheable = CacheUtility.createCacheableGuild(client, 123.toSnowflake());
      expect(123.toSnowflake(), cacheable.id);
    });

    test("Cacheable Role", () {
      final cacheableGuild = CacheUtility.createCacheableGuild(client, 123.toSnowflake());
      final cacheable = CacheUtility.createCacheableRole(client, 123.toSnowflake(), cacheableGuild);
      expect(123.toSnowflake(), cacheable.id);
      expect(123.toSnowflake(), cacheableGuild.id);
    });

    test("Cacheable Channel", () {
      final cacheable = CacheUtility.createCacheableChannel(client, 123.toSnowflake());
      expect(123.toSnowflake(), cacheable.id);
    });

    test("Cacheable Member", () {
      final cacheableGuild = CacheUtility.createCacheableGuild(client, 123.toSnowflake());
      final cacheable = CacheUtility.createCacheableMember(client, 123.toSnowflake(), cacheableGuild);
      expect(123.toSnowflake(), cacheable.id);
      expect(123.toSnowflake(), cacheableGuild.id);
    });

    test("Cacheable Message", () {
      final cacheableChannel = CacheUtility.createCacheableTextChannel(client, 123.toSnowflake());
      final cacheable = CacheUtility.createCacheableMessage(client, 123.toSnowflake(), cacheableChannel);
      expect(123.toSnowflake(), cacheable.id);
      expect(123.toSnowflake(), cacheableChannel.id);
    });
  });

  group("Entity utils", () {
    test("Create user object", () {
      final user = EntityUtility.createUser(client, sampleUserRawData);

      expect(123.toSnowflake(), user.id);
      expect("Test test", user.username);
      expect(123, user.discriminator);
      expect(user.avatarURL(), isNotNull);
      expect(user.avatarURL(), contains("${123 % 5}.png"));
      expect(user.bot, false);
      expect(user.system, false);
      expect(user.userFlags, isNotNull);
      expect(user.userFlags!.discordEmployee, true);
      expect(user.userFlags!.earlySupporter, false);
    });

    test("Create member object", () {
      final member = EntityUtility.createGuildMember(client, 123.toSnowflake(), sampleMemberData);

    });
  });
}