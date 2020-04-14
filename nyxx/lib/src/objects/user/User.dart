part of nyxx;

/// Represents a single user of Discord, either a human or a bot, outside of any specific guild's context.
class User extends SnowflakeEntity with ISend, Mentionable, IMessageAuthor {
  Nyxx client;

  /// The user's username.
  @override
  late final String username;

  /// The user's discriminator.
  @override
  late final int discriminator;

  /// The user's avatar hash.
  late final String? avatar;

  /// The string to mention the user.
  @override
  String get mention => "<@!${this.id}>";

  /// Returns String with username#discriminator
  @override
  String get tag => "${this.username}#${this.discriminator}";

  /// Whether the user belongs to an OAuth2 application
  @override
  late final bool bot;

  /// Whether the user is an Official Discord System user (part of the urgent message system)
  late final bool system;

  /// The member's status. `offline`, `online`, `idle`, or `dnd`.
  ClientStatus? status;

  /// The member's presence.
  Presence? presence;

  /// Additional flags associated with user account. Describes if user has certain
  /// features like joined into one of houses or is discord employee.
  UserFlags? userFlags;

  /// Premium types denote the level of premium a user has.
  NitroType? nitroType;

  User._new(Map<String, dynamic> raw, this.client)
      : super(Snowflake(raw['id'] as String)) {
    this.username = raw['username'] as String;
    this.discriminator = int.parse(raw['discriminator'] as String);
    this.avatar = raw['avatar'] as String?;
    this.bot = raw['bot'] as bool? ?? false;
    this.system = raw['system'] as bool? ?? false;

    if(raw['public_flags'] != null) {
      this.userFlags = UserFlags._new(raw['public_flags'] as int);
    }

    if(raw['premium_type'] != null) {
      this.nitroType = NitroType.from(raw['premium_type'] as int);
    }
  }

  /// The user's avatar, represented as URL.
  /// In case if user does not have avatar, default discord avatar will be returned with specified size and png format.
  @override
  String? avatarURL({String format = 'webp', int size = 128}) {
    if (this.avatar != null) {
      return 'https://cdn.${_Constants.host}/avatars/${this.id}/${this.avatar}.$format?size=$size';
    }

    return "https://cdn.${_Constants.host}/embed/avatars/${discriminator % 5}.png?size=$size";
  }

  /// Gets the [DMChannel] for the user.
  Future<DMChannel> get dmChannel async {
    Future<DMChannel> downloadChannel() async {
      HttpResponse r = await client._http.send('POST', "/users/@me/channels",
          body: {"recipient_id": this.id.toString()});
      var chan = DMChannel._new(r.body as Map<String, dynamic>, client);
      this.client.channels.add(chan.id, chan);
      return chan;
    }

    return (client.channels.findOne(
                (Channel c) => c is DMChannel && c.recipient.id == this.id)
            as DMChannel?) ??
        await downloadChannel();
  }

  @override

  /// Sends a message to user.
  Future<Message> send(
      {dynamic content,
        List<AttachmentBuilder>? files,
        EmbedBuilder? embed,
        bool? tts,
        AllowedMentions? allowedMentions,
        MessageBuilder? builder}) async {
    DMChannel channel = await this.dmChannel;
    return channel.send(
        content: content,
        files: files,
        embed: embed,
        tts: tts,
        allowedMentions: allowedMentions,
        builder: builder);
  }

  /// Returns a mention of user
  @override
  String toString() => this.mention;
}
