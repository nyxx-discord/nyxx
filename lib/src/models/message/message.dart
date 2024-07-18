import 'package:nyxx/src/builders/emoji/reaction.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/interaction.dart';
import 'package:nyxx/src/models/message/activity.dart';
import 'package:nyxx/src/models/message/attachment.dart';
import 'package:nyxx/src/models/message/channel_mention.dart';
import 'package:nyxx/src/models/message/component.dart';
import 'package:nyxx/src/models/message/embed.dart';
import 'package:nyxx/src/models/message/author.dart';
import 'package:nyxx/src/models/message/poll.dart';
import 'package:nyxx/src/models/message/reference.dart';
import 'package:nyxx/src/models/message/reaction.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/message/role_subscription_data.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/sticker/sticker.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/webhook.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template partial_message}
/// A partial [Message] object.
/// {@endtemplate}
class PartialMessage extends WritableSnowflakeEntity<Message> {
  @override
  final MessageManager manager;

  /// The ID of the [Channel] the message was sent in.
  Snowflake get channelId => manager.channelId;

  /// {@macro partial_message}
  /// @nodoc
  PartialMessage({required super.id, required this.manager});

  /// The channel this message was sent in.
  PartialTextChannel get channel => manager.client.channels[channelId] as PartialTextChannel;

  /// Update this message.
  // An often-used alias to update
  Future<Message> edit(MessageUpdateBuilder builder) => update(builder);

  /// Crosspost this message to all channels following the channel this message was sent in.
  Future<void> crosspost() => manager.crosspost(id);

  /// Pin this message.
  Future<void> pin({String? auditLogReason}) => manager.pin(id, auditLogReason: auditLogReason);

  /// Unpin this message.
  Future<void> unpin({String? auditLogReason}) => manager.unpin(id, auditLogReason: auditLogReason);

  /// Creates a reaction on this message.
  /// ```dart
  /// await message.react('👍');
  /// ```
  /// or
  /// ```dart
  /// final emoji = await client.emoji.fetch(Snowflake(123456789012345678));
  /// await message.react(emoji.toString());
  /// ```
  Future<void> react(ReactionBuilder emoji) => manager.addReaction(id, emoji);

  /// Deletes a reaction by a user, if specified on this message.
  /// Otherwise deletes reactions by [emoji].
  Future<void> deleteReaction(ReactionBuilder emoji, {Snowflake? userId}) =>
      userId == null ? manager.deleteReaction(id, emoji) : manager.deleteReactionForUser(id, userId, emoji);

  /// Deletes all reactions on this message.
  Future<void> deleteAllReactions() => manager.deleteAllReactions(id);

  /// Deletes reaction the current user has made on this message.
  Future<void> deleteOwnReaction(ReactionBuilder emoji) => manager.deleteOwnReaction(id, emoji);

  /// Get a list of users that reacted with a given emoji on a message.
  Future<List<User>> fetchReactions(ReactionBuilder emoji, {Snowflake? after, int? limit}) => manager.fetchReactions(id, emoji, after: after, limit: limit);

  /// Get a list of users that voted for this specific answer.
  Future<List<User>> fetchAnswerVoters(int answerId, {Snowflake? after, int? limit}) => manager.fetchAnswerVoters(id, answerId, after: after, limit: limit);

  /// Immediately ends the poll.
  Future<Message> endPoll() => manager.endPoll(id);
}

/// {@template message}
/// Represents a message sent in a [TextChannel].
///
/// Not all messages are sent by users. Messages can also be system messages such as the "message pinned" notice that is sent to a channel when a message is
/// pinned. Check [type] to see if a message is [MessageType.normal] or [MessageType.reply].
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-object
/// {@endtemplate}
class Message extends PartialMessage {
  /// The author of this message.
  ///
  /// This could be a [User] or a [WebhookAuthor].
  final MessageAuthor author;

  /// The content of the message.
  ///
  /// {@template message_content_intent_required}
  /// The message content intent is needed for this field to be non-empty.
  /// {@endtemplate}
  final String content;

  /// The time when this message was sent.
  final DateTime timestamp;

  /// The time when this message was last edited, or `null` if the message was never edited.
  final DateTime? editedTimestamp;

  /// Whether this was a TTS message.
  final bool isTts;

  /// Whether this message mentions everyone.
  final bool mentionsEveryone;

  /// A list of users specifically mentioned in this message.
  final List<User> mentions;

  final List<Snowflake> roleMentionIds;

  /// A list of channels specifically mentioned in this message.
  final List<ChannelMention> channelMentions;

  /// A list of files attached to this message.
  ///
  /// {@macro message_content_intent_required}
  final List<Attachment> attachments;

  /// A list of embeds in this message.
  ///
  /// {@macro message_content_intent_required}
  final List<Embed> embeds;

  /// A list of reactions to this message.
  final List<Reaction> reactions;

  /// A user-set value to validate a message was sent.
  ///
  /// This can be an [int] or a [String], set using [MessageBuilder.nonce].
  final dynamic /* int | String */ nonce;

  /// Whether this message is pinned.
  final bool isPinned;

  /// The ID of the webhook that sent this message if it was sent by a webhook, `null` otherwise.
  final Snowflake? webhookId;

  /// The type of this message.
  final MessageType type;

  /// Activity information if this message is related to Rich Presence, `null` otherwise.
  final MessageActivity? activity;

  /// The application associated with this message if this messages is related to Rich Presence, `null` otherwise.
  final PartialApplication? application;

  /// The ID of the [Application] that sent this message if it is an interaction or a webhook, `null` otherwise.
  final Snowflake? applicationId;

  /// Data showing the source of a crosspost, channel follow add, pin, or reply message.
  final MessageReference? reference;

  /// Any flags applied to this message.
  final MessageFlags flags;

  /// The message associated with [reference].
  final Message? referencedMessage;

  /// Information about the interaction related to this message.
  final MessageInteractionMetadata? interactionMetadata;

  /// Information about the interaction related to this message.
  // ignore: deprecated_member_use_from_same_package
  @Deprecated('Use `interactionMetadata`')
  final MessageInteraction? interaction;

  /// The thread that was started from this message if any, `null` otherwise.
  final Thread? thread;

  /// A list of components in this message.
  final List<MessageComponent>? components;

  /// List of sticker attached to message
  final List<StickerItem> stickers;

  /// A generally increasing integer (there may be gaps or duplicates) that represents the approximate position of this message in a thread.
  ///
  /// Can be used to estimate the relative position of the message in a thread in company with [Thread.totalMessagesSent] on parent thread
  final int? position;

  /// Data about the role subscription purchase that prompted this message if this is a [MessageType.roleSubscriptionPurchase] message.
  final RoleSubscriptionData? roleSubscriptionData;

  /// Data about entities in this message's auto-populated select menus.
  final ResolvedData? resolved;

  /// A poll.
  final Poll? poll;

  /// The message(s) associated with the [reference].
  final List<MessageSnapshot>? snapshots;

  /// {@macro message}
  /// @nodoc
  Message({
    required super.id,
    required super.manager,
    required this.author,
    required this.content,
    required this.timestamp,
    required this.editedTimestamp,
    required this.isTts,
    required this.mentionsEveryone,
    required this.mentions,
    required this.roleMentionIds,
    required this.channelMentions,
    required this.attachments,
    required this.embeds,
    required this.reactions,
    required this.nonce,
    required this.isPinned,
    required this.webhookId,
    required this.type,
    required this.activity,
    required this.application,
    required this.applicationId,
    required this.reference,
    required this.flags,
    required this.referencedMessage,
    required this.interactionMetadata,
    required this.interaction,
    required this.thread,
    required this.components,
    required this.position,
    required this.roleSubscriptionData,
    required this.stickers,
    required this.resolved,
    required this.poll,
    required this.snapshots,
  });

  /// The webhook that sent this message if it was sent by a webhook, `null` otherwise.
  PartialWebhook? get webhook => webhookId == null ? null : manager.client.webhooks[webhookId!];

  // Cannot provide roleMentions as we do not have access to the guild.
}

/// The type of a message.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-object-message-types
final class MessageType extends EnumLike<int, MessageType> {
  static const normal = MessageType(0);
  static const recipientAdd = MessageType(1);
  static const recipientRemove = MessageType(2);
  static const call = MessageType(3);
  static const channelNameChange = MessageType(4);
  static const channelIconChange = MessageType(5);
  static const channelPinnedMessage = MessageType(6);
  static const userJoin = MessageType(7);
  static const guildBoost = MessageType(8);
  static const guildBoostTier1 = MessageType(9);
  static const guildBoostTier2 = MessageType(10);
  static const guildBoostTier3 = MessageType(11);
  static const channelFollowAdd = MessageType(12);
  static const guildDiscoveryDisqualified = MessageType(14);
  static const guildDiscoveryRequalified = MessageType(15);
  static const guildDiscoveryGracePeriodInitialWarning = MessageType(16);
  static const guildDiscoveryGracePeriodFinalWarning = MessageType(17);
  static const threadCreated = MessageType(18);
  static const reply = MessageType(19);
  static const chatInputCommand = MessageType(20);
  static const threadStarterMessage = MessageType(21);
  static const guildInviteReminder = MessageType(22);
  static const contextMenuCommand = MessageType(23);
  static const autoModerationAction = MessageType(24);
  static const roleSubscriptionPurchase = MessageType(25);
  static const interactionPremiumUpsell = MessageType(26);
  static const stageStart = MessageType(27);
  static const stageEnd = MessageType(28);
  static const stageSpeaker = MessageType(29);
  static const stageTopic = MessageType(31);
  static const guildApplicationPremiumSubscription = MessageType(32);
  static const guildIncidentAlertModeEnabled = MessageType(36);
  static const guildIncidentAlertModeDisabled = MessageType(37);
  static const guildIncidentReportRaid = MessageType(38);
  static const guildIncidentReportFalseAlarm = MessageType(39);
  static const purchaseNotification = MessageType(44);

  /// @nodoc
  const MessageType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  MessageType.parse(int value) : this(value);
}

/// Flags that can be applied to a [Message].
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-object-message-flags
class MessageFlags extends Flags<MessageFlags> {
  /// This message has been published to subscribed channels (via Channel Following).
  static const crossposted = Flag<MessageFlags>.fromOffset(0);

  /// This message originated from a message in another channel (via Channel Following).
  static const isCrosspost = Flag<MessageFlags>.fromOffset(1);

  /// Do not include any embeds when serializing this message.
  static const suppressEmbeds = Flag<MessageFlags>.fromOffset(2);

  /// The source message for this crosspost has been deleted (via Channel Following).
  static const sourceMessageDeleted = Flag<MessageFlags>.fromOffset(3);

  /// This message came from the urgent message system.
  static const urgent = Flag<MessageFlags>.fromOffset(4);

  /// This message has an associated thread, with the same id as the message.
  static const hasThread = Flag<MessageFlags>.fromOffset(5);

  /// This message is only visible to the user who invoked the Interaction.
  static const ephemeral = Flag<MessageFlags>.fromOffset(6);

  /// This message is an Interaction Response and the bot is "thinking".
  static const loading = Flag<MessageFlags>.fromOffset(7);

  /// This message failed to mention some roles and add their members to the thread.
  static const failedToMentionSomeRolesInThread = Flag<MessageFlags>.fromOffset(8);

  /// This message will not trigger push and desktop notifications.
  static const suppressNotifications = Flag<MessageFlags>.fromOffset(12);

  /// This message is a voice message.
  static const isVoiceMessage = Flag<MessageFlags>.fromOffset(13);

  /// Whether this set of flags has the [crossposted] flag set.
  bool get wasCrossposted => has(crossposted);

  /// Whether this set of flags has the [isCrosspost] flag set.
  bool get isACrosspost => has(isCrosspost);

  /// Whether this set of flags has the [suppressEmbeds] flag set.
  bool get suppressesEmbeds => has(suppressEmbeds);

  /// Whether this set of flags has the [sourceMessageDeleted] flag set.
  bool get sourceMessageWasDeleted => has(sourceMessageDeleted);

  /// Whether this set of flags has the [urgent] flag set.
  bool get isUrgent => has(urgent);

  /// Whether this set of flags has the [hasThread] flag set.
  bool get hasAThread => has(hasThread);

  /// Whether this set of flags has the [ephemeral] flag set.
  bool get isEphemeral => has(ephemeral);

  /// Whether this set of flags has the [loading] flag set.
  bool get isLoading => has(loading);

  /// Whether this set of flags has the [failedToMentionSomeRolesInThread] flag set.
  bool get didFailToMentionSomeRolesInThread => has(failedToMentionSomeRolesInThread);

  /// Whether this set of flags has the [suppressNotifications] flag set.
  bool get suppressesNotifications => has(suppressNotifications);

  /// Whether this set of flags has the [isVoiceMessage] flag set.
  bool get isAVoiceMessage => has(isVoiceMessage);

  /// Create a new [MessageFlags].
  const MessageFlags(super.value);
}

@Deprecated('Use MessageInteractionMetadata')

/// {@template message_interaction}
/// Information about an interaction associated with a message.
/// {@endtemplate}
class MessageInteraction with ToStringHelper {
  /// The ID of the interaction.
  final Snowflake id;

  /// The type of the interaction.
  final InteractionType type;

  /// The name of the command.
  final String name;

  /// The user that triggered the interaction.
  final User user;

  /// The member that triggered the interaction.
  final PartialMember? member;

  /// {@macro message_interaction}
  /// @nodoc
  MessageInteraction({
    required this.id,
    required this.type,
    required this.name,
    required this.user,
    required this.member,
  });
}

/// {@template message_interaction_metadata}
/// Metadata about the interaction, including the source of the interaction and relevant server and user IDs.
/// {@endtemplate}
class MessageInteractionMetadata with ToStringHelper {
  /// The ID of the interaction.
  final Snowflake id;

  /// The type of the interaction.
  final InteractionType type;

  /// ID of the user that triggered the interaction.
  final Snowflake userId;

  /// The user that triggered the interaction.
  final User user;

  /// IDs for installation context(s) related to an interaction.
  final Map<ApplicationIntegrationType, Snowflake> authorizingIntegrationOwners;

  /// ID of the original response message, present only on follow-up messages.
  final Snowflake? originalResponseMessageId;

  /// ID of the message that contained interactive component, present only on messages created from component interactions.
  final Snowflake? interactedMessageId;

  /// Metadata for the interaction that was used to open the modal, present only on modal submit interactions
  final MessageInteractionMetadata? triggeringInteractionMetadata;

  /// {@macro message_interaction_metadata}
  /// @nodoc
  MessageInteractionMetadata({
    required this.id,
    required this.type,
    required this.userId,
    required this.user,
    required this.authorizingIntegrationOwners,
    required this.originalResponseMessageId,
    required this.interactedMessageId,
    required this.triggeringInteractionMetadata,
  });
}

class MessageSnapshot {
  /// The forwarded message.
  final ForwardedMessage message;

  MessageSnapshot({required this.message});
}

// No id provided, apparently.
/// A message that was forwarded from another channel.
class ForwardedMessage {
  /// The type of this message.
  final MessageType type;

  /// The content of the message.
  ///
  /// {@macro message_content_intent_required}
  final String content;

  /// A list of embeds in this message.
  ///
  /// {@macro message_content_intent_required}
  final List<Embed> embeds;

  /// A list of files attached to this message.
  ///
  /// {@macro message_content_intent_required}
  final List<Attachment> attachments;

  /// The time when this message was sent.
  final DateTime timestamp;

  /// The time when this message was last edited, or `null` if the message was never edited.
  final DateTime? editedTimestamp;

  /// Any flags applied to this message.
  final MessageFlags flags;

  /// A list of users specifically mentioned in this message.
  final List<User> mentions;

  // Cannot provide roleMentions as we (still) do not have access to the guild.

  ForwardedMessage({
    required this.type,
    required this.content,
    required this.embeds,
    required this.attachments,
    required this.timestamp,
    required this.editedTimestamp,
    required this.flags,
    required this.mentions,
  });
}
