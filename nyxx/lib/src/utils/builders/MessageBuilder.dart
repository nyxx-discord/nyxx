part of nyxx;

/// Message builder for editing messages.
class MessageEditBuilder {
  /// Clear character which can be used to skip first line in message body or sanitize message content
  static const clearCharacter = "‎";

  /// Embed to include in message
  EmbedBuilder? embed;

  /// [AllowedMentions] object to control mentions in message
  AllowedMentions? allowedMentions;

  final _content = StringBuffer();

  /// Clears current content of message and sets new
  set content(Object content) {
    _content.clear();
    _content.write(content);
  }

  /// Returns current content of message
  String get content => _content.toString();

  /// Allows to add embed to message
  void setEmbed(void Function(EmbedBuilder embed) builder) {
    this.embed = EmbedBuilder();
    builder(embed!);
  }

  /// Appends clear character. Can be used to skip first line in message body.
  void appendClearCharacter() => _content.writeln(clearCharacter);

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
}

/// Allows to create pre built custom messages which can be passed to classes which inherits from [ISend].
class MessageBuilder extends MessageEditBuilder {
  /// Set to true if message should be TTS
  bool? tts;

  /// List of files to send with message
  List<AttachmentBuilder>? files;

  /// Add attachment
  void addAttachment(AttachmentBuilder attachment) {
    if (this.files == null) this.files = [];

    this.files!.add(attachment);
  }

  /// Add attachment from specified file
  void addFileAttachment(File file, {String? name, bool spoiler = false}) {
    addAttachment(AttachmentBuilder.file(file, name: name, spoiler: spoiler));
  }

  /// Add attachment from specified bytes
  void addBytesAttachment(List<int> bytes, String name, {bool spoiler = false}) {
    addAttachment(AttachmentBuilder.bytes(bytes, name, spoiler: spoiler));
  }

  /// Add attachment at specified path
  void addPathAttachment(String path, {String? name, bool spoiler = false}) {
    addAttachment(AttachmentBuilder.path(path, name: name, spoiler: spoiler));
  }

  /// Sends message
  Future<Message?> send(ISend entity) => entity.sendMessage(builder: this);
}

/// Specifies formatting of String appended with [MessageBuilder]
class MessageDecoration extends IEnum<String> {
  /// Italic text is surrounded with `*`
  static const MessageDecoration italics = MessageDecoration._new("*");

  /// Bold text is surrounded with `**`
  static const MessageDecoration bold = MessageDecoration._new("**");

  /// Spoiler text is surrounded with `||`. In discord client will render as clickable box to reveal text.
  static const MessageDecoration spoiler = MessageDecoration._new("||");

  /// Strike text is surrounded with `~~`
  static const MessageDecoration strike = MessageDecoration._new("~~");

  /// Inline code text is surrounded with ```
  static const MessageDecoration codeSimple = MessageDecoration._new("`");

  /// Multiline code block is surrounded with `````
  static const MessageDecoration codeLong = MessageDecoration._new("```");

  /// Underlined text is surrounded with `__`
  static const MessageDecoration underline = MessageDecoration._new("__");

  const MessageDecoration._new(String value) : super(value);

  @override
  String toString() => _value;

  /// Creates formatted string
  String format(Object text) => "$_value$text$_value";
}
