part of discord;

/// The client's OAuth2 app, if the client is a bot.
class ClientOAuth2Application extends OAuth2Application {
  /// The app's flags.
  int flags;

  /// The app's owner.
  User owner;

  ClientOAuth2Application._new(Client client, Map<String, dynamic> data)
      : super._new(client, data) {
    this.flags = data['flags'];
    this.owner = new User._new(client, data['owner'] as Map<String, dynamic>);
  }
}
