import 'package:nyxx/src/core/message/attachment.dart';
import 'package:nyxx/src/core/message/components/message_component.dart';
import 'package:nyxx/src/core/message/message_flags.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/embed/embed.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/message/reaction.dart';
import 'package:nyxx/src/core/message/unicode_emoji.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
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
    message = Message(client, raw["d"] as RawApiMap);

    if (client.cacheOptions.messageCachePolicyLocation.event && client.cacheOptions.messageCachePolicy.canCache(message)) {
      message.channel.getFromCache()?.messageCache[message.id] = message;
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
    channel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["d"]["channel_id"]));
    messageId = Snowflake(raw["d"]["id"]);

    message = channel.getFromCache()?.messageCache[messageId];
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
    channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));

    if (json["d"]["guild_id"] != null) {
      guild = GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    } else {
      guild = null;
    }

    deletedMessagesIds = (json["d"]["ids"] as RawApiList).map((stringId) => Snowflake(stringId));
  }

  /// Searches cache for deleted messages and returns those which are present in bots cache.
  /// Will return empty collection if cannot obtain channel instance from cache.
  /// It is not guaranteed that returned collection will have all deleted messages.
  @override
  Iterable<IMessage> getDeletedMessages() {
    final channelInstance = channel.getFromCache();

    if (channelInstance == null) {
      return [];
    }

    return channelInstance.messageCache.values.where((item) => deletedMessagesIds.contains(item.id));
  }
}

abstract class IMessageReactionEvent {
  /// Reference to user who is behind event
  Cacheable<Snowflake, IUser> get user;

  /// Channel on which event was fired
  CacheableTextChannel<ITextChannel> get channel;

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
    user = UserCacheable(client, Snowflake(json["d"]["user_id"]));
    channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));

    messageId = Snowflake(json["d"]["message_id"]);

    final channelInstance = channel.getFromCache();
    if (channelInstance != null) {
      message = channelInstance.messageCache[messageId];
    } else {
      message = null;
    }

    if (json["d"]["emoji"]["id"] == null) {
      emoji = UnicodeEmoji(json["d"]["emoji"]["name"] as String);
    } else {
      emoji = ResolvableGuildEmojiPartial(json["d"]["emoji"] as RawApiMap, client);
    }
  }
}

abstract class IMessageReactionAddedEvent implements IMessageReactionEvent {}

/// Emitted when reaction is add to message
class MessageReactionAddedEvent extends MessageReactionEvent implements IMessageReactionAddedEvent {
  /// Creates na instance of [MessageReactionAddedEvent]
  MessageReactionAddedEvent(RawApiMap raw, INyxx client) : super(raw, client) {
    if (message == null) {
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

abstract class IMessageReactionRemovedEvent implements IMessageReactionEvent {}

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
    channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));
    guild = GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    message = MessageCacheable(client, Snowflake(json["d"]["message_id"]), channel);

    final messageInstance = message.getFromCache();
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
    channel = CacheableTextChannel<ITextChannel>(client, Snowflake(json["d"]["channel_id"]));
    guild = GuildCacheable(client, Snowflake(json["d"]["guild_id"]));
    message = MessageCacheable(client, Snowflake(json["d"]["message_id"]), channel);

    if (json["d"]["emoji"]["id"] == null) {
      emoji = UnicodeEmoji(json["d"]["emoji"]["name"] as String);
    } else {
      emoji = ResolvableGuildEmojiPartial(json["d"]["emoji"] as RawApiMap, client);
    }

    final messageInstance = message.getFromCache();
    if (messageInstance != null) {
      messageInstance.reactions.removeWhere((element) => element.emoji == emoji);
    }
  }
}

abstract class IMessageUpdateEvent {
  /// Edited message with updated fields
  IMessage? get updatedMessage;

  /// The message before it was updated, if it was cached.
  IMessage? get oldMessage;

  /// Id of channel where message was edited
  CacheableTextChannel<ITextChannel> get channel;

  /// Id of edited message
  Snowflake get messageId;
}

/// Sent when a message is updated.
class MessageUpdateEvent implements IMessageUpdateEvent {
  /// Edited message with updated fields
  @override
  late final IMessage? updatedMessage;

  @override
  late final IMessage? oldMessage;

  /// Id of channel where message was edited
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// Id of edited message
  @override
  late final Snowflake messageId;

  /// Creates na instance of [MessageUpdateEvent]
  MessageUpdateEvent(RawApiMap raw, INyxx client) {
    channel = CacheableTextChannel<ITextChannel>(client, Snowflake(raw["d"]["channel_id"]));
    messageId = Snowflake(raw["d"]["id"]);

    final channelInstance = channel.getFromCache();
    if (channelInstance == null) {
      return;
    }

    oldMessage = channelInstance.messageCache[messageId];

    if (oldMessage == null) {
      return;
    }

    updatedMessage = Message.copy(oldMessage as Message);

    if (raw["d"]["content"] != updatedMessage!.content) {
      (updatedMessage! as Message).content = raw["d"]["content"].toString();
    }

    if (raw["d"]["embeds"] != null) {
      (updatedMessage! as Message).embeds = (raw["d"]["embeds"] as RawApiList).map((e) => Embed(e as RawApiMap)).toList();
    }

    if (raw['d']['edited_timestamp'] != null) {
      (updatedMessage as Message).editedTimestamp = DateTime.parse(raw['d']['edited_timestamp'] as String);
    }

    if (raw['d']['attachments'] != null) {
      (updatedMessage as Message).attachments = [for (final attachment in raw['d']['attachments']) Attachment(attachment as RawApiMap)];
    }

    if (raw['d']['pinned'] != null) {
      (updatedMessage as Message).pinned = raw['d']['pinned'] as bool;
    }

    if (raw['d']['flags'] != null) {
      (updatedMessage as Message).flags = MessageFlags(raw['d']['flags'] as int);
    }

    if (raw['d']['components'] != null && (raw['d']['components'] as RawApiList).isNotEmpty) {
      (updatedMessage as Message).components = [
        for (final rawRow in raw['d']["components"]) [for (final componentRaw in rawRow["components"]) MessageComponent.deserialize(componentRaw as RawApiMap)]
      ];
    }

    channelInstance.messageCache[messageId] = updatedMessage!;
  }
}
