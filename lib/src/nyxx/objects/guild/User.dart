part of nyxx;

/// A user.
class User extends SnowflakeEntity with ISend {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The user's username.
  String username;

  /// The user's discriminator.
  String discriminator;

  /// The user's avatar hash.
  String avatar;

  /// The string to mention the user.
  String mention;

  /// The string to mention the user by nickname
  String mentionNickname;

  /// Whether or not the user is a bot.
  bool bot = false;

  /// Voice state
  UserVoiceState get voiceState => client._voiceStates.containsKey(this.id)
      ? client._voiceStates[this.id]
      : null;

  User._new(this.client, this.raw) : super(new Snowflake(raw['id'] as String)) {
    this.username = raw['username'] as String;
    this.discriminator = raw['discriminator'] as String;
    this.avatar = raw['avatar'] as String;
    this.mention = "<@${this.id}>";
    this.mentionNickname = "<@!${this.id}>";

    // This will not be set at all in some cases.
    if (raw['bot'] != null) this.bot = raw['bot'] as bool;

    client.users[this.id] = this;
  }

  /// The user's avatar, represented as URL.
  String avatarURL({String format: 'webp', int size: 128}) {
    if (this.id != null)
      return 'https://cdn.${_Constants.host}/avatars/${this.id}/${this.avatar}.$format?size=$size';

    return null;
  }

  /// Gets the [DMChannel] for the user.
  Future<DMChannel> getDMChannel() async {
    try {
      return client.channels.values.firstWhere(
              (Channel c) => c is DMChannel && c.recipient.id == this.id)
          as DMChannel;
    } catch (err) {
      HttpResponse r = await client.http.send('POST', "/users/@me/channels",
          body: {"recipient_id": this.id.toString()});
      return new DMChannel._new(
          client, r.body);
    }
  }

  @override

  /// Sends a message.
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

    DMChannel channel = await getDMChannel();

    final HttpResponse r = await this.client.http.send(
        'POST', '/channels/${channel.id.toString()}/messages',
        body: <String, dynamic>{
          "content": newContent,
          "tts": tts,
          "nonce": nonce,
          "embed": embed
        });
    return new Message._new(
        this.client, r.body);
  }

  /// Returns a mention of user
  @override
  String toString() => this.mention;
}
