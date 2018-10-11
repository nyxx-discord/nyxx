part of nyxx;

/// The client's OAuth2 app, if the client is a bot.
class ClientOAuth2Application extends OAuth2Application {
  /// The app's flags.
  int flags;

  /// The app's owner.
  User owner;

  ClientOAuth2Application._new(Map<String, dynamic> raw) : super._new(raw) {
    this.flags = raw['flags'] as int;
    this.owner = User._new(raw['owner'] as Map<String, dynamic>);
  }

  /// Creates an OAuth2 URL with the specified permissions.
  String getInviteUrl([int permissions = 0]) =>
      "https://discordapp.com/oauth2/authorize?client_id=$id&scope=bot&permissions=$permissions";
}
