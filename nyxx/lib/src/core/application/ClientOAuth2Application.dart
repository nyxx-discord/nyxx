import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/application/OAuth2Application.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/typedefs.dart';

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
  @override
  late final int? flags;

  /// The app's owner.
  @override
  late final IUser owner;

  /// Creates an instance of [ClientOAuth2Application]
  ClientOAuth2Application(RawApiMap raw, this.client) : super(raw) {
    this.flags = raw["flags"] as int?;
    this.owner = User(client, raw["owner"] as RawApiMap);
  }

  /// Creates an OAuth2 URL with the specified permissions.
  @override
  String getInviteUrl([int? permissions]) =>
      this.client.httpEndpoints.getApplicationInviteUrl(this.id, permissions);
}
