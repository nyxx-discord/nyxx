part of nyxx;

/// Provides abstraction of messages for [TextChannel], [DMChannel] and [GroupDMChannel].
/// Implements iterator which allows to use message object in for loops to access
/// messages sequentially.
///
/// ```
/// var chan = client.channels.firstWhere((ch) => ch is TextChannel);
///
/// for (var message in chan) {
///   print(message.author.id);
/// }
/// ```
class MessageChannel extends Channel
    with IterableMixin<Message>, ISend, Disposable {
  Timer _typing;

  /// Sent when a new message is received.
  Stream<MessageReceivedEvent> onMessage;

  /// Emitted when user starts typing.
  Stream<TypingEvent> onTyping;

  StreamController<MessageReceivedEvent> _onMessage;
  StreamController<TypingEvent> _onTyping;

  /// A collection of messages sent to this channel.
  MessageCache messages;

  MessageChannel._new(Map<String, dynamic> raw, int type, Nyxx client)
      : super._new(raw, type, client) {
    this.messages = MessageCache._new(client._options);

    _onMessage = StreamController.broadcast();
    _onTyping = StreamController.broadcast();

    onTyping = _onTyping.stream;
    onMessage = _onMessage.stream;
  }

  /// Returns message with given [id]. Allows to force fetch message from api
  /// with [force] property. By default it checks if message is in cache and fetches from api if not.
  Future<Message> getMessage(Snowflake id, {bool force = false}) async {
    if (force || !messages.hasKey(id)) {
      var r = await client._http
          .send('GET', "/channels/${this.id.toString()}/messages/$id");
      var msg = Message._new(r.body as Map<String, dynamic>, client);

      return messages._cacheMessage(msg);
    }

    return messages[id];
  }

  @override

  /// Sends message to channel. Performs `toString()` on thing passed to [content]. Allows to send embeds with [embed] field.
  ///
  /// ```
  /// await chan.send(content: "Very nice message!");
  /// ```
  ///
  /// Can be used in combination with [Emoji]. Just run `toString()` on [Emoji] instance:
  /// ```
  /// var emoji = guild.emojis.values.firstWhere((e) => e.name.startsWith("dart"));
  /// await chan.send(content: "Dart is superb! ${emoji.toString()}");
  /// ```
  /// Embeds can be sent very easily:
  /// ```
  /// var embed = new EmbedBuilder()
  ///   ..title = "Example Title"
  ///   ..addField(name: "Memory usage", value: "${ProcessInfo.currentRss / 1024 / 1024}MB");
  ///
  /// await chan.send(embed: embed);
  /// ```
  ///
  ///
  /// Method also allows to send file and optional [content] with [embed].
  /// Use `expandAttachment(String file)` method to expand file names in embed
  ///
  /// ```
  /// await chan.send(files: [new File("kitten.png"), new File("kitten.jpg")], content: "Kittens ^-^"]);
  /// ```
  /// ```
  /// var embed = new nyxx.EmbedBuilder()
  ///   ..title = "Example Title"
  ///   ..thumbnailUrl = "${attach('kitten.jpg')}";
  ///
  /// await e.message.channel
  ///   .send(files: [new File("kitten.jpg")], embed: embed, content: "HEJKA!");
  /// ```
  Future<Message> send(
      {Object content = "",
      List<AttachmentBuilder> files,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone,
      MessageBuilder builder}) async {
    if (builder != null) {
      content = builder._content;
      files = builder.files;
      embed = builder.embed;
      tts = builder.tts ?? false;
      disableEveryone = builder.disableEveryone;
    }

    var newContent = _sanitizeMessage(content, disableEveryone, client);

    Map<String, dynamic> reqBody = {
      "content": newContent ?? "",
      "embed": embed != null ? embed._build() : ""
    };

    // Cancel typing if present
    this._typing?.cancel();

    HttpResponse r;
    if (files != null && files.isNotEmpty) {
      r = await client._http.sendMultipart(
          'POST', '/channels/${this.id}/messages', files,
          data: reqBody);
    } else {
      r = await client._http.send('POST', '/channels/${this.id}/messages',
          body: reqBody..addAll({"tts": tts}));
    }

    return Message._new(r.body as Map<String, dynamic>, client);
  }

  /// Starts typing.
  Future<void> startTyping() async {
    await client._http.send('POST', "/channels/$id/typing");
  }

  /// Loops `startTyping` until `stopTypingLoop` is called.
  void startTypingLoop() {
    startTyping();
    this._typing =
        Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  /// Stops a typing loop if one is running.
  void stopTypingLoop() => this._typing?.cancel();

  /// Bulk removes many messages by its ids. [messagesIds] is list of messages ids to delete.
  ///
  /// ```
  /// var toDelete = chan.messages.keys.take(5);
  /// await chan.bulkRemoveMessages(toDelete);
  /// ```
  Future<void> bulkRemoveMessages(Iterable<Message> messagesIds) async {
    await for (var chunk in Utils.chunk(messagesIds.toList(), 90)) {
      await client._http.send(
          'POST', "/channels/${id.toString()}/messages/bulk-delete",
          body: {"messages": chunk.map((f) => f.id.toString()).toList()});
    }
  }

  /// Gets several [Message] objects from API. Only one of [after], [before], [around] can be specified
  /// otherwise it'll throw.
  ///
  /// ```
  /// var messages = await chan.getMessages(limit: 100, after: Snowflake("222078108977594368"));
  /// ```
  Stream<Message> getMessages(
      {int limit = 50,
      Snowflake after,
      Snowflake before,
      Snowflake around}) async* {
    Map<String, String> query = {"limit": limit.toString()};

    if (after != null) query['after'] = after.toString();
    if (before != null) query['before'] = before.toString();
    if (around != null) query['around'] = around.toString();

    final HttpResponse r = await client._http
        .send('GET', '/channels/${this.id}/messages', queryParams: query);

    for (dynamic val in r.body) {
      yield Message._new(val as Map<String, dynamic>, client);
    }
  }

  @override
  Iterator<Message> get iterator => messages.values.iterator;

  @override
  Future<void> dispose() => Future(() {
        _onMessage.close();
        _onTyping.close();
        messages.dispose();
      });
}
