part of nyxx;

/// Type of webhook. Either [incoming] if it its normal webhook executable with token,
/// or [channelFollower] if its discord internal webhook
class WebhookType extends IEnum<int> {
  /// Incoming Webhooks can post messages to channels with a generated token
  static const WebhookType incoming = WebhookType._create(1);

  /// 	Channel Follower Webhooks are internal webhooks used with Channel Following to post new messages into channels
  static const WebhookType channelFollower = WebhookType._create(2);

  const WebhookType._create(int? value) : super(value ?? 0);
  WebhookType.from(int? value) : super(value ?? 0);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == _value;
    }

    return super == other;
  }
}

///Webhooks are a low-effort way to post messages to channels in Discord.
///They do not require a bot user or authentication to use.
class Webhook extends SnowflakeEntity implements IMessageAuthor {
  /// The webhook's name.
  late final String? name;

  /// The webhook's token. Defaults to empty string
  late final String token;

  /// The webhook's channel, if this is accessed using a normal client and the client has that channel in it's cache.
  late final CachelessTextChannel? channel;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  late final Guild? guild;

  /// The user, if this is accessed using a normal client.
  late final User? user;

  /// Webhook type
  late final WebhookType type;

  /// Webhooks avatar hash
  late final String? avatarHash;

  /// Default webhook avatar id
  int get defaultAvatarId => 0;

  @override
  String get username => this.name.toString();

  @override
  int get discriminator => -1;

  @override
  bool get bot => true;

  // TODO: It should be here???
  @override
  String get tag => name.toString();

  /// Reference to [Nyxx] object
  final Nyxx client;

  Webhook._new(Map<String, dynamic> raw, this.client) : super(Snowflake(raw["id"] as String)) {
    this.name = raw["name"] as String?;
    this.token = raw["token"] as String? ?? "";
    this.avatarHash = raw["avatar"] as String?;
    this.type = WebhookType.from(raw["type"] as int);

    if (raw["channel_id"] != null) {
      this.channel = client.channels[Snowflake(raw["channel_id"] as String)] as CachelessTextChannel?;
    }

    if (raw["guild_id"] != null) {
      this.guild = client.guilds[Snowflake(raw["guild_id"] as String)];
    }

    if (raw["user"] != null) {
      this.user = client.users[Snowflake(raw["user"]["id"] as String)];
    }
  }

  /// Executes webhook. Webhooks can send multiple embeds in one messsage using [embeds].
  ///
  /// [wait] - waits for server confirmation of message send before response,
  /// and returns the created message body (defaults to false; when false a message that is not save does not return an error)
  Future<Message> execute(
      {dynamic content,
      List<AttachmentBuilder>? files,
      List<EmbedBuilder>? embeds,
      bool? tts,
      AllowedMentions? allowedMentions,
      bool? wait,
      String? avatarUrl}) async {
    allowedMentions ??= client._options.allowedMentions;

    final reqBody = {
      if (content != null) "content": content.toString(),
      if (allowedMentions != null) "allowed_mentions": allowedMentions._build(),
      if(embeds != null) "embeds" : [
        for(final e in embeds)
          e._build()
      ],
      if (content != null && tts != null) "tts": tts,
      if(avatarUrl != null) "avatar_url" : avatarUrl,
    };

    final queryParams = { if(wait != null) "wait" : wait };

    _HttpResponse response;

    if (files != null && files.isNotEmpty) {
      response = await client._http
          ._execute(MultipartRequest._new("/webhooks/${this.id.toString()}/${this.token}", files, method: "POST", fields: reqBody, queryParams: queryParams));
    } else {
      response = await client._http
          ._execute(BasicRequest._new("/webhooks/${this.id.toString()}/${this.token}", body: reqBody, method: "POST", queryParams: queryParams));
    }

    if (response is HttpResponseSuccess) {
      return Message._deserialize(response.jsonBody as Map<String, dynamic>, client);
    }

    return Future.error(response);
  }

  @override
  String avatarURL({String format = "webp", int size = 128}) {
    if (this.avatarHash != null) {
      return "https://cdn.${Constants.cdnHost}/avatars/${this.id}/${this.avatarHash}.$format?size=$size";
    }

    return "https://cdn.${Constants.cdnHost}/embed/avatars/$defaultAvatarId.png?size=$size";
  }

  /// Edits the webhook.
  Future<Webhook> edit(
      {String? name, ITextChannel? channel, File? avatar, String? encodedAvatar, String? auditReason}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (channel != null) "channel_id": channel.id.toString()
    };

    final base64Encoded = avatar != null ? base64Encode(await avatar.readAsBytes()) : encodedAvatar;
    body["avatar"] = "data:image/jpeg;base64,$base64Encoded";

    final response = await client._http
        ._execute(BasicRequest._new("/webhooks/$id/$token", method: "PATCH", auditLog: auditReason, body: body));

    if (response is HttpResponseSuccess) {
      this.name = response.jsonBody["name"] as String;
      return this;
    }

    return Future.error(response);
  }

  /// Deletes the webhook.
  Future<void> delete({String? auditReason}) =>
      client._http._execute(BasicRequest._new("/webhooks/$id/$token", method: "DELETE", auditLog: auditReason));

  /// Returns a string representation of this object.
  @override
  String toString() => this.name.toString();
}
