part of discord;

/// A user.
class Webhook extends _BaseObj {
  _Http _http;

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

  /// The user, if this is accessed using a normal client.
  User user;

  /// When the webhook was created;
  DateTime createdAt;

  Webhook._fromApi(Client client, Map<String, dynamic> data) : super(client) {
    this._http = _client._http;

    this.name = data['name'];
    this.id = data['id'];
    this.token = data['token'];
    this.channelId = data['channel_id'];
    this.guildId = data['guild_id'];
    this.createdAt = Util.getDate(this.id);
    this.channel = this._client.channels[this.channelId];
    this.guild = this._client.guilds[this.guildId];
    this.user = new User._new(_client, data['user'] as Map<String, dynamic>);
  }

  Webhook._fromToken(this._http, Map<String, dynamic> data) : super(null) {
    this.name = data['name'];
    this.id = data['id'];
    this.token = data['token'];
    this.channelId = data['channel_id'];
    this.guildId = data['guild_id'];
    this.createdAt = Util.getDate(this.id);
  }

  /// Gets a webhook by its ID and token.
  static Future<Webhook> fromToken(String id, String token) async {
    _Http http = new _Http();
    w_transport.Response r = await http.send('GET', "/webhooks/$id/$token");
    return new Webhook._fromToken(
        http, r.body.asJson() as Map<String, dynamic>);
  }

  /// Edits the webhook.
  Future<Webhook> edit({String name}) async {
    w_transport.Response r = await this
        ._http
        .send('PATCH', "/webhooks/$id/$token", body: {"name": name});
    this.name = r.body.asJson()['name'];
    return this;
  }

  /// Deletes the webhook.
  Future<Null> delete() async {
    await this._http.send('DELETE', "/webhooks/$id/$token");
    return null;
  }

  /// Sends a message with the webhook.
  Future<Null> sendMessage(
      {String content,
      List<Map<String, dynamic>> embeds,
      String username,
      String avatarUrl,
      bool tts}) async {
    Map<String, dynamic> payload = {
      "content": content,
      "username": username,
      "avatar_url": avatarUrl,
      "tts": tts,
      "embeds": embeds
    };

    await this._http.send('POST', "webhooks/$id/$token", body: payload);
    return null;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
