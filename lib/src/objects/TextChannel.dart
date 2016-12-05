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

  TextChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, guild, "text") {
    this.topic = data['topic'];
    this.lastMessageID = data['last_message_id'];
    this.messages = new Map<String, Message>();
  }

  void _cacheMessage(Message message) {
    if (this._client._options.messageCacheSize > 0) {
      if (this.messages.length >= this._client._options.messageCacheSize) {
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
  ///     Channel.sendMessage(content: "My content!");
  Future<Message> sendMessage(
      {String content,
      Map<dynamic, dynamic> embed,
      bool tts: false,
      String nonce,
      bool disableEveryone}) async {
    String newContent;
    if (content != null &&
        (disableEveryone == true ||
            (disableEveryone == null &&
                this._client._options.disableEveryone))) {
      newContent = content
          .replaceAll("@everyone", "@\u200Beveryone")
          .replaceAll("@here", "@\u200Bhere");
    } else {
      newContent = content;
    }

    final w_transport.Response r = await this._client.http.send(
        'POST', '/channels/${this.id}/messages', body: <String, dynamic>{
      "content": newContent,
      "tts": tts,
      "nonce": nonce,
      "embed": embed
    });
    return new Message._new(
        this._client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Edits the channel.
  Future<TextChannel> edit({
    String name: null,
    String topic: null,
    int position: null,
  }) async {
    w_transport.Response r =
        await this._client.http.send('PATCH', "/channels/${this.id}", body: {
      "name": name != null ? name : this.name,
      "topic": topic != null ? topic : this.topic,
      "position": position != null ? position : this.position
    });
    return new TextChannel._new(
        this._client, r.body.asJson() as Map<String, dynamic>, this.guild);
  }

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Channel.getMessage("message id");
  Future<Message> getMessage(dynamic message) async {
    if (this._client.user.bot) {
      final String id = Util.resolve('message', message);

      final w_transport.Response r = await this
          ._client
          .http
          .send('GET', '/channels/${this.id}/messages/$id');
      return new Message._new(
          this._client, r.body.asJson() as Map<String, dynamic>);
    } else {
      throw new Exception("'getMessage' is only usable by bot accounts.");
    }
  }

  /// Starts typing.
  Future<Null> startTyping() async {
    await this._client.http.send('POST', "/channels/$id/typing");
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

  /// Gets all of the webhooks for this channel.
  Future<Map<String, Webhook>> getWebhooks() async {
    w_transport.Response r =
        await this._client.http.send('GET', "/channels/$id/webhooks");
    Map<String, dynamic> map = <String, dynamic>{};
    r.body.asJson().forEach((Map<String, dynamic> o) {
      Webhook webhook = new Webhook._fromApi(this._client, o);
      map[webhook.id] = webhook;
    });
    return map;
  }

  /// Creates a webhook.
  Future<Webhook> createWebhook(String name) async {
    w_transport.Response r = await this
        ._client
        .http
        .send('POST', "/channels/$id/webhooks", body: {"name": name});
    return new Webhook._fromApi(
        this._client, r.body.asJson() as Map<String, dynamic>);
  }
}
