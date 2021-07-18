part of nyxx;

abstract class Message extends SnowflakeEntity implements Disposable, Convertable<MessageBuilder> {
  /// Reference to bot instance
  final INyxx client;

  /// The message's content.
  late String content;

  /// Channel in which message was sent
  late final CacheableTextChannel<TextChannel> channel;

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
  late final Iterable<Snowflake> stickersIds;

  /// Message reply
  late final ReferencedMessage? referencedMessage;

  /// List of components attached to message.
  late final List<List<IMessageComponent>> components;

  /// A nonce that can be used for optimistic message sending (up to 25 characters)
  /// You will be able to identify that message when receiving it through gateway
  late final String? nonce;

  /// If the message is a response to an Interaction, this is the id of the interaction's application
  late final Snowflake? applicationId;

  /// Inline timestamps of current message
  Iterable<MessageTimeStamp> get timestamps sync* {
    for (final match in MessageTimeStamp.regex.allMatches(this.content)) {
      yield MessageTimeStamp._new(match);
    }
  }

  factory Message._deserialize(INyxx client, RawApiMap raw) {
    if (raw["member"] != null) {
      return GuildMessage._new(client, raw);
    }

    return DMMessage._new(client, raw);
  }

  Message._new(this.client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    this.content = raw["content"] as String;
    this.channel = CacheableTextChannel<TextChannel>._new(client, Snowflake(raw["channel_id"]));

    this.pinned = raw["pinned"] as bool;
    this.tts = raw["tts"] as bool;
    this.mentionEveryone = raw["mention_everyone"] as bool;
    this.type = MessageType.from(raw["type"] as int);

    this.stickersIds = [
      if (raw["sticker_items"] != null)
        for (final rawSticker in raw["sticker_items"])
          Snowflake(rawSticker)
    ];

    if (raw["flags"] != null) {
      this.flags = MessageFlags._new(raw["flags"] as int);
    }

    if (raw["edited_timestamp"] != null) {
      this.editedTimestamp = DateTime.parse(raw["edited_timestamp"] as String).toUtc();
    }

    this.embeds = [
      if (raw["embeds"] != null && raw["embeds"].isNotEmpty as bool)
        for (var r in raw["embeds"]) Embed._new(r as RawApiMap)
    ];

    this.attachments = [
      if (raw["attachments"] != null && raw["attachments"].isNotEmpty as bool)
        for (var r in raw["attachments"]) Attachment._new(r as RawApiMap)
    ];

    this.reactions = [
      if (raw["reactions"] != null && raw["reactions"].isNotEmpty as bool)
        for (var r in raw["reactions"]) Reaction._new(r as RawApiMap)
    ];

    if (raw["mentions"] != null && raw["mentions"].isNotEmpty as bool) {
      for (final rawUser in raw["mentions"]) {
        final user = User._new(client, rawUser as RawApiMap);
        this.client.users[user.id] = user;

        this.mentions.add(_UserCacheable(client, user.id));
      }
    }

    if (raw["type"] == 19) {
      this.referencedMessage = ReferencedMessage._new(client, raw);
    } else {
      this.referencedMessage = null;
    }

    if (raw["nonce"] != null) {
      this.nonce = raw["nonce"].toString();
    } else {
      this.nonce = null;
    }

    this.applicationId = raw["application_id"] != null
        ? Snowflake(raw["application_id"])
        : null;

    if (raw["components"] != null) {
      this.components = [
        for (final rawRow in raw["components"]) [
          for (final componentRaw in rawRow["components"])
            IMessageComponent._deserialize(componentRaw as RawApiMap)
        ]
      ];
    } else {
      this.components = [];
    }
  }

  /// Suppresses embeds in message. Can be executed in other users messages.
  Future<Message> suppressEmbeds() =>
      client.httpEndpoints.suppressMessageEmbeds(this.channel.id, this.id);

  /// Edits the message.
  Future<Message> edit(MessageBuilder builder) =>
      client.httpEndpoints.editMessage(this.channel.id, this.id, builder);

  /// Add reaction to message.
  Future<void> createReaction(IEmoji emoji) =>
      client.httpEndpoints.createMessageReaction(this.channel.id, this.id, emoji);

  /// Deletes reaction of bot.
  Future<void> deleteSelfReaction(IEmoji emoji) =>
      client.httpEndpoints.deleteMessageReaction(this.channel.id, this.id, emoji);

  /// Deletes reaction of given user.
  Future<void> deleteUserReaction(IEmoji emoji, SnowflakeEntity entity) =>
      client.httpEndpoints.deleteMessageUserReaction(this.channel.id, this.id, emoji, entity.id);

  /// Deletes all reactions
  Future<void> deleteAllReactions() =>
      client.httpEndpoints.deleteMessageAllReactions(this.channel.id, this.id);

  /// Deletes the message.
  Future<void> delete({String? auditReason}) =>
      client.httpEndpoints.deleteMessage(this.channel.id, this.id);

  /// Pins [Message] in message's channel
  Future<void> pinMessage() =>
      client.httpEndpoints.pinMessage(this.channel.id, this.id);

  /// Unpins [Message] in message's channel
  Future<void> unpinMessage() =>
      client.httpEndpoints.unpinMessage(this.channel.id, this.id);

  /// Creates a thread based on this message, that only retrieves a [ThreadPreviewChannel]
  Future<ThreadPreviewChannel> createThread(ThreadBuilder builder) async =>
      client.httpEndpoints.createThreadWithMessage(this.channel.id, this.id, builder);

  /// Creates a thread in a message
  Future<ThreadChannel> createAndGetThread(ThreadBuilder builder) async {
    final preview = await client.httpEndpoints.createThreadWithMessage(this.channel.id, this.id, builder);
    return preview.getThreadChannel().getOrDownload();
  }

  @override
  Future<void> dispose() => Future.value(null);

  @override
  MessageBuilder toBuilder() => MessageBuilder.fromMessage(this);

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

  @override
  int get hashCode => this.id.hashCode;
}

/// Message that is sent in dm channel or group dm channel
class DMMessage extends Message {
  @override
  late final User author;

  /// Returns clickable url to this message.
  @override
  String get url => "https://discordapp.com/channels/@me"
      "/${this.channel.id}/${this.id}";

  DMMessage._new(INyxx client, RawApiMap raw) : super._new(client, raw) {
    final user = client.users[Snowflake(raw["author"]["id"])];

    if (user == null) {
      final authorData = raw["author"] as RawApiMap;
      this.author = User._new(client, authorData);

      if (client._cacheOptions.userCachePolicyLocation.objectConstructor) {
        this.client.users[this.author.id] = this.author;
      }
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

  GuildMessage._new(INyxx client, RawApiMap raw) : super._new(client, raw) {
    if (raw["message_reference"] != null) {
      this.crossPostReference = MessageReference._new(
          raw["message_reference"] as RawApiMap, client);
    }

    this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"]));

    if (raw["webhook_id"] != null) {
      this.author = Webhook._new(raw["author"] as RawApiMap, client);
    } else {
      this.author = User._new(client, raw["author"] as RawApiMap);

      if (client._cacheOptions.userCachePolicyLocation.objectConstructor) {
        this.client.users[this.author.id] = this.author as User;
      }
    }

    if (raw["member"] != null) {
      // In case member object doesnt have id property and we need it for member object
      raw["member"]["user"] = <String, dynamic>{
        "id": raw["author"]["id"]
      };
      this.member = Member._new(client, raw["member"] as RawApiMap, this.guild.id);

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

  /// Cross post a Message into all guilds what follow the news channel indicated.
  /// This endpoint requires the "DISCOVERY" feature to be present for the guild.
  Future<void> crossPost() async =>
      client.httpEndpoints.crossPostGuildMessage(this.channel.id, this.id);
}
