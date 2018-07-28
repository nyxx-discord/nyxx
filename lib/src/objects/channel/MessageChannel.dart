part of nyxx;

/// Provides abstraction of messages for [TextChannel], [DMChannel] and [DMGroupChannel].
/// Caches message to avoid abusing API.
class MessageChannel extends Channel {
  Timer _typing;

  /// Sent when a new message is received.
  Stream<MessageEvent> onMessage;

  StreamController<MessageEvent> _onMessage;

  /// A collection of messages sent to this channel.
  LinkedHashMap<String, Message> messages;

  /// The ID for the last message in the channel.
  Snowflake lastMessageID;

  MessageChannel._new(Client client, Map<String, dynamic> data, String type)
      : super._new(client, data, type) {
    if (raw.containsKey('last_message_id') && raw['last_message_id'] != null)
      this.lastMessageID = new Snowflake(raw['last_message_id']);
    this.messages = new LinkedHashMap<String, Message>();

    _onMessage = new StreamController.broadcast();
    onMessage = _onMessage.stream;
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

  /// Sends file to channel and optional [content]. [filepath] is relative to project root.
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.send(content: "My content!");
  Future<Message> sendFile(List<String> filepaths,
      {String content = "", EmbedBuilder embed = null}) async {
    final HttpResponse r = await this.client.http.sendMultipart(
        'POST', '/channels/${this.id}/messages', filepaths,
        data: JSON.encode(<String, dynamic>{
          "content": content,
          "embed": embed != null ? embed.build() : ""
        }));

    return new Message._new(
        this.client, r.body.asJson() as Map<String, dynamic>);
  }

  Message getMessage(String id) =>
      messages.values.toList().firstWhere((i) => i.id.toString() == id);

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.send(content: "My content!");
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

    final HttpResponse r = await this
        .client
        .http
        .send('POST', '/channels/${this.id}/messages', body: <String, dynamic>{
      "content": newContent,
      "tts": tts,
      "nonce": nonce,
      "embed": embed != null ? embed.build() : ""
    });
    return new Message._new(
        this.client, r.body.asJson() as Map<String, dynamic>);
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

  /// Bulk removes many messages by its ids. [messagesIds] is list of messages ids to delete.
  Future<Null> bulkRemoveMessages(List<String> messagesIds) async {
    await this.client.http.send('POST', "/channels/$id/messages/bulk-delete",
        body: {"messages": messagesIds});

    return null;
  }

  /// Gets several [Message] objects.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.getMessages(limit: 100, after: "222078108977594368");
  Future<LinkedHashMap<String, Message>> getMessages({
    int limit: 50,
    Snowflake after: null,
    Snowflake before: null,
    Snowflake around: null,
  }) async {
    Map<String, dynamic> query = {"limit": limit.toString()};

    if (after != null) query['after'] = after.toString();
    if (before != null) query['before'] = before.toString();
    if (around != null) query['around'] = around.toString();

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
}
