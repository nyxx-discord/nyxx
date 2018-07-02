part of nyxx;

/// A user.
class User {
  Timer _typing;

  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The user's username.
  String username;

  /// The user's ID.
  String id;

  /// The user's discriminator.
  String discriminator;

  /// The user's avatar hash.
  String avatar;

  /// The string to mention the user.
  String mention;

  /// A timestamp of when the user was created.
  DateTime createdAt;

  /// Whether or not the user is a bot.
  bool bot = false;

  User._new(this.client, this.raw) {
    this.username = raw['username'];
    this.id = raw['id'];
    this.discriminator = raw['discriminator'];
    this.avatar = raw['avatar'];
    this.mention = "<@${this.id}>";
    this.createdAt = Util.getDate(this.id);

    // This will not be set at all in some cases.
    if (raw['bot'] == true) {
      this.bot = raw['bot'];
    }

    client.users[this.id] = this;
  }

  /// The user's avatar, represented as URL.
  String avatarURL({String format: 'webp', int size: 128}) {
    return 'https://cdn.${_Constants.host}/avatars/${this.id}/${this.avatar}.$format?size=$size';
  }

  /// Gets the [DMChannel] for the user.
  Future<DMChannel> getChannel() async {
    try {
      return client.channels.values.firstWhere(
          (dynamic c) => c is DMChannel && c.recipient.id == this.id);
    } catch (err) {
      HttpResponse r = await client.http
          .send('POST', "/users/@me/channels", body: {"recipient_id": this.id});
      return new DMChannel._new(
          client, r.body.asJson() as Map<String, dynamic>);
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

    DMChannel channel = await getChannel();
    String channelId = channel.id.toString();

    final HttpResponse r = await this.client.http.send(
        'POST', '/channels/$channelId/messages', body: <String, dynamic>{
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

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Channel.getMessage("message id");
  Future<Message> getMessage(dynamic message) async {
    if (this.client.user.bot) {
      final String id = Util.resolve('message', message);
      DMChannel channel = await getChannel();
      String channelId = channel.id.toString();

      final HttpResponse r = await this
          .client
          .http
          .send('GET', '/channels/$channelId/messages/$id');
      return new Message._new(
          this.client, r.body.asJson() as Map<String, dynamic>);
    } else {
      throw new Exception("'getMessage' is only usable by bot accounts.");
    }
  }

  /// Starts typing.
  Future<Null> startTyping() async {
    DMChannel channel = await getChannel();
    String channelId = channel.id.toString();

    await this.client.http.send('POST', "/channels/$channelId/typing");
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

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.username;
  }
}
