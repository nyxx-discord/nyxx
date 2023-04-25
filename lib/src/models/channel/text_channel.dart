import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';

//// A text channel
abstract class TextChannel implements Channel {
  /// A [Manager] for the [Message]s of this channel.
  MessageManager get messages;

  /// The ID of the last [Message] snt in this channel, or `null` if no messages have been sent.
  Snowflake? get lastMessageId;

  /// The rate limit duration per user.
  Duration? get rateLimitPerUser;

  /// The time at which the last message was pinned, or `null` if no messages have been pinned.
  DateTime? get lastPinTimestamp;

  /// Send a message to this channel.
  ///
  /// Returns the created message.
  ///
  /// External references:
  /// * [MessageManager.create]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#create-message
  Future<Message> sendMessage(MessageBuilder builder);

  /// Trigger a typing indicator in this channel from the current user.
  ///
  /// External references:
  /// * [ChannelManager.triggerTyping]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#trigger-typing-indicator
  Future<void> triggerTyping();
}
