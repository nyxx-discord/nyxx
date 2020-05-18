part of nyxx;

/// ClientUser is bot's discord account. Allows to change bot's presence.
class ClientUser extends User {
  /// Weather or not the client user's account is verified.
  bool? verified;

  /// Weather or not the client user has MFA enabled.
  bool? mfa;

  ClientUser._new(Map<String, dynamic> data, Nyxx client) : super._new(data, client) {
    this.verified = data["verified"] as bool;
    this.mfa = data["mfa_enabled"] as bool;
  }

  /// Allows to get [Member] objects for all guilds for bot user.
  Map<Guild, Member> getMembership() {
    final membershipCollection = <Guild, Member>{};

    for (final guild in client.guilds.values) {
      final member = guild.members[this.id];

      if (member != null) {
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

    final body = <String, dynamic>{
      if (username != null) "username": username
    };

    final base64Encoded = avatar != null ? base64Encode(await avatar.readAsBytes()) : encodedAvatar;
    body["avatar"] = "data:image/jpeg;base64,$base64Encoded";

    final response = await client._http._execute(BasicRequest._new("/users/@me", method: "PATCH", body: body));

    if (response is HttpResponseSuccess) {
      return User._new(response.jsonBody as Map<String, dynamic>, client);
    }

    return Future.error(response);
  }
}
