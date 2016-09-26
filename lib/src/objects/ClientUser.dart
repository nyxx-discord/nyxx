import '../../discord.dart';

/// The client user.
class ClientUser {
  /// The client user's username.
  String username;

  /// The client user's ID.
  String id;

  /// The client user's discriminator.
  String discriminator;

  /// The client user's avatar hash.
  String avatar;

  /// The client user's email, null if the client user is a bot.
  String email;

  /// The string for mentioning the client user.
  String mention;

  /// A timestamp for when the client user was created.
  double createdAt;

  /// Weather or not the client user is a bot.
  bool bot = false;

  /// Weather or not the client user's account is verified.
  bool verified;

  /// Weather or not the client user has MFA enabled.
  bool mfa;

  /// Constructs a new [ClientUser].
  ClientUser(Map<String, dynamic> data) {
    this.username = data['username'];
    this.id = data['id'];
    this.discriminator = data['discriminator'];
    this.avatar = data['avatar'];
    this.email = data['email'];
    this.mention = "<@${this.id}>";
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
    this.verified = data['verified'];
    this.mfa = data['mfa_enabled'];

    if (data['bot']) {
      this.bot = data['bot'];
    }
  }

  /// Returns a string representation of this object.
  String toString() {
    return this.username;
  }
}
