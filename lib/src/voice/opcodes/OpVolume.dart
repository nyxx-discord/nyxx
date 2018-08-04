part of nyxx.voice;

class OpVolume {
  String op = "volume";
  Guild guild;
  int volume;

  OpVolume(this.guild, this.volume);

  Map<String, dynamic> build() {
    return {
      "op": op,
      "volume": volume,
      "guildId": guild.id.toString()
    };
  }
}
