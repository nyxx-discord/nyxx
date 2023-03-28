import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/snowflake.dart';

class PartialTextChannel extends PartialChannel {
  late final MessageManager messages = MessageManager(
    manager.client.options.messageCacheConfig,
    manager.client,
    channelId: id,
  );

  PartialTextChannel({required super.id, required super.manager});
}

abstract class TextChannel extends PartialTextChannel implements Channel {
  final Snowflake? lastMessageId;

  final Duration? rateLimitPerUser;

  final DateTime? lastPinTimestamp;

  TextChannel({
    required super.id,
    required super.manager,
    required this.lastMessageId,
    required this.rateLimitPerUser,
    required this.lastPinTimestamp,
  });
}
