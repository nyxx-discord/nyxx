import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

class PartialDmChannel extends PartialTextChannel {
  PartialDmChannel({required super.id, required super.manager});
}

class DmChannel extends PartialDmChannel implements TextChannel {
  final User recipient;

  @override
  final Snowflake? lastMessageId;

  @override
  final DateTime? lastPinTimestamp;

  @override
  final Duration? rateLimitPerUser;

  @override
  ChannelType get type => ChannelType.dm;

  DmChannel({
    required super.id,
    required super.manager,
    required this.recipient,
    required this.lastMessageId,
    required this.lastPinTimestamp,
    required this.rateLimitPerUser,
  });
}
