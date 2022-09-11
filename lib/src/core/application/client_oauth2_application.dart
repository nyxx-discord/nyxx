import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/application/oauth2_application.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/typedefs.dart';

/// The client's OAuth2 app, if the client is a bot.
abstract class IClientOAuth2Application implements IOAuth2Application {
  /// The app's flags.
  int? get flags;

  /// The app's owner.
  IUser get owner;

  /// Creates an OAuth2 URL with the specified permissions.
  String getInviteUrl([int? permissions]);
}

/// The client's OAuth2 app, if the client is a bot.
class ClientOAuth2Application extends OAuth2Application implements IClientOAuth2Application {
  /// The app's flags.
  @override
  late final int? flags;

  /// The app's owner.
  @override
  late final IUser owner;

  /// Creates an instance of [ClientOAuth2Application]
  ClientOAuth2Application(RawApiMap raw, INyxx client) : super(raw, client) {
    flags = raw["flags"] as int?;
    owner = User(client, raw["owner"] as RawApiMap);
  }

  /// Creates an OAuth2 URL with the specified permissions.
  @override
  String getInviteUrl([int? permissions]) => client.httpEndpoints.getApplicationInviteUrl(id, permissions);
}
