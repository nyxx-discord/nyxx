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
class MessageChannel extends Channel with IterableMixin<Message>, ISend, Disposable {
  Timer? _typing;

  /// Sent when a new message is received.
  late final Stream<MessageReceivedEvent> onMessage;

  /// Emitted when user starts typing.
  late final Stream<TypingEvent> onTyping;

  /// A collection of messages sent to this channel.
  late final MessageCache messages;

  /// File upload limit for channel
  int get fileUploadLimit {
    if (this is GuildChannel) {
      return (this as GuildChannel).guild.fileUploadLimit;
    }

    return 8 * 1024 * 1024;
  }

  MessageChannel._new(Map<String, dynamic> raw, int type, Nyxx client) : super._new(raw, type, client) {
    this.messages = MessageCache._new(client._options.messageCacheSize);

    onTyping = client.onTyping.where((event) => event.channel == this);
    onMessage = client.onMessageReceived.where((event) => event.message.channel == this);
  }

  /// Returns message with given [id]. Allows to force fetch message from api
  /// with [ignoreCache] property. By default it checks if message is in cache and fetches from api if not.
  Future<Message?> getMessage(Snowflake id, {bool ignoreCache = false}) async {
    if (ignoreCache || !messages.hasKey(id)) {
      final response = await client._http._execute(BasicRequest._new("/channels/${this.id.toString()}/messages/$id"));

      if (response is HttpResponseError) {
        return Future.error(response);
      }

      var msg = Message._deserialize((response as HttpResponseSuccess).jsonBody as Map<String, dynamic>, client);
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
  ///   ..thumbnailUrl = "${attach("kitten.jpg")}";
  ///
  /// await e.message.channel
  ///   .send(files: [new File("kitten.jpg")], embed: embed, content: "HEJKA!");
  /// ```
  Future<Message> send(
      {dynamic content,
      List<AttachmentBuilder>? files,
      EmbedBuilder? embed,
      bool? tts,
      AllowedMentions? allowedMentions,
      MessageBuilder? builder}) async {
    if (builder != null) {
      content = builder._content;
      files = builder.files;
      embed = builder.embed;
      tts = builder.tts ?? false;
      allowedMentions = builder.allowedMentions;
    }

    final  reqBody = {
      ..._initMessage(content, embed, allowedMentions),
      if (content != null && tts != null) "tts": tts
    };

    // Cancel typing if present
    this._typing?.cancel();

    _HttpResponse response;

    if (files != null && files.isNotEmpty) {
      for (final file in files) {
        if (file._bytes.length > fileUploadLimit) {
          return Future.error("File with name: [${file._name}] is too big!");
        }
      }

      response = await client._http
          ._execute(MultipartRequest._new("/channels/${this.id}/messages", files, method: "POST", fields: reqBody));
    } else {
      response = await client._http
          ._execute(BasicRequest._new("/channels/${this.id}/messages", body: reqBody, method: "POST"));
    }

    if (response is HttpResponseSuccess) {
      return Message._deserialize(response.jsonBody as Map<String, dynamic>, client);
    } else {
      return Future.error(response);
    }
  }

  /// Starts typing.
  Future<void> startTyping() async =>
    client._http._execute(BasicRequest._new("/channels/$id/typing", method: "POST"));

  /// Loops `startTyping` until `stopTypingLoop` is called.
  void startTypingLoop() {
    startTyping();
    this._typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
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
    await for (final chunk in Utils.chunk(messagesIds.toList(), 90)) {
      await client._http._execute(BasicRequest._new("/channels/${id.toString()}/messages/bulk-delete",
          method: "POST", body: {"messages": chunk.map((f) => f.id.toString()).toList()}));
    }
  }

  /// Gets several [Message] objects from API. Only one of [after], [before], [around] can be specified,
  /// otherwise, it will throw.
  ///
  /// ```
  /// var messages = await chan.getMessages(limit: 100, after: Snowflake("222078108977594368"));
  /// ```
  Stream<Message> getMessages({int limit = 50, Snowflake? after, Snowflake? before, Snowflake? around}) async* {
    final queryParams = {
      "limit": limit.toString(),
      if (after != null) "after": after.toString(),
      if (before != null) "before": before.toString(),
      if (around != null) "around": around.toString()
    };

    final response =
        await client._http._execute(BasicRequest._new("/channels/${this.id}/messages", queryParams: queryParams));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    for (final val in (response as HttpResponseSuccess).jsonBody) {
      yield Message._deserialize(val as Map<String, dynamic>, client);
    }
  }

  @override
  Iterator<Message> get iterator => messages.values.iterator;

  @override
  Future<void> dispose() async {
    await messages.dispose();
  }
}
