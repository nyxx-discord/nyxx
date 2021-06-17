part of nyxx_lavalink;

/// A player of a specific guild
class GuildPlayer {
  /// Track queue
  List<QueuedTrack> queue = [];
  /// The currently playing track
  QueuedTrack? nowPlaying;
  /// Guild where this player operates on
  Snowflake guildId;

  /// A map to combine server state and server update events to send them to lavalink
  final Map<String, dynamic> _serverUpdate = {};
  /// A reference to the parent node
  final Node _nodeRef;

  GuildPlayer._new(this._nodeRef, this.guildId);

  void _dispatchVoiceUpdate() {
    if(_serverUpdate.containsKey("sessionId") && _serverUpdate.containsKey("event")) {
      _nodeRef._sendPayload("voiceUpdate", this.guildId, _serverUpdate);
    }
  }

  void _handleServerUpdate(VoiceServerUpdateEvent event) {
    this._serverUpdate["event"] = {
      "token": event.token,
      "endpoint": event.endpoint,
      "guildId": this.guildId.toString()
    };

    _dispatchVoiceUpdate();
  }
  void _handleStateUpdate(VoiceStateUpdateEvent event) {
    this._serverUpdate["sessionId"] = event.state.sessionId;

    _dispatchVoiceUpdate();
  }
}
