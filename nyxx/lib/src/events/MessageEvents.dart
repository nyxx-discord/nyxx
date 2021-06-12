part of nyxx;

/// Sent when a new message is received.
class MessageReceivedEvent {
  /// The new message.
  late final Message message;

  MessageReceivedEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.message = Message._deserialize(client, raw["d"] as Map<String, dynamic>);
    message.channel.getFromCache()?.messageCache.put(this.message);
  }
}

/// Sent when a message is deleted.
class MessageDeleteEvent {
  /// The message, if cached.
  late final Message? message;

  /// The ID of the message.
  late final Snowflake messageId;

  /// Channel where message was deleted
  late final CacheableTextChannel<TextChannel> channel;

  MessageDeleteEvent._new(Map<String, dynamic> raw, Nyxx client) {
    this.channel = CacheableTextChannel<TextChannel>._new(client, Snowflake(raw["d"]["channel_id"]));
    this.messageId = Snowflake(raw["d"]["id"]);

    this.message = channel.getFromCache()?.messageCache[this.messageId];
  }
}

/// Emitted when multiple messages are deleted at once.
class MessageDeleteBulkEvent {
  /// List of deleted messages ids
  late final Iterable<Snowflake> deletedMessagesIds;

  /// Channel on which messages were deleted.
  late final CacheableTextChannel<TextChannel> channel;

  /// Id of guild where event occurred
  late final Cacheable<Snowflake, Guild>? guild;

  MessageDeleteBulkEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channel = CacheableTextChannel<TextChannel>._new(client, Snowflake(json["d"]["channel_id"]));

    if (json["d"]["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    } else {
      this.guild = null;
    }

    this.deletedMessagesIds = (json["d"]["ids"] as List<dynamic>).map((stringId) => Snowflake(stringId));
  }

  /// Searches cache for deleted messages and returns those which are present in bots cache.
  /// Will return empty collection if cannot obtain channel instance from cache.
  /// It is not guaranteed that returned collection will have all deleted messages.
  Iterable<Message> getDeletedMessages() {
    final channelInstance = this.channel.getFromCache();

    if (channelInstance == null) {
      return [];
    }

    return channelInstance.messageCache.find((item) => this.deletedMessagesIds.contains(item.id));
  }
}

/// Emitted when reaction is added or removed from message
abstract class MessageReactionEvent {
  /// Reference to user who is behind event
  late final Cacheable<Snowflake, User> user;

  /// Channel on which event was fired
  late final CacheableTextChannel<TextChannel> channel;

  // TODO: Probably not working
  /// Reference to guild if event happened in guild
  late final Cacheable<Snowflake, Guild> guild;

  /// Message reference
  late final Message? message;

  /// Id of message
  late final Snowflake messageId;

  /// The member who reacted if this happened in a guild
  late final Member member;

  /// Emoji object.
  late final IEmoji emoji;

  MessageReactionEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.user = _UserCacheable(client, Snowflake(json["d"]["user_id"]));
    this.channel = CacheableTextChannel<TextChannel>._new(client, Snowflake(json["d"]["channel_id"]));

    this.messageId = Snowflake(json["d"]["message_id"]);

    final channelInstance = this.channel.getFromCache();
    if (channelInstance != null) {
      this.message = channelInstance.messageCache[this.messageId];
    } else {
      this.message = null;
    }

    if (json["d"]["emoji"]["id"] == null) {
      this.emoji = UnicodeEmoji(json["d"]["emoji"]["name"] as String);
    } else {
      this.emoji = GuildEmojiPartial._new(json["d"]["emoji"] as Map<String, dynamic>);
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
  }
}

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent {
  /// Channel on which event was fired
  late CacheableTextChannel<TextChannel> channel;

  /// Message reference
  late final Cacheable<Snowflake, Message> message;

  /// Guild where event occurs
  late final Cacheable<Snowflake, Guild>? guild;

  MessageReactionsRemovedEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channel = CacheableTextChannel<TextChannel>._new(client, Snowflake(json["d"]["channel_id"]));
    this.guild = _GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    this.message = _MessageCacheable(client, Snowflake(json["d"]["message_id"]), channel);

    final messageInstance = this.message.getFromCache();
    if (messageInstance != null) {
      messageInstance.reactions.clear();
    }
  }
}

/// Emitted when reactions of certain emoji are deleted
class MessageReactionRemoveEmojiEvent {
  /// Channel on which event was fired
  late final CacheableTextChannel<TextChannel> channel;

  /// Message reference
  late final Cacheable<Snowflake, Message> message;

  /// Guild where event occurs
  late final Cacheable<Snowflake, Guild>? guild;

  /// Removed emoji
  late final IEmoji emoji;

  MessageReactionRemoveEmojiEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channel = CacheableTextChannel<TextChannel>._new(client, Snowflake(json["d"]["channel_id"]));
    this.guild = _GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    this.message = _MessageCacheable(client, Snowflake(json["d"]["message_id"]), channel);

    if (json["d"]["emoji"]["id"] == null) {
      this.emoji = UnicodeEmoji(json["d"]["emoji"]["name"] as String);
    } else {
      this.emoji = GuildEmojiPartial._new(json["d"]["emoji"] as Map<String, dynamic>);
    }

    final messageInstance = this.message.getFromCache();
    if (messageInstance != null) {
      messageInstance.reactions.removeWhere((element) => element.emoji == this.emoji);
    }
  }
}

// TODO: FINISH
/// Sent when a message is updated.
class MessageUpdateEvent {
  /// Edited message with updated fields
  late final Message? updatedMessage;

  /// Id of channel where message was edited
  late final CacheableTextChannel<TextChannel> channel;

  /// Id of edited message
  late final Snowflake messageId;

  MessageUpdateEvent._new(Map<String, dynamic> json, Nyxx client) {
    this.channel = CacheableTextChannel<TextChannel>._new(client, Snowflake(json["d"]["channel_id"]));
    this.messageId = Snowflake(json["d"]["id"]);

    final channelInstance = channel.getFromCache();
    if (channelInstance == null) {
      return;
    }

    this.updatedMessage = channelInstance.messageCache[this.messageId];
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
  }
}
