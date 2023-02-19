import 'package:nyxx/src/utils/enum.dart';

/// Represents messgae type
class MessageType extends IEnum<int> {
  static const MessageType def = MessageType._create(0);
  static const MessageType recipientAdd = MessageType._create(1);
  static const MessageType recipientRemove = MessageType._create(2);
  static const MessageType call = MessageType._create(3);
  static const MessageType channelNameChange = MessageType._create(4);
  static const MessageType channelIconChange = MessageType._create(5);
  static const MessageType channelPinnedMessage = MessageType._create(6);
  static const MessageType guildMemberJoin = MessageType._create(7);
  static const MessageType userPremiumGuildSubscription = MessageType._create(8);
  static const MessageType userPremiumGuildSubscriptionTier1 = MessageType._create(9);
  static const MessageType userPremiumGuildSubscriptionTier2 = MessageType._create(10);
  static const MessageType userPremiumGuildSubscriptionTier3 = MessageType._create(11);
  static const MessageType channelFollowAdd = MessageType._create(12);
  static const MessageType guildDiscoveryDisqualified = MessageType._create(14);
  static const MessageType guildStream = MessageType._create(13);
  static const MessageType guildDiscoveryRequalified = MessageType._create(15);
  static const MessageType guildDiscoveryGracePeriodInitialWarning = MessageType._create(16);
  static const MessageType guildDiscoveryGracePeriodFinalWarning = MessageType._create(17);
  static const MessageType threadCreated = MessageType._create(18);
  static const MessageType reply = MessageType._create(19);
  static const MessageType chatInputCommand = MessageType._create(20);
  static const MessageType threadStarterMessage = MessageType._create(21);
  static const MessageType guildInviteRemainder = MessageType._create(22);
  static const MessageType contextMenuCommand = MessageType._create(23);
  static const MessageType autoModerationAction = MessageType._create(24);
  static const MessageType roleSubscriptionPurchase = MessageType._create(25);
  static const MessageType interactionPremiumUpsell = MessageType._create(26);
  static const MessageType stageStart = MessageType._create(27);
  static const MessageType stageEnd = MessageType._create(28);
  static const MessageType stageSpeaker = MessageType._create(29);
  static const MessageType stageRaiseHand = MessageType._create(30);
  static const MessageType stageTopic = MessageType._create(31);
  static const MessageType guildApplicationPremiumSubscription = MessageType._create(32);

  /// Creates instance of [MessageType] from [value].
  MessageType.from(int? value) : super(value ?? 0);
  const MessageType._create(int? value) : super(value ?? 0);

  @override
  bool operator ==(dynamic other) {
    if (other is int) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => value.hashCode;
}
