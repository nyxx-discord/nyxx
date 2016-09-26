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
    this.username = data['username'];
    this.map['username'] = this.username;

    this.id = data['id'];
    this.map['id'] = this.id;

    this.discriminator = data['discriminator'];
    this.map['discriminator'] = this.discriminator;

    this.avatar = data['avatar'];
    this.map['avatar'] = this.avatar;

    this.mention = "<@${this.id}>";
    this.map['mention'] = this.mention;

    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
    this.map['createdAt'] = this.createdAt;

    if (data['bot']) {
      this.bot = data['bot'];
    }
    this.map['bot'] = this.bot;
  }

  /// Returns a string representation of this object.
  String toString() {
    return this.username;
  }
}
