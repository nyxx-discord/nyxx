part of discord;

/// A user.
class Webhook extends _BaseObj {
  /// The webhook's name.
  String name;

  /// The webhook's id.
  String id;

  /// The webhook's token.
  String token;

  /// The webhook's channel id.
  String channelId;

  /// The webhook's channel, if this is accessed using a normal client and the client has that channel in it's cache.
  TextChannel channel;

  /// The webhook's guild id.
  String guildId;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  Guild guild;

  /// When the webhook was created;
  DateTime createdAt;

  /// Constructs a new [User].
  Webhook._new(Client client, Map<String, dynamic> data) : super(client) {
    this.name = data['name'];
    this.id = data['id'];
    this.token = data['token'];
    this.channelId = data['channel_id'];
    this.guildId = data['guild_id'];
    this.createdAt = _Util.getDate(this.id);

    if (client != null) {
      this.channel = this._client.channels[this.channelId];
      this.guild = this._client.guilds[this.guildId];
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
