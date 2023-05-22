import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/voice/voice_region.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A manager for [VoiceState]s.
class VoiceManager {
  /// The client this manager belongs to.
  final NyxxRest client;

  /// Create a new [VoiceManager].
  VoiceManager(this.client);

  /// Parse a [VoiceState] from a [Map].
  VoiceState parseVoiceState(Map<String, Object?> raw) {
    return VoiceState(
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      channelId: maybeParse(raw['channel_id'], Snowflake.parse),
      userId: Snowflake.parse(raw['user_id'] as String),
      sessionId: raw['session_id'] as String,
      isServerDeafened: raw['deaf'] as bool,
      isServerMuted: raw['mute'] as bool,
      isSelfDeafened: raw['self_deaf'] as bool,
      isSelfMuted: raw['self_mute'] as bool,
      isStreaming: raw['self_stream'] as bool? ?? false,
      isVideoEnabled: raw['self_video'] as bool,
      isSuppressed: raw['suppress'] as bool,
      requestedToSpeakAt: maybeParse(raw['request_to_speak_timestamp'], DateTime.parse),
    );
  }

  /// Parse a [VoiceRegion] from a [Map].
  VoiceRegion parseVoiceRegion(Map<String, Object?> raw) {
    return VoiceRegion(
      id: raw['id'] as String,
      name: raw['name'] as String,
      isOptimal: raw['optimal'] as bool,
      isDeprecated: raw['deprecated'] as bool,
      isCustom: raw['custom'] as bool,
    );
  }

  /// List all the available voice regions.
  Future<List<VoiceRegion>> listRegions() async {
    final route = HttpRoute()
      ..voice()
      ..regions();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List, parseVoiceRegion);
  }
}