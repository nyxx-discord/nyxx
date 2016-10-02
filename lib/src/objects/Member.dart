import '../../discord.dart';

/// A guild member.
class Member extends User {
  User _user;

  /// The member's nickname, null if not set.
  String nickname;

  /// When the member joined the guild.
  DateTime joinedAt;

  /// Weather or not the member is deafened.
  bool deaf;

  /// Weather or not the member is muted.
  bool mute;

  /// A list of role IDs the member has.
  List<String> roles;

  /// The guild that the member is a part of.
  Guild guild;

  /// Constructs a new [Member].
  Member(Client client, Map<String, dynamic> data, Guild guild)
      : super(client, data['user'] as Map<String, dynamic>) {
    this.nickname = this.map['nickname'] = data['nick'];
    this.deaf = this.map['deaf'] = data['deaf'];
    this.mute = this.map['mute'] = data['mute'];
    this.roles = this.map['roles'] = data['roles'] as List<String>;
    this.guild = this.map['guild'] = guild;
    this._user = new User(client, data['user'] as Map<String, dynamic>);

    if (data['joined_at'] != null) {
      this.joinedAt = this.map['joinedAt'] = DateTime.parse(data['joined_at']);
    }
  }

  /// Returns a user from the member.
  User toUser() {
    return this._user;
  }
}
