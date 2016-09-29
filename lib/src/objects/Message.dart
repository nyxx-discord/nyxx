import 'dart:async';
import 'dart:convert';
import '../../discord.dart';
import 'package:http/http.dart' as http;

/// A message.
class Message {
  /// The client.
  Client client;

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
  GuildChannel channel;

  /// The message's guild.
  Guild guild;

  /// The message's author.
  User author;

  /// The message's author in a member form.
  Member member;

  /// The mentions in the message.
  Collection mentions;

  /// A list of IDs for the role mentions in the message.
  List<String> roleMentions = <String>[];

  /// A list of the embeds in the message.
  List<Embed> embeds = <Embed>[];

  /// The attachments in the message.
  Collection attachments;

  /// When the message was created, redundant of `timestamp`.
  DateTime createdAt;

  /// Whether or not the message is pinned.
  bool pinned;

  /// Whether or not the message was sent with TTS enabled.
  bool tts;

  /// Whether or @everyone was mentioned in the message.
  bool mentionEveryone;

  /// Constructs a new [Message].
  Message(this.client, Map<String, dynamic> data) {
    this.content = data['content'];
    this.id = data['id'];
    this.nonce = data['nonce'];
    this.timestamp = DateTime.parse(data['timestamp']);
    this.author = new User(client, data['author'] as Map<String, dynamic>);
    this.channel = this.client.channels.map[data['channel_id']];
    this.pinned = data['pinned'];
    this.tts = data['tts'];
    this.mentionEveryone = data['mention_everyone'];
    this.roleMentions = data['mention_roles'] as List<String>;
    this.createdAt = getDate(this.id);

    if (this.channel is GuildChannel) {
      this.guild = this.channel.guild;
      this.member = guild.members.get(this.author.id);
    }

    if (data['edited_timestamp'] != null) {
      this.editedTimestamp = DateTime.parse(data['edited_timestamp']);
    }

    this.mentions = new Collection();
    data['mentions'].forEach((Map<String, dynamic> o) {
      final User user = new User(client, o);
      this.mentions.map[user.id] = user;
    });

    data['embeds'].forEach((Map<String, dynamic> o) {
      this.embeds.add(new Embed(o));
    });

    this.attachments = new Collection();
    data['attachments'].forEach((Map<String, dynamic> o) {
      final Attachment attachment = new Attachment(o);
      this.attachments.map[attachment.id] = attachment;
    });
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
    if (this.client.ready) {
      MessageOptions options;
      if (msgOptions == null) {
        options = new MessageOptions();
      } else {
        options = msgOptions;
      }

      String newContent;
      if (options.disableEveryone ||
          (options.disableEveryone == null &&
              this.client.options.disableEveryone)) {
        newContent = content
            .replaceAll("@everyone", "@\u200Beveryone")
            .replaceAll("@here", "@\u200Bhere");
      } else {
        newContent = content;
      }

      final http.Response r = await this.client.http.patch(
          'channels/${this.channel.id}/messages/${this.id}',
          <String, dynamic>{"content": newContent});
      final res = JSON.decode(r.body) as Map<String, dynamic>;

      if (r.statusCode == 200) {
        return new Message(this.client, res);
      } else {
        throw new Exception("${res['code']}:${res['message']}");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Deletes the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.delete();
  Future<bool> delete() async {
    if (this.client.ready) {
      final http.Response r = await this
          .client
          .http
          .delete('channels/${this.channel.id}/messages/${this.id}');

      if (r.statusCode == 204) {
        return true;
      } else {
        throw new Exception("'delete' error.");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }
}
