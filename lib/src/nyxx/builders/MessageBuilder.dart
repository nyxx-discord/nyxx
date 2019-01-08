part of nyxx;

class MessageBuilder {
  Object _content = "";
  EmbedBuilder embed;
  bool tts;
  List<File> files;
  bool disableEveryone;

  void setEmbed(void builder(EmbedBuilder embed)) {
    this.embed = EmbedBuilder();
    builder(embed);
  }

  void append(String text) => _content = "$_content$text";
}
