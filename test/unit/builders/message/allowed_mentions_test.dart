import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  group('AllowedMentions', () {
    test('build', () {
      final builder = AllowedMentions(
        parse: ['a', 'b', 'c'],
        repliedUser: false,
        roles: [Snowflake.zero],
        users: [Snowflake(1)],
      );

      expect(
        builder.build(),
        equals({
          'parse': ['a', 'b', 'c'],
          'replied_user': false,
          'roles': ['0'],
          'users': ['1'],
        }),
      );
    });

    test('operator |', () {
      final a = AllowedMentions.users([Snowflake(1), Snowflake(2), Snowflake(3)]);
      final b = AllowedMentions(
        repliedUser: true,
        users: [Snowflake(1)],
        roles: [Snowflake.zero],
        parse: ['everyone'],
      );

      final builder = a | b;

      expect(builder.parse, equals(['everyone']));
      expect(builder.users, equals([Snowflake(1), Snowflake(2), Snowflake(3)]));
      expect(builder.roles, equals([Snowflake.zero]));
      expect(builder.repliedUser, isTrue);
    });

    test('operator &', () {
      final a = AllowedMentions.users([Snowflake(1), Snowflake(2), Snowflake(3)]);
      final b = AllowedMentions(
        repliedUser: true,
        users: [Snowflake(1)],
        roles: [Snowflake.zero],
        parse: ['everyone'],
      );

      final builder = a & b;

      expect(builder.parse, []);
      expect(builder.users, equals([Snowflake(1)]));
      expect(builder.roles, []);
      expect(builder.repliedUser, isFalse);
    });
  });
}
