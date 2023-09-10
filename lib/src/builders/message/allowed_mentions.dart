import 'package:nyxx/src/models/snowflake.dart';

class AllowedMentions {
  List<String>? parse;

  List<Snowflake>? users;

  List<Snowflake>? roles;

  bool? repliedUser;

  AllowedMentions({this.parse, this.users, this.roles, this.repliedUser});

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

    bool? repliedUser = this.repliedUser;
    if (repliedUser != null && other.repliedUser != null) {
      repliedUser = repliedUser || other.repliedUser!;
    } else {
      repliedUser ??= other.repliedUser;
    }

    return AllowedMentions(
      parse: parse,
      users: users,
      roles: roles,
      repliedUser: repliedUser,
    );
  }

  AllowedMentions operator &(AllowedMentions other) {
    List<String>? parse;
    if (this.parse != null && other.parse != null) {
      // If both this and other provide parse, perform the intersection
      parse = this.parse!.where((element) => other.parse!.contains(element)).toList();
    } else if ((this.parse == null) ^ (other.parse == null)) {
      // If only one of this and other supply parse, don't allow anything.
      parse = [];
    }

    List<Snowflake>? users;
    if (this.users != null && other.users != null) {
      // If both this an other provide users, perform the intersection
      users = this.users!.where(other.users!.contains).toList();
    } else if (this.parse?.contains('users') == true || other.parse?.contains('users') == true) {
      // Otherwise, if one of this or other supplies user and the other has 'users' in its parse, use the users from whichever provides it.
      // This assumes correctly formatted AllowedMentions that don't both provide users and have 'users' in its parse
      users = this.users ?? other.users;
    } else if ((this.users == null) ^ (other.users == null)) {
      // If only one of this and other provide users, don't allow anything.
      users = [];
    }

    List<Snowflake>? roles;
    // Same as above
    if (this.roles != null && other.roles != null) {
      roles = this.users!.where(other.roles!.contains).toList();
    } else if (this.parse?.contains('roles') == true || other.parse?.contains('roles') == true) {
      roles = this.roles ?? other.roles;
    } else if ((this.roles == null) ^ (other.roles == null)) {
      roles = [];
    }

    return AllowedMentions(
      parse: parse,
      roles: roles,
      users: users,
      repliedUser: repliedUser == true && other.repliedUser == true,
    );
  }

  Map<String, Object?> build() => {
        if (parse != null) 'parse': parse,
        if (users != null && users!.isNotEmpty) 'users': users!.map((e) => e.toString()).toList(),
        if (roles != null && roles!.isNotEmpty) 'roles': roles!.map((e) => e.toString()).toList(),
        if (repliedUser != null) 'replied_user': repliedUser,
      };
}
