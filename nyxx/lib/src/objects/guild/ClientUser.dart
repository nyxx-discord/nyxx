part of nyxx;

/// ClientUser is bot's discord account. Allows to change bot's presence.
class ClientUser extends User {
  /// Weather or not the client user's account is verified.
  bool? verified;

  /// Weather or not the client user has MFA enabled.
  bool? mfa;

  ClientUser._new(Map<String, dynamic> data, Nyxx client)
      : super._new(data, client) {
    this.verified = data['verified'] as bool;
    this.mfa = data['mfa_enabled'] as bool;
  }

  /// Updates the client's presence. All parameters are optional.
  void setPresence(
      {String? status, bool afk = false, Activity? game, DateTime? since}) {
    client.shard
        .setPresence(status: status, afk: afk, game: game, since: since);
  }

  /// Allows to get [Member] objects for all guilds for bot user.
  Map<Guild, Member> getMembership() {
    var membershipCollection = Map<Guild, Member>();

    for (var guild in client.guilds.values) {
      var member = guild.members[this.id];

      if(member != null) {
        membershipCollection[guild] = member;
      }
    }

    return membershipCollection;
  }

  /// Edits current user. This changes user's username - not per guild nickname.
  Future<User> edit({String? username, File? avatar, String? encodedAvatar}) async {
    if (username == null && (avatar == null || encodedAvatar == null)) {
      return Future.error("Cannot edit user with null values");
    }
    
    var body = <String, dynamic> {
      if (username != null) 'username' : username
    };

    var base64Encoded = avatar != null ? base64Encode(await avatar.readAsBytes()) : encodedAvatar;
    body['avatar'] = "data:image/jpeg;base64,$base64Encoded";

    var response = await client._http._execute(
        JsonRequest._new("/users/@me", method: "PATCH", body: body));


    if(response is HttpResponseSuccess) {
      return User._new(response.jsonBody as Map<String, dynamic>, client);
    }

    return Future.error(response);
  }
}
