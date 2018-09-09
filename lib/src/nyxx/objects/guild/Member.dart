part of nyxx;

/// A guild member.
class Member extends User {
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
  Presence presence;

  /// A list of role IDs the member has.
  List<Role> roles;

  /// The guild that the member is a part of.
  Guild guild;

  /// Returns user instance of member
  User get user => client.users[id];

  /// Returs highest role for member
  Role get highestRole =>
      roles.reduce((f, s) => f.position > s.position ? f : s);

  Role get color => roles
      .where((r) => r.color != null)
      .reduce((f, s) => f.position > s.position ? f : s);

  /// Returns total permissions of user.
  Permissions get totalPermissions {
    var total = 0;
    for (var role in roles) total |= role.permissions.raw;

    return Permissions.fromInt(total);
  }

  Member._new(Nyxx client, Map<String, dynamic> data, [Guild guild])
      : super._new(client, data['user'] as Map<String, dynamic>, false) {
    this.nickname = data['nick'] as String;
    this.deaf = data['deaf'] as bool;
    this.mute = data['mute'] as bool;
    this.status = data['status'] as String;

    if (guild == null)
      this.guild = this.client.guilds[Snowflake(data['guild_id'] as String)];
    else
      this.guild = guild;

    if (data['roles'] != null) {
      roles = List();
      data['roles'].forEach((i) {
        roles.add(this.guild.roles[Snowflake(i as String)]);
      });
    }

    if (data['joined_at'] != null)
      this.joinedAt = DateTime.parse(data['joined_at'] as String);

    if (data['game'] != null)
      this.presence = Presence._new(this.client, data['game'] as Map<String, dynamic>);

    if (guild != null) this.guild.members[this.id] = this;
    client.users[this.id] = this;
  }

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<void> ban(
      {int deleteMessageDays = 0,
      String reason,
      String auditReason = ""}) async {
    await this.client.http.send(
        'PUT', "/guilds/${this.guild.id}/bans/${this.id}",
        body: {"delete-message-days": deleteMessageDays, "reason": reason},
        reason: auditReason);
  }

  /// Adds role to user
  ///
  /// ```
  /// var r = guild.roles.values.first;
  /// await member.addRole(r);
  /// ```
  Future<void> addRole(Role role, {String auditReason = ""}) async {
    await this.client.http.send(
        'PUT', '/guilds/${guild.id}/members/${this.id}/roles/${role.id}',
        reason: auditReason);
    return null;
  }

  Future<void> removeRole(Role role, {String auditReason = ""}) async {
    await this.client.http.send("DELETE",
        "/guilds/${this.guild.id.toString()}/members/${this.id.toString()}/roles/${role.id.toString()}",
        reason: auditReason);
  }

  /// Kicks the member
  Future<void> kick({String auditReason = ""}) async {
    await this.client.http.send(
        'DELETE', "/guilds/${this.guild.id}/members/${this.id}",
        reason: auditReason);
  }

  Future<void> edit(
      {String nick,
      List<Role> roles,
      bool mute,
      bool deaf,
      VoiceChannel channel,
      String auditReason = ""}) async {
    var req = Map<String, dynamic>();
    if (nick != null) req["nick"] = nick;
    if (roles != null) req['roles'] = roles.map((f) => f.id.toString());
    if (mute != null) req['mute'] = mute;
    if (deaf != null) req['deaf'] = deaf;
    if (deaf != null) req['channel_id'] = channel.id.toString();

    await this.client.http.send("PATCH",
        "/guilds/${this.guild.id.toString()}/members/${this.id.toString()}",
        body: req, reason: auditReason);
  }

  @override
  String toString() => super.toString();
}
