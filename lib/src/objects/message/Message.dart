part of nyxx;

/// A message.
class Message {
  StreamController<MessageUpdateEvent> _onUpdate;
  StreamController<MessageDeleteEvent> _onDelete;

  /// The [Client] object.
  Client client;

  /// The raw object returned by the API.
  Map<String, dynamic> raw;

  /// The message's content.
  String content;

  /// The message's ID.
  String id;

  /// The message's nonce, null if not set.
  String nonce;

  /// The timestamp of when the message was created.
  DateTime timestamp;

  /// The timestamp of when the message was last edited, null if not edited.
  DateTime editedTimestamp;

  /// The message's channel. Due many possible channel types This is instance of [MessageChannel] interface
  /// which has only `send()` signature. If you want future informations about Channel cast it.
  MessageChannel channel;

  /// The message's guild.
  Guild guild;

  /// The message's author.
  User author;

  /// The message's author in a member form. Very rarely can be null if `forceFetchMembers` is disabled.
  Member member;

  /// The mentions in the message.
  Map<String, User> mentions;

  /// A list of IDs for the role mentions in the message.
  Map<String, Role> roleMentions;

  /// A collection of the embeds in the message.
  Map<String, Embed> embeds;

  /// The attachments in the message.
  Map<String, Attachment> attachments;

  /// When the message was created, redundant of `timestamp`.
  DateTime createdAt;

  /// Whether or not the message is pinned.
  bool pinned;

  /// Whether or not the message was sent with TTS enabled.
  bool tts;

  /// Whether or @everyone was mentioned in the message.
  bool mentionEveryone;

  /// List of message reactions
  List<Reaction> reactions;

  /// Emitted when the message is edited, if it is in the channel cache.
  Stream<MessageUpdateEvent> onUpdate;

  /// Emitted when the message is deleted, if it is in the channel cache.
  Stream<MessageDeleteEvent> onDelete;

  Message._new(this.client, this.raw) {
    this._onUpdate = new StreamController.broadcast();
    this.onUpdate = this._onUpdate.stream;

    this._onDelete = new StreamController.broadcast();
    this.onDelete = this._onDelete.stream;

    this.content = raw['content'];
    this.id = raw['id'];
    this.nonce = raw['nonce'];
    this.timestamp = DateTime.parse(raw['timestamp']);
    this.author =
        new User._new(this.client, raw['author'] as Map<String, dynamic>);
    this.channel = this.client.channels[raw['channel_id']];
    this.pinned = raw['pinned'];
    this.tts = raw['tts'];
    this.mentionEveryone = raw['mention_everyone'];
    this.createdAt = Util.getDate(this.id);

    this.channel._cacheMessage(this);
    this.channel.lastMessageID = this.id;

    /// Safe cast to [GuildChannel]
    if (this.channel is GuildChannel) {
      this.guild = this.channel.guild;
      this.member = guild.members[this.author.id];

      this.roleMentions = new Map<String, Role>();
      raw['mention_roles'].forEach((String o) {
        this.roleMentions[guild.roles[o].id] = guild.roles[o];
      });
    }

    if (raw['edited_timestamp'] != null) {
      this.editedTimestamp = DateTime.parse(raw['edited_timestamp']);
    }

    this.mentions = new Map<String, User>();
    raw['mentions'].forEach((Map<String, dynamic> o) {
      final User user = new User._new(this.client, o);
      this.mentions[user.id] = user;
    });
    this.mentions;

    this.embeds = new Map<String, Embed>();
    raw['embeds'].forEach((Map<String, dynamic> o) {
      Embed embed = new Embed._new(this.client, o);
      this.embeds[embed.title] = embed;
    });
    this.embeds;

    this.attachments = new Map<String, Attachment>();
    raw['attachments'].forEach((Map<String, dynamic> o) {
      final Attachment attachment = new Attachment._new(this.client, o);
      this.attachments[attachment.id] = attachment;
    });
    this.attachments;

    this.reactions = new List<Reaction>();
    if (raw['reactions'] != null) {
      raw['reactions'].forEach((Map<String, dynamic> o) {
        this.reactions.add(new Reaction._new(o));
      });
    }
    this.reactions;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.content;
  }

  /// Edits the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.edit("My edited content!");
  Future<Message> edit(
      {String content,
      Map<dynamic, dynamic> embed,
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
        body: <String, dynamic>{"content": newContent, "embed": embed});
    return new Message._new(
        this.client, r.body.asJson() as Map<String, dynamic>);
  }

  /// Add reaction to message. Emoji as ':emoji_name:'
  Future<Null> createReaction(String emoji) async {
    await this.client.http.send('PUT',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/$emoji/@me");
    return null;
  }

  /// Deletes reaction of bot. Emoji as ':emoji_name:'
  Future<Null> deleteReaction(String emoji) async {
    await this.client.http.send('DELETE',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/$emoji/@me");
    return null;
  }

  /// Deletes reaction of given user. Emoji as ':emoji_name:'
  Future<Null> deleteUserReaction(String emoji, String userId) async {
    await this.client.http.send('DELETE',
        "/channels/${this.channel.id}/messages/${this.id}/reactions/$emoji/$userId");
    return null;
  }

  /// Deletes all reactions
  Future<Null> deleteAllReactions() async {
    await this.client.http.send(
        'DELETE', "/channels/${this.channel.id}/messages/${this.id}/reactions");
    return null;
  }

  /// Deletes the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.delete();
  Future<Null> delete() async {
    await this
        .client
        .http
        .send('DELETE', '/channels/${this.channel.id}/messages/${this.id}');
    return null;
  }

  /// Pins [Message] in current [Channel]
  Future<Null> pinMessage() async {
    await this.client.http.send('PUT', "/channels/${channel.id}/pins/$id");
    return null;
  }

  /// Unpins [Message] in current [Channel]
  Future<Null> unpinMessage() async {
    await this.client.http.send('DELETE', "/channels/${channel.id}/pins/$id");
    return null;
  }
}
