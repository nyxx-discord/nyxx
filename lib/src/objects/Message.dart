import 'dart:async';
import 'dart:convert';
import '../client.dart';
import '../../objects.dart';
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
  String timestamp;

  /// The timestamp of when the message was last edited, null if not edited.
  String editedTimestamp;

  /// The message's channel.
  GuildChannel channel;

  /// The message's guild.
  Guild guild;

  /// The message's author.
  User author;

  /// The message's author in a member form.
  Member member;

  /// A list of the mentions in the message.
  List<User> mentions = <User>[];

  /// A list of IDs for the role mentions in the message.
  List<String> roleMentions = <String>[];

  /// A list of the embeds in the message.
  List<Embed> embeds = <Embed>[];

  /// A list of attachments in the message.
  List<Attachment> attachments = <Attachment>[];

  /// When the message was created, redundant of `timestamp`.
  double createdAt;

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
    this.timestamp = data['timestamp'];
    this.editedTimestamp = data['edited_timestamp'];
    this.author = new User(data['author']);
    this.channel = this.client.channels[data['channel_id']];
    this.guild = this.channel.guild;
    this.pinned = data['pinned'];
    this.tts = data['tts'];
    this.mentionEveryone = data['mention_everyone'];
    this.roleMentions = data['mention_roles'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
    this.member = guild.members[this.author.id];

    data['mentions'].forEach((Map<String, dynamic> user) {
      this.mentions.add(new User(user));
    });

    data['embeds'].forEach((Map<String, dynamic> embed) {
      this.embeds.add(new Embed(embed));
    });

    data['attachments'].forEach((Map<String, dynamic> attachment) {
      this.attachments.add(new Attachment(attachment));
    });
  }

  /// Edits the message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Message.edit("My edited content!");
  Future<Message> edit(String content, [MessageOptions options]) async {
    if (this.client.ready) {
      if (options == null) {
        options = new MessageOptions();
      }

      if (options.disableEveryone || (options.disableEveryone == null && this.client.options.disableEveryone)) {
        content = content.replaceAll("@everyone", "@\u200Beveryone").replaceAll("@here", "@\u200Bhere");
      }

      http.Response r = await this.client.http.patch('channels/${this.channel.id}/messages/${this.id}', <String, dynamic>{"content": content});
      Map<String, dynamic> res = JSON.decode(r.body);

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
      http.Response r = await this.client.http.delete('channels/${this.channel.id}/messages/${this.id}');

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
