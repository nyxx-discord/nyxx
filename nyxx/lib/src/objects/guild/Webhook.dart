part of nyxx;

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
  late final int type;

  /// Webhook avatar
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
    this.type = raw['type'] as int;

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
  Future<Webhook> edit(String name, {String? auditReason}) async {
    var response = await client._http._execute(
        JsonRequest._new("/webhooks/$id/$token",
            method: "PATCH", auditLog: auditReason, body: {"name": name}));

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
