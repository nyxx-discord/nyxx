part of discord;

/// A user.
class User extends _BaseObj {
  Map<String, dynamic> _raw;

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

  User._new(Client client, Map<String, dynamic> data) : super(client) {
    this._raw = data;
    this.username = this._map['username'] = data['username'];
    this.id = this._map['id'] = data['id'];
    this.discriminator = this._map['discriminator'] = data['discriminator'];
    this.avatar = this._map['avatar'] = data['avatar'];
    this.avatarURL = this._map['avatarURL'] =
        "https://discordapp.com/api/v6/users/${this.id}/avatars/${this.avatar}.jpg";
    this.mention = this._map['mention'] = "<@${this.id}>";
    this.createdAt =
        this._map['createdAt'] = this._client._util.getDate(this.id);

    // This will not be set at all in some cases.
    if (data['bot'] == true) {
      this.bot = this._map['bot'] = data['bot'];
    } else {
      this._map['bot'] = false;
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.username;
  }
}
