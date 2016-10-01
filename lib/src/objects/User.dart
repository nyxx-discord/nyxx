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

  /// The user's avatar URL.
  String avatarURL;

  /// The string to mention the user.
  String mention;

  /// A timestamp of when the user was created.
  DateTime createdAt;

  /// Whether or not the user is a bot.
  bool bot = false;

  /// Constructs a new [User].
  User(this.client, Map<String, dynamic> data) {
    this.username = this.map['username'] = data['username'];
    this.id = this.map['id'] = data['id'];
    this.discriminator = this.map['discriminator'] = data['discriminator'];
    this.avatar = this.map['avatar'] = data['avatar'];
    this.avatarURL = this.map['avatarURL'] =
        "https://discordapp.com/api/v6/users/${this.id}/avatars/${this.avatar}.jpg";
    this.mention = this.map['mention'] = "<@${this.id}>";
    this.createdAt =
        this.map['createdAt'] = this.client.internal.util.getDate(this.id);

    // This will not be set at all in some cases.
    if (data['bot'] == true) {
      this.bot = this.map['bot'] = data['bot'];
    } else {
      this.map['bot'] = false;
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.username;
  }
}
