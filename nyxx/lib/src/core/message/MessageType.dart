part of nyxx;

class MessageType extends IEnum<int> {
  static const MessageType Default = MessageType._create(0);
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

  const MessageType._create(int? value) : super(value ?? 0);
  MessageType.from(int? value) : super(value ?? 0);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == _value;
    }

    return super == other;
  }
}
