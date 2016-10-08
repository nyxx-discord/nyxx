part of discord;

/// The client's OAuth2 app, if the client is a bot.
class ClientOAuth2Application extends OAuth2Application {
  /// The app's flags.
  int flags;

  /// The app's owner.
  User owner;

  /// Constructs a new [ClientOAuth2Application].
  ClientOAuth2Application(Client client, Map<String, dynamic> data)
      : super(client, data) {
    this.flags = data['flags'];
    this.owner = new User(client, data['owner'] as Map<String, dynamic>);
  }
}
