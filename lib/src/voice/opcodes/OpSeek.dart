part of nyxx.voice;

class OpSeek {
  String op = "seek";
  Guild guild;
  int seek;

  OpSeek(this.guild, this.seek);

  Map<String, dynamic> build() {
    return {
      "op": op,
      "posistion": seek,
      "guildId": guild.id.toString()
    };
  }
}