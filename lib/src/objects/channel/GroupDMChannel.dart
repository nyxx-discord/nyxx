part of nyxx;

/// A group DM channel.
class GroupDMChannel extends Channel {
  Timer _typing;

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// A collection of messages sent to this channel.
  LinkedHashMap<String, Message> messages;

  /// The recipients.
  Map<String, User> recipients;

  GroupDMChannel._new(Client client, Map<String, dynamic> data)
      : super._new(client, data, "private") {
    this.lastMessageID = raw['last_message_id'];
    this.messages = new LinkedHashMap<String, Message>();

    this.recipients = new Map<String, User>();
    raw['recipients'].forEach((Map<String, dynamic> o) {
      final User user = new User._new(client, o);
      this.recipients[user.id] = user;
    });
  }

  void _cacheMessage(Message message) {
    if (this.client._options.messageCacheSize > 0) {
      if (this.messages.length >= this.client._options.messageCacheSize) {
        this.messages.values.toList().first._onUpdate.close();
        this.messages.values.toList().first._onDelete.close();
        this.messages.remove(this.messages.values.toList().first.id);
      }
      this.messages[message.id.toString()] = message;
    }
  }

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.send(content: "My content!");
  @override
  Future<Message> send(
      {String content,
      EmbedBuilder embed,
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
      "embed": embed.build()
    });
    return new Message._new(
        this.client, r.body.asJson() as Map<String, dynamic>);
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
}
