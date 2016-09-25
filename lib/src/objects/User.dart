import '../../discord.dart';

/// A user.
class User {
  /// The user's username.
  String username;

  /// The user's ID.
  String id;

  /// The user's discriminator.
  String discriminator;

  /// The user's avatar hash.
  String avatar;

  /// The string to mention the user.
  String mention;

  /// A timestamp of when the user was created.
  double createdAt;

  /// Whether or not the user is a bot.
  bool bot = false;

  /// Constructs a new [User].
  User(Map<String, dynamic> data) {
    this.username = data['username'];
    this.id = data['id'];
    this.discriminator = data['discriminator'];
    this.avatar = data['avatar'];
    this.mention = "<@${this.id}>";
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;

    if (data['bot']) {
      this.bot = data['bot'];
    }
  }
}
