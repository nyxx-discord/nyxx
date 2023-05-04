import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template message_reference}
/// A reference to an external entity contained in a message.
///
/// Different message types will have different objects in their [Message.reference] field.
///
/// - [Crosspost messages](https://discord.com/developers/docs/resources/channel#message-types-crosspost-messages)
///   (messages with [MessageFlags.isCrosspost] set):
///
///   All three fields are present.
///
/// - [Channel Follow Add messages](https://discord.com/developers/docs/resources/channel#message-types-channel-follow-add-messages)
///   ([MessageType.channelFollowAdd])
///
///   Only [channelId] and [guildId] are present.
///
/// - [Pin messages](https://discord.com/developers/docs/resources/channel#message-types-pin-messages)
///   ([MessageType.channelPinnedMessage])
///
///   All three fields are present, except if the message was pinned outside of a guild, in which case [guildId] is `null`.
///
/// - [Replies](https://discord.com/developers/docs/resources/channel#message-types-replies)
///   ([MessageType.reply])
///
///   All three fields are present, except if the message was sent outside of a guild, in which case [guildId] is `null`.
///
/// - [Thread Created messages](https://discord.com/developers/docs/resources/channel#message-types-thread-created-messages)
///   ([MessageType.threadCreated])
///
///   Only [channelId] and [guildId] are present, and point to the newly created thread.
///
/// - [Thread starter messages](https://discord.com/developers/docs/resources/channel#message-types-thread-starter-messages)
///   ([MessageType.threadStarterMessage])
///
///   All three fields are present.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-reference-object
/// {@endtemplate}
class MessageReference with ToStringHelper {
  /// The ID of the originating [Message].
  final Snowflake? messageId;

  /// The ID of the originating message's [Channel].
  final Snowflake channelId;

  /// The ID of the originating message's [Guild].
  final Snowflake? guildId;

  /// {@macro message_reference}
  MessageReference({
    required this.messageId,
    required this.channelId,
    required this.guildId,
  });
}
