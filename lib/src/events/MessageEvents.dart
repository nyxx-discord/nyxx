import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/channel/CacheableTextChannel.dart';
import 'package:nyxx/src/core/channel/ITextChannel.dart';
import 'package:nyxx/src/core/embed/Embed.dart';
import 'package:nyxx/src/core/guild/Guild.dart';
import 'package:nyxx/src/core/message/Emoji.dart';
import 'package:nyxx/src/core/message/GuildEmoji.dart';
import 'package:nyxx/src/core/message/Message.dart';
import 'package:nyxx/src/core/message/Reaction.dart';
import 'package:nyxx/src/core/message/UnicodeEmoji.dart';
import 'package:nyxx/src/core/user/Member.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

/// Sent when a new message is received.
abstract class IMessageReceivedEvent {
  /// The new message.
  IMessage get message;
}

/// Sent when a new message is received.
class MessageReceivedEvent implements IMessageReceivedEvent {
  /// The new message.
  @override
  late final IMessage message;

  /// Creates an instance of [MessageReceivedEvent]
  MessageReceivedEvent(RawApiMap raw, INyxx client) {
    this.message = Message(client, raw["d"] as RawApiMap);

    if(client.cacheOptions.messageCachePolicyLocation.event && client.cacheOptions.messageCachePolicy.canCache(this.message)) {
      message.channel.getFromCache()?.messageCache[this.message.id] = this.message;
    }
  }
}

abstract class IMessageDeleteEvent {
  /// The message, if cached.
  IMessage? get message;

  /// The ID of the message.
  Snowflake get messageId;

  /// Channel where message was deleted
  CacheableTextChannel<ITextChannel> get channel;
}

/// Sent when a message is deleted.
class MessageDeleteEvent implements IMessageDeleteEvent {
  /// The message, if cached.
  @override
  late final IMessage? message;

  /// The ID of the message.
  @override
  late final Snowflake messageId;

  /// Channel where message was deleted
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// Creates na instance of [MessageDeleteEvent]
  MessageDeleteEvent(RawApiMap raw, INyxx client) {
    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["d"]["channel_id"]));
    this.messageId = Snowflake(raw["d"]["id"]);

    this.message = channel.getFromCache()?.messageCache[this.messageId];
  }
}

abstract class IMessageDeleteBulkEvent {
  /// List of deleted messages ids
  Iterable<Snowflake> get deletedMessagesIds;

  /// Channel on which messages were deleted.
  CacheableTextChannel<ITextChannel> get channel;

  /// Id of guild where event occurred
  Cacheable<Snowflake, IGuild>? get guild;

  /// Searches cache for deleted messages and returns those which are present in bots cache.
  /// Will return empty collection if cannot obtain channel instance from cache.
  /// It is not guaranteed that returned collection will have all deleted messages.
  Iterable<IMessage> getDeletedMessages();
}

/// Emitted when multiple messages are deleted at once.
class MessageDeleteBulkEvent implements IMessageDeleteBulkEvent {
  /// List of deleted messages ids
  @override
  late final Iterable<Snowflake> deletedMessagesIds;

  /// Channel on which messages were deleted.
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// Id of guild where event occurred
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Creates an instance of [MessageDeleteBulkEvent]
  MessageDeleteBulkEvent(RawApiMap json, INyxx client) {
    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));

    if (json["d"]["guild_id"] != null) {
      this.guild = GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    } else {
      this.guild = null;
    }

    this.deletedMessagesIds = (json["d"]["ids"] as List<dynamic>).map((stringId) => Snowflake(stringId));
  }

  /// Searches cache for deleted messages and returns those which are present in bots cache.
  /// Will return empty collection if cannot obtain channel instance from cache.
  /// It is not guaranteed that returned collection will have all deleted messages.
  @override
  Iterable<IMessage> getDeletedMessages() {
    final channelInstance = this.channel.getFromCache();

    if (channelInstance == null) {
      return [];
    }

    return channelInstance.messageCache.values.where((item) => this.deletedMessagesIds.contains(item.id));
  }
}

abstract class IMessageReactionEvent {
  /// Reference to user who is behind event
  Cacheable<Snowflake, IUser> get user;

  /// Channel on which event was fired
  CacheableTextChannel<ITextChannel> get channel;

  // TODO: Probably not working
  /// Reference to guild if event happened in guild
  Cacheable<Snowflake, IGuild> get guild;

  /// Message reference
  late final IMessage? message;

  /// Id of message
  late final Snowflake messageId;

  /// The member who reacted if this happened in a guild
  late final IMember member;

  /// Emoji object.
  late final IEmoji emoji;
}

/// Emitted when reaction is added or removed from message
abstract class MessageReactionEvent {
  /// Reference to user who is behind event
  late final Cacheable<Snowflake, IUser> user;

  /// Channel on which event was fired
  late final CacheableTextChannel<ITextChannel> channel;

  // TODO: Probably not working
  /// Reference to guild if event happened in guild
  late final Cacheable<Snowflake, IGuild> guild;

  /// Message reference
  late final IMessage? message;

  /// Id of message
  late final Snowflake messageId;

  /// The member who reacted if this happened in a guild
  late final IMember member;

  /// Emoji object.
  late final IEmoji emoji;

  /// Creates na instance of [MessageReactionEvent]
  MessageReactionEvent(RawApiMap json, INyxx client) {
    this.user = UserCacheable(client, Snowflake(json["d"]["user_id"]));
    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));

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
      this.emoji = GuildEmojiPartial(Snowflake(json["d"]["emoji"]['id']));
    }
  }
}

abstract class IMessageReactionAddedEvent implements IMessageReactionEvent {

}

/// Emitted when reaction is add to message
class MessageReactionAddedEvent extends MessageReactionEvent implements IMessageReactionAddedEvent {
  /// Creates na instance of [MessageReactionAddedEvent]
  MessageReactionAddedEvent(RawApiMap raw, INyxx client) : super(raw, client) {
    if (this.message == null) {
      return;
    }

    final r = message!.reactions.indexWhere((r) => r.emoji == emoji);

    if (r == -1) {
      message!.reactions.add(Reaction.event(emoji, user == (client as NyxxWebsocket).self));
    } else {
      (message!.reactions[r] as Reaction).count++;
    }
  }
}

abstract class IMessageReactionRemovedEvent implements IMessageReactionEvent {

}

/// Emitted when reaction is removed from message
class MessageReactionRemovedEvent extends MessageReactionEvent implements IMessageReactionRemovedEvent {
  /// Creates na instance of [MessageReactionRemovedEvent]
  MessageReactionRemovedEvent(RawApiMap json, INyxx client) : super(json, client) {
    if (message == null) {
      return;
    }

    final r = message!.reactions.indexWhere((r) => r.emoji == emoji);

    if (r != -1) {
      if (message!.reactions[r].count == 1) {
        message!.reactions.removeAt(r);
      } else {
        (message!.reactions[r] as Reaction).count--;
      }
    }
  }
}

abstract class IMessageReactionsRemovedEvent {
  /// Channel on which event was fired
  CacheableTextChannel<ITextChannel> get channel;

  /// Message reference
  Cacheable<Snowflake, IMessage> get message;

  /// Guild where event occurs
  Cacheable<Snowflake, IGuild>? get guild;
}

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent implements IMessageReactionsRemovedEvent {
  /// Channel on which event was fired
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// Message reference
  @override
  late final Cacheable<Snowflake, IMessage> message;

  /// Guild where event occurs
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Creates na instance of [MessageReactionsRemovedEvent]
  MessageReactionsRemovedEvent(RawApiMap json, INyxx client) {
    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));
    this.guild = GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    this.message = MessageCacheable(client, Snowflake(json["d"]["message_id"]), channel);

    final messageInstance = this.message.getFromCache();
    if (messageInstance != null) {
      messageInstance.reactions.clear();
    }
  }
}

abstract class IMessageReactionRemoveEmojiEvent {
  /// Channel on which event was fired
  CacheableTextChannel<ITextChannel> get channel;

  /// Message reference
  Cacheable<Snowflake, IMessage> get message;

  /// Guild where event occurs
  Cacheable<Snowflake, IGuild>? get guild;

  /// Removed emoji
  IEmoji get emoji;
}

/// Emitted when reactions of certain emoji are deleted
class MessageReactionRemoveEmojiEvent implements IMessageReactionRemoveEmojiEvent {
  /// Channel on which event was fired
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// Message reference
  @override
  late final Cacheable<Snowflake, IMessage> message;

  /// Guild where event occurs
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Removed emoji
  @override
  late final IEmoji emoji;

  /// Creates na instance of [MessageReactionRemoveEmojiEvent]
  MessageReactionRemoveEmojiEvent(RawApiMap json, INyxx client) {
    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));
    this.guild = GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    this.message = MessageCacheable(client, Snowflake(json["d"]["message_id"]), channel);

    if (json["d"]["emoji"]["id"] == null) {
      this.emoji = UnicodeEmoji(json["d"]["emoji"]["name"] as String);
    } else {
      this.emoji = GuildEmojiPartial(Snowflake(json["d"]["emoji"]['id']));
    }

    final messageInstance = this.message.getFromCache();
    if (messageInstance != null) {
      messageInstance.reactions.removeWhere((element) => element.emoji == this.emoji);
    }
  }
}

abstract class IMessageUpdateEvent {
  /// Edited message with updated fields
  IMessage? get updatedMessage;

  /// Id of channel where message was edited
  CacheableTextChannel<ITextChannel> get channel;

  /// Id of edited message
  Snowflake get messageId;
}

// TODO: FINISH
/// Sent when a message is updated.
class MessageUpdateEvent implements IMessageUpdateEvent {
  /// Edited message with updated fields
  @override
  late final IMessage? updatedMessage;

  /// Id of channel where message was edited
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// Id of edited message
  @override
  late final Snowflake messageId;

  /// Creates na instance of [MessageUpdateEvent]
  MessageUpdateEvent(RawApiMap json, INyxx client) {
    this.channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));
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
      (this.updatedMessage! as Message).content = json["d"]["content"].toString();
    }

    if (json["d"]["embeds"] != null) {
      (this.updatedMessage! as Message).embeds = (json["d"]["embeds"] as List<dynamic>).map((e) => Embed(e as RawApiMap)).toList();
    }
  }
}
