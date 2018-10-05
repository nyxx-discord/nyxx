part of nyxx;

/// A webhook.
class Webhook extends SnowflakeEntity {
  /// The webhook's name.
  String name;

  /// The webhook's token.
  String token = "";

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

  Webhook._new(Map<String, dynamic> raw)
      : super(Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.token = raw['token'] as String;

    if (raw['channel_id'] != null) {
      this.channel = _client.channels[this.channelId] as TextChannel;
      this.channelId = Snowflake(raw['channel_id'] as String);
    }

    if (raw['guild_id'] != null) {
      this.guildId = Snowflake(raw['guild_id'] as String);
      this.guild = _client.guilds[this.guildId];
    }

    this.user = User._new(raw['user'] as Map<String, dynamic>);
  }

  /// Edits the webhook.
  Future<Webhook> edit({String name, String auditReason = ""}) async {
    HttpResponse r = await _client.http.send('PATCH', "/webhooks/$id/$token",
        body: {"name": name}, reason: auditReason);
    this.name = r.body['name'] as String;
    return this;
  }

  /// Deletes the webhook.
  Future<void> delete({String auditReason = ""}) async {
    await _client.http
        .send('DELETE', "/webhooks/$id/$token", reason: auditReason);
  }

  /// Sends a message with the webhook.
  Future<void> send(
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

    await _client.http.send('POST', "/webhooks/$id/$token", body: payload);
  }

  /// Sends message to webhook with files
  Future<void> sendFile(
      {String content,
      List<File> files,
      List<EmbedBuilder> embeds,
      String username,
      String avatarUrl,
      bool tts}) async {
    await _client.http
        .sendMultipart("POST", "/webhooks/$id/$token", files, data: {
      "content": content,
      "username": username,
      "avatar_url": avatarUrl,
      "tts": tts,
      "embeds": embeds.map((t) => t._build())
    });
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;
}
