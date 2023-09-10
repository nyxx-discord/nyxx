import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

/// {@template dm_channel}
/// A DM channel.
/// {@endtemplate}
class DmChannel extends TextChannel {
  /// The recipient of this channel.
  final User recipient;

  @override
  final Snowflake? lastMessageId;

  @override
  final DateTime? lastPinTimestamp;

  @override
  final Duration? rateLimitPerUser;

  @override
  ChannelType get type => ChannelType.dm;

  /// {@macro dm_channel}
  DmChannel({
    required super.id,
    required super.manager,
    required this.recipient,
    required this.lastMessageId,
    required this.lastPinTimestamp,
    required this.rateLimitPerUser,
  });

  @override
  PartialMessage? get lastMessage => lastMessageId == null ? null : messages[lastMessageId!];
}
