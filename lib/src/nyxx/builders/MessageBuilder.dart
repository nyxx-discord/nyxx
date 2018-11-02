part of nyxx;

class MessageBuilder {
  String _content = "";

  set content(Object content) => _content = content.toString();
  EmbedBuilder embed;
  bool tts;
  List<File> files;
  bool disableEveryone;

  void setEmbed(void builder(EmbedBuilder embed)) {
    this.embed = EmbedBuilder();
    builder(embed);
  }

  void append(String text) => _content += text;
}
