part of nyxx;

/// Type of webhook. Either [incoming] if it its normal webhook executable with token,
/// or [channelFollower] if its discord internal webhook
class WebhookType {
  static const WebhookType incoming = const WebhookType._create(1);
  static const WebhookType channelFollower = const WebhookType._create(2);

  final int _value;

  const WebhookType._create(int? value) : _value = value ?? 0;
  WebhookType.from(int? value) : _value = value ?? 0;

  @override
  String toString() => _value.toString();

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) {
    if (other is PremiumTier || other is int)
      return other == _value;

    return false;
  }
}

///Webhooks are a low-effort way to post messages to channels in Discord.
///They do not require a bot user or authentication to use.
class Webhook extends SnowflakeEntity implements IMessageAuthor {
  /// The webhook's name.
  late final String? name;

  /// The webhook's token.
  late final String? token;

  /// The webhook's channel, if this is accessed using a normal client and the client has that channel in it's cache.
  late final TextChannel? channel;

  /// The webhook's guild, if this is accessed using a normal client and the client has that guild in it's cache.
  late final Guild? guild;

  /// The user, if this is accessed using a normal client.
  late final User? user;

  // TODO: Create data class
  /// Webhook type
  late final WebhookType type;

  /// Webhooks avatar hash
  late final String? avatarHash;

  @override
  String get username => this.name.toString();

  @override
  int get discriminator => -1;

  @override
  bool get bot => true;

  // TODO: It should be here???
  @override
  String get tag => name.toString();

  Nyxx client;

  Webhook._new(Map<String, dynamic> raw, this.client)
      : super(Snowflake(raw['id'] as String)) {
    this.name = raw['name'] as String?;
    this.token = raw['token'] as String?;
    this.avatarHash = raw['avatar'] as String?;
    this.type = WebhookType.from(raw['type'] as int);

    if (raw['channel_id'] != null) {
      this.channel = client.channels[Snowflake(raw['channel_id'] as String)] as TextChannel?;
    }

    if (raw['guild_id'] != null) {
      this.guild = client.guilds[Snowflake(raw['guild_id'] as String)];
    }

    if(raw['user'] != null) {
      this.user = client.users[Snowflake(raw['user']['id'] as String)];
    }
  }

  @override
  String avatarURL({String format = 'webp', int size = 128}) {
    if(this.avatarHash != null) {
      return 'https://cdn.${_Constants.host}/avatars/${this.id}/${this.avatarHash}.$format?size=$size';
    }

    return "https://cdn.${_Constants.host}/embed/avatars/0.png?size=$size";
  }

  /// Edits the webhook.
  Future<Webhook> edit({String? name, TextChannel? channel, File? avatar, String? encodedAvatar, String? auditReason}) async {
    var body = <String, dynamic> {
      if(name != null) "name" : name,
      if(channel != null) "channel_id" : channel.id.toString()
    };

    var base64Encoded = avatar != null ? base64Encode(await avatar.readAsBytes()) : encodedAvatar;
    body['avatar'] = "data:image/jpeg;base64,$base64Encoded";

    var response = await client._http._execute(
        JsonRequest._new("/webhooks/$id/$token",
            method: "PATCH", auditLog: auditReason, body: body));

    if(response is HttpResponseSuccess) {
      this.name = response.jsonBody['name'] as String;
      return this;
    }

    return Future.error(response);
  }

  /// Deletes the webhook.
  Future<void> delete({String? auditReason}) {
    return client._http._execute(JsonRequest._new("/webhooks/$id/$token", method: "DELETE", auditLog: auditReason));
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name.toString();
}
