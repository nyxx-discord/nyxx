import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/application/oauth2_application.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/permissions.dart';

/// The client's OAuth2 app, if the client is a bot.
abstract class IClientOAuth2Application implements IOAuth2Application {
  /// The app's flags.
  IApplicationFlags? get flags;

  /// The app's owner.
  IUser get owner;

  /// When false only app owner can join the app's bot to guilds.
  bool get isPublic;

  /// When true the app's bot will only join upon completion of the full oauth2 code grant flow.
  bool get requireCodeGrant;

  /// Creates an OAuth2 URL with the specified permissions.
  String getInviteUrl([int? permissions]);
}

/// The client's OAuth2 app, if the client is a bot.
class ClientOAuth2Application extends OAuth2Application implements IClientOAuth2Application {
  /// The app's flags.
  @override
  late final IApplicationFlags? flags;

  /// The app's owner.
  @override
  late final IUser owner;

  @override
  late final bool isPublic;

  @override
  late final bool requireCodeGrant;

  /// Creates an instance of [ClientOAuth2Application]
  ClientOAuth2Application(RawApiMap raw, INyxx client) : super(raw, client) {
    flags = raw["flags"] != null ? ApplicationFlags(raw['flags'] as int) : null;
    owner = User(client, raw["owner"] as RawApiMap);
    isPublic = raw['bot_public'] as bool;
    requireCodeGrant = raw['bot_require_code_grant'] as bool;
  }

  /// Creates an OAuth2 URL with the specified permissions.
  @override
  String getInviteUrl([int? permissions]) => client.httpEndpoints.getApplicationInviteUrl(id, permissions);
}

/// https://discord.com/developers/docs/resources/application#application-object-application-flags
abstract class IApplicationFlags {
  /// Intent required for bots in 100 or more servers to receive `presence_update` events.
  bool get gatewayPresence;

  /// Intent required for bots in under 100 servers to receive `presence_update` events, found in Bot Settings
  bool get gatewayPresenceLimited;

  /// Intent required for bots in 100 or more servers to receive member-related events like `guild_member_add`.
  bool get gatewayGuildMembers;

  /// Intent required for bots in under 100 servers to receive member-related events like `guild_member_add`, found in Bot Settings.
  bool get gatewayGuildMembersLimited;

  /// Indicates unusual growth of an app that prevents verification.
  bool get verificationPendingGuildLimit;

  /// Indicates if an app is embedded within the Discord client (currently unavailable publicly).
  bool get embedded;

  /// Intent required for bots in 100 or more servers to receive message content.
  bool get gatewayMessageContent;

  /// Intent required for bots in under 100 servers to receive message content, found in Bot Settings.
  bool get gatewayMessageContentLimited;

  /// Indicates if an app has registered global [application commands](https://discord.com/developers/docs/interactions/application-commands).
  bool get applicationCommandBadge;
}

class ApplicationFlags implements IApplicationFlags {
  @override
  bool get applicationCommandBadge => PermissionsUtils.isApplied(raw, 1 << 12);

  @override
  bool get embedded => PermissionsUtils.isApplied(raw, 1 << 13);

  @override
  bool get gatewayGuildMembers => PermissionsUtils.isApplied(raw, 1 << 14);

  @override
  bool get gatewayGuildMembersLimited => PermissionsUtils.isApplied(raw, 1 << 15);

  @override
  bool get gatewayMessageContent => PermissionsUtils.isApplied(raw, 1 << 16);

  @override
  bool get gatewayMessageContentLimited => PermissionsUtils.isApplied(raw, 1 << 17);

  @override
  bool get gatewayPresence => PermissionsUtils.isApplied(raw, 1 << 18);

  @override
  bool get gatewayPresenceLimited => PermissionsUtils.isApplied(raw, 1 << 19);

  @override
  bool get verificationPendingGuildLimit => PermissionsUtils.isApplied(raw, 1 << 23);

  final int raw;
  const ApplicationFlags(this.raw);
}
