part of nyxx;

/// Emitted when client connects/disconnects/mutes etc to voice channel
class VoiceStateUpdateEvent {
  /// Voices state
  VoiceState state;

  // Raw gateway response
  Map<String, dynamic> json;

  VoiceStateUpdateEvent._new(this.json) {
    this.state = VoiceState._new(json['d'] as Map<String, dynamic>);
    if (state.user != null) {
      if (state.channel != null)
        state.guild.voiceStates[state.user.id] = state;
      else {
        state.guild.voiceStates.remove(state.user.id);
      }
    }

    client._events.onVoiceStateUpdate.add(this);
  }
}
