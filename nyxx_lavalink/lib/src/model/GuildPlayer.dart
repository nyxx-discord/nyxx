part of nyxx_lavalink;

class GuildPlayer {
  /// Track queue
  List<QueuedTrack> queue = [];
  /// Now playing track
  QueuedTrack? nowPlaying;
  final Node _nodeRef;
  /// Guild where this player operates on
  Snowflake guildId;

  final Map<String, dynamic> _serverUpdate = {};

  GuildPlayer._new(this._nodeRef, this.guildId);

  void _dispatchVoiceUpdate() {
    if(_serverUpdate.containsKey("sessionId") && _serverUpdate.containsKey("event")) {
      _nodeRef._sendPayload("voiceUpdate", this.guildId, _serverUpdate);

      _serverUpdate.clear();
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