part of discord;

/// A text channel.
class TextChannel extends GuildChannel {
  /// The channel's topic.
  String topic;

  /// The ID for the last message in the channel.
  String lastMessageID;

  /// Constructs a new [TextChannel].
  TextChannel(Client client, Map<String, dynamic> data, Guild guild)
      : super(client, data, guild, "text") {
    this.topic = this.map['topic'] = data['topic'];
    this.lastMessageID = this.map['lastMessageID'] = data['last_message_id'];
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
      if (newOptions.disableEveryone == true ||
          (newOptions.disableEveryone == null &&
              this.client._options.disableEveryone)) {
        newContent = content
            .replaceAll("@everyone", "@\u200Beveryone")
            .replaceAll("@here", "@\u200Bhere");
      } else {
        newContent = content;
      }

      final http.Response r = await this.client._http.post(
          '/channels/${this.id}/messages', <String, dynamic>{
        "content": newContent,
        "tts": newOptions.tts,
        "nonce": newOptions.nonce
      });
      final res = JSON.decode(r.body) as Map<String, dynamic>;

      if (r.statusCode == 200) {
        return new Message(this.client, res);
      } else {
        throw new HttpError(r);
      }
    } else {
      throw new ClientNotReadyError();
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
        final String id = this.client._util.resolve('message', message);

        final http.Response r =
            await this.client._http.get('/channels/${this.id}/messages/$id');
        final res = JSON.decode(r.body) as Map<String, dynamic>;

        if (r.statusCode == 200) {
          return new Message(this.client, res);
        } else {
          throw new HttpError(r);
        }
      } else {
        throw new Exception("'getMessage' is only usable by bot accounts.");
      }
    } else {
      throw new ClientNotReadyError();
    }
  }
}
