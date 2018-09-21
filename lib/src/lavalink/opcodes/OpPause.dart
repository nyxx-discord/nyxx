part of nyxx.voice;

/// Opcode for pausing playback
class _OpPause {
  String _op = "pause";
  Guild _guild;
  bool _pause;

  _OpPause(this._guild, this._pause);

  Map<String, dynamic> build() {
    return {"op": _op, "guildId": _guild.id.toString(), "pause": _pause};
  }
}
