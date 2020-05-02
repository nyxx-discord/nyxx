part of nyxx;

class DMMessage extends Message {
  late final User author;

  /// Returns clickable url to this message.
  String get url => "https://discordapp.com/channels/@me"
      "/${this.channel.id}/${this.id}";

  DMMessage._new(Map<String, dynamic> raw, Nyxx client) :
      super._new(raw, client) {
    var user = client.users[Snowflake(raw['author']['id'] as String)];

    if (user == null) {
      var authorData = raw['author'] as Map<String, dynamic>;
      this.author = User._new(authorData, client);
    } else {
      this.author = user;
    }
  }
}

class GuildMessage extends Message implements GuildEntity {
  /// The message's guild.
  @override
  late final Guild guild;

  /// Reference to original message if this message cross posts other message
  late final MessageReference? crosspostReference;

  /// True if this message is cross posts other message
  bool get isCrossposting => this.crosspostReference != null;

  /// Returns clickable url to this message.
  String get url => "https://discordapp.com/channels/${this.guild.id}"
      "/${this.channel.id}/${this.id}";

  /// The message's author. Can be instance of [Member] or [Webhook]
  late final IMessageAuthor author;

  // TODO: Consider how to handle properly webhooks as message authors.
  bool get isByWebhook => author is Webhook;

  /// A list of IDs for the role mentions in the message.
  late List<Role> roleMentions;

  GuildMessage._new(Map<String, dynamic> raw, Nyxx client) :
        super._new(raw, client) {
    if(raw['message_reference'] != null) {
      this.crosspostReference = MessageReference._new(raw['message_reference']
      as Map<String, dynamic>, client);
    }

    this.guild = client.guilds[Snowflake(raw['guild_id'])]!;

    if(raw['webhook_id'] != null) {
      this.author = Webhook._new(raw['author'] as Map<String, dynamic>, client);
    } else if (raw['author'] != null) {
      var member = this.guild.members[Snowflake(raw['author']['id'] as String)];

      if (member == null) {
        if (raw['member'] == null) {
          this.author = User._new(raw['author'] as Map<String, dynamic>, client);
        } else {
          var authorData = raw['author'] as Map<String, dynamic>;
          var memberData = raw['member'] as Map<String, dynamic>;

          var author = Member._fromUser(authorData, memberData,
              client.guilds[Snowflake(raw['guild_id'])] as Guild, client);

          client.users[author.id] = author;
          guild.members[author.id] = author;
          this.author = author;
        }
      } else {
        this.author = member;
      }
    }

    this.roleMentions = [
      if (raw['mention_roles'] != null)
        for(var r in raw['mention_roles'])
          this.guild.roles[Snowflake(r)] as Role
    ];
  }
}

/// [Message] class represents single message. It contains it's Event [Stream]s.
/// [Message] among all it is properties has also back-reference to [MessageChannel] from which it was sent, [Guild] and [User] properties which are associated with this message.
abstract class Message extends SnowflakeEntity implements Disposable {
  /// Reference to bot instance
  Nyxx client;

  /// The message's content.
  late String content;

  /// Channel in which message was sent
  late final MessageChannel channel;

  /// The timestamp of when the message was last edited, null if not edited.
  late final DateTime? editedTimestamp;

  /// The message's author. Can be instance of [Member]
  IMessageAuthor get author;

  /// The mentions in the message. [User] value of this map can be [Member]
  late List<User> mentions;

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
  MessageFlags? flags;

  /// Returns clickable url to this message.
  String get url;

  factory Message._deserialize(Map<String, dynamic> raw, Nyxx client) {
    if(raw['guild_id'] != null) {
      return GuildMessage._new(raw, client);
    }

    return DMMessage._new(raw, client);
  }

  Message._new(Map<String, dynamic> raw, this.client)
      : super(Snowflake(raw['id'] as String)) {
    this.content = raw['content'] as String;

    this.channel = client.channels[Snowflake(raw['channel_id'] as String)] as MessageChannel;

    this.pinned = raw['pinned'] as bool;
    this.tts = raw['tts'] as bool;
    this.mentionEveryone = raw['mention_everyone'] as bool;
    this.type = MessageType.from(raw['type'] as int);

    if(raw['flags'] != null) {
      this.flags = MessageFlags._new(raw['flags'] as int);
    }

    if (raw['edited_timestamp'] != null) {
      this.editedTimestamp =
          DateTime.parse(raw['edited_timestamp'] as String).toUtc();
    }

    this.embeds = [
      if (raw['embeds'] != null && raw['embeds'].isNotEmpty as bool)
        for(var r in raw['embeds'])
          Embed._new(r as Map<String, dynamic>)
    ];

    this.attachments = [
      if (raw['attachments'] != null && raw['attachments'].isNotEmpty as bool)
        for(var r in raw['attachments'])
          Attachment._new(r as Map<String, dynamic>)
    ];

    this.reactions = [
      if (raw['reactions'] != null && raw['reactions'].isNotEmpty as bool)
        for(var r in raw['reactions'])
          Reaction._new(r as Map<String, dynamic>)
    ];

    this.mentions = [
      if (raw['mentions'] != null && raw['mentions'].isNotEmpty as bool)
        for (var r in raw['mentions'])
          User._new(r as Map<String, dynamic>, client)
    ];
  }

  /// Returns content of message
  @override
  String toString() => this.content;

  /// Edits the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.edit("My edited content!");
  Future<Message> edit(
      {dynamic content,
      EmbedBuilder? embed,
      AllowedMentions? allowedMentions}) async {
    if (this.author.id != client.self.id) {
      return Future.error("Cannot edit someones message");
    }

    var body = <String, dynamic>{
      if(content != null) "content" : content.toString(),
      if(embed != null) "embed" : embed._build(),
      if(allowedMentions != null) "allowed_mentions" : allowedMentions._build()
    };

    var response = await client._http._execute(
        BasicRequest._new('/channels/${this.channel.id}/messages/${this.id}',
            method: "PATCH", body: body));

    if(response is HttpResponseSuccess) {
      return Message._deserialize(response.jsonBody as Map<String, dynamic>, client);
    }

    return Future.error(response);
  }

  /// Add reaction to message.
  Future<void> createReaction(Emoji emoji) {
    return client._http._execute(
        BasicRequest._new("/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/@me",
            method: "PUT"));
  }

  /// Deletes reaction of bot. Emoji as ':emoji_name:'
  Future<void> deleteReaction(Emoji emoji) {
    return client._http._execute(
        BasicRequest._new("/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/@me",
            method: "DELETE"));
  }

  /// Deletes reaction of given user.
  Future<void> deleteUserReaction(Emoji emoji, String userId) {
    return client._http._execute(
        BasicRequest._new("/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/$userId",
            method: "DELETE"));
  }

  /// Deletes all reactions
  Future<void> deleteAllReactions() {
    return client._http._execute(
        BasicRequest._new("/channels/${this.channel.id}/messages/${this.id}/reactions",
            method: "DELETE"));
  }

  /// Deletes the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  Future<void> delete({String? auditReason}) {
    return client._http._execute(
        BasicRequest._new('/channels/${this.channel.id}/messages/${this.id}',
            method: "DELETE", auditLog: auditReason));
  }

  /// Pins [Message] in current [Channel]
  Future<void> pinMessage() {
    return client._http._execute(
        BasicRequest._new("/channels/${channel.id}/pins/$id", method: "PUT"));
  }

  /// Unpins [Message] in current [Channel]
  Future<void> unpinMessage() {
    return client._http._execute(
        BasicRequest._new("/channels/${channel.id}/pins/$id", method: "DELETE"));
  }

  @override
  bool operator ==(other) {
    if (other is Message) {
      return other.content == this.content ||
          other.embeds.any((e) => this.embeds.any((f) => e == f));
    }

    return false;
  }

  @override
  Future<void> dispose() async {
    embeds.clear();
    mentions.clear();
    attachments.clear();
  }
}
