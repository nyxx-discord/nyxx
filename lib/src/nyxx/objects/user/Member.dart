part of nyxx;

/// A user with [Guild] context.
class Member extends User {
  /// The member's nickname, null if not set.
  String nickname;

  /// The member's status. `offline`, `online`, `idle`, or `dnd`.
  MemberStatus status;

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
  
  Snowflake _guildId;
  
  /// The guild that the member is a part of.
  Guild get guild => client.guilds[_guildId];

  /// Returns highest role for member
  Role get highestRole =>
      roles.reduce((f, s) => f.position > s.position ? f : s);

  int get color => roles
      .where((r) => r.color > 0)
      .reduce((f, s) => f.position > s.position ? f : s)
      .color;

  /// Voice state
  VoiceState get voiceState => guild.voiceStates[this.id];

  /// Returns total permissions of user.
  Permissions get totalPermissions {
    var total = 0;
    for (var role in roles) total |= role.permissions.raw;

    return Permissions.fromInt(total);
  }

  Member._reverse(Map<String, dynamic> data, Guild guild) : super._new(data) {
    this._guildId = guild.id;
    _cons(data['member'] as Map<String, dynamic>, guild);
  }

  Member._new(Map<String, dynamic> data, Guild guild)
      : super._new(data['user'] as Map<String, dynamic>) {
    this._guildId = guild.id;
    _cons(data, guild);
  }

  void _cons(Map<String, dynamic> data, Guild guild) {
    this.nickname = data['nick'] as String;
    this.deaf = data['deaf'] as bool;
    this.mute = data['mute'] as bool;
    this.status = MemberStatus.from(data['status'] as String);

    if (data['roles'] != null && guild.roles != null) {
      this.roles = List();
      data['roles'].forEach((i) {
        this.roles.add(guild.roles[Snowflake(i as String)]);
      });
    }

    if (data['joined_at'] != null)
      this.joinedAt = DateTime.parse(data['joined_at'] as String).toUtc();

    if (data['game'] != null)
      this.presence = Presence._new(data['game'] as Map<String, dynamic>);
  }

  /// Checks if member has specified role
  bool hasRole(bool Function(Role role) func) => this.roles.any(func);

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<void> ban(
      {int deleteMessageDays = 0,
      String reason,
      String auditReason = ""}) async {
    await _client.http.send('PUT', "/guilds/${this.guild.id}/bans/${this.id}",
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
    await _client.http.send(
        'PUT', '/guilds/${guild.id}/members/${this.id}/roles/${role.id}',
        reason: auditReason);
  }

  Future<void> removeRole(Role role, {String auditReason = ""}) async {
    await _client.http.send("DELETE",
        "/guilds/${this.guild.id.toString()}/members/${this.id.toString()}/roles/${role.id.toString()}",
        reason: auditReason);
  }

  /// Kicks the member
  Future<void> kick({String auditReason = ""}) async {
    await _client.http.send(
        'DELETE', "/guilds/${this.guild.id}/members/${this.id}",
        reason: auditReason);
  }

  /// Edits the user.
  /// Allows to move user in voice channel, mute or deaf, change nick, roles.
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

    await _client.http.send("PATCH",
        "/guilds/${this.guild.id.toString()}/members/${this.id.toString()}",
        body: req, reason: auditReason);
  }

  @override
  String toString() => super.toString();
}
