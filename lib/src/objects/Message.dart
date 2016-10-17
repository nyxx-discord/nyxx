part of discord;

/// A message.
class Message extends _BaseObj {
  StreamController<MessageUpdateEvent> _onUpdate;
  StreamController<MessageDeleteEvent> _onDelete;

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

  /// Emitted when the message is edited, if it is in the channel cache.
  Stream<MessageUpdateEvent> onUpdate;

  /// Emitted when the message is deleted, if it is in the channel cache.
  Stream<MessageDeleteEvent> onDelete;

  Message._new(Client client, Map<String, dynamic> data) : super(client, data) {
    this._onUpdate = new StreamController.broadcast();
    this.onUpdate = this._onUpdate.stream;

    this._onDelete = new StreamController.broadcast();
    this.onDelete = this._onDelete.stream;

    this.content = data['content'];
    this.id = data['id'];
    this.nonce = data['nonce'];
    this.timestamp = DateTime.parse(data['timestamp']);
    this.author =
        new User._new(this._client, data['author'] as Map<String, dynamic>);
    this.channel = this._client.channels[data['channel_id']];
    this.pinned = data['pinned'];
    this.tts = data['tts'];
    this.mentionEveryone = data['mention_everyone'];
    this.createdAt = this._client._util.getDate(this.id);

    this.channel._cacheMessage(this);
    this.channel.lastMessageID = this.id;

    if (this.channel is GuildChannel) {
      this.guild = this.channel.guild;
      this.member = guild.members[this.author.id];

      this.roleMentions = new Map<String, Role>();
      data['mention_roles'].forEach((String o) {
        this.roleMentions[guild.roles[o].id] = guild.roles[o];
      });
    }

    if (data['edited_timestamp'] != null) {
      this.editedTimestamp = DateTime.parse(data['edited_timestamp']);
    }

    this.mentions = new Map<String, User>();
    data['mentions'].forEach((Map<String, dynamic> o) {
      final User user = new User._new(client, o);
      this.mentions[user.id] = user;
    });
    this.mentions;

    this.embeds = new Map<String, Embed>();
    data['embeds'].forEach((Map<String, dynamic> o) {
      Embed embed = new Embed._new(this._client, o);
      this.embeds[embed.url] = embed;
    });
    this.embeds;

    this.attachments = new Map<String, Attachment>();
    data['attachments'].forEach((Map<String, dynamic> o) {
      final Attachment attachment = new Attachment._new(this._client, o);
      this.attachments[attachment.id] = attachment;
    });
    this.attachments;
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
    return new Message._new(this._client, r.json as Map<String, dynamic>);
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
