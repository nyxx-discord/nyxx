import '../../discord.dart';

/// The client user.
class ClientUser extends User {
  /// The client user's email, null if the client user is a bot.
  String email;

  /// Weather or not the client user's account is verified.
  bool verified;

  /// Weather or not the client user has MFA enabled.
  bool mfa;

  /// Constructs a new [ClientUser].
  ClientUser(Client client, Map<String, dynamic> data) : super(client, data) {
    this.email = this.map['email'] = data['email'];
    this.verified = this.map['verified'] = data['verified'];
    this.mfa = this.map['mfa'] = data['mfa_enabled'];
  }
}
