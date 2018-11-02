part of nyxx;

/// Represents a single user of Discord, either a human or a bot, outside of any specific guild's context.
class User extends SnowflakeEntity with ISend, IMentionable, Nameable {
  /// The user's username.
  String username;

  /// The user's discriminator.
  String discriminator;

  /// The user's avatar hash.
  String avatar;

  @override

  /// The string to mention the user.
  String get mention => "<@!${this.id}>";

  /// Returns String with username#discriminator
  String get tag => "${this.username}#${this.discriminator}";

  /// Whether or not the user is a bot.
  bool bot;

  User._new(Map<String, dynamic> raw) : super(Snowflake(raw['id'] as String)) {
    this.username = raw['username'] as String;
    this.discriminator = raw['discriminator'] as String;
    this.avatar = raw['avatar'] as String;
    this.bot = raw['bot'] as bool ?? false;
  }

  /// The user's avatar, represented as URL.
  String avatarURL({String format = 'webp', int size = 128}) {
    if (this.avatar != null)
      return 'https://cdn.${_Constants.host}/avatars/${this.id}/${this.avatar}.$format?size=$size';

    return null;
  }

  /// Gets the [DMChannel] for the user.
  Future<DMChannel> get dmChannel async {
    try {
      return client.channels.findOne(
              (Channel c) => c is DMChannel && c.recipient.id == this.id)
          as DMChannel;
    } catch (err) {
      HttpResponse r = await client._http.send('POST', "/users/@me/channels",
          body: {"recipient_id": this.id.toString()});
      return DMChannel._new(r.body as Map<String, dynamic>);
    }
  }

  @override

  /// Sends a message to user.
  Future<Message> send(
      {Object content = "",
      List<File> files,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone,
      MessageBuilder builder}) async {
    DMChannel channel = await this.dmChannel;
    return channel.send(
        content: content,
        files: files,
        embed: embed,
        tts: tts,
        disableEveryone: disableEveryone,
        builder: builder);
  }

  /// Returns a mention of user
  @override
  String toString() => this.mention;

  @override
  String get nameString => "User ${this.tag} [${this.id}]";
}
