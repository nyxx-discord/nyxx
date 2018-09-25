part of nyxx.lavalink;

/// Base for simple opcodes
class _SimpleOp {
  String _op;
  Guild _guild;

  _SimpleOp(this._op, this._guild);

  Map<String, dynamic> _build() {
    return {"op": _op, "guildId": _guild.id.toString()};
  }
}
