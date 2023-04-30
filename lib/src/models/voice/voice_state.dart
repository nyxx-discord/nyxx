import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class VoiceState with ToStringHelper {
  final Snowflake? guildId;

  final Snowflake? channelId;

  final Snowflake userId;

  // TODO
  //final Member member;

  final String sessionId;

  final bool isServerDeafened;

  final bool isServerMuted;

  final bool isSelfDeafened;

  final bool isSelfMuted;

  final bool isStreaming;

  final bool isVideoEnabled;

  final bool isSuppressed;

  final DateTime? requestedToSpeakAt;

  VoiceState({
    required this.guildId,
    required this.channelId,
    required this.userId,
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

  bool get isDeafened => isServerDeafened || isSelfDeafened;

  bool get isMuted => isServerMuted || isSelfMuted;
}
