import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

class GroupDmChannel extends Channel implements TextChannel {
  @override
  late final MessageManager messages = MessageManager(manager.client.options.messageCacheConfig, manager.client, channelId: id);

  final String name;

  final List<User> recipients;

  final String? iconHash;

  final Snowflake ownerId;

  final Snowflake? applicationId;

  final bool isManaged;

  @override
  final Snowflake? lastMessageId;

  @override
  final DateTime? lastPinTimestamp;

  @override
  final Duration? rateLimitPerUser;

  @override
  ChannelType get type => ChannelType.groupDm;

  GroupDmChannel({
    required super.id,
    required super.manager,
    required this.name,
    required this.recipients,
    required this.iconHash,
    required this.ownerId,
    required this.applicationId,
    required this.isManaged,
    required this.lastMessageId,
    required this.lastPinTimestamp,
    required this.rateLimitPerUser,
  });

  @override
  Future<Message> sendMessage(MessageBuilder builder) => messages.create(builder);

  @override
  Future<void> triggerTyping() => manager.triggerTyping(id);
}
