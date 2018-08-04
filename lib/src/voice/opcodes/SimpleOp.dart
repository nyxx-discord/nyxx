part of nyxx.voice;

class SimpleOp {
  String op;
  Guild guild;

  SimpleOp(this.op, this.guild);

  Map<String, dynamic> build() {
    return {
      "op": op,
      "guildId": guild.id.toString()
    };
  }
}