part of nyxx;

/// [TextChannel] represents single text channel on [Guild].
/// Inhertits from [MessageChannel] and mixes [GuildChannel].
class TextChannel extends MessageChannel
    with GuildChannel
    implements Mentionable {
  /// Emitted when channel pins are updated.
  late final Stream<ChannelPinsUpdateEvent> pinsUpdated;

  /// The channel's topic.
  String? topic;

  @override

  /// The channel's mention string.
  String get mention => "<#${this.id}>";

  /// Channel's slowmode rate limit in seconds. This must be between 0 and 120.
  late final int slowModeThreshold;

  /// Returns url to this channel.
  String get url =>
      "https://discordapp.com/channels/${this.guild.id.toString()}"
      "/${this.id.toString()}";

  TextChannel._new(Map<String, dynamic> raw, Guild guild, Nyxx client)
      : super._new(raw, 0, client) {
    _initialize(raw, guild);

    this.topic = raw['topic'] as String?;
    this.slowModeThreshold = raw['rate_limit_per_user'] as int? ?? 0;

    pinsUpdated = client.onChannelPinsUpdate.where((event) => event.channel == this);
  }

  /// Edits the channel.
  Future<TextChannel> edit(
      {String? name, String? topic, int? position, int? slowModeTreshold}) async {

    var body = <String, dynamic> {
      if(name != null) "name" : name,
      if(topic != null) "topic" : topic,
      if(position != null) "position" : position,
      if(slowModeTreshold != null) "rate_limit_per_user" : slowModeTreshold,
    };

    var response = await client._http._execute(
        BasicRequest._new( "/channels/${this.id}", method: "PATCH", body: body));

    if(response is HttpResponseSuccess) {
      return TextChannel._new(response.jsonBody as Map<String, dynamic>, this.guild, client);
    }

    return Future.error(response);
  }

  /// Gets all of the webhooks for this channel.
  Stream<Webhook> getWebhooks() async* {
    var response = await client._http._execute(BasicRequest._new("/channels/$id/webhooks"));

    if(response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for(var o in (response as HttpResponseSuccess).jsonBody.values) {
      yield Webhook._new(o as Map<String, dynamic>, client);
    }
  }

  /// Creates a webhook for channel.
  /// Valid file types for [avatarFile] are jpeg, gif and png.
  ///
  /// ```
  /// var webhook = await chan.createWebhook("!a Send nudes kek6407");
  /// ```
  Future<Webhook> createWebhook(String name, {File? avatarFile, String auditReason = ""}) async {
    if(name.isEmpty || name.length > 80) {
      return Future.error("Webhook's name cannot be shorter than 1 character and longer than 80 characters");
    }

    var body = <String, dynamic> {
      "name": name
    };

    if(avatarFile != null) {
      final extension = Utils.getFileExtension(avatarFile.path);
      final data = base64Encode(await avatarFile.readAsBytes());

      body['avatar'] = "data:image/${extension};base64,${data}";
    }
    
    var response = await client._http._execute(
        BasicRequest._new("/channels/$id/webhooks", method: "POST", body: body, auditLog: auditReason));
    
    if(response is HttpResponseSuccess) {
      return Webhook._new(response.jsonBody as Map<String, dynamic>, client);
    }
    
    return Future.error(response);
  }

  /// Returns pinned [Message]s for [Channel].
  Stream<Message> getPinnedMessages() async* {
    var response = await client._http._execute(BasicRequest._new("/channels/$id/pins"));

    if(response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (Map<String, dynamic> val in ((response as HttpResponseSuccess).jsonBody.values.first as Iterable<Map<String, dynamic>>)) {
      yield Message._deserialize(val, client);
    }
  }

  @override

  /// Returns mention to channel
  String toString() => this.mention;
}
