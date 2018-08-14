part of nyxx;

/// [Message] class represents single message. It contains it's Event [Stream]s.
/// [Message] among all it's poperties has also backreference to [Channel] from which it was sent, [Guild] and [User] which sent this message.
/// Supports sending files via `sendFile()` - method can send file or file and use it in embed. Read how to use it [here](https://github.com/l7ssha/nyxx/wiki/Embeds)
class Message extends SnowflakeEntity {
  StreamController<MessageUpdateEvent> _onUpdate;
  StreamController<MessageDeleteEvent> _onDelete;
  StreamController<MessageReactionEvent> _onReactionAdded;
  StreamController<MessageReactionEvent> _onReactionRemove;
  StreamController<MessageReactionsRemovedEvent> _onReactionsRemoved;

  /// The [Client] object.
  Client client;

  /// The raw object returned by the API.
  Map<String, dynamic> raw;

  /// The message's content.
  String content;

  /// The message's nonce, null if not set.
  String nonce;

  /// The timestamp of when the message was last edited, null if not edited.
  DateTime editedTimestamp;

  /// Channel in which message was sent
  MessageChannel channel;

  /// The message's guild.
  Guild guild;

  /// The message's author.
  User author;

  /// The message's author in a member form. Very rarely can be null if `forceFetchMembers` is disabled.
  Member member;

  /// The mentions in the message.
  Map<Snowflake, User> mentions;

  /// A list of IDs for the role mentions in the message.
  Map<Snowflake, Role> roleMentions;

  /// A collection of the embeds in the message.
  Map<String, Embed> embeds;

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

  /// Emitted when the message is edited.
  Stream<MessageUpdateEvent> onUpdate;

  /// Emitted when the message is deleted.
  Stream<MessageDeleteEvent> onDelete;

  /// Emitted when a user adds a reaction to a message.
  Stream<MessageReactionEvent> onReactionAdded;

  /// Emitted when a user adds a reaction to a message.
  Stream<MessageReactionEvent> onReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  Stream<MessageReactionsRemovedEvent> onReactionsRemoved;

  Message._new(this.client, this.raw)
      : super(new Snowflake(raw['id'] as String)) {
    this._onUpdate = new StreamController.broadcast();
    this.onUpdate = this._onUpdate.stream;

    this._onDelete = new StreamController.broadcast();
    this.onDelete = this._onDelete.stream;

    this._onReactionRemove = new StreamController.broadcast();
    this.onReactionRemove = this._onReactionRemove.stream;

    this._onReactionAdded = new StreamController.broadcast();
    this.onReactionAdded = this._onReactionAdded.stream;

    this._onReactionsRemoved = new StreamController.broadcast();
    this.onReactionsRemoved = this._onReactionsRemoved.stream;

    this.content = raw['content'] as String;
    this.nonce = raw['nonce'] as String;
    this.author =
        new User._new(this.client, raw['author'] as Map<String, dynamic>);
    this.channel = this
        .client
        .channels[new Snowflake(raw['channel_id'] as String)] as MessageChannel;
    this.pinned = raw['pinned'] as bool;
    this.tts = raw['tts'] as bool;
    this.mentionEveryone = raw['mention_everyone'] as bool;

    this.channel._cacheMessage(this);
    this.channel.lastMessageID = this.id;

    /// Safe cast to [GuildChannel]
    if (this.channel is TextChannel) {
      this.guild = (this.channel as TextChannel).guild;
      this.member = guild.members[this.author.id];

      if (raw['mention_roles'] != null) {
        this.roleMentions = new Map<Snowflake, Role>();
        raw['mention_roles'].forEach((dynamic o) {
          var s = new Snowflake(o as String);
          this.roleMentions[s] = guild.roles[s];
        });
      }
    }

    if (raw['edited_timestamp'] != null)
      this.editedTimestamp = DateTime.parse(raw['edited_timestamp'] as String);

    raw['mentions'].forEach((dynamic o) {
      this.mentions = new Map<Snowflake, User>();
      final User user = new User._new(this.client, o as Map<String, dynamic>);
      this.mentions[user.id] = user;
    });

    raw['embeds'].forEach((dynamic o) {
      this.embeds = new Map<String, Embed>();
      Embed embed = new Embed._new(this.client, o as Map<String, dynamic>);
      this.embeds[embed.title] = embed;
    });

    raw['attachments'].forEach((dynamic o) {
      this.attachments = new Map<Snowflake, Attachment>();
      final Attachment attachment =
          new Attachment._new(this.client, o as Map<String, dynamic>);
      this.attachments[attachment.id] = attachment;
    });

    if (raw['reactions'] != null) {
      this.reactions = new List<Reaction>();
      raw['reactions'].forEach((dynamic o) {
        this.reactions.add(new Reaction._new(o as Map<String, dynamic>));
      });
    }
  }

  /// Returns mention of message
  @override
  String toString() => this.content;

  /// Edits the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.edit("My edited content!");
  Future<Message> edit(
      {String content,
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
          .replaceAll("@everyone", "@\u200Beveryone")
          .replaceAll("@here", "@\u200Bhere");
    } else {
      newContent = content;
    }

    final HttpResponse r = await this.client.http.send(
        'PATCH', '/channels/${this.channel.id}/messages/${this.id}',
        body: <String, dynamic>{
          "content": newContent,
          "embed": (embed != null ? embed._build() : "")
        });
    return new Message._new(
        this.client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Add reaction to message.
  Future<void> createReaction(Emoji emoji) async {
    await this.client.http.send('PUT',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/@me");
  }

  /// Deletes reaction of bot. Emoji as ':emoji_name:'
  Future<void> deleteReaction(Emoji emoji) async {
    await this.client.http.send('DELETE',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/@me");
  }

  /// Deletes reaction of given user.
  Future<void> deleteUserReaction(Emoji emoji, String userId) async {
    await this.client.http.send('DELETE',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/${emoji.encode()}/$userId");
  }

  /// Deletes all reactions
  Future<void> deleteAllReactions() async {
    await this.client.http.send(
        'DELETE', "/channels/${this.channel.id}/messages/${this.id}/reactions");
  }

  /// Deletes the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.delete();
  Future<void> delete({String auditReason: ""}) async {
    await this.client.http.send(
        'DELETE', '/channels/${this.channel.id}/messages/${this.id}',
        reason: auditReason);
  }

  /// Pins [Message] in current [Channel]
  Future<void> pinMessage() async {
    await this.client.http.send('PUT', "/channels/${channel.id}/pins/$id");
  }

  /// Unpins [Message] in current [Channel]
  Future<void> unpinMessage() async {
    await this.client.http.send('DELETE', "/channels/${channel.id}/pins/$id");
  }
}
