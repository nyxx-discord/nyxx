part of nyxx;

/// Sent when a new message is received.
class MessageReceivedEvent {
  /// The new message.
  late final Message message;

  MessageReceivedEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.message = Message._deserialize(raw["d"] as Map<String, dynamic>, client);
    message.channel?.messages.put(this.message);
  }
}

/// Sent when a message is deleted.
class MessageDeleteEvent {
  /// The message, if cached.
  late Message? message;

  /// The ID of the message.
  late final Snowflake messageId;

  MessageDeleteEvent._new(Map<String, dynamic> raw, Nyxx client) {
    final channel = client.channels[Snowflake(raw["d"]["channel_id"] as String)] as MessageChannel?;
    this.messageId = Snowflake(raw["d"]["id"]);

    final message = channel?.messages[this.messageId];

    if (message != null) {
      this.message = message;
      message.channel?.messages.remove(this.messageId);
    }
  }
}

/// Emitted when multiple messages are deleted at once.
class MessageDeleteBulkEvent {
  /// List of deleted messages ids
  late final Iterable<Snowflake> deletedMessagesIds;

  /// List of references to deleted messages
  late final Iterable<Message>? deletedMessages;

  /// Channel on which messages were deleted.
  MessageChannel? channel;

  /// Id of guild where event occurred
  late final Snowflake? guildId;

  /// Channel id where messages were deleted
  late final Snowflake channelId;

  MessageDeleteBulkEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channelId = Snowflake(json["d"]["channel_id"]);

    if (json["d"]["guild_id"] != null) {
      this.guildId = Snowflake(json["d"]["guild_id"]);
    }

    this.channel = client.channels[this.channelId] as MessageChannel?;

    this.deletedMessagesIds = (json["d"]["ids"] as List<dynamic>).map((stringId) => Snowflake(stringId));
    if (this.channel != null) {
      this.deletedMessages = this.channel!.messages.find((item) => this.deletedMessagesIds.contains(item.id));
      this.channel!.messages.removeWhere((key, value) => this.deletedMessagesIds.contains(key));
    }
  }
}

/// Emitted when reaction is added or removed from message
abstract class MessageReactionEvent {
  /// Reference to user who is behind event
  User? user;

  /// Id of user who is behind event
  late final Snowflake userId;

  /// Channel on which event was fired
  late MessageChannel? channel;

  /// Id of channel on which event was fired
  late final Snowflake channelId;

  /// Message reference
  late final Message? message;

  /// Id of message
  late final Snowflake messageId;

  /// Emoji object.
  late final Emoji emoji;

  MessageReactionEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.userId = Snowflake(json["d"]["user_id"]);
    this.user = client.users[this.userId];

    this.channelId = Snowflake(json["d"]["channel_id"]);
    this.channel = client.channels[this.channelId] as MessageChannel?;

    this.messageId = Snowflake(json["d"]["message_id"]);
    if (this.channel != null) {
      this.message = this.channel!.messages[this.messageId];
    }

    if (json["d"]["emoji"]["id"] == null) {
      this.emoji = UnicodeEmoji(json["d"]["emoji"]["name"] as String);
    } else {
      this.emoji = GuildEmoji._partial(json["d"]["emoji"] as Map<String, dynamic>);
    }
  }
}

/// Emitted when reaction is add to message
class MessageReactionAddedEvent extends MessageReactionEvent {
  MessageReactionAddedEvent._new(Map<String, dynamic> json, Nyxx client) : super._new(json, client) {
    if (message == null) {
      return;
    }

    final r = message!.reactions.indexWhere((r) => r.emoji == emoji);

    if (r == -1) {
      message!.reactions.add(Reaction._event(emoji, user == client.self));
    } else {
      message!.reactions[r].count++;
    }

    client._events.onMessageReactionAdded.add(this);
  }
}

/// Emitted when reaction is removed from message
class MessageReactionRemovedEvent extends MessageReactionEvent {
  MessageReactionRemovedEvent._new(Map<String, dynamic> json, Nyxx client) : super._new(json, client) {
    if (message == null) {
      return;
    }

    final r = message!.reactions.indexWhere((r) => r.emoji == emoji);

    if (r != -1) {
      if (message!.reactions[r].count == 1) {
        message!.reactions.removeAt(r);
      } else {
        message!.reactions[r].count--;
      }
    }

    client._events.onMessageReactionRemove.add(this);
  }
}

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent {
  /// Channel on which event was fired
  late MessageChannel? channel;

  /// Id of channel on which event was fired
  late final Snowflake channelId;

  /// Message reference
  late final Message? message;

  /// Id of message
  late final Snowflake messageId;

  /// Guild where event occurs
  late final Guild? guild;

  /// Id of guild
  late final Snowflake guildId;

  MessageReactionsRemovedEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channelId = Snowflake(json["d"]["channel_id"]);
    this.channel = client.channels[this.channelId] as MessageChannel?;

    this.guildId = Snowflake(json["d"]["guild_id"]);
    this.guild = client.guilds[this.guildId];

    this.messageId = Snowflake(json["d"]["message_id"]);
    if (this.channel != null) {
      this.message = this.channel!.messages[messageId];
    }

    if (this.message != null) {
      this.message!.reactions.clear();
    }
  }
}

/// Emitted when reactions of certain emoji are deleted
class MessageReactionRemoveEmojiEvent {
  /// Channel on which event was fired
  late MessageChannel? channel;

  /// Id of channel on which event was fired
  late final Snowflake channelId;

  /// Message reference
  late final Message? message;

  /// Id of message
  late final Snowflake messageId;

  /// Guild where event occurs
  late final Guild? guild;

  /// Id of guild
  late final Snowflake guildId;

  /// Removed emoji
  late final Emoji emoji;

  MessageReactionRemoveEmojiEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channelId = Snowflake(json["d"]["channel_id"]);
    this.channel = client.channels[this.channelId] as MessageChannel?;

    this.guildId = Snowflake(json["d"]["guild_id"]);
    this.guild = client.guilds[this.guildId];

    this.messageId = Snowflake(json["d"]["message_id"]);
    if (this.channel != null) {
      this.message = this.channel!.messages[messageId];
    }

    if (json["d"]["emoji"]["id"] == null) {
      this.emoji = UnicodeEmoji(json["d"]["emoji"]["name"] as String);
    } else {
      this.emoji = GuildEmoji._partial(json["d"]["emoji"] as Map<String, dynamic>);
    }

    if (this.message != null) {
      this.message!.reactions.removeWhere((element) => element.emoji == this.emoji);
    }
  }
}

// TODO: FINISH
/// Sent when a message is updated.
class MessageUpdateEvent {
  /// Edited message with updated fields
  late final Message? updatedMessage;

  /// Id of channel where message was edited
  late final Snowflake channelId;

  /// Id of edited message
  late final Snowflake messageId;

  MessageUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channelId = Snowflake(json["d"]["channel_id"]);
    this.messageId = Snowflake(json["d"]["id"]);

    final channel = client.channels[this.channelId] as MessageChannel?;

    if (channel == null) {
      return;
    }

    this.updatedMessage = channel.messages[this.messageId];

    if (this.updatedMessage == null) {
      return;
    }

    if (json["d"]["content"] != this.updatedMessage!.content) {
      this.updatedMessage!.content = json["d"]["content"].toString();
    }

    if (json["d"]["embeds"] != null) {
      this.updatedMessage!.embeds =
          (json["d"]["embeds"] as List<dynamic>).map((e) => Embed._new(e as Map<String, dynamic>)).toList();
    }

    if (json["d"]["mentions"] != null) {
      this.updatedMessage!.mentions =
          (json["d"]["mentions"] as List<dynamic>).map((e) => User._new(e as Map<String, dynamic>, client)).toList();
    }
  }
}
