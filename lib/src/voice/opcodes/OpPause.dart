part of nyxx.voice;

class OpPause {
  String op = "pause";
  Guild guild;

  OpPause(this.guild);

  Map<String, dynamic> build() {
    return {
      "op": op,
      "guildId": guild.id.toString()
    };
  }
}