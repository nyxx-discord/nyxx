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
  Snowflake id;

  /// The user's discriminator.
  String discriminator;

  /// The user's avatar hash.
  String avatar;

  /// The string to mention the user.
  String mention;

  /// The string to mention the user by nickname
  String mentionNickname;

  /// A timestamp of when the user was created.
  DateTime createdAt;

  /// Whether or not the user is a bot.
  bool bot = false;

  User._new(this.client, this.raw) {
    this.username = raw['username'] as String;
    this.id = new Snowflake(raw['id'] as String);
    this.discriminator = raw['discriminator'] as String;
    this.avatar = raw['avatar'] as String;
    this.mention = "<@${this.id}>";
    this.mentionNickname = "<@!${this.id}>";
    this.createdAt = id.timestamp;

    // This will not be set at all in some cases.
    if (raw['bot'] == true) {
      this.bot = raw['bot'] as bool;
    }

    client.users[this.id.toString()] = this;
  }

  /// The user's avatar, represented as URL.
  String avatarURL({String format: 'webp', int size: 128}) {
    if (this.id != null)
      return 'https://cdn.${_Constants.host}/avatars/${this.id}/${this.avatar}.$format?size=$size';

    return null;
  }

  /// Gets the [DMChannel] for the user.
  Future<DMChannel> getChannel() async {
    try {
      return client.channels.values.firstWhere((Channel c) => c is DMChannel && c.recipient.id == this.id) as DMChannel;
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

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Channel.getMessage("message id");
  Future<Message> getMessage(String messageId) async {
    if (this.client.user.bot) {
      DMChannel channel = await getChannel();
      String channelId = channel.id.toString();

      final HttpResponse r = await this
          .client
          .http
          .send('GET', '/channels/$channelId/messages/$messageId');
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

  /// Returns a mention of user
  @override
  String toString() => this.mention;
}
