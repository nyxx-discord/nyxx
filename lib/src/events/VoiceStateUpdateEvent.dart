part of nyxx;

class VoiceStateUpdateEvent {
  VoiceState state;

  VoiceStateUpdateEvent._new(Client client, Map<String, dynamic> json) {
    state = new VoiceState._new(client, json['d']);

    client._events.onVoiceStateUpdate.add(this);
  }
}
