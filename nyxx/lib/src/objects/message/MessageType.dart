part of nyxx;

class MessageType {
  // TODO: rename Default
  static const MessageType Default = const MessageType._create(0);
  static const MessageType recipientAdd = const MessageType._create(1);
  static const MessageType recipientRemove = const MessageType._create(2);
  static const MessageType call = const MessageType._create(3);
  static const MessageType channelNameChange = const MessageType._create(4);
  static const MessageType channelIconChange = const MessageType._create(5);
  static const MessageType channelPinnedMessage = const MessageType._create(6);
  static const MessageType guildMemberJoin = const MessageType._create(7);
  static const MessageType userPremiumGuildSubscription = const MessageType._create(8);
  static const MessageType userPremiumGuildSubscriptionTier1 = const MessageType._create(9);
  static const MessageType userPremiumGuildSubscriptionTier2 = const MessageType._create(10);
  static const MessageType userPremiumGuildSubscriptionTier3 = const MessageType._create(11);
  static const MessageType channelFollowAdd = const MessageType._create(12);
  static const MessageType guildDiscoveryDisqualified = const MessageType._create(14);
  static const MessageType guildStream = const MessageType._create(13);
  static const MessageType guildDiscoveryRequalified =const MessageType._create(15);

  final int _value;

  const MessageType._create(int? value) : _value = value ?? 0;
  MessageType.from(int? value) : _value = value ?? 0;

  @override
  String toString() => _value.toString();

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) {
  if (other is MessageType || other is int)
    return other == _value;

  return false;
  }
}