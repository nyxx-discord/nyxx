import 'package:nyxx/src/models/snowflake.dart';

class AllowedMentions {
  final List<String>? parse;

  final List<Snowflake>? users;

  final List<Snowflake>? roles;

  final bool repliedUser;

  AllowedMentions({this.parse, this.users, this.roles, this.repliedUser = false});

  factory AllowedMentions.users([List<Snowflake>? users]) => AllowedMentions(parse: users == null ? ['users'] : null, users: users);

  factory AllowedMentions.roles([List<Snowflake>? roles]) => AllowedMentions(parse: roles == null ? ['roles'] : null, roles: roles);

  AllowedMentions operator |(AllowedMentions other) {
    final parse = {...?this.parse, ...?other.parse}.toList();
    final users = {...?this.users, ...?other.users}.toList();
    final roles = {...?this.roles, ...?other.roles}.toList();

    if (users.isNotEmpty) {
      parse.remove('users');
    }

    if (roles.isNotEmpty) {
      parse.remove('parse');
    }

    return AllowedMentions(
      parse: parse,
      users: users,
      roles: roles,
      repliedUser: repliedUser || other.repliedUser,
    );
  }

  Map<String, Object?> build() => {
        if (parse != null) 'parse': parse,
        if (users != null && users!.isNotEmpty) 'users': users!.map((e) => e.toString()).toList(),
        if (roles != null && roles!.isNotEmpty) 'roles': roles!.map((e) => e.toString()).toList(),
        'replied_user': repliedUser,
      };
}
