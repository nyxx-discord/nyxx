import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

/// {@template group_dm_channel}
/// A DM channel with multiple recipients.
/// {@endtemplate}
class GroupDmChannel extends TextChannel {
  /// The name of this channel.
  final String name;

  /// The recipients of this channel.
  final List<User> recipients;

  /// The hash of this channel's icon.
  final String? iconHash;

  /// The ID of this channel's owner.
  final Snowflake ownerId;

  /// The ID of the application which created this channel, if it was created by an application.
  final Snowflake? applicationId;

  /// Whether this channel is managed.
  final bool isManaged;

  @override
  final Snowflake? lastMessageId;

  @override
  final DateTime? lastPinTimestamp;

  @override
  final Duration? rateLimitPerUser;

  @override
  ChannelType get type => ChannelType.groupDm;

  /// {@macro group_dm_channel}
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
  PartialMessage? get lastMessage => lastMessageId == null ? null : messages[lastMessageId!];

  /// This channel's owner.
  PartialUser get owner => manager.client.users[ownerId];

  /// The application that created this channel, if it was created by an application.
  PartialApplication? get application => applicationId == null ? null : manager.client.applications[applicationId!];
}
