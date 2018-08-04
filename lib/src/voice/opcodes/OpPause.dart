part of nyxx.voice;

class OpPause {
  String op = "pause";
  Guild guild;
  bool pause;

  OpPause(this.guild, this.pause);

  Map<String, dynamic> build() {
    return {
      "op": op,
      "guildId": guild.id.toString(),
      "pause": pause
    };
  }
}