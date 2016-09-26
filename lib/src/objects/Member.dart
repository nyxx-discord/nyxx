import '../../discord.dart';

/// A guild member.
class Member extends User{
  User _user;

  /// The client.
  Client client;

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

  /// Constructs a new [Member].
  Member(Client client, Map<String, dynamic> data, Guild guild) : super(client, data['user']) {
    this.client = client;

    this.nickname = this.map['nickname'] = data['nick'];
    this.joinedAt = this.map['joinedAt'] = data['joined_at'];
    this.deaf = this.map['deaf'] = data['deaf'];
    this.mute = this.map['mute'] = data['mute'];
    this.roles = this.map['roles'] = data['roles'];
    this.guild = this.map['guild'] = guild;
    this._user = new User(client, data['user']);
  }

  /// Returns a string representation of this object.
  String toString() {
    return this.username;
  }

  /// Returns a user from the member.
  User toUser() {
    return this._user;
  }
}
