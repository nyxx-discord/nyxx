part of nyxx;

/// [TextChannel] represents single text channel on [Guild].
/// Inhertits from [MessageChannel] and mixes [GuildChannel].
class TextChannel extends MessageChannel with GuildChannel {
  /// Emitted when channel pins are updated.
  Stream<ChannelPinsUpdateEvent> pinsUpdated;

  StreamController<ChannelPinsUpdateEvent> _pinsUpdated;

  /// The channel's topic.
  String topic;

  /// The channel's mention string.
  String mention;

  /// Channel's slowmode rate limit in seconds. This must be between 0 and 120.
  int slowModeThreshold;

  /// Returns url to this channel.
  String get url => "https://discordapp.com/channels/${this.guild.id.toString()}"
      "/${this.id.toString()}";

  TextChannel._new(Nyxx client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, 0) {
    _initialize(data, guild);

    this.topic = raw['topic'] as String;
    this.mention = "<#${this.id}>";
    this.guild.channels[this.id] = this;
    this.slowModeThreshold = raw['rate_limit_per_user'] as int ?? 0;

    _pinsUpdated = StreamController.broadcast();
    pinsUpdated = _pinsUpdated.stream;
  }

  /// Edits the channel.
  Future<TextChannel> edit({
    String name,
    String topic,
    int position,
    int slowModeTreshold
  }) async {
    HttpResponse r =
        await this.client.http.send('PATCH', "/channels/${this.id}", body: {
      "name": name ?? this.name,
      "topic": topic ?? this.topic,
      "position": position ?? this.position,
      "rate_limit_per_user": slowModeTreshold ?? slowModeTreshold
    });
    return TextChannel._new(
        this.client, r.body as Map<String, dynamic>, this.guild);
  }

  /// Gets all of the webhooks for this channel.
  Future<Map<String, Webhook>> getWebhooks() async {
    HttpResponse r =
        await this.client.http.send('GET', "/channels/$id/webhooks");
    Map<String, Webhook> map = Map();

    r.body.forEach((k, o) {
      Webhook webhook = Webhook._new(this.client, o as Map<String, dynamic>);
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
    HttpResponse r = await this.client.http.send(
        'POST', "/channels/$id/webhooks",
        body: {"name": name}, reason: auditReason);
    return Webhook._new(this.client, r.body as Map<String, dynamic>);
  }

  /// Fetches and returns all channel's [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  Future<Map<String, Invite>> getChannelInvites() async {
    final HttpResponse r =
        await this.client.http.send('GET', "/channels/$id/invites");

    Map<String, Invite> invites = Map();
    for (Map<String, dynamic> val in r.body.values.first) {
      invites[val["code"] as String] = Invite._new(this.client, val);
    }

    return invites;
  }

  /// Creates new [Invite] for [Channel] and returns it's instance
  ///
  /// ```
  /// var inv = await chan.createInvite(maxUses: 2137);
  /// ```
  Future<Invite> createInvite(
      {int maxAge = 0,
      int maxUses = 0,
      bool temporary = false,
      bool unique = false,
      String auditReason = ""}) async {
    Map<String, dynamic> params = Map<String, dynamic>();

    params['max_age'] = maxAge;
    params['maxUses'] = maxUses;
    params['temporary'] = temporary;
    params['unique'] = unique;

    final HttpResponse r = await this.client.http.send(
        'POST', "/channels/$id/invites",
        body: params, reason: auditReason);

    return Invite._new(this.client, r.body as Map<String, dynamic>);
  }

  /// Returns pinned [Message]s for [Channel].
  Future<Map<String, Message>> getPinnedMessages() async {
    final HttpResponse r =
        await this.client.http.send('GET', "/channels/$id/pins");

    Map<String, Message> messages = Map();
    for (Map<String, dynamic> val in r.body.values.first) {
      messages[val["id"] as String] = Message._new(this.client, val);
    }

    return messages;
  }

  @override

  /// Returns mention to channel
  String toString() => this.mention;
}
