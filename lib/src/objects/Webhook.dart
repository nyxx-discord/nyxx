part of nyxx;

/// A webhook.
class Webhook {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The HTTP client.
  Http http;

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

  Webhook._fromApi(this.client, this.raw) {
    this.http = client.http;

    this.name = raw['name'];
    this.id = raw['id'];
    this.token = raw['token'];
    this.channelId = raw['channel_id'];
    this.guildId = raw['guild_id'];
    this.createdAt = Util.getDate(this.id);
    this.channel = this.client.channels[this.channelId];
    this.guild = this.client.guilds[this.guildId];
    this.user = new User._new(client, raw['user'] as Map<String, dynamic>);
  }

  Webhook._fromToken(this.http, Map<String, dynamic> raw) {
    this.name = raw['name'];
    this.id = raw['id'];
    this.token = raw['token'];
    this.channelId = raw['channel_id'];
    this.guildId = raw['guild_id'];
    this.createdAt = Util.getDate(this.id);
  }

  /// Gets a webhook by its ID and token.
  static Future<Webhook> fromToken(String id, String token) async {
    Http http = new Http._new();
    HttpResponse r = await http.send('GET', "/webhooks/$id/$token");
    return new Webhook._fromToken(
        http, r.body.asJson() as Map<String, dynamic>);
  }

  /// Edits the webhook.
  Future<Webhook> edit({String name}) async {
    HttpResponse r = await this
        .http
        .send('PATCH', "/webhooks/$id/$token", body: {"name": name});
    this.name = r.body.asJson()['name'];
    return this;
  }

  /// Deletes the webhook.
  Future<Null> delete() async {
    await this.http.send('DELETE', "/webhooks/$id/$token");
    return null;
  }

  /// Sends a message with the webhook.
  Future<Null> send(
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

    await this.http.send('POST', "/webhooks/$id/$token", body: payload);
    return null;
  }

  @deprecated

  /// Sends a message with the webhook.
  Future<Message> sendMessage(
      {String content,
      List<Map<String, dynamic>> embeds,
      String username,
      String avatarUrl,
      bool tts}) async {
    return this.send(
        content: content,
        embeds: embeds,
        tts: tts,
        username: username,
        avatarUrl: avatarUrl);
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
