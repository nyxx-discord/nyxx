import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/presence.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

// TODO: Docs say everything is optional, but is it really?
// Pre-6.0.0 nyxx had everything non-nullable and we never had any issues.
class PresenceUpdateEvent extends DispatchEvent {
  final PartialUser? user;

  final Snowflake? guildId;

  final UserStatus? status;

  final List<Activity>? activities;

  final ClientStatus? clientStatus;

  PresenceUpdateEvent({
    required this.user,
    required this.guildId,
    required this.status,
    required this.activities,
    required this.clientStatus,
  });
}

class TypingStartEvent extends DispatchEvent {
  final Snowflake channelId;

  final Snowflake? guildId;

  final Snowflake userId;

  final DateTime timestamp;

  final Member? member;

  TypingStartEvent({
    required this.channelId,
    required this.guildId,
    required this.userId,
    required this.timestamp,
    required this.member,
  });
}

class UserUpdateEvent extends DispatchEvent {
  final User user;

  UserUpdateEvent({required this.user});
}
