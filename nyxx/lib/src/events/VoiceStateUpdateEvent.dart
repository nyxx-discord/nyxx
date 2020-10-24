part of nyxx;

/// Emitted when client connects/disconnects/mutes etc to voice channel
class VoiceStateUpdateEvent {
  /// Used to represent a user's voice connection status.
  late final VoiceState state;

  /// Raw gateway response
  Map<String, dynamic> raw;

  VoiceStateUpdateEvent._new(this.raw, Nyxx client) {
    this.state = VoiceState._new(client, raw["d"] as Map<String, dynamic>);

    if (state.channel != null) {
      state.guild?.getFromCache()?.voiceStates[this.state.user.id] = this.state;
    } else {
      state.guild?.getFromCache()?.voiceStates.remove(state.user.id);
    }
  }
}
