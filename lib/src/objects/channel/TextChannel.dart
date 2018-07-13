part of nyxx;

/// [TextChannel] represents single text channel on [Guild].
/// Inhertits from [MessageChannel] and mixes [GuildChannel].
class TextChannel extends MessageChannel with GuildChannel {
  /// The channel's topic.
  String topic;

  /// The channel's mention string.
  String mention;

  TextChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, "text") {
    initialize(data);
    this.topic = raw['topic'];
    this.guild = guild;

    this.mention = "<#${this.id}>";
    this.guild.channels[this.id.toString()] = this;
  }

  /// Edits the channel.
  Future<TextChannel> edit({
    String name: null,
    String topic: null,
    int position: null,
  }) async {
    HttpResponse r =
        await this.client.http.send('PATCH', "/channels/${this.id}", body: {
      "name": name != null ? name : this.name,
      "topic": topic != null ? topic : this.topic,
      "position": position != null ? position : this.position
    });
    return new TextChannel._new(
        this.client, r.body.asJson() as Map<String, dynamic>, this.guild);
  }

  /// Gets all of the webhooks for this channel.
  Future<Map<String, Webhook>> getWebhooks() async {
    HttpResponse r =
        await this.client.http.send('GET', "/channels/$id/webhooks");
    Map<String, dynamic> map = <String, dynamic>{};
    r.body.asJson().forEach((Map<String, dynamic> o) {
      Webhook webhook = new Webhook._fromApi(this.client, o);
      map[webhook.id.toString()] = webhook;
    });
    return map;
  }

  /// Creates a webhook.
  Future<Webhook> createWebhook(String name, {String auditReason: ""}) async {
    HttpResponse r = await this.client.http.send(
        'POST', "/channels/$id/webhooks",
        body: {"name": name}, reason: auditReason);
    return new Webhook._fromApi(
        this.client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Returns all [Channel]s [Invite]s
  Future<Map<String, Invite>> getChannelInvites() async {
    final HttpResponse r =
        await this.client.http.send('GET', "/channels/$id/invites");

    Map<String, Invite> invites = new Map();
    for (Map<String, dynamic> val in r.body.asJson()) {
      invites[val["code"]] = new Invite._new(this.client, val);
    }

    return invites;
  }

  /// Creates new [Invite] for [Channel] and returns it
  Future<Invite> createInvite(
      {int maxAge: 0,
      int maxUses: 0,
      bool temporary: false,
      bool unique: false,
      String auditReason: ""}) async {
    Map<String, dynamic> params = new Map<String, dynamic>();

    params['max_age'] = maxAge;
    params['maxUses'] = maxUses;
    params['temporary'] = temporary;
    params['unique'] = unique;

    final HttpResponse r = await this.client.http.send(
        'POST', "/channels/$id/invites",
        body: params, reason: auditReason);

    return new Invite._new(
        this.client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Returns pinned [Message]s for [Channel]
  Future<Map<String, Message>> getPinnedMessages() async {
    final HttpResponse r =
        await this.client.http.send('GET', "/channels/$id/pins");

    Map<String, Message> messages = new Map();
    for (Map<String, dynamic> val in r.body.asJson()) {
      messages[val["id"]] = new Message._new(this.client, val);
    }

    return messages;
  }

  @override
  /// Returns mention to channel
  String toString() => this.mention;
}
