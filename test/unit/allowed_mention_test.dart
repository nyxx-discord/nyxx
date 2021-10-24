import 'package:nyxx/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

main() {
  test(".allow", () {
    final testAllowed = AllowedMentions();

    testAllowed.allow(reply: true, everyone: true, roles: true, users: true);

    final buildResult = testAllowed.build();
    final expectedResult = <String, dynamic>{
      "parse": [
        "everyone",
        "roles",
        "users",
      ],
      "replied_user": true
    };

    expect(expectedResult, equals(buildResult));
  });

  test('.suppressUser exception', () {
    final testAllowed = AllowedMentions()
        ..allow(users: false)
        ..suppressUser(Snowflake(123));

    expect(() => testAllowed.build(), throwsA(isA<ArgumentError>()));
  });

  test('.suppressUser', () {
    final testAllowed = AllowedMentions()
      ..allow(users: true)
      ..suppressUser(Snowflake(123))
      ..suppressUsers([
        Snowflake(456),
        Snowflake(789),
      ]);

    final expectedResult = <String, dynamic>{
      'parse': ['users'],
      'replied_user': false,
      'users': [
        '123',
        '456',
        '789',
      ]
    };

    expect(expectedResult, equals(testAllowed.build()));
  });

  test('.suppressRole exception', () {
    final testAllowed = AllowedMentions()
      ..allow(users: false)
      ..suppressRole(Snowflake(123));

    expect(() => testAllowed.build(), throwsA(isA<ArgumentError>()));
  });

  test('.suppressRole', () {
    final testAllowed = AllowedMentions()
      ..allow(roles: true)
      ..suppressRole(Snowflake(123))
      ..suppressRoles([
        Snowflake(456),
        Snowflake(789),
      ]);

    final expectedResult = <String, dynamic>{
      'parse': ['roles'],
      'replied_user': false,
      'roles': [
        '123',
        '456',
        '789',
      ]
    };

    expect(expectedResult, equals(testAllowed.build()));
  });
}
