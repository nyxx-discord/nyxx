part of nyxx.lavalink;

/// Opcode for intercepting Voice events from discord to lavalink
class _OpVoiceUpdate {
  String _op = "voiceUpdate";
  String _guildId;
  String _sessionId;
  dynamic _event;

  _OpVoiceUpdate(this._guildId, this._sessionId, this._event);

  dynamic build() {
    return {
      "op": _op,
      "guildId": _guildId,
      "sessionId": _sessionId,
      "event": _event['d']
    };
  }
}
