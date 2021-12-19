import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';

/// ClientUser is bot's discord account. Allows to change bot's presence.
abstract class IClientUser implements IUser {
  /// Weather or not the client user's account is verified.
  bool? get verified;

  /// Weather or not the client user has MFA enabled.
  bool? get mfa;

  /// Edits current user. This changes user's username - not per guild nickname.
  Future<IUser> edit({String? username, AttachmentBuilder? avatarAttachment});
}

/// ClientUser is bot's discord account. Allows to change bot's presence.
class ClientUser extends User implements IClientUser {
  /// Weather or not the client user's account is verified.
  @override
  late final bool? verified;

  /// Weather or not the client user has MFA enabled.
  @override
  late final bool? mfa;

  /// Creates an instance of [ClientUser]
  ClientUser(NyxxWebsocket client, RawApiMap raw) : super(client, raw) {
    verified = raw["verified"] as bool;
    mfa = raw["mfa_enabled"] as bool;
  }

  /// Edits current user. This changes user's username - not per guild nickname.
  @override
  Future<IUser> edit({String? username, AttachmentBuilder? avatarAttachment}) =>
      client.httpEndpoints.editSelfUser(username: username, avatarAttachment: avatarAttachment);
}
