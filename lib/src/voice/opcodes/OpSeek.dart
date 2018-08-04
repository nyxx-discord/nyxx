part of nyxx.voice;

/// Opcode for seeking music
class _OpSeek {
  String _op = "seek";
  Guild _guild;
  int _seek;

  _OpSeek(this._guild, this._seek);

  Map<String, dynamic> build() {
    return {
      "op": _op,
      "posistion": _seek,
      "guildId": _guild.id.toString()
    };
  }
}