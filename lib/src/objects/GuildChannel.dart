import 'dart:async';
import 'dart:convert';
import '../../discord.dart';
import 'package:http/http.dart' as http;

/// A guild channel.
class GuildChannel {
  /// The client.
  Client client;

  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The channel's name.
  String name;

  /// The channel's ID.
  String id;

  /// The channel's topic, only available if the channel is a text channel.
  String topic;

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// The guild that the channel is in.
  Guild guild;

  /// The channel's type, 0 for text, 2 for voice.
  int type;

  /// The channel's position in the channel list.
  int position;

  /// The channel's bitrate, only available if the channel is a voice channel.
  int bitrate;

  /// The channel's user limit, only available if the channel is a voice channel.
  int userLimit;

  /// A timestamp for when the channel was created.
  double createdAt;

  /// Always false representing that it is a GuildChannel.
  bool isPrivate = false;

  /// Constructs a new [GuildChannel].
  GuildChannel(this.client, Map<String, dynamic> data, this.guild) {
    this.name = this.map['name'] = data['name'];
    this.id = this.map['id'] = data['id'];
    this.type = this.map['type'] = data['type'];
    this.position = this.map['position'] = data['position'];
    this.createdAt = this.map['createdAt'] = (int.parse(this.id) / 4194304) + 1420070400000;
    this.topic = this.map['topic'] = data['topic'];
    this.lastMessageID = this.map['lastMessageID'] = data['last_message_id'];
    this.bitrate = this.map['bitrate'] = data['bitrate'];
    this.userLimit = this.map['userLimit'] = data['user_limit'];
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.sendMessage("My content!");
  Future<Message> sendMessage(String content, [MessageOptions options]) async {
    if (this.client.ready) {
      MessageOptions newOptions;
      if (options == null) {
        newOptions = new MessageOptions();
      } else {
        newOptions = options;
      }

      String newContent;
      if (newOptions.disableEveryone || (newOptions.disableEveryone == null && this.client.options.disableEveryone)) {
        newContent = content.replaceAll("@everyone", "@\u200Beveryone").replaceAll("@here", "@\u200Bhere");
      } else {
        newContent = content;
      }

      final http.Response r = await this.client.http.post('channels/${this.id}/messages', <String, dynamic>{"content": newContent, "tts": newOptions.tts, "nonce": newOptions.nonce});
      final Map<String, dynamic> res = JSON.decode(r.body);

      if (r.statusCode == 200) {
        return new Message(this.client, res);
      } else {
        throw new Exception("${res['code']}: ${res['message']}");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Channel.getMessage("message id");
  Future<Message> getMessage(dynamic message) async {
    if (this.client.ready) {
      if (this.client.user.bot) {
        final String id = this.client.resolve('message', message);

        final http.Response r = await this.client.http.get('channels/${this.id}/messages/$id');
        final Map<String, dynamic> res = JSON.decode(r.body);

        if (r.statusCode == 200) {
          return new Message(this.client, res);
        } else {
          throw new Exception("${res['code']}:${res['message']}");
        }
      } else {
        throw new Exception("'getMessage' is only usable by bot accounts.");
      }
    } else {
      throw new Exception("the client isn't ready");
    }
  }
}
