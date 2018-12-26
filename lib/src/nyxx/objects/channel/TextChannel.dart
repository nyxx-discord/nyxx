part of nyxx;

/// [TextChannel] represents single text channel on [Guild].
/// Inhertits from [MessageChannel] and mixes [GuildChannel].
class TextChannel extends MessageChannel
    with GuildChannel
    implements Mentionable {
  /// Emitted when channel pins are updated.
  Stream<ChannelPinsUpdateEvent> pinsUpdated;

  StreamController<ChannelPinsUpdateEvent> _pinsUpdated;

  /// The channel's topic.
  String topic;

  @override

  /// The channel's mention string.
  String get mention => "<#${this.id}>";

  /// Channel's slowmode rate limit in seconds. This must be between 0 and 120.
  int slowModeThreshold;

  /// Returns url to this channel.
  String get url =>
      "https://discordapp.com/channels/${this.guild.id.toString()}"
      "/${this.id.toString()}";

  TextChannel._new(Map<String, dynamic> raw, Guild guild, Nyxx client) : super._new(raw, 0, client) {
    _initialize(raw, guild);

    this.topic = raw['topic'] as String;
    this.slowModeThreshold = raw['rate_limit_per_user'] as int ?? 0;

    _pinsUpdated = StreamController.broadcast();
    pinsUpdated = _pinsUpdated.stream;
  }

  //T getRaw<T>(Map<String, dynamic> raw, String name) => raw[name] as T;

  /// Edits the channel.
  Future<TextChannel> edit(
      {String name, String topic, int position, int slowModeTreshold}) async {
    HttpResponse r =
        await client._http.send('PATCH', "/channels/${this.id}", body: {
      "name": name ?? this.name,
      "topic": topic ?? this.topic,
      "position": position ?? this.position,
      "rate_limit_per_user": slowModeTreshold ?? slowModeTreshold
    });
    return TextChannel._new(r.body as Map<String, dynamic>, this.guild, client);
  }

  /// Gets all of the webhooks for this channel.
  Future<Map<String, Webhook>> getWebhooks() async {
    HttpResponse r = await client._http.send('GET', "/channels/$id/webhooks");
    Map<String, Webhook> map = Map();

    r.body.forEach((k, o) {
      Webhook webhook = Webhook._new(o as Map<String, dynamic>, client);
      map[webhook.id.toString()] = webhook;
    });

    return map;
  }

  /// Creates a webhook for channel.
  ///
  /// ```
  /// var webhook = await chan.createWebhook("!a Send nudes kek6407");
  /// ```
  Future<Webhook> createWebhook(String name, {String auditReason = ""}) async {
    HttpResponse r = await client._http.send('POST', "/channels/$id/webhooks",
        body: {"name": name}, reason: auditReason);
    return Webhook._new(r.body as Map<String, dynamic>, client);
  }

  /// Returns pinned [Message]s for [Channel].
  Future<Map<String, Message>> getPinnedMessages() async {
    final HttpResponse r =
        await client._http.send('GET', "/channels/$id/pins");

    Map<String, Message> messages = Map();
    for (Map<String, dynamic> val in r.body.values.first) {
      messages[val["id"] as String] = Message._new(val, client);
    }

    return messages;
  }

  @override
  String get debugString => "[${this.guild.name}] Text Channel [${this.id}]";

  @override

  /// Returns mention to channel
  String toString() => this.mention;
}
