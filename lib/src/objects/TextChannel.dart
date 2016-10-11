part of discord;

/// A text channel.
class TextChannel extends GuildChannel {
  /// The channel's topic.
  String topic;

  /// A collection of messages sent to this channel.
  Collection<Message> messages;

  /// The ID for the last message in the channel.
  String lastMessageID;

  TextChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, guild, "text") {
    this.topic = this._map['topic'] = data['topic'];
    this.lastMessageID = this._map['lastMessageID'] = data['last_message_id'];
    this.messages = new Collection<Message>();
  }

  void _cacheMessage(Message message) {
    if (this.messages.size >= this._client._options.messageCacheSize) {
      this.messages.map.remove(this.messages.first.id);
    }
    this.messages.add(message);
  }

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.sendMessage("My content!");
  Future<Message> sendMessage(String content, [MessageOptions options]) async {
    if (this._client.ready) {
      MessageOptions newOptions;
      if (options == null) {
        newOptions = new MessageOptions();
      } else {
        newOptions = options;
      }

      String newContent;
      if (newOptions.disableEveryone == true ||
          (newOptions.disableEveryone == null &&
              this._client._options.disableEveryone)) {
        newContent = content
            .replaceAll("@everyone", "@\u200Beveryone")
            .replaceAll("@here", "@\u200Bhere");
      } else {
        newContent = content;
      }

      final http.Response r = await this._client._http.post(
          '/channels/${this.id}/messages', <String, dynamic>{
        "content": newContent,
        "tts": newOptions.tts,
        "nonce": newOptions.nonce
      });
      final res = JSON.decode(r.body) as Map<String, dynamic>;
      return new Message._new(this._client, res);
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
    if (this._client.ready) {
      if (this._client.user.bot) {
        final String id = this._client._util.resolve('message', message);

        final http.Response r =
            await this._client._http.get('/channels/${this.id}/messages/$id');
        final res = JSON.decode(r.body) as Map<String, dynamic>;
        return new Message._new(this._client, res);
      } else {
        throw new Exception("'getMessage' is only usable by bot accounts.");
      }
    } else {
      throw new ClientNotReadyError();
    }
  }
}
