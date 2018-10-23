part of nyxx;

/// [Message] class represents single message. It contains it's Event [Stream]s.
/// [Message] among all it's properties has also back-reference to [MessageChannel] from which it was sent, [Guild] and [User] properties which are associated with this message.
class Message extends SnowflakeEntity implements GuildEntity, Disposable {
  StreamController<MessageReactionEvent> _onReactionAdded;
  StreamController<MessageReactionEvent> _onReactionRemove;
  StreamController<MessageReactionsRemovedEvent> _onReactionsRemoved;

  /// The message's content.
  String content;

  /// The timestamp of when the message was last edited, null if not edited.
  DateTime editedTimestamp;

  /// Channel in which message was sent
  MessageChannel channel;

  @override
  /// The message's guild.
  Guild guild;

  /// The message's author. Can be instance of member
  User author;

  /// The mentions in the message. [User] value of this map can be [Member]
  Map<Snowflake, User> mentions;

  /// A list of IDs for the role mentions in the message.
  Map<Snowflake, Role> roleMentions;

  /// A collection of the embeds in the message.
  List<Embed> embeds;

  /// The attachments in the message.
  Map<Snowflake, Attachment> attachments;

  /// Whether or not the message is pinned.
  bool pinned;

  /// Whether or not the message was sent with TTS enabled.
  bool tts;

  /// Whether or @everyone was mentioned in the message.
  bool mentionEveryone;

  /// List of message reactions
  List<Reaction> reactions;

  /// Emitted when a user adds a reaction to a message.
  Stream<MessageReactionEvent> onReactionAdded;

  /// Emitted when a user adds a reaction to a message.
  Stream<MessageReactionEvent> onReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  Stream<MessageReactionsRemovedEvent> onReactionsRemoved;

  /// Returns clickable url to this message.
  String get url =>
      "https://discordapp.com/channels/${this.guild.id.toString()}"
      "/${this.channel.id.toString()}/${this.id.toString()}";

  Message._combine(Message old, Map<String, dynamic> raw) : super(old.id) {
    this.content = raw['content'] == null ? old.content : raw['content'] as String;
    this.editedTimestamp = raw['edited_timestamp'] == null ? DateTime.now() : DateTime.parse(raw['edited_timestamp'] as String);
    this.channel = old.channel;
    this.guild = old.guild;
    this.author = old.author;

    if(raw['mentions'] != null) {
      this.mentions = Map<Snowflake, User>();
      raw['mentions'].forEach((o) {
        if (o['member'] == null) {
          final user = User._new(o as Map<String, dynamic>);
          this.mentions[user.id] = user;
        } else {
          final user = Member._reverse(o as Map<String, dynamic>, this.guild);
          this.mentions[user.id] = user;
        }
      });
    } else {
      this.mentions = old.mentions;
    }

    if(raw['mention_roles'] != null) {
      this.roleMentions = Map<Snowflake, Role>();
      raw['mention_roles'].forEach((o) {
        var s = Snowflake(o as String);
        this.roleMentions[s] = guild.roles[s];
      });
    } else
      this.roleMentions = old.roleMentions;

    if (raw['embeds'] != null && raw['embeds'].isNotEmpty as bool) {
      this.embeds = List<Embed>();
      raw['embeds'].forEach((o) {
        Embed embed = Embed._new(o as Map<String, dynamic>);
        this.embeds.add(embed);
      });
    } else {
      this.embeds = old.embeds;
    }

    if (raw['attachments'] != null && raw['attachments'].isNotEmpty as bool) {
      this.attachments = Map<Snowflake, Attachment>();
      raw['attachments'].forEach((o) {
        final Attachment attachment = Attachment._new(o as Map<String, dynamic>);
        this.attachments[attachment.id] = attachment;
      });
    } else
      this.attachments = old.attachments;

    if (raw['reactions'] != null && raw['reactions'].isNotEmpty as bool) {
      this.reactions = List();
      raw['reactions'].forEach((o) {
        this.reactions.add(Reaction._new(o as Map<String, dynamic>));
      });
    } else
      this.reactions = old.reactions;

    this._onReactionRemove = StreamController.broadcast();
    this.onReactionRemove = this._onReactionRemove.stream;

    this._onReactionAdded = StreamController.broadcast();
    this.onReactionAdded = this._onReactionAdded.stream;

    this._onReactionsRemoved = StreamController.broadcast();
    this.onReactionsRemoved = this._onReactionsRemoved.stream;

    this.channel.messages._cacheMessage(this);
  }

  Message._new(Map<String, dynamic> raw)
      : super(Snowflake(raw['id'] as String)) {
    this._onReactionRemove = StreamController.broadcast();
    this.onReactionRemove = this._onReactionRemove.stream;

    this._onReactionAdded = StreamController.broadcast();
    this.onReactionAdded = this._onReactionAdded.stream;

    this._onReactionsRemoved = StreamController.broadcast();
    this.onReactionsRemoved = this._onReactionsRemoved.stream;

    this.content = raw['content'] as String;

    this.channel = _client.channels[Snowflake(raw['channel_id'] as String)]
        as MessageChannel;

    this.pinned = raw['pinned'] as bool;
    this.tts = raw['tts'] as bool;
    this.mentionEveryone = raw['mention_everyone'] as bool;

    if (this.channel is GuildChannel)
      this.guild = (this.channel as GuildChannel).guild;

    if (this.guild != null) {
      if (raw['author'] != null) {
        this.author =
            this.guild.members[Snowflake(raw['author']['id'] as String)];

        if (this.author == null) {
          if (raw['member'] == null) {
            this.author = User._new(raw['author'] as Map<String, dynamic>);
          } else {
            var r = raw['author'];
            r['member'] = raw['member'];
            var author = Member._reverse(r as Map<String, dynamic>,
                client.guilds[Snowflake(raw['guild_id'] as String)]);
            _client.users[author.id] = author;
            guild.members[author.id] = author;
            this.author = author;
          }
        }
      }

      if (raw['mention_roles'] != null) {
        this.roleMentions = Map<Snowflake, Role>();
        raw['mention_roles'].forEach((o) {
          var s = Snowflake(o as String);
          this.roleMentions[s] = guild.roles[s];
        });
      }
    } else {
      this.author = client.users[Snowflake(raw['author']['id'] as String)];

      if (this.author == null) {
        var r = raw['author'];
        r['member'] = raw['member'];
        var author = Member._reverse(r as Map<String, dynamic>,
            client.guilds[Snowflake(raw['guild_id'] as String)]);
        _client.users[author.id] = author;
        this.author = author;
      }
    }

    if (raw['edited_timestamp'] != null)
      this.editedTimestamp =
          DateTime.parse(raw['edited_timestamp'] as String).toUtc();

    if (raw['mentions'] != null && raw['mentions'].isNotEmpty as bool) {
      this.mentions = Map<Snowflake, User>();
      raw['mentions'].forEach((o) {
        if (o['member'] == null) {
          final user = User._new(o as Map<String, dynamic>);
          this.mentions[user.id] = user;
        } else {
          final user = Member._reverse(o as Map<String, dynamic>, this.guild);
          this.mentions[user.id] = user;
        }
      });
    }

    if (raw['embeds'] != null && raw['embeds'].isNotEmpty as bool) {
      this.embeds = List<Embed>();
      raw['embeds'].forEach((o) {
        Embed embed = Embed._new(o as Map<String, dynamic>);
        this.embeds.add(embed);
      });
    }

    if (raw['attachments'] != null && raw['attachments'].isNotEmpty as bool) {
      this.attachments = Map<Snowflake, Attachment>();
      raw['attachments'].forEach((o) {
        final Attachment attachment =
            Attachment._new(o as Map<String, dynamic>);
        this.attachments[attachment.id] = attachment;
      });
    }

    if (raw['reactions'] != null && raw['reactions'].isNotEmpty as bool) {
      this.reactions = List();
      raw['reactions'].forEach((o) {
        this.reactions.add(Reaction._new(o as Map<String, dynamic>));
      });
    }

    this.channel.messages._cacheMessage(this);
    this.channel.lastMessageID = this.id;
  }

  /// Returns mention of message
  @override
  String toString() => this.content;

  /// Replies to message. By default it mentions user who sends message.
  Future<Message> reply({Object content = "",
      List<File> files,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone,
      bool mention = true}) async => this.channel.send(
      content: "${mention ? this.author.mention : ""} $content", files: files,
  embed: embed, tts: tts, disableEveryone: disableEveryone);

  /// Edits the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.edit("My edited content!");
  Future<Message> edit(
      {String content,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone}) async {
    if (this.author.id != _client.self.id) return null;
    String newContent = _sanitizeMessage(content, disableEveryone);

    final HttpResponse r = await _client.http.send(
        'PATCH', '/channels/${this.channel.id}/messages/${this.id}',
        body: <String, dynamic>{
          "content": newContent,
          "embed": (embed != null ? embed._build() : "")
        });
    return Message._new(r.body as Map<String, dynamic>);
  }

  /// Add reaction to message.
  Future<void> createReaction(Emoji emoji) async {
    await _client.http.send('PUT',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/@me");
  }

  /// Deletes reaction of bot. Emoji as ':emoji_name:'
  Future<void> deleteReaction(Emoji emoji) async {
    await _client.http.send('DELETE',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/@me");
  }

  /// Deletes reaction of given user.
  Future<void> deleteUserReaction(Emoji emoji, String userId) async {
    await _client.http.send('DELETE',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/$userId");
  }

  /// Deletes all reactions
  Future<void> deleteAllReactions() async {
    await _client.http.send(
        'DELETE', "/channels/${this.channel.id}/messages/${this.id}/reactions");
  }

  /// Deletes the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  Future<void> delete({String auditReason = ""}) async {
    await _client.http.send(
        'DELETE', '/channels/${this.channel.id}/messages/${this.id}',
        reason: auditReason);
  }

  /// Pins [Message] in current [Channel]
  Future<void> pinMessage() async {
    await _client.http.send('PUT', "/channels/${channel.id}/pins/$id");
  }

  /// Unpins [Message] in current [Channel]
  Future<void> unpinMessage() async {
    await _client.http.send('DELETE', "/channels/${channel.id}/pins/$id");
  }

  @override
  Future<void> dispose() {
    _onReactionAdded.close();
    _onReactionRemove.close();
    _onReactionsRemoved.close();

    if(embeds != null) {
      embeds.clear();
      embeds = null;
    }

    if(mentions != null) {
      mentions.clear();
      mentions = null;
    }

    if(roleMentions != null) {
      roleMentions.clear();
      roleMentions = null;
    }

    if(attachments != null) {
      attachments.clear();
      attachments = null;
    }
  }
}
