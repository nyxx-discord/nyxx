part of nyxx.lavalink;

/// Opcode for volume
class _OpVolume {
  String _op = "volume";
  Guild _guild;
  int _volume;

  _OpVolume(this._guild, this._volume);

  Map<String, dynamic> build() {
    return {"op": _op, "volume": _volume, "guildId": _guild.id.toString()};
  }
}
