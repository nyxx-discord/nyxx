part of discord;

/// The client user.
class ClientUser extends User {
  /// The client user's email, null if the client user is a bot.
  String email;

  /// Weather or not the client user's account is verified.
  bool verified;

  /// Weather or not the client user has MFA enabled.
  bool mfa;

  ClientUser._new(Client client, Map<String, dynamic> data)
      : super._new(client, data) {
    this.email = raw['email'];
    this.verified = raw['verified'];
    this.mfa = raw['mfa_enabled'];
    this.client = client;
  }

  /// Updates the client's status.
  ///     ClientUser.setStatus(status: 'dnd');
  ClientUser setStatus({String status: null}) {
    return this.setPresence(status: status);
  }

  /// Updates the client's game.
  ///     ClientUser.setGame(name: '<3');
  ClientUser setGame({String name: null, type: 0, url: null}) {
    Map<String, dynamic> game = {'name': name, 'type': type, 'url': url};

    return this.setPresence(activity: game);
  }

  /// Updates the client's presence.
  ///     ClientUser.setPresence(status: s, activity: { 'name': args.join(' ') });
  ClientUser setPresence(
      {String status: null, bool afk: false, dynamic activity: null}) {
    Map<String, dynamic> game = {
      'name': activity != null ? activity['name'] : null,
      'type': activity != null
          ? activity['type'] != null ? activity['type'] : 0
          : 0,
      'url': activity != null ? activity['url'] : null
    };

    this.client.shards.forEach((int id, Shard shard) {
      shard.setPresence(status: status, afk: afk, activity: game);
    });

    return this;
  }
}
