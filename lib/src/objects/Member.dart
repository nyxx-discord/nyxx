part of discord;

/// A guild member.
class Member extends User {
  User _user;

  /// The member's nickname, null if not set.
  String nickname;

  /// The member's status, `offline`, `online`, `idle`, or `dnd`.
  String status;

  /// When the member joined the guild.
  DateTime joinedAt;

  /// Weather or not the member is deafened.
  bool deaf;

  /// Weather or not the member is muted.
  bool mute;

  /// The member's game.
  Game game;

  /// A list of role IDs the member has.
  List<String> roles;

  /// The guild that the member is a part of.
  Guild guild;

  Member._new(Client client, Map<String, dynamic> data, [Guild guild])
      : super._new(client, data['user'] as Map<String, dynamic>) {
    this.nickname = this._map['nickname'] = data['nick'];
    this.deaf = this._map['deaf'] = data['deaf'];
    this.mute = this._map['mute'] = data['mute'];
    this.status = this._map['status'] = data['status'];
    this.roles = this._map['roles'] = data['roles'] as List<String>;
    this._user = new User._new(client, data['user'] as Map<String, dynamic>);

    if (guild == null) {
      this.guild = this._client.guilds[data['guild_id']];
    } else {
      this.guild = this._map['guild'] = guild;
    }

    if (data['joined_at'] != null) {
      this.joinedAt = this._map['joinedAt'] = DateTime.parse(data['joined_at']);
    }

    if (data['game'] != null) {
      this.game = this._map['game'] =
          new Game._new(this._client, ['game'] as Map<String, dynamic>);
    }
  }

  /// Returns a user from the member.
  User toUser() {
    return this._user;
  }
}
