part of nyxx;

/// The client's OAuth2 app, if the client is a bot.
abstract class IClientOAuth2Application implements IOAuth2Application {
  /// Reference to [NyxxWebsocket]
  INyxx get client;

  /// The app's flags.
  int? get flags;

  /// The app's owner.
  IUser get owner;

  /// Creates an OAuth2 URL with the specified permissions.
  String getInviteUrl([int? permissions]);
}

/// The client's OAuth2 app, if the client is a bot.
class ClientOAuth2Application extends OAuth2Application implements IClientOAuth2Application {
  /// Reference to [NyxxWebsocket]
  @override
  final NyxxWebsocket client;

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
