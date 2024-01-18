import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// A partial [TextChannel].
class PartialTextChannel extends PartialChannel {
  /// A [Manager] for the [Message]s of this channel.
  MessageManager get messages => MessageManager(manager.client.options.messageCacheConfig, manager.client, channelId: id);

  /// Create a new [PartialTextChannel].
  /// @nodoc
  PartialTextChannel({required super.id, required super.manager});

  /// Send a message to this channel.
  ///
  /// Returns the created message.
  ///
  /// External references:
  /// * [MessageManager.create]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#create-message
  Future<Message> sendMessage(MessageBuilder builder) => messages.create(builder);

  /// Trigger a typing indicator in this channel from the current user.
  ///
  /// External references:
  /// * [ChannelManager.triggerTyping]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#trigger-typing-indicator
  Future<void> triggerTyping() => manager.triggerTyping(id);

  // DO NOT override get() and fetch() to return TextChannels
  // Although this improves the API, all PartialChannels returned
  // by ChannelManager.[] are PartialTextChannels, so the overrides
  // added in this class would be used by *all* PartialChannels,
  // even non-text ones.
}

//// A text channel
abstract class TextChannel extends PartialTextChannel implements Channel {
  /// The ID of the last [Message] snt in this channel, or `null` if no messages have been sent.
  Snowflake? get lastMessageId;

  /// The rate limit duration per user.
  Duration? get rateLimitPerUser;

  /// The time at which the last message was pinned, or `null` if no messages have been pinned.
  DateTime? get lastPinTimestamp;

  /// @nodoc
  TextChannel({required super.id, required super.manager});

  /// The last message sent in this channel, or `null` if no messages have been sent.
  PartialMessage? get lastMessage;
}
