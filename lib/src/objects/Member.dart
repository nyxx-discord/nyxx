import '../objects.dart';

/// A guild member.
class Member {
  /// The member's nickname, null if not set.
  String nickname;

  /// When the member joined the guild.
  String joinedAt;

  /// Weather or not the member is deafened.
  bool deaf;

  /// Weather or not the member is muted.
  bool mute;

  /// A list of role IDs the member has.
  List<String> roles;

  /// The [User] object for the member.
  User user;

  /// The guild that the member is a part of.
  Guild guild;

  Member(Map data, Guild guild) {
    this.nickname = data['nick'];
    this.joinedAt = data['joined_at'];
    this.deaf = data['deaf'];
    this.mute = data['mute'];
    this.roles = data['roles'];
    this.user = new User(data['user']);
    this.guild = guild;
  }
}
