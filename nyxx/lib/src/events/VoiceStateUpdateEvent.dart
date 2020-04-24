part of nyxx;

/// Emitted when client connects/disconnects/mutes etc to voice channel
class VoiceStateUpdateEvent {
  /// Used to represent a user's voice connection status.
  late final VoiceState state;

  /// Raw gateway response
  Map<String, dynamic> raw;

  VoiceStateUpdateEvent._new(this.raw, Nyxx client) {
    this.state = VoiceState._new(raw['d'] as Map<String, dynamic>, client);

    if (state.user == null) {
      return;
    }

    if (state.channel != null) {
      state.guild!.voiceStates[state.user!.id] = state;
    } else {
      state.guild!.voiceStates.remove(state.user!.id);
    }
  }
}
