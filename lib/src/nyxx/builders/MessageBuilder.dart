part of nyxx;

/// Allows to create pre built custom messages which can be passed to classes which inherits from [ISend].
class MessageBuilder {
  StringBuffer _content = StringBuffer();
  EmbedBuilder embed;
  bool tts;
  List<AttachmentBuilder> files;
  bool disableEveryone;

  /// Clear content of message and sste new
  set content(Object content) {
    _content.clear();
    _content.write(content);
  }

  /// Allows to add embed to message
  void setEmbed(void builder(EmbedBuilder embed)) {
    this.embed = EmbedBuilder();
    builder(embed);
  }

  /// Add attachment
  void addAttachment(AttachmentBuilder attachment) {
    if(this.files == null)
      this.files = List();

    this.files.add(attachment);
  }

  /// Add attachment from specified file
  void addFileAttachment(File file, {String name, bool spoiler = false}){
    addAttachment(AttachmentBuilder.file(file, name: name, spoiler: spoiler));
  }

  /// Add attachment from specified bytes
  void addBytesAttachment(List<int> bytes, String name, {bool spoiler = false}) {
    addAttachment(AttachmentBuilder.bytes(bytes, name, spoiler: spoiler));
  }

  /// Add attachment at specified path
  void addPathAttachment(String path, {String name, bool spoiler = false}) {
    addAttachment(AttachmentBuilder.path(path, name: name, spoiler: spoiler));
  }

  /// Appends empty line to message
  void appendNewLine() => _content.writeln();

  /// Allows to append
  void append(Object text) => _content.write(text);

  /// Appends spoiler to message
  void appendSpoiler(Object text) => appendWithDecoration(text, MessageDecoration.spoiler);

  /// Appends italic text to message
  void appendItalics(Object text) => appendWithDecoration(text, MessageDecoration.italics);

  /// Appends bold text to message
  void appendBold(Object text) => appendWithDecoration(text, MessageDecoration.bold);

  /// Appends strikeout text to message
  void appendStrike(Object text) => appendWithDecoration(text, MessageDecoration.strike);

  /// Appends simple code to message
  void appendCodeSimple(Object text) => appendWithDecoration(text, MessageDecoration.codeSimple);

  /// Appends code block to message
  void appendCode(Object language, Object code) => appendWithDecoration("$language\n$code", MessageDecoration.codeLong);

  /// Appends formatted text to message
  void appendWithDecoration(Object text, MessageDecoration decoration) {
    _content.write("$decoration$text$decoration");
  }

  /// Sends message
  Future<Message> send(ISend entity) {
    return entity.send(builder: this);
  }
}

class MessageDecoration {
  static const MessageDecoration italics = const MessageDecoration("*");
  static const MessageDecoration bold = const MessageDecoration("**");
  static const MessageDecoration spoiler = const MessageDecoration("||");
  static const MessageDecoration strike = const MessageDecoration("~~");
  static const MessageDecoration codeSimple = const MessageDecoration("`");
  static const MessageDecoration codeLong = const MessageDecoration("```");
  static const MessageDecoration underline = const MessageDecoration("__");

  final String _value;
  const MessageDecoration(this._value);

  @override
  String toString() => _value;

  @override
  int get hashCode => _value.hashCode;

  /// Creates formatted string
  String create(Object text) => "$_value$text$_value";

  @override
  bool operator ==(other) => (other is String && other == this._value)
      || (other is MessageDecoration && other._value == this._value);

}