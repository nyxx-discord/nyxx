part of nyxx;

abstract class Message extends SnowflakeEntity implements Disposable {
  /// Reference to bot instance
  final INyxx client;

  /// The message's content.
  late String content;

  /// Channel in which message was sent
  late final Cacheable<Snowflake, TextChannel> channel;

  /// The timestamp of when the message was last edited, null if not edited.
  late final DateTime? editedTimestamp;

  /// The message's author.
  IMessageAuthor get author;

  /// The mentions in the message.
  List<Cacheable<Snowflake, User>> mentions = [];

  /// A collection of the embeds in the message.
  late List<Embed> embeds;

  /// The attachments in the message.
  late final List<Attachment> attachments;

  /// Whether or not the message is pinned.
  late final bool pinned;

  /// Whether or not the message was sent with TTS enabled.
  late final bool tts;

  /// Whether or @everyone was mentioned in the message.
  late final bool mentionEveryone;

  /// List of message reactions
  late final List<Reaction> reactions;

  /// Type of message
  late final MessageType type;

  /// Extra features of the message
  late final MessageFlags? flags;

  /// Returns clickable url to this message.
  String get url;

  /// The stickers sent with the message
  late final Iterable<Sticker> stickers;

  /// Message reply
  late final ReferencedMessage? referencedMessage;

  factory Message._deserialize(INyxx client, Map<String, dynamic> raw) {
    if (raw["guild_id"] != null) {
      return GuildMessage._new(client, raw);
    }

    return DMMessage._new(client, raw);
  }

  Message._new(this.client, Map<String, dynamic> raw) : super(Snowflake(raw["id"])) {
    this.content = raw["content"] as String;
    this.channel = _ChannelCacheable(client, Snowflake(raw["channel_id"]));

    this.pinned = raw["pinned"] as bool;
    this.tts = raw["tts"] as bool;
    this.mentionEveryone = raw["mention_everyone"] as bool;
    this.type = MessageType.from(raw["type"] as int);

    this.stickers = [
      if (raw["stickers"] != null)
        for (final rawSticker in raw["stickers"])
          Sticker._new(rawSticker as Map<String, dynamic>)
    ];

    if (raw["flags"] != null) {
      this.flags = MessageFlags._new(raw["flags"] as int);
    }

    if (raw["edited_timestamp"] != null) {
      this.editedTimestamp = DateTime.parse(raw["edited_timestamp"] as String).toUtc();
    }

    this.embeds = [
      if (raw["embeds"] != null && raw["embeds"].isNotEmpty as bool)
        for (var r in raw["embeds"]) Embed._new(r as Map<String, dynamic>)
    ];

    this.attachments = [
      if (raw["attachments"] != null && raw["attachments"].isNotEmpty as bool)
        for (var r in raw["attachments"]) Attachment._new(r as Map<String, dynamic>)
    ];

    this.reactions = [
      if (raw["reactions"] != null && raw["reactions"].isNotEmpty as bool)
        for (var r in raw["reactions"]) Reaction._new(r as Map<String, dynamic>)
    ];

    if (raw["mentions"] != null && raw["mentions"].isNotEmpty as bool) {
      for (final rawUser in raw["mentions"]) {
        final user = User._new(client, rawUser as Map<String, dynamic>);
        this.client.users[user.id] = user;

        this.mentions.add(_UserCacheable(client, user.id));
      }
    }

    if (raw["type"] == 19) {
      this.referencedMessage = ReferencedMessage._new(client, raw);
    } else {
      this.referencedMessage = null;
    }
  }

  /// Suppresses embeds in message. Can be executed in other users messages.
  Future<Message> suppressEmbeds() =>
      client._httpEndpoints.suppressMessageEmbeds(this.channel.id, this.id);

  /// Edits the message.
  Future<Message> edit({dynamic content, EmbedBuilder? embed, AllowedMentions? allowedMentions, MessageEditBuilder? builder}) =>
      client._httpEndpoints.editMessage(this.channel.id, this.id, content: content, embed: embed, allowedMentions: allowedMentions, builder: builder);

  /// Add reaction to message.
  Future<void> createReaction(IEmoji emoji) =>
      client._httpEndpoints.createMessageReaction(this.channel.id, this.id, emoji);

  /// Deletes reaction of bot.
  Future<void> deleteSelfReaction(IEmoji emoji) =>
      client._httpEndpoints.deleteMessageReaction(this.channel.id, this.id, emoji);

  /// Deletes reaction of given user.
  Future<void> deleteUserReaction(IEmoji emoji, SnowflakeEntity entity) =>
      client._httpEndpoints.deleteMessageUserReaction(this.channel.id, this.id, emoji, entity.id);

  /// Deletes all reactions
  Future<void> deleteAllReactions() =>
      client._httpEndpoints.deleteMessageAllReactions(this.channel.id, this.id);

  /// Deletes the message.
  Future<void> delete({String? auditReason}) =>
      client._httpEndpoints.deleteMessage(this.channel.id, this.id);

  /// Pins [Message] in message's channel
  Future<void> pinMessage() =>
      client._httpEndpoints.pinMessage(this.channel.id, this.id);

  /// Unpins [Message] in message's channel
  Future<void> unpinMessage() =>
      client._httpEndpoints.unpinMessage(this.channel.id, this.id);

  @override
  Future<void> dispose() => Future.value(null);

  @override
  bool operator ==(other) {
    if (other is Message) {
      return this.id == other.id;
    }

    if(other is Snowflake) {
      return this.id == other;
    }

    if(other is int) {
      return this.id == other;
    }

    if(other is String) {
      return this.id == other;
    }

    return false;
  }
}

/// Message that is sent in dm channel or group dm channel
class DMMessage extends Message {
  @override
  late final User author;

  /// Returns clickable url to this message.
  @override
  String get url => "https://discordapp.com/channels/@me"
      "/${this.channel.id}/${this.id}";

  DMMessage._new(INyxx client, Map<String, dynamic> raw) : super._new(client, raw) {
    final user = client.users[Snowflake(raw["author"]["id"])];

    if (user == null) {
      final authorData = raw["author"] as Map<String, dynamic>;
      this.author = User._new(client, authorData);
      this.client.users.add(this.author.id, this.author);
    } else {
      this.author = user;
    }
  }
}

/// Message that is sent in guild channel
class GuildMessage extends Message {
  /// The message's guild.
  late final Cacheable<Snowflake, Guild> guild;

  /// Reference to original message if this message cross posts other message
  late final MessageReference? crossPostReference;

  /// True if this message is cross posts other message
  bool get isCrossPosting => this.crossPostReference != null;

  /// Returns clickable url to this message.
  @override
  String get url => "https://discordapp.com/channels/${this.guild.id}"
      "/${this.channel.id}/${this.id}";

  /// The message's author. Can be instance of [User] or [Webhook]
  @override
  late final IMessageAuthor author;

  /// Member data of message author
  late final Member member;

  // TODO: Consider how to handle properly webhooks as message authors.
  /// True if message is sent by a webhook
  bool get isByWebhook => author is Webhook;

  /// Role mentions in this message
  late final List<Cacheable<Snowflake, Role>> roleMentions;

  GuildMessage._new(INyxx client, Map<String, dynamic> raw) : super._new(client, raw) {
    if (raw["message_reference"] != null) {
      this.crossPostReference = MessageReference._new(
          raw["message_reference"] as Map<String, dynamic>, client);
    }

    this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"]));

    if (raw["webhook_id"] != null) {
      this.author = Webhook._new(raw["author"] as Map<String, dynamic>, client);
    } else {
      this.author = User._new(client, raw["author"] as Map<String, dynamic>);
    }

    if (raw["member"] != null) {
      // In case member object doesnt have id property and we need it for member object
      raw["member"]["user"] = <String, dynamic>{
        "id": raw["author"]["id"]
      };
      this.member = Member._new(client, raw["member"] as Map<String, dynamic>, this.guild.id);

      if (client._cacheOptions.memberCachePolicyLocation.objectConstructor && client._cacheOptions.memberCachePolicy.canCache(member)) {
        this.guild.getFromCache()?.members[member.id] = member;
      }
    }

    this.roleMentions = [
      if (raw["mention_roles"] != null)
        for (var roleId in raw["mention_roles"])
          _RoleCacheable(client, Snowflake(roleId), this.guild)
    ];
  }

  /// Crosspost a Message into all guilds what follow the news channel indicated.
  /// This endpoint requires the "DISCOVERY" feature to be present for the guild.
  Future<void> crossPost() async =>
      client._httpEndpoints.crossPostGuildMessage(this.channel.id, this.id);
}
