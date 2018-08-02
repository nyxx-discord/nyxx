part of nyxx;

/// Used to represent a user's voice connection status.
class VoiceState {
  /// Channel id user is connected
  VoiceChannel channel;

  /// User this voice state is for
  User user;

  /// Session id for this voice state
  String sessionId;

  /// Whether this user is muted by the server
  bool deaf;

  /// Whether this user is locally deafened
  bool selfDeaf;

  /// Whether this user is locally muted
  bool selfMute;

  /// Whether this user is muted by the current user
  bool suppress;

  /// Raw object returned by API
  Map<String, dynamic> raw;

  VoiceState._new(Client client, this.raw) {
    this.channel = client.channels[raw['channel_id']] as VoiceChannel;
    this.user = client.users[raw['user_id']];
    this.sessionId = raw['session_id'] as String;
    this.deaf = raw['deaf'] as bool;
    this.selfDeaf = raw['self_deaf'] as bool;
    this.selfMute = raw['self_mute'] as bool;
    this.suppress = raw['suppress'] as bool;
  }
}
