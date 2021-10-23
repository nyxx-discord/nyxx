part of nyxx;

/// Emitted when client connects/disconnects/mutes etc to voice channel
class VoiceStateUpdateEvent implements IVoiceStateUpdateEvent {
  /// Used to represent a user's voice connection status.
  @override
  late final IVoiceState state;

  /// Raw gateway response
  @override
  final RawApiMap raw;

  /// Creates na instance of [VoiceStateUpdateEvent]
  VoiceStateUpdateEvent(this.raw, INyxx client) {
    this.state = VoiceState(client, raw["d"] as RawApiMap);

    if (state.channel != null) {
      state.guild?.getFromCache()?.voiceStates[this.state.user.id] = this.state;
    } else {
      state.guild?.getFromCache()?.voiceStates.remove(state.user.id);
    }
  }
}
