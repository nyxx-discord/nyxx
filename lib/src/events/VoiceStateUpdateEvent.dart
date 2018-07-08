part of nyxx;

/// Emmited when client connects/disconnecs/mutes etc to voice channel
class VoiceStateUpdateEvent {
  /// Voices state
  VoiceState state;

  VoiceStateUpdateEvent._new(Client client, Map<String, dynamic> json) {
    state = new VoiceState._new(client, json['d']);

    client._events.onVoiceStateUpdate.add(this);
  }
}
