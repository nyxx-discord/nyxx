part of nyxx;

/// A webhook.
class Webhook extends SnowflakeEntity {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The webhook's name.
  String name;

  /// The webhook's token.
  String token;

  /// The webhook's channel id.
  Snowflake channelId;

  /// The webhook's channel, if this is accessed using a normal client and the client has that channel in it's cache.
  TextChannel channel;

  /// The webhook's guild id.
  Snowflake guildId;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  Guild guild;

  /// The user, if this is accessed using a normal client.
  User user;

  Webhook._fromApi(this.client, this.raw) : super(new Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.token = raw['token'] as String;

    if (raw['channel_id'] != null) {
      this.channel = this.client.channels[this.channelId.id] as TextChannel;
      this.channelId = new Snowflake(raw['channel_id'] as String);
    }

    if (raw['guild_id'] != null) {
      this.guildId = new Snowflake(raw['guild_id'] as String);
      this.guild = this.client.guilds[this.guildId];
    }

    this.user = new User._new(client, raw['user'] as Map<String, dynamic>);
  }

  Webhook._fromToken(this.client, Map<String, dynamic> raw) : super(new Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.token = raw['token'] as String;
    this.channelId = new Snowflake(raw['channel_id'] as String);
    this.guildId = new Snowflake(raw['guild_id'] as String);
  }

  /// Edits the webhook.
  Future<Webhook> edit({String name, String auditReason: ""}) async {
    HttpResponse r = await this.client.http.send('PATCH', "/webhooks/$id/$token",
        body: {"name": name}, reason: auditReason);
    this.name = r.body.asJson()['name'] as String;
    return this;
  }

  /// Deletes the webhook.
  Future<Null> delete({String auditReason: ""}) async {
    await this.client.http.send('DELETE', "/webhooks/$id/$token", reason: auditReason);
    return null;
  }

  /// Sends a message with the webhook.
  Future<Null> send(
      {String content,
      List<EmbedBuilder> embeds,
      String username,
      String avatarUrl,
      bool tts}) async {
    Map<String, dynamic> payload = {
      "content": content,
      "username": username,
      "avatar_url": avatarUrl,
      "tts": tts,
      "embeds": embeds.map((t) => t._build())
    };

    await this.client.http.send('POST', "/webhooks/$id/$token", body: payload);
    return null;
  }

  Future<Null> sendFile(
      {String content,
      List<String> filepaths,
      List<EmbedBuilder> embeds,
      String username,
      String avatarUrl,
      bool tts}) async {
      await this.client.http.sendMultipart(
        "POST", "/webhooks/$id/$token", filepaths,
        data: jsonEncode({
          "content": content,
          "username": username,
          "avatar_url": avatarUrl,
          "tts": tts,
          "embeds": embeds.map((t) => t._build())
        })
      );
      return null;
    }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;
}
