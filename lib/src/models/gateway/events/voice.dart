import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';

class VoiceStateUpdateEvent extends DispatchEvent {
  final VoiceState state;

  VoiceStateUpdateEvent({required this.state});
}

class VoiceServerUpdateEvent extends DispatchEvent {
  final String token;

  final Snowflake guildId;

  final String? endpoint;

  VoiceServerUpdateEvent({required this.token, required this.guildId, required this.endpoint});
}
