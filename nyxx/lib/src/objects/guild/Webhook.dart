part of nyxx;

///Webhooks are a low-effort way to post messages to channels in Discord.
///They do not require a bot user or authentication to use.
class Webhook extends SnowflakeEntity with ISend implements IMessageAuthor {
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

  // TODO: What's that and where it came from
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
  String? avatarURL({String format = 'webp', int size = 128}) {
    if(this.avatarHash != null) {
      return 'https://cdn.${_Constants.host}/avatars/${this.id}/${this.avatarHash}.$format?size=$size';
    }

    return null;
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

  @override

  // TODO: SUPPOER MULTIPLE EMBEDS
  // TODO: File limits
  /// Allows to send message via webhook
  Future<Message> send(
        {dynamic content,
        List<AttachmentBuilder>? files,
        EmbedBuilder? embed,
        bool? tts,
        AllowedMentions? allowedMentions,
        MessageBuilder? builder}) async {
    if (builder != null) {
      content = builder._content;
      files = builder.files;
      embed = builder.embed;
      tts = builder.tts ?? false;
      allowedMentions = builder.allowedMentions;
    }

    Map<String, dynamic> reqBody = {
      ..._initMessage(content, embed, allowedMentions),
      if(content != null && tts != null) "tts": tts
    };

    HttpResponse response;

    if (files != null && files.isNotEmpty) {
      for(var file in files) {
        // TODO: Check how to handle file size limit
        if(file._bytes.length > 8 * 1024 * 1024) {
          return Future.error("File with name: [${file._name}] is too big!");
        }
      }

      response = await client._http._execute(
          MultipartRequest._new('/webhooks/${this.id}/${this.token}',
              files, method: "POST", fields: reqBody));
    } else {
      response = await client._http._execute(
          JsonRequest._new('/webhooks/${this.id}/${this.token}',
              body: reqBody, method: "POST"));
    }

    if(response is HttpResponseSuccess) {
      return Message._new(response.jsonBody as Map<String, dynamic>, client);
    } else {
      return Future.error(response);
    }
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name.toString();
}
