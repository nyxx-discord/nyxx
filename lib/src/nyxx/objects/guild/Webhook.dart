part of nyxx;

///Webhooks are a low-effort way to post messages to channels in Discord.
///They do not require a bot user or authentication to use.
class Webhook extends SnowflakeEntity implements ISend {
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
    HttpResponse r = await _client._http.send('PATCH', "/webhooks/$id/$token",
        body: {"name": name}, reason: auditReason);
    this.name = r.body['name'] as String;
    return this;
  }

  /// Deletes the webhook.
  Future<void> delete({String auditReason = ""}) async {
    await _client._http
        .send('DELETE', "/webhooks/$id/$token", reason: auditReason);
  }

  @override
  /// Allows to send message via webhook
  Future<Message> send(
      {Object content = "",
        List<File> files,
        EmbedBuilder embed,
        bool tts = false,
        bool disableEveryone,
        MessageBuilder builder}) async {
    if(builder != null) {
      content = builder._content;
      files = builder.files;
      embed = builder.embed;
      tts = builder.tts ?? false;
      disableEveryone = builder.disableEveryone;
    }

    var newContent = _sanitizeMessage(content, disableEveryone);

    Map<String, dynamic> reqBody = {
      "content": newContent,
      "embed": embed != null ? embed._build() : ""
    };

    HttpResponse r;
    if (files != null && files.isNotEmpty) {
      r = await _client._http.sendMultipart(
          'POST', '/channels/${this.id}/messages', files,
          data: reqBody..addAll({"tts": tts}));
    } else {
      r = await _client._http.send('POST', '/channels/${this.channel.id}/messages',
          body: reqBody..addAll({"tts": tts}));
    }

    return Message._new(r.body as Map<String, dynamic>);
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;
}
