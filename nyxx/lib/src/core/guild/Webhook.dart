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
  late final Cacheable<Snowflake, TextGuildChannel> channel;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  late final Cacheable<Snowflake, Guild>? guild;

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

  @override
  String get tag => "";

  /// Reference to [Nyxx] object
  final Nyxx client;

  Webhook._new(Map<String, dynamic> raw, this.client) : super(Snowflake(raw["id"] as String)) {
    this.name = raw["name"] as String?;
    this.token = raw["token"] as String? ?? "";
    this.avatarHash = raw["avatar"] as String?;
    this.type = WebhookType.from(raw["type"] as int);

    this.channel = _ChannelCacheable(client, Snowflake(raw["channel_id"]));

    if (raw["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"] as String));
    } else {
      this.guild = null;
    }

    if (raw["user"] != null) {
      this.user = User._new(client, raw["user"] as Map<String, dynamic>);
    } else {
      this.user = null;
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
      String? avatarUrl}) =>
      client._httpEndpoints.executeWebhook(
        this.id,
        token: token,
        content: content,
        files: files,
        embeds: embeds,
        tts: tts,
        allowedMentions: allowedMentions,
        wait: wait,
        avatarUrl: avatarUrl
      );

  @override
  String avatarURL({String format = "webp", int size = 128}) =>
      client._httpEndpoints.userAvatarURL(this.id, this.avatarHash, 0, format: format, size: size);

  /// Edits the webhook.
  Future<Webhook> edit({String? name, SnowflakeEntity? channel, File? avatar, String? encodedAvatar, String? auditReason}) =>
    client._httpEndpoints.editWebhook(this.id, token: this.token, name: name,
        channel: channel, avatar: avatar, encodedAvatar: encodedAvatar, auditReason: auditReason);

  /// Deletes the webhook.
  Future<void> delete({String? auditReason}) =>
      client._httpEndpoints.deleteWebhook(this.id, token: token, auditReason: auditReason);

  /// Returns a string representation of this object.
  @override
  String toString() => this.name.toString();
}
