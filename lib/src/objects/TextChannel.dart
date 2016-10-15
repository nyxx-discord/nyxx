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
    if (this.messages.length >= this._client._options.messageCacheSize) {
      this.messages.remove(this.messages.values.toList().first.id);
    }
    this.messages[message.id] = message;
  }

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.sendMessage("My content!");
  Future<Message> sendMessage(String content, [MessageOptions options]) async {
    MessageOptions newOptions;
    if (options == null) {
      newOptions = new MessageOptions();
    } else {
      newOptions = options;
    }

    String newContent;
    if (newOptions.disableEveryone == true ||
        (newOptions.disableEveryone == null &&
            this._client._options.disableEveryone)) {
      newContent = content
          .replaceAll("@everyone", "@\u200Beveryone")
          .replaceAll("@here", "@\u200Bhere");
    } else {
      newContent = content;
    }

    final _HttpResponse r = await this._client._http.post(
        '/channels/${this.id}/messages', <String, dynamic>{
      "content": newContent,
      "tts": newOptions.tts,
      "nonce": newOptions.nonce
    });
    return new Message._new(this._client, r.json as Map<String, dynamic>);
  }

  /// Edits the channel.
  Future<TextChannel> edit({
    String name: null,
    String topic: null,
    int position: null,
  }) async {
    _HttpResponse r = await this._client._http.patch("/channels/${this.id}", {
      "name": name != null ? name : this.name,
      "topic": topic != null ? topic : this.topic,
      "position": position != null ? position : this.position
    });
    return new TextChannel._new(
        this._client, r.json as Map<String, dynamic>, this.guild);
  }

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Channel.getMessage("message id");
  Future<Message> getMessage(dynamic message) async {
    if (this._client.user.bot) {
      final String id = this._client._util.resolve('message', message);

      final _HttpResponse r =
          await this._client._http.get('/channels/${this.id}/messages/$id');
      return new Message._new(this._client, r.json as Map<String, dynamic>);
    } else {
      throw new Exception("'getMessage' is only usable by bot accounts.");
    }
  }

  /// Starts typing.
  Future<Null> startTyping() async {
    await this._client._http.post("/channels/$id/typing", {});
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
