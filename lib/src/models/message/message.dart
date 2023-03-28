import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/message/activity.dart';
import 'package:nyxx/src/models/message/attachment.dart';
import 'package:nyxx/src/models/message/channel_mention.dart';
import 'package:nyxx/src/models/message/embed.dart';
import 'package:nyxx/src/models/message/author.dart';
import 'package:nyxx/src/models/message/reference.dart';
import 'package:nyxx/src/models/message/reaction.dart';
import 'package:nyxx/src/models/message/role_subscription_data.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/flags.dart';

class PartialMessage extends SnowflakeEntity<Message> with SnowflakeEntityMixin<Message> {
  @override
  final MessageManager manager;

  Snowflake get channelId => manager.channelId;

  PartialMessage({required super.id, required this.manager});
}

class Message extends PartialMessage {
  final MessageAuthor author;

  final String content;

  final DateTime timestamp;

  final DateTime? editedTimestamp;

  final bool isTts;

  final bool mentionsEveryone;

  final List<User> mentions;

  // TODO
  //final List<Role> roleMentions;

  final List<ChannelMention> channelMentions;

  final List<Attachment> attachments;

  final List<Embed> embeds;

  final List<Reaction> reactions;

  final dynamic /* int | String */ nonce;

  final bool pinned;

  final Snowflake? webhookId;

  final MessageType type;

  final MessageActivity? activity;

  // TODO
  //final PartialApplication? application;

  final Snowflake? applicationId;

  final MessageReference? reference;

  final MessageFlags flags;

  final Message? referencedMessage;

  // TODO: Do we want to include the interaction field?

  final Thread? thread;

  // TODO
  //final List<MessageComponent> components;

  //TODO (the sticker_items field).
  //final List<Sticker>? stickers;

  final int? position;

  final RoleSubscriptionData? roleSubscriptionData;

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
    required this.channelMentions,
    required this.attachments,
    required this.embeds,
    required this.reactions,
    required this.nonce,
    required this.pinned,
    required this.webhookId,
    required this.type,
    required this.activity,
    required this.applicationId,
    required this.reference,
    required this.flags,
    required this.referencedMessage,
    required this.thread,
    required this.position,
    required this.roleSubscriptionData,
  });
}

enum MessageType {
  normal._(0),
  recipientAdd._(1),
  recipientRemove._(2),
  call._(3),
  channelNameChange._(4),
  channelIconChange._(5),
  channelPinnedMessage._(6),
  userJoin._(7),
  guildBoost._(8),
  guildBoostTier1._(9),
  guildBoostTier2._(10),
  guildBoostTier3._(11),
  channelFollowAdd._(12),
  guildDiscoveryDisqualified._(14),
  guildDiscoveryRequalified._(15),
  guildDiscoveryGracePeriodInitialWarning._(16),
  guildDiscoveryGracePeriodFinalWarning._(17),
  threadCreated._(18),
  reply._(19),
  chatInputCommand._(20),
  threadStarterMessage._(21),
  guildInviteReminder._(22),
  contextMenuCommand._(23),
  autoModerationAction._(24),
  roleSubscriptionPurchase._(25),
  interactionPremiumUpsell._(26),
  stageStart._(27),
  stageEnd._(28),
  stageSpeaker._(29),
  stageTopic._(31),
  guildApplicationPremiumSubscription._(32);

  final int value;

  const MessageType._(this.value);

  factory MessageType.parse(int value) => MessageType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown MessageType', value),
      );

  @override
  String toString() => 'MessageType($value)';
}

class MessageFlags extends Flags<MessageFlags> {
  static const crossposted = Flag<MessageFlags>.fromOffset(0);
  static const isCrosspost = Flag<MessageFlags>.fromOffset(1);
  static const suppressEmbeds = Flag<MessageFlags>.fromOffset(2);
  static const sourceMessageDeleted = Flag<MessageFlags>.fromOffset(3);
  static const urgent = Flag<MessageFlags>.fromOffset(4);
  static const hasThread = Flag<MessageFlags>.fromOffset(5);
  static const ephemeral = Flag<MessageFlags>.fromOffset(6);
  static const loading = Flag<MessageFlags>.fromOffset(7);
  static const failedToMentionSomeRolesInThread = Flag<MessageFlags>.fromOffset(8);
  static const suppressNotifications = Flag<MessageFlags>.fromOffset(12);

  bool get wasCrossposted => has(crossposted);
  bool get isACrosspost => has(isCrosspost);
  bool get suppressesEmbeds => has(suppressEmbeds);
  bool get sourceMessageWasDeleted => has(sourceMessageDeleted);
  bool get isUrgent => has(urgent);
  bool get hasAThread => has(hasThread);
  bool get isEphemeral => has(ephemeral);
  bool get isLoading => has(loading);
  bool get didFailToMentionSomeRolesInThread => has(failedToMentionSomeRolesInThread);
  bool get suppressesNotifications => has(suppressNotifications);

  const MessageFlags(super.value);
}
