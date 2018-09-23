part of nyxx;

/// Represents a single user of Discord, either a human or a bot, outside of any specific guild's context.
class User extends SnowflakeEntity with ISend {
  /// The user's username.
  String username;

  /// The user's discriminator.
  String discriminator;

  /// The user's avatar hash.
  String avatar;

  /// The string to mention the user.
  String get mention => "<@${this.id}>";

  /// The string to mention the user by nickname
  String get mentionNickname => "<@!${this.id}>";

  /// Whether or not the user is a bot.
  bool bot = false;

  User._new(Map<String, dynamic> raw)
      : super(Snowflake(raw['id'] as String)) {
    this.username = raw['username'] as String;
    this.discriminator = raw['discriminator'] as String;
    this.avatar = raw['avatar'] as String;
    this.bot = raw['bot'] as bool ?? false;
  }

  /// The user's avatar, represented as URL.
  String avatarURL({String format = 'webp', int size = 128}) {
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
      return DMChannel._new(r.body as Map<String, dynamic>);
    }
  }

  @override

  /// Sends a message.
  Future<Message> send(
      {Object content = "",
        List<File> files,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone}) async {
    DMChannel channel = await getDMChannel();
    return await channel.send(
        content: content,
        files: files,
        embed: embed,
        tts: tts,
        disableEveryone: disableEveryone);
  }

  /// Returns a mention of user
  @override
  String toString() => this.mention;
}
