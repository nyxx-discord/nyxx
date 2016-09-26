import '../../discord.dart';

/// A user.
class User {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

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
  User(this.client, Map<String, dynamic> data) {
    this.username = this.map['username'] = data['username'];
    this.id = this.map['id'] = data['id'];
    this.discriminator = this.map['discriminator'] = data['discriminator'];
    this.avatar = this.map['avatar'] = data['avatar'];
    this.mention = this.map['mention'] = "<@${this.id}>";
    this.createdAt = this.map['createdAt'] = (int.parse(this.id) / 4194304) + 1420070400000;

    if (data['bot']) {
      this.bot = this.map['bot'] = data['bot'];
    } else {
      this.map['bot'] = false;
    }
  }

  /// Returns a string representation of this object.
  String toString() {
    return this.username;
  }
}
