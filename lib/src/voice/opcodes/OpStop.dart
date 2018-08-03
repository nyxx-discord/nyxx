part of nyxx.voice;

class OpStop {
  String op = "stop";
  Guild guild;

  OpStop(this.guild);

  Map<String, dynamic> build() {
    return {
      "op": op,
      "guildId": guild.id.toString()
    };
  }
}