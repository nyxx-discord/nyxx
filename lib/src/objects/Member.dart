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
    this.nickname = data['nick'];
    this.deaf = data['deaf'];
    this.mute = data['mute'];
    this.status = data['status'];
    this.roles = data['roles'] as List<String>;
    this._user = new User._new(client, data['user'] as Map<String, dynamic>);

    if (guild == null) {
      this.guild = this._client.guilds[data['guild_id']];
    } else {
      this.guild = guild;
    }

    if (data['joined_at'] != null) {
      this.joinedAt = DateTime.parse(data['joined_at']);
    }

    if (data['game'] != null) {
      this.game =
          new Game._new(this._client, data['game'] as Map<String, dynamic>);
    }

    this.guild.members[this.id] = this;
    client.users[this.toUser().id] = this.toUser();
  }

  /// Returns a user from the member.
  User toUser() {
    return this._user;
  }

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<Null> ban([int deleteMessageDays = 0]) async {
    await this._client._http.put("/guilds/${this.guild.id}/bans/${this.id}",
        {"delete-message-days": deleteMessageDays});
    return null;
  }

  /// Kicks the member
  Future<Null> kick() async {
    await this
        ._client
        ._http
        .delete("/guilds/${this.guild.id}/members/${this.id}");
    return null;
  }
}
