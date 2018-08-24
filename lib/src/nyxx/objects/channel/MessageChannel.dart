part of nyxx;

/// Provides abstraction of messages for [TextChannel], [DMChannel] and [GroupDMChannel].
/// Caches message to avoid abusing API.
class MessageChannel extends Channel with IterableMixin<Message>, ISend {
  Timer _typing;

  /// Sent when a new message is received.
  Stream<MessageEvent> onMessage;

  /// Emitted when user starts typing
  Stream<TypingEvent> onTyping;

  StreamController<MessageEvent> _onMessage;
  StreamController<TypingEvent> _onTyping;

  /// A collection of messages sent to this channel.
  LinkedHashMap<Snowflake, Message> messages;

  /// The ID for the last message in the channel.
  Snowflake lastMessageID;

  MessageChannel._new(Client client, Map<String, dynamic> data, String type)
      : super._new(client, data, type) {
    if (raw.containsKey('last_message_id') && raw['last_message_id'] != null)
      this.lastMessageID = new Snowflake(raw['last_message_id'] as String);
    this.messages = new LinkedHashMap<Snowflake, Message>();

    _onMessage = new StreamController.broadcast();
    _onTyping = new StreamController.broadcast();

    onTyping = _onTyping.stream;
    onMessage = _onMessage.stream;
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

  /// Sends file to channel and optional [content].
  /// [filepaths] are path to files - relative to project root.
  /// Throws an [Exception] if the HTTP request errored.
  Future<Message> sendFile(List<String> filepaths,
      {String content = "", EmbedBuilder embed}) async {
    final HttpResponse r = await this.client.http.sendMultipart(
        'POST', '/channels/${this.id}/messages', filepaths,
        data: jsonEncode(<String, dynamic>{
          "content": content,
          "embed": embed != null ? embed._build() : ""
        }));

    return new Message._new(
        this.client, r.body);
  }

  Message getMessage(Snowflake id) => messages[id];

  @override

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.send(content: "My content!");
  Future<Message> send(
      {Object content: "",
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
          .toString()
          .replaceAll("@everyone", "@\u200Beveryone")
          .replaceAll("@here", "@\u200Bhere");
    } else {
      newContent = content.toString();
    }

    final HttpResponse r = await this
        .client
        .http
        .send('POST', '/channels/${this.id}/messages', body: <String, dynamic>{
      "content": newContent,
      "tts": tts,
      "nonce": nonce,
      "embed": embed != null ? embed._build() : ""
    });
    return new Message._new(
        this.client, r.body);
  }

  /// Starts typing.
  Future<void> startTyping() async {
    await this.client.http.send('POST', "/channels/$id/typing");
  }

  /// Loops `startTyping` until `stopTypingLoop` is called.
  void startTypingLoop() {
    startTyping();
    this._typing = new Timer.periodic(
        const Duration(seconds: 7), (Timer t) => startTyping());
  }

  /// Stops a typing loop if one is running.
  void stopTypingLoop() => this._typing?.cancel();

  /// Bulk removes many messages by its ids. [messagesIds] is list of messages ids to delete.
  Future<void> bulkRemoveMessages(Iterable<Snowflake> messagesIds) async {
    if (messages.isEmpty) return null;

    await this.client.http.send(
        'POST', "/channels/${id.toString()}/messages/bulk-delete",
        body: {"messages": messagesIds.take(99)});

    await bulkRemoveMessages(messagesIds.skip(99));
  }

  /// Gets several [Message] objects.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.getMessages(limit: 100, after: "222078108977594368");
  Future<LinkedHashMap<Snowflake, Message>> getMessages({
    int limit: 50,
    Snowflake after,
    Snowflake before,
    Snowflake around,
  }) async {
    Map<String, String> query = {"limit": limit.toString()};

    if (after != null) query['after'] = after.toString();
    if (before != null) query['before'] = before.toString();
    if (around != null) query['around'] = around.toString();

    final HttpResponse r = await this
        .client
        .http
        .send('GET', '/channels/${this.id}/messages', queryParams: query);

    var response = new LinkedHashMap<Snowflake, Message>();

    for (Map<String, dynamic> val in r.body.values.first) {
      var msg = new Message._new(this.client, val);
      response[msg.id] = msg;
    }

    return response;
  }

  @override
  Iterator<Message> get iterator => messages.values.iterator;
}
