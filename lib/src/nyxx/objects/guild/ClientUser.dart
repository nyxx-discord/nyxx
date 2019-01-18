part of nyxx;

/// ClientUser is bot's discord account. Allows to change bot's presence.
class ClientUser extends User {
  /// Weather or not the client user's account is verified.
  bool verified;

  /// Weather or not the client user has MFA enabled.
  bool mfa;

  ClientUser._new(Map<String, dynamic> data, Nyxx client)
      : super._new(data, client) {
    this.verified = data['verified'] as bool;
    this.mfa = data['mfa_enabled'] as bool;
  }

  /// Updates the client's presence. All parameters are optional.
  void setPresence(
      {String status, bool afk = false, Presence game, DateTime since}) {
    client.shard
        .setPresence(status: status, afk: afk, game: game, since: since);
  }

  /// Allows to get [Member] objects for all guilds for bot user.
  Map<Guild, Member> getMembership() {
    var tmp = Map<Guild, Member>();
    for (var guild in client.guilds.values) tmp[guild] = guild.members[this.id];

    return tmp;
  }

  /// Edits current user. This changes user's username - not per guild nickname.
  Future<User> edit({String username, File avatar, String encodedData}) async {
    if (username == null && avatar == null) return null;
    var req = Map<String, dynamic>();

    var enc = avatar != null ? base64Encode(await avatar.readAsBytes()) : encodedData;
    if (username != null) req['username'] = username;
    if (avatar != null)
      req['avatar'] =
          "data:image/jpeg;base64,$enc";

    var res = await client._http.send("PATCH", "/users/@me", body: req);
    return User._new(res.body as Map<String, dynamic>, client);
  }
}
