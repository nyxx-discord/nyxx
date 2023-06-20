import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/invite/invite.dart';
import 'package:nyxx/src/models/invite/invite_metadata.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// {@template invite_create_event}
/// Emitted when an invite is created.
/// {@endtemplate}
class InviteCreateEvent extends DispatchEvent {
  /// The invite that was created.
  final Invite invite;

  /// Extra metadata about the invite.
  final InviteMetadata metadata;

  /// {@macro invite_create_event}
  InviteCreateEvent({required this.invite, required this.metadata});
}

/// {@template invite_delete_event}
/// Emitted when an invite is deleted.
/// {@endtemplate}
class InviteDeleteEvent extends DispatchEvent {
  /// The ID of the channel the invite was for.
  final Snowflake channelId;

  /// The ID of the guild the invite was for.
  final Snowflake? guildId;

  /// The code of the invite.
  final String code;

  /// {@macro invite_delete_event}
  InviteDeleteEvent({required this.channelId, required this.guildId, required this.code});
}
