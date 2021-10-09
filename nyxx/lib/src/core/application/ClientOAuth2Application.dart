part of nyxx;

/// The client's OAuth2 app, if the client is a bot.
class ClientOAuth2Application extends OAuth2Application {
  /// Reference to [Nyxx]
  final Nyxx client;

  /// The app's flags.
  late final int? flags;

  /// The app's owner.
  late final User owner;

  ClientOAuth2Application._new(RawApiMap raw, this.client) : super._new(raw) {
    this.flags = raw["flags"] as int?;
    this.owner = User._new(client, raw["owner"] as RawApiMap);
  }

  /// Creates an OAuth2 URL with the specified permissions.
  String getInviteUrl([int? permissions]) =>
      this.client.httpEndpoints.getApplicationInviteUrl(this.id, permissions);
}
