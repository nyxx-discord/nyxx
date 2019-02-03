part of nyxx;

/// Allows to create pre built custom messages which can be passed to classes which inherits from [ISend].
class MessageBuilder {
  StringBuffer _content = StringBuffer();
  EmbedBuilder embed;
  bool tts;
  List<AttachmentBuilder> files;
  bool disableEveryone;

  set content(Object content) {
    _content.clear();
    _content.write(content);
  }

  /// Allows to add embed to message
  void setEmbed(void builder(EmbedBuilder embed)) {
    this.embed = EmbedBuilder();
    builder(embed);
  }

  /// Allows to append
  void append(Object text) => _content.write(text);
}
