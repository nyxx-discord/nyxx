import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

/// {@template message_create_event}
/// Emitted when a message is sent.
/// {@endtemplate}
class MessageCreateEvent extends DispatchEvent {
  /// The ID of the guild the message was sent in.
  final Snowflake? guildId;

  /// The member that sent the message.
  final PartialMember? member;

  /// A list of users explicitly mentioned in the message.
  final List<User> mentions;

  /// The message that was sent.
  final Message message;

  /// {@macro message_create_event}
  /// @nodoc
  MessageCreateEvent({required super.gateway, required this.guildId, required this.member, required this.mentions, required this.message});

  /// The guild the message was sent in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];
}

/// {@template message_update_event}
/// Emitted when a message is updated.
/// {@endtemplate}
class MessageUpdateEvent extends DispatchEvent {
  /// The ID of the guild the message was in.
  final Snowflake? guildId;

  /// The member that sent the message.
  final PartialMember? member;

  /// A list of users explicitly mentioned in the message.
  final List<User>? mentions;

  /// The updated message.
  final PartialMessage message;

  /// The message as it was cached before the update.
  final Message? oldMessage;

  /// {@macro message_update_event}
  /// @nodoc
  MessageUpdateEvent({
    required super.gateway,
    required this.guildId,
    required this.member,
    required this.mentions,
    required this.message,
    required this.oldMessage,
  });

  /// The guild the message was updated in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];
}

/// {@template message_delete_event}
/// Emitted when a message is deleted.
/// {@endtemplate}
class MessageDeleteEvent extends DispatchEvent {
  /// The ID of the deleted message.
  final Snowflake id;

  /// The ID of the channel the message was deleted in.
  final Snowflake channelId;

  /// The ID of the guild the message was deleted in.
  final Snowflake? guildId;

  /// The message as it was cached before being deleted.
  final Message? deletedMessage;

  /// {@macro message_delete_event}
  /// @nodoc
  MessageDeleteEvent({required super.gateway, required this.id, required this.channelId, required this.guildId, required this.deletedMessage});

  /// The guild the message was deleted in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];

  /// The channel the message was deleted in.
  PartialTextChannel get channel => gateway.client.channels[channelId] as PartialTextChannel;
}

/// {@template message_bulk_delete_event}
/// Emitted when multiple messages are bulk deleted.
/// {@endtemplate}
class MessageBulkDeleteEvent extends DispatchEvent {
  /// A list of the IDs of the deleted messages.
  final List<Snowflake> ids;

  /// A list of the messages that were found in cache before being deleted.
  final List<Message?> deletedMessages;

  /// The ID of the channel the messages were deleted in.
  final Snowflake channelId;

  /// The ID of the guild the messages were deleted in.
  final Snowflake? guildId;

  /// {@macro message_bulk_delete_event}
  /// @nodoc
  MessageBulkDeleteEvent({required super.gateway, required this.ids, required this.deletedMessages, required this.channelId, required this.guildId});

  /// The guild the messages were deleted in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];

  /// The channel the messages were deleted in.
  PartialTextChannel get channel => gateway.client.channels[channelId] as PartialTextChannel;
}

/// {@template message_reaction_add_event}
/// Emitted when a reaction is added to a message.
/// {@endtemplate}
class MessageReactionAddEvent extends DispatchEvent {
  /// The ID of the user that added the reaction.
  final Snowflake userId;

  /// The ID of the channel the message is in.
  final Snowflake channelId;

  /// The ID of the message the reaction was added to.
  final Snowflake messageId;

  /// The ID of the guild the message is in.
  final Snowflake? guildId;

  /// The member that added the reaction to the message.
  final Member? member;

  /// The emoji that was added.
  final Emoji emoji;

  /// The ID of the user that sent the message the reaction was added to.
  final Snowflake? messageAuthorId;

  /// {@macro message_reaction_add_event}
  /// @nodoc
  MessageReactionAddEvent({
    required super.gateway,
    required this.userId,
    required this.channelId,
    required this.messageId,
    required this.guildId,
    required this.member,
    required this.emoji,
    required this.messageAuthorId,
  });

  /// The guild the message is in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];

  /// The channel the message is in.
  PartialTextChannel get channel => gateway.client.channels[channelId] as PartialTextChannel;

  /// The user that added the reaction.
  PartialUser get user => gateway.client.users[userId];

  /// The message the reaction was added to.
  PartialMessage get message => channel.messages[messageId];

  /// The user that sent the message the reaction was added to
  PartialUser? get messageAuthor => messageAuthorId == null ? null : gateway.client.users[messageAuthorId!];
}

/// {@template message_reaction_remove_event}
/// Emitted when a reaction is removed from a message.
/// {@endtemplate}
class MessageReactionRemoveEvent extends DispatchEvent {
  /// The ID of the user that removed their reaction.
  final Snowflake userId;

  /// The ID of the channel the message is in.
  final Snowflake channelId;

  /// The ID of the message the reaction was removed from.
  final Snowflake messageId;

  /// The ID of the guild the message is in.
  final Snowflake? guildId;

  /// The emoji that was removed.
  final Emoji emoji;

  /// {@macro message_reaction_remove_event}
  /// @nodoc
  MessageReactionRemoveEvent({
    required super.gateway,
    required this.userId,
    required this.channelId,
    required this.messageId,
    required this.guildId,
    required this.emoji,
  });

  /// The guild the message is in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];

  /// The channel the message is in.
  PartialTextChannel get channel => gateway.client.channels[channelId] as PartialTextChannel;

  /// The user that removed the reaction.
  PartialUser get user => gateway.client.users[userId];

  /// The message the reaction was removed from.
  PartialMessage get message => channel.messages[messageId];
}

/// {@template message_reaction_remove_all_event}
/// Emitted when all reactions are removed from a message.
/// {@endtemplate}
class MessageReactionRemoveAllEvent extends DispatchEvent {
  /// The ID of the channel the message is in.
  final Snowflake channelId;

  /// The ID of the messages the reactions were removed from.
  final Snowflake messageId;

  /// The ID of the guild the message is in.
  final Snowflake? guildId;

  /// {@macro message_reaction_remove_all_event}
  /// @nodoc
  MessageReactionRemoveAllEvent({
    required super.gateway,
    required this.channelId,
    required this.messageId,
    required this.guildId,
  });

  /// The guild the message is in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];

  /// The channel the message is in.
  PartialTextChannel get channel => gateway.client.channels[channelId] as PartialTextChannel;

  /// The message the reactions were removed from.
  PartialMessage get message => channel.messages[messageId];
}

/// {@template message_reaction_remove_emoji_event}
/// Emitted when all reactions of a specific emoji are removed from a message.
/// {@endtemplate}
class MessageReactionRemoveEmojiEvent extends DispatchEvent {
  /// The ID of the channel the message is in.
  final Snowflake channelId;

  /// The ID of the message the reactions were removed from.
  final Snowflake messageId;

  /// The ID of the guild the message is in.
  final Snowflake? guildId;

  final PartialEmoji emoji;

  /// {@macro message_reaction_remove_emoji_event}
  /// @nodoc
  MessageReactionRemoveEmojiEvent({
    required super.gateway,
    required this.channelId,
    required this.messageId,
    required this.guildId,
    required this.emoji,
  });

  /// The guild the message is in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];

  /// The channel the message is in.
  PartialTextChannel get channel => gateway.client.channels[channelId] as PartialTextChannel;

  /// The message the reactions were removed from.
  PartialMessage get message => channel.messages[messageId];
}
