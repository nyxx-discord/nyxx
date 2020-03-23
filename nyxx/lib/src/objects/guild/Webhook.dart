part of nyxx;

///Webhooks are a low-effort way to post messages to channels in Discord.
///They do not require a bot user or authentication to use.
class Webhook extends SnowflakeEntity implements ISend {
  /// The webhook's name.
  late final String name;

  /// The webhook's token.
  late final String? token;

  /// The webhook's channel, if this is accessed using a normal client and the client has that channel in it's cache.
  late final TextChannel? channel;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  late final Guild? guild;

  /// The user, if this is accessed using a normal client.
  late final User? user;

  Nyxx client;

  Webhook._new(Map<String, dynamic> raw, this.client)
      : super(Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String;
    this.token = raw['token'] as String?;

    if (raw['channel_id'] != null) {
      this.channel = client.channels[Snowflake(raw['channel_id'] as String)] as TextChannel?;
    }

    if (raw['guild_id'] != null) {
      this.guild = client.guilds[Snowflake(raw['guild_id'] as String)];
    }

    this.user = User._new(raw['user'] as Map<String, dynamic>, client);
  }

  /// Edits the webhook.
  Future<Webhook> edit(String name, {String? auditReason}) async {
    HttpResponse r = await client._http.send('PATCH', "/webhooks/$id/$token",
        body: {"name": name}, reason: auditReason);
    this.name = r.body['name'] as String;
    return this;
  }

  /// Deletes the webhook.
  Future<void> delete({String auditReason = ""}) {
    return client._http
        .send('DELETE', "/webhooks/$id/$token", reason: auditReason);
  }

  @override

  /// Allows to send message via webhook
  Future<Message?> send(
      {Object content = "",
      List<AttachmentBuilder>? files,
      EmbedBuilder? embed,
      bool tts = false,
      bool? disableEveryone,
      MessageBuilder? builder}) async {
    if (builder != null) {
      content = builder._content;
      files = builder.files;
      embed = builder.embed;
      tts = builder.tts ?? false;
      disableEveryone = builder.disableEveryone;
    }

    var newContent = _sanitizeMessage(content, disableEveryone, client);

    Map<String, dynamic> reqBody = {
      "content": newContent,
      "embed": embed != null ? embed._build() : ""
    };

    HttpResponse r;
    if (files != null && files.isNotEmpty) {
      r = await client._http.sendMultipart(
          'POST', '/channels/${this.id}/messages', files,
          data: reqBody..addAll({"tts": tts}));
    } else {
      if(this.channel == null) {
        return null;
      }

      r = await client._http.send(
          'POST', '/channels/${this.channel!.id}/messages',
          body: reqBody..addAll({"tts": tts}));
    }

    return Message._new(r.body as Map<String, dynamic>, client);
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;
}
