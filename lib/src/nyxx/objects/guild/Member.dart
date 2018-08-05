part of nyxx;

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
  List<Role> roles;

  /// The guild that the member is a part of.
  Guild guild;

  Member._new(Client client, Map<String, dynamic> data, [Guild guild])
      : super._new(client, data['user'] as Map<String, dynamic>) {
    this.nickname = data['nick'] as String;
    this.deaf = data['deaf'] as bool;
    this.mute = data['mute'] as bool;
    this.status = data['status'] as String;

    if (guild == null)
      this.guild = this.client.guilds[data['guild_id']];
    else
      this.guild = guild;

    roles = new List();
    data['roles'].forEach((dynamic id) {
      roles.add(this.guild.roles.values.firstWhere((i) => i.id == id));
    });

    this._user = new User._new(client, data['user'] as Map<String, dynamic>);

    roles = new List();
    data['roles'].forEach((dynamic i) {
      roles.add(this.guild.roles[i]);
    });

    if (data['joined_at'] != null)
      this.joinedAt = DateTime.parse(data['joined_at'] as String);

    if (data['game'] != null)
      this.game =
          new Game._new(this.client, data['game'] as Map<String, dynamic>);

    if (guild != null) this.guild.members[this.id.toString()] = this;
    client.users[this.toUser().id.toString()] = this.toUser();
  }

  /// Returns a user from the member.
  User toUser() => this._user;

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<Null> ban({int deleteMessageDays = 0, String auditReason: ""}) async {
    await this.client.http.send(
        'PUT', "/guilds/${this.guild.id}/bans/${this.id}",
        body: {"delete-message-days": deleteMessageDays}, reason: auditReason);
    return null;
  }

  /// Kicks the member
  Future<Null> kick({String auditReason: ""}) async {
    await this.client.http.send(
        'DELETE', "/guilds/${this.guild.id}/members/${this.id}",
        reason: auditReason);
    return null;
  }

  Future<Permissions> getTotalPermissions() async {
    var total = 0;
    for (var role in roles) total |= role.permissions.raw;

    return new Permissions.fromInt(total);
  }
}
