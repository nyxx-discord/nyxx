part of nyxx.voice;

/// Discord gateway opcode for sending voice state
class _Opcode4 {
  bool _deaf;
  bool _mute;
  Guild _guild;
  VoiceChannel _channel;

  _Opcode4(this._guild, this._channel, this._mute, this._deaf);

  Map<String, dynamic> _build() {
    return <String, dynamic>{
      "guild_id": _guild.id.toString(),
      "channel_id": _channel == null ? null : _channel.id.toString(),
      "self_mute": _mute,
      "self_deaf": _deaf
    };
  }
}
