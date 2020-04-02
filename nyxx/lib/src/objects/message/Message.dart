part of nyxx;

/// [Message] class represents single message. It contains it's Event [Stream]s.
/// [Message] among all it is properties has also back-reference to [MessageChannel] from which it was sent, [Guild] and [User] properties which are associated with this message.
class Message extends SnowflakeEntity implements GuildEntity, Disposable {
  /// Reference to bot instance
  Nyxx client;

  /// The message's content.
  late final String content;

  /// The timestamp of when the message was last edited, null if not edited.
  late final DateTime? editedTimestamp;

  /// Channel in which message was sent
  late final MessageChannel channel;

  /// The message's guild.
  @override
  late final Guild? guild;

  /// The message's author. Can be instance of [Member]
  late final IMessageAuthor? author;

  // TODO: Consider how to handle properly webhooks as message authors.
  late final bool isByWebhook;

  /// The mentions in the message. [User] value of this map can be [Member]
  late final Map<Snowflake, User> mentions;

  /// A list of IDs for the role mentions in the message.
  late final Map<Snowflake, Role> roleMentions;

  /// A collection of the embeds in the message.
  late final List<Embed> embeds;

  /// The attachments in the message.
  late final Map<Snowflake, Attachment> attachments;

  /// Whether or not the message is pinned.
  late final bool pinned;

  /// Whether or not the message was sent with TTS enabled.
  late final bool tts;

  /// Whether or @everyone was mentioned in the message.
  late final bool mentionEveryone;

  /// List of message reactions
  late final List<Reaction> reactions;

  late final MessageType type;

  /// Returns clickable url to this message.
  String get url => "https://discordapp.com/channels/${this.guild!.id}"
      "/${this.channel.id}/${this.id}";

  Message._new(Map<String, dynamic> raw, this.client)
      : super(Snowflake(raw['id'] as String)) {
    this.content = raw['content'] as String;

    this.channel = client.channels[Snowflake(raw['channel_id'] as String)]
        as MessageChannel;

    this.pinned = raw['pinned'] as bool;
    this.tts = raw['tts'] as bool;
    this.mentionEveryone = raw['mention_everyone'] as bool;

    if (this.channel is GuildChannel) {
      this.guild = (this.channel as GuildChannel).guild;

      if(raw['webhook_id'] != null) {
        this.isByWebhook = true;
        this.author = Webhook._new(raw['author'] as Map<String, dynamic>, client);

      } else if (raw['author'] != null) {
        this.isByWebhook = false;

        this.author =
            this.guild!.members[Snowflake(raw['author']['id'] as String)];

        if (this.author == null) {
          if (raw['member'] == null) {
            this.author =
                User._new(raw['author'] as Map<String, dynamic>, client);
          } else {
            var r = raw['author'];
            r['member'] = raw['member'];
            // TODO: NNBD - To consider
            var author = _ReverseMember(r as Map<String, dynamic>,
                client.guilds[Snowflake(raw['guild_id'] as String)] as Guild, client);
            client.users[author.id] = author;
            guild!.members[author.id] = author;
            this.author = author;
          }
        }
      }

      this.roleMentions = Map<Snowflake, Role>();
      if (raw['mention_roles'] != null) {
        raw['mention_roles'].forEach((o) {
          var s = Snowflake(o as String);
          this.roleMentions[s] = guild!.roles[s];
        });
      }
    } else {
      if (raw['author'] != null)
        this.author = client.users[Snowflake(raw['author']['id'] as String)];

      if (this.author == null && raw['member'] != null) {
        var r = raw['author'];
        r['member'] = raw['member'];
        // TODO: NNBD - To consider
        var author = _ReverseMember(r as Map<String, dynamic>,
            client.guilds[Snowflake(raw['guild_id'] as String)] as Guild, client);
        this.author = author;
      }
    }

    if (raw['edited_timestamp'] != null) {
      this.editedTimestamp =
          DateTime.parse(raw['edited_timestamp'] as String).toUtc();
    }

    this.mentions = Map<Snowflake, User>();
    if (raw['mentions'] != null && raw['mentions'].isNotEmpty as bool) {
      raw['mentions'].forEach((o) {
        if (o['member'] == null) {
          final user = User._new(o as Map<String, dynamic>, client);
          this.mentions[user.id] = user;
        } else {
          final user =
              _ReverseMember(o as Map<String, dynamic>, this.guild!, client);
          this.mentions[user.id] = user;
        }
      });
    }

    this.embeds = List<Embed>();
    if (raw['embeds'] != null && raw['embeds'].isNotEmpty as bool) {
      raw['embeds'].forEach((o) {
        Embed embed = Embed._new(o as Map<String, dynamic>);
        this.embeds.add(embed);
      });
    }

    this.attachments = Map<Snowflake, Attachment>();
    if (raw['attachments'] != null && raw['attachments'].isNotEmpty as bool) {
      raw['attachments'].forEach((o) {
        final Attachment attachment =
            Attachment._new(o as Map<String, dynamic>);
        this.attachments[attachment.id] = attachment;
      });
    }

    this.reactions = List();
    if (raw['reactions'] != null && raw['reactions'].isNotEmpty as bool) {
      raw['reactions'].forEach((o) {
        this.reactions.add(Reaction._new(o as Map<String, dynamic>));
      });
    }
  }

  /// Returns content of message
  @override
  String toString() => this.content;

  /// Replies to message. By default it mentions user who sends message.
  Future<Message> reply(
          {Object content = "",
          List<AttachmentBuilder>? files,
          EmbedBuilder? embed,
          bool tts = false,
          bool? disableEveryone,
          bool mention = true}) =>
      this.channel.send(
          content: "${mention && !this.isByWebhook ? "${(this.author as User).mention} " : ""}$content",
          files: files,
          embed: embed,
          tts: tts,
          disableEveryone: disableEveryone);

  /// Edits the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.edit("My edited content!");
  Future<Message> edit(
      {String? content,
      EmbedBuilder? embed,
      bool tts = false,
      bool? disableEveryone}) async {
    if (this.author != null && this.author!.id != client.self.id)
      return Future.error("Cannot edit someones message");

    var body = Map<String, dynamic>();
    if (content != null)
      body['content'] = _sanitizeMessage(content, disableEveryone, client);
    if (embed != null) body['embed'] = embed._build();

    final HttpResponse r = await client._http.send(
        'PATCH', '/channels/${this.channel.id}/messages/${this.id}',
        body: body);
    return Message._new(r.body as Map<String, dynamic>, client);
  }

  /// Add reaction to message.
  Future<void> createReaction(Emoji emoji) {
    return client._http.send('PUT',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/@me");
  }

  /// Deletes reaction of bot. Emoji as ':emoji_name:'
  Future<void> deleteReaction(Emoji emoji) {
    return client._http.send('DELETE',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/@me");
  }

  /// Deletes reaction of given user.
  Future<void> deleteUserReaction(Emoji emoji, String userId) {
    return client._http.send('DELETE',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/$userId");
  }

  /// Deletes all reactions
  Future<void> deleteAllReactions() {
    return client._http.send(
        'DELETE', "/channels/${this.channel.id}/messages/${this.id}/reactions");
  }

  /// Deletes the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  Future<void> delete({String auditReason = ""}) {
    return client._http.send(
        'DELETE', '/channels/${this.channel.id}/messages/${this.id}',
        reason: auditReason);
  }

  /// Pins [Message] in current [Channel]
  Future<void> pinMessage() {
    return client._http.send('PUT', "/channels/${channel.id}/pins/$id");
  }

  /// Unpins [Message] in current [Channel]
  Future<void> unpinMessage() {
    return client._http.send('DELETE', "/channels/${channel.id}/pins/$id");
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
    roleMentions.clear();
    attachments.clear();
  }
}

class MessageType {}
