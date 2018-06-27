part of discord;

/// A text channel.
class TextChannel extends GuildChannel {
  Timer _typing;

  /// The channel's topic.
  String topic;

  /// A collection of messages sent to this channel.
  LinkedHashMap<String, Message> messages;

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// The channel's mention string.
  String mention;

  TextChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, guild, "text") {
    this.topic = raw['topic'];
    this.lastMessageID = raw['last_message_id'];
    this.messages = new LinkedHashMap<String, Message>();
    this.mention = "<#${this.id}>";
  }

  void _cacheMessage(Message message) {
    if (this.client._options.messageCacheSize > 0) {
      if (this.messages.length >= this.client._options.messageCacheSize) {
        this.messages.values.toList().first._onUpdate.close();
        this.messages.values.toList().first._onDelete.close();
        this.messages.remove(this.messages.values.toList().first.id);
      }
      this.messages[message.id] = message;
    }
  }

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.send(content: "My content!");
  Future<Message> send(
      {String content,
      Map<dynamic, dynamic> embed,
      bool tts: false,
      String nonce,
      bool disableEveryone}) async {
    String newContent;
    if (content != null &&
        (disableEveryone == true ||
            (disableEveryone == null &&
                this.client._options.disableEveryone))) {
      newContent = content
          .replaceAll("@everyone", "@\u200Beveryone")
          .replaceAll("@here", "@\u200Bhere");
    } else {
      newContent = content;
    }

    final HttpResponse r = await this.client.http.send(
        'POST', '/channels/${this.id}/messages', body: <String, dynamic>{
      "content": newContent,
      "tts": tts,
      "nonce": nonce,
      "embed": embed
    });
    return new Message._new(
        this.client, r.body.asJson() as Map<String, dynamic>);
  }

  @deprecated

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.sendMessage(content: "My content!");
  Future<Message> sendMessage(
      {String content,
      Map<dynamic, dynamic> embed,
      bool tts: false,
      String nonce,
      bool disableEveryone}) async {
    return this.send(
        content: content,
        embed: embed,
        tts: tts,
        nonce: nonce,
        disableEveryone: disableEveryone);
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

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Channel.getMessage("message id");
  Future<Message> getMessage(dynamic message) async {
    if (this.client.user.bot) {
      final String id = Util.resolve('message', message);

      final HttpResponse r = await this
          .client
          .http
          .send('GET', '/channels/${this.id}/messages/$id');
      return new Message._new(
          this.client, r.body.asJson() as Map<String, dynamic>);
    } else {
      throw new Exception("'getMessage' is only usable by bot accounts.");
    }
  }

  /// Gets several [Message] objects.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.getMessages(limit: 100, after: "222078108977594368");
  Future<LinkedHashMap<String, Message>> getMessages({
    int limit: 50,
    String after: null,
    String before: null,
    String around: null,
  }) async {
    Map<String, dynamic> query = {"limit": limit.toString()};

    if (after != null) query['after'] = after;
    if (before != null) query['before'] = before;
    if (around != null) query['around'] = around;

    final HttpResponse r = await this
        .client
        .http
        .send('GET', '/channels/${this.id}/messages', queryParams: query);

    LinkedHashMap<String, Message> response =
        new LinkedHashMap<String, Message>();

    for (Map<String, dynamic> val in r.body.asJson()) {
      response[val["id"]] = new Message._new(this.client, val);
    }

    return response;
  }

  /// Starts typing.
  Future<Null> startTyping() async {
    await this.client.http.send('POST', "/channels/$id/typing");
    return null;
  }

  /// Loops `startTyping` until `stopTypingLoop` is called.
  void startTypingLoop() {
    startTyping();
    this._typing = new Timer.periodic(
        const Duration(seconds: 7), (Timer t) => startTyping());
  }

  /// Stops a typing loop if one is running.
  void stopTypingLoop() {
    this._typing?.cancel();
  }

  Future<Null> bulkRemoveMessages(List<String> messagesIds) async {
    await this.client.http.send('POST', "/channels/$id/messages/bulk-delete",
        body: {"messages": messagesIds});

    return null;
  }

  /// Gets all of the webhooks for this channel.
  Future<Map<String, Webhook>> getWebhooks() async {
    HttpResponse r =
        await this.client.http.send('GET', "/channels/$id/webhooks");
    Map<String, dynamic> map = <String, dynamic>{};
    r.body.asJson().forEach((Map<String, dynamic> o) {
      Webhook webhook = new Webhook._fromApi(this.client, o);
      map[webhook.id] = webhook;
    });
    return map;
  }

  /// Creates a webhook.
  Future<Webhook> createWebhook(String name) async {
    HttpResponse r = await this
        .client
        .http
        .send('POST', "/channels/$id/webhooks", body: {"name": name});
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
      bool unique: false}) async {
    Map<String, dynamic> params = new Map<String, dynamic>();

    params['max_age'] = maxAge;
    params['maxUses'] = maxUses;
    params['temporary'] = temporary;
    params['unique'] = unique;

    final HttpResponse r = await this
        .client
        .http
        .send('POST', "/channels/$id/invites", body: params);

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
}
