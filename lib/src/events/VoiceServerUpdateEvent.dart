part of nyxx;

/// Emitted when guild's voice server changes
class VoiceServerUpdateEvent {
  String token;
  Guild guild;
  String endpoint;

  VoiceServerUpdateEvent._new(Client client, Map<String, dynamic> json) {
    this.token = json['d']['token'];
    this.guild = client.guilds[json['d']['guild_id']];
    this.endpoint = json['d']['endpoint'];

    client._events.onVoiceServerUpdate.add(this);
  }
}
