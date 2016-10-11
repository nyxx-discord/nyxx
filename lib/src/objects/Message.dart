part of discord;

/// A message.
class Message extends _BaseObj {
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

  /// The message's channel.
  dynamic channel;

  /// The message's guild.
  Guild guild;

  /// The message's author.
  User author;

  /// The message's author in a member form.
  Member member;

  /// The mentions in the message.
  Collection<User> mentions;

  /// A list of IDs for the role mentions in the message.
  List<String> roleMentions = <String>[];

  /// A collection of the embeds in the message.
  Collection<Embed> embeds;

  /// The attachments in the message.
  Collection<Attachment> attachments;

  /// When the message was created, redundant of `timestamp`.
  DateTime createdAt;

  /// Whether or not the message is pinned.
  bool pinned;

  /// Whether or not the message was sent with TTS enabled.
  bool tts;

  /// Whether or @everyone was mentioned in the message.
  bool mentionEveryone;

  Message._new(Client client, Map<String, dynamic> data) : super(client) {
    this.content = this._map['content'] = data['content'];
    this.id = this._map['id'] = data['id'];
    this.nonce = this._map['nonce'] = data['nonce'];
    this.timestamp = this._map['timestamp'] = DateTime.parse(data['timestamp']);
    this.author = this._map['author'] =
        new User._new(this._client, data['author'] as Map<String, dynamic>);
    this.channel =
        this._map['channel'] = this._client.channels.map[data['channel_id']];
    this.pinned = this._map['pinned'] = data['pinned'];
    this.tts = this._map['tts'] = data['tts'];
    this.mentionEveryone =
        this._map['mentionEveryone'] = data['mention_everyone'];
    this.roleMentions =
        this._map['roleMentions'] = data['mention_roles'] as List<String>;
    this.createdAt =
        this._map['createdAt'] = this._client._util.getDate(this.id);

    this.channel._cacheMessage(this);
    this.channel.lastMessageID = this.id;

    if (this.channel is GuildChannel) {
      this.guild = this._map['guild'] = this.channel.guild;
      this.member = this._map['member'] = guild.members[this.author.id];
    }

    if (data['edited_timestamp'] != null) {
      this.editedTimestamp = this._map['editedTimestamp'] =
          DateTime.parse(data['edited_timestamp']);
    }

    this.mentions = new Collection<User>();
    data['mentions'].forEach((Map<String, dynamic> o) {
      final User user = new User._new(client, o);
      this.mentions.add(user);
    });
    this._map['mentions'] = this.mentions;

    this.embeds = new Collection<Embed>();
    data['embeds'].forEach((Map<String, dynamic> o) {
      this.embeds.add(new Embed._new(this._client, o));
    });
    this._map['embeds'] = this.embeds;

    this.attachments = new Collection<Attachment>();
    data['attachments'].forEach((Map<String, dynamic> o) {
      final Attachment attachment = new Attachment._new(this._client, o);
      this.attachments.add(attachment);
    });
    this._map['attachments'] = this.attachments;
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
  Future<Message> edit(String content, [MessageOptions msgOptions]) async {
    MessageOptions options;
    if (msgOptions == null) {
      options = new MessageOptions();
    } else {
      options = msgOptions;
    }

    String newContent;
    if (options.disableEveryone == true ||
        (options.disableEveryone == null &&
            this._client._options.disableEveryone)) {
      newContent = content
          .replaceAll("@everyone", "@\u200Beveryone")
          .replaceAll("@here", "@\u200Bhere");
    } else {
      newContent = content;
    }

    final _HttpResponse r = await this._client._http.patch(
        '/channels/${this.channel.id}/messages/${this.id}',
        <String, dynamic>{"content": newContent});
    return new Message._new(this._client, r.json);
  }

  /// Deletes the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.delete();
  Future<Null> delete() async {
    await this
        ._client
        ._http
        .delete('/channels/${this.channel.id}/messages/${this.id}');
    return null;
  }
}
