import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template voice_state}
/// A user's voice connection state.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/voice#voice-state-object
/// {@endtemplate}
class VoiceState with ToStringHelper {
  /// The ID of the guild this state is in.
  final Snowflake? guildId;

  /// The ID of the channel the user is connected to.
  final Snowflake? channelId;

  /// The ID of the user this state is for.
  final Snowflake userId;

  final Member? member;

  /// This state's session ID.
  final String sessionId;

  /// Whether the user is deafened by the server.
  final bool isServerDeafened;

  /// Whether the user is muted by the server.
  final bool isServerMuted;

  /// Whether the user has deafened themselves.
  final bool isSelfDeafened;

  /// Whether the used has muted themselves.
  final bool isSelfMuted;

  /// Whether the user is streaming.
  final bool isStreaming;

  /// Whether the user's camera is enabled.
  final bool isVideoEnabled;

  /// Whether the user is not permitted to speak.
  final bool isSuppressed;

  /// The timestamp at which this user requested to speak.
  final DateTime? requestedToSpeakAt;

  /// {@macro voice_state}
  VoiceState({
    required this.guildId,
    required this.channelId,
    required this.userId,
    required this.member,
    required this.sessionId,
    required this.isServerDeafened,
    required this.isServerMuted,
    required this.isSelfDeafened,
    required this.isSelfMuted,
    required this.isStreaming,
    required this.isVideoEnabled,
    required this.isSuppressed,
    required this.requestedToSpeakAt,
  });

  /// Whether this user is deafened.
  bool get isDeafened => isServerDeafened || isSelfDeafened;

  /// Whether this user is muted.
  bool get isMuted => isServerMuted || isSelfMuted;
}
