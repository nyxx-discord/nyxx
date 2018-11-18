part of nyxx.lavalink;

/// Opcode for pausing playback
class _OpEqualizer {
  String _op = "equalizer";
  Guild _guild;

  Map<num, num> bands;

  _OpEqualizer(this._guild, this.bands);

  Map<String, dynamic> build() {
    List<Map<String, num>> b = List();
    bands.forEach((n1, n2) => b.add({"band": n1, "gain": n2}));

    return {"op": _op, "guildId": _guild.id.toString(), "bands": b};
  }
}