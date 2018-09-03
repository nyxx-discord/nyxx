part of nyxx;

/// [TextChannel] represents single text channel on [Guild].
/// Inhertits from [MessageChannel] and mixes [GuildChannel].
class TextChannel extends MessageChannel with GuildChannel {
  /// The channel's topic.
  String topic;

  /// The channel's mention string.
  String mention;

  TextChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, 0) {
    _initialize(data, guild);

    this.topic = raw['topic'] as String;
    this.mention = "<#${this.id}>";
    this.guild.channels[this.id] = this;
  }

  /// Edits the channel.
  Future<TextChannel> edit({
    String name,
    String topic,
    int position,
  }) async {
    HttpResponse r =
        await this.client.http.send('PATCH', "/channels/${this.id}", body: {
      "name": name != null ? name : this.name,
      "topic": topic != null ? topic : this.topic,
      "position": position != null ? position : this.position
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
