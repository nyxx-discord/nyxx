import 'package:nyxx/src/models/channel/text_channel.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/presence.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

/// {@template presence_update_event}
/// Emitted when a user updates their presence.
/// {@endtemplate}
class PresenceUpdateEvent extends DispatchEvent {
  /// The user that updated their presence.
  final PartialUser? user;

  /// The ID of the guild the presence was updated in.
  final Snowflake? guildId;

  /// The user's current status.
  final UserStatus? status;

  /// The user's current activities.
  final List<Activity>? activities;

  /// The user's current client status.
  final ClientStatus? clientStatus;

  /// {@macro presence_update_event}
  /// @nodoc
  PresenceUpdateEvent({
    required super.gateway,
    required this.user,
    required this.guildId,
    required this.status,
    required this.activities,
    required this.clientStatus,
  });

  /// The guild the presence was updated in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];
}

/// {@template typing_start_event}
/// Emitted when a user starts typing in a channel.
/// {@endtemplate}
class TypingStartEvent extends DispatchEvent {
  /// The ID of the channel.
  final Snowflake channelId;

  /// The ID of the guild the channel is in.
  final Snowflake? guildId;

  /// The ID of the user that started typing.
  final Snowflake userId;

  /// The time at which the user started typing.
  final DateTime timestamp;

  /// The member that started typing.
  final Member? member;

  /// {@macro typing_start_event}
  /// @nodoc
  TypingStartEvent({
    required super.gateway,
    required this.channelId,
    required this.guildId,
    required this.userId,
    required this.timestamp,
    required this.member,
  });

  /// The guild the user started typing in.
  PartialGuild? get guild => guildId == null ? null : gateway.client.guilds[guildId!];

  /// The channel the user started typing in.
  PartialTextChannel get channel => gateway.client.channels[channelId] as PartialTextChannel;

  /// The user that started typing.
  PartialUser get user => gateway.client.users[userId];
}

/// {@template user_update_event}
/// Emitted when a user is updated.
/// {@endtemplate}
class UserUpdateEvent extends DispatchEvent {
  /// The user as it was cached before it was updated.
  final User? oldUser;

  /// The updated user.
  final User user;

  /// {@macro user_update_event}
  /// @nodoc
  UserUpdateEvent({required super.gateway, required this.oldUser, required this.user});
}
