import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/voice/voice_state.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IVoiceStateUpdateEvent {
  /// Used to represent a user's voice connection status.
  IVoiceState get state;

  /// The previous voice state, if it was cached.
  IVoiceState? get oldState;

  /// Raw gateway response
  RawApiMap get raw;
}

/// Emitted when client connects/disconnects/mutes etc to voice channel
class VoiceStateUpdateEvent implements IVoiceStateUpdateEvent {
  /// Used to represent a user's voice connection status.
  @override
  late final IVoiceState state;

  @override
  late final IVoiceState? oldState;

  /// Raw gateway response
  @override
  final RawApiMap raw;

  /// Creates an instance of [VoiceStateUpdateEvent]
  VoiceStateUpdateEvent(this.raw, INyxx client) {
    state = VoiceState(client, raw["d"] as RawApiMap);

    oldState = state.guild?.getFromCache()?.voiceStates[state.user.id];

    if (state.channel != null) {
      state.guild?.getFromCache()?.voiceStates[state.user.id] = state;
    } else {
      state.guild?.getFromCache()?.voiceStates.remove(state.user.id);
    }
  }
}
