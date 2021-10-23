part of nyxx;

/// Allows to create pre built custom messages which can be passed to classes which inherits from [ISend].
class MessageBuilder extends BuilderWithClient {
  /// Clear character which can be used to skip first line in message body or sanitize message content
  static const clearCharacter = "‎";

  /// Set to true if message should be TTS
  bool? tts;

  /// List of files to send with message
  List<AttachmentBuilder>? files;

  /// Allows to create message that replies to another message
  ReplyBuilder? replyBuilder;

  /// Embed to include in message
  List<EmbedBuilder> embeds = [];

  /// [AllowedMentions] object to control mentions in message
  AllowedMentions? allowedMentions;

  /// A nonce that can be used for optimistic message sending (up to 25 characters)
  /// You will be able to identify that message when receiving it through gateway
  String? nonce;

  final _content = StringBuffer();

  /// Clears current content of message and sets new
  set content(Object content) {
    _content.clear();
    _content.write(content);
  }

  /// Returns current content of message
  String get content => _content.toString();

  /// Generic constructor for [MessageBuilder]
  MessageBuilder();

  /// Creates [MessageBuilder] with only content
  factory MessageBuilder.content(String content) =>
      MessageBuilder()
        ..content = content;

  /// Creates [MessageBuilder] with content of empty character
  factory MessageBuilder.empty() =>
      MessageBuilder()
        ..appendClearCharacter();

  /// Creates [MessageBuilder] with only embed
  factory MessageBuilder.embed(EmbedBuilder embed) =>
      MessageBuilder()
        ..embeds = [embed];

  /// Creates [MessageBuilder] with only specified files
  factory MessageBuilder.files(List<AttachmentBuilder> files) =>
      MessageBuilder()
        ..files = files;

  /// Creates [MessageBuilder] from [Message].
  /// Copies content, tts and first embed of target [message]
  factory MessageBuilder.fromMessage(Message message) => MessageBuilder()
        ..content = message.content
        ..tts = message.tts
        ..embeds = message.embeds.map((e) => e.toBuilder()).toList()
        ..replyBuilder = message.referencedMessage?.toBuilder();

  /// Allows to add embed to message
  void addEmbed(void Function(EmbedBuilder embed) builder) {
    final e = EmbedBuilder();
    builder(e);
    this.embeds.add(e);
  }

  /// Appends clear character. Can be used to skip first line in message body.
  void appendClearCharacter() => _content.writeln(clearCharacter);

  /// Appends empty line to message
  void appendNewLine() => _content.writeln();

  /// Allows to append
  void append(Object text) => _content.write(text);

  /// Appends spoiler to message
  void appendSpoiler(Object text) =>
      appendWithDecoration(text, MessageDecoration.spoiler);

  /// Appends italic text to message
  void appendItalics(Object text) =>
      appendWithDecoration(text, MessageDecoration.italics);

  /// Appends bold text to message
  void appendBold(Object text) =>
      appendWithDecoration(text, MessageDecoration.bold);

  /// Appends strikeout text to message
  void appendStrike(Object text) =>
      appendWithDecoration(text, MessageDecoration.strike);

  /// Appends simple code to message
  void appendCodeSimple(Object text) =>
      appendWithDecoration(text, MessageDecoration.codeSimple);

  /// Appends code block to message
  void appendCode(Object language, Object code) =>
      appendWithDecoration("$language\n$code", MessageDecoration.codeLong);

  /// Appends formatted text to message
  void appendWithDecoration(Object text, MessageDecoration decoration) {
    _content.write("$decoration$text$decoration");
  }

  /// Appends [Mentionable] object to message
  void appendMention(Mentionable mentionable) =>
      this.append(mentionable.mention);

  /// Appends timestamp to message from [dateTime]
  void appendTimestamp(DateTime dateTime, {TimeStampStyle style = TimeStampStyle.def}) =>
      this.append(style.format(dateTime));

  /// Add attachment
  void addAttachment(AttachmentBuilder attachment) {
    if (this.files == null) {
      this.files = [];
    }

    this.files!.add(attachment);
  }

  /// Add attachment from specified file
  void addFileAttachment(File file, {String? name, bool spoiler = false}) {
    addAttachment(AttachmentBuilder.file(file, name: name, spoiler: spoiler));
  }

  /// Add attachment from specified bytes
  void addBytesAttachment(List<int> bytes, String name,
      {bool spoiler = false}) {
    addAttachment(AttachmentBuilder.bytes(bytes, name, spoiler: spoiler));
  }

  /// Add attachment at specified path
  void addPathAttachment(String path, {String? name, bool spoiler = false}) {
    addAttachment(AttachmentBuilder.path(path, name: name, spoiler: spoiler));
  }

  /// Sends message
  Future<Message> send(ISend entity) => entity.sendMessage(this);

  /// Returns if this instance of message builder can be used when editing message
  bool canBeUsedAsNewMessage() =>
      this.content.isNotEmpty || embeds.isNotEmpty || (this.files != null && this.files!.isNotEmpty);

  @override
  RawApiMap build(INyxx client) {
    allowedMentions ??= client._options.allowedMentions;

    return <String, dynamic>{
      if (content.isNotEmpty) "content": content.toString(),
      if (embeds.isNotEmpty) "embeds": [for (final e in embeds) e.build()],
      if (allowedMentions != null) "allowed_mentions": allowedMentions!.build(),
      if (replyBuilder != null) "message_reference": replyBuilder!.build(),
      if (tts != null) "tts": tts,
      if (nonce != null) "nonce": nonce
    };
  }

  bool hasFiles() => this.files != null && this.files!.isNotEmpty;
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
  String toString() => value;

  /// Creates formatted string
  String format(String text) => "$value$text$value";
}
