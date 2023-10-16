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

      final builder2 = AllowedMentions.roles([Snowflake.zero]);

      expect(
        builder2.build(),
        equals({
          'roles': ['0'],
        }),
      );

      final builder3 = AllowedMentions.users();

      expect(
        builder3.build(),
        equals({
          'parse': ['users'],
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

      final parseIntersect1 = AllowedMentions(parse: ['users', 'roles']);
      final parseIntersect2 = AllowedMentions(parse: ['roles', 'everyone']);

      expect((parseIntersect1 & parseIntersect2).parse, equals(['roles']));

      final user1 = AllowedMentions.users();
      final user2 = AllowedMentions(users: [Snowflake.zero]);

      expect((user1 & user2).parse, isEmpty);
      expect((user1 & user2).users, equals([Snowflake.zero]));

      final user3 = AllowedMentions();

      expect((user1 & user3).parse, isEmpty);
      expect((user1 & user3).users, isNull);

      final role1 = AllowedMentions.roles();
      final role2 = AllowedMentions(roles: [Snowflake.zero]);

      expect((role1 & role2).parse, isEmpty);
      expect((role1 & role2).roles, equals([Snowflake.zero]));

      final role3 = AllowedMentions();

      expect((role1 & role3).parse, isEmpty);
      expect((role1 & role3).roles, isNull);
    });
  });
}
