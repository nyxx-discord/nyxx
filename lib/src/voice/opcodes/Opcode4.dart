part of nyxx.voice;

class Opcode4 {
  bool deaf;
  bool mute;
  Guild guild;
  VoiceChannel channel;

  Opcode4(this.guild, this.channel, this.mute, this.deaf);

  Map<String, dynamic> _build() {
    return <String, dynamic> {
      "guild_id": guild.id.toString(),
      "channel_id": channel == null ? null : channel.id.toString(),
      "self_mute": mute,
      "self_deaf": deaf
    };
  }
}