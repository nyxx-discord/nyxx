import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nyxx/src/core/allowed_mentions.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/message/message_time_stamp.dart';
import 'package:nyxx/src/internal/interfaces/send.dart';
import 'package:nyxx/src/internal/interfaces/mentionable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';
import 'package:nyxx/src/utils/enum.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/embed_builder.dart';
import 'package:nyxx/src/utils/builders/reply_builder.dart';

class MessageFlagBuilder implements Builder {
  bool suppressNotifications = false;
  bool suppressEmbeds = false;

  @override
  RawApiMap build() {
    var bitset = 0;

    if (suppressNotifications) {
      bitset |= (1 << 12);
    }

    if (suppressEmbeds) {
      bitset |= (1 << 2);
    }

    return {if (bitset > 0) "flags": bitset};
  }
}

/// Allows to create pre built custom messages which can be passed to classes which inherits from [ISend].
class MessageBuilder {
  /// Clear character which can be used to skip first line in message body or sanitize message content
  static const clearCharacter = "‎";

  /// Set to true if message should be TTS
  bool? tts;

  /// List of files to send with message
  List<AttachmentBuilder>? files;

  /// Allows to create message that replies to another message
  ReplyBuilder? replyBuilder;

  /// Embed to include in message
  List<EmbedBuilder>? embeds;

  /// [AllowedMentions] object to control mentions in message
  AllowedMentions? allowedMentions;

  /// A nonce that can be used for optimistic message sending (up to 25 characters)
  /// You will be able to identify that message when receiving it through gateway
  String? nonce;

  /// List of attachments to send with message
  List<AttachmentMetadataBuilder>? attachments;

  /// Flags to attach to message
  MessageFlagBuilder? flags;

  final _content = StringBuffer();

  /// Clears current content of message and sets new
  set content(Object? content) {
    _content.clear();
    _content.write(content);
  }

  /// Returns current content of message
  String get content => _content.toString();

  /// Generic constructor for [MessageBuilder]
  MessageBuilder({
    String? content = '',
    this.allowedMentions,
    this.attachments,
    this.embeds,
    this.files,
    this.nonce,
    this.replyBuilder,
    this.tts,
  }) {
    this.content = content;
  }

  /// Creates [MessageBuilder] with only content
  factory MessageBuilder.content(String content) => MessageBuilder()..content = content;

  /// Creates [MessageBuilder] with content of empty character
  factory MessageBuilder.empty() => MessageBuilder()..appendClearCharacter();

  /// Creates [MessageBuilder] with only embed
  factory MessageBuilder.embed(EmbedBuilder embed) => MessageBuilder()..embeds = [embed];

  /// Creates [MessageBuilder] with only specified files
  factory MessageBuilder.files(List<AttachmentBuilder> files) => MessageBuilder()..files = files;

  /// Creates [MessageBuilder] from [Message].
  /// Copies content, tts and first embed of target [message]
  factory MessageBuilder.fromMessage(IMessage message) => MessageBuilder()
    ..content = message.content
    ..tts = message.tts
    ..embeds = message.embeds.map((e) => e.toBuilder()).toList()
    ..replyBuilder = message.referencedMessage?.toBuilder();

  /// Allows to add embed to message.
  /// Warning: Completes future synchronously!
  FutureOr<void> addEmbed(FutureOr<void> Function(EmbedBuilder embed) builder) async {
    embeds ??= [];

    final e = EmbedBuilder();
    await builder(e);
    embeds!.add(e);
  }

  /// Appends clear character. Can be used to skip first line in message body.
  void appendClearCharacter() => _content.write(clearCharacter);

  /// Appends empty line to message
  void appendNewLine() => _content.writeln();

  /// Allows to append
  void append(Object text) => _content.write(text);

  /// Appends spoiler to message
  void appendSpoiler(Object text) => appendWithDecoration(text, MessageDecoration.spoiler);

  /// Appends italic text to message
  void appendItalics(Object text) => appendWithDecoration(text, MessageDecoration.italics);

  // TODO: bug: when placed next to italics additional space should be generated
  /// Appends bold text to message
  void appendBold(Object text) => appendWithDecoration(text, MessageDecoration.bold);

  /// Appends strikeout text to message
  void appendStrike(Object text) => appendWithDecoration(text, MessageDecoration.strike);

  /// Appends simple code to message
  void appendCodeSimple(Object text) => appendWithDecoration(text, MessageDecoration.codeSimple);

  /// Appends code block to message
  void appendCode(Object language, Object code) {
    appendNewLine();
    appendWithDecoration("$language\n$code", MessageDecoration.codeLong);
  }

  /// Appends formatted text to message
  void appendWithDecoration(Object text, MessageDecoration decoration) {
    _content.write("$decoration$text$decoration");
  }

  /// Appends [Mentionable] object to message
  void appendMention(Mentionable mentionable) => append(mentionable.mention);

  /// Appends timestamp to message from [dateTime]
  void appendTimestamp(DateTime dateTime, {TimeStampStyle style = TimeStampStyle.def}) => append(style.format(dateTime));

  /// Limits the length of the content of the builder to [length].
  ///
  /// If [content] is shorter than [length], this method does nothing. Else, it truncates content and appends [ellipsis] (if non-null) in a way that the new
  /// content length equals [length].
  void limitLength({int length = 2000, String? ellipsis = '...'}) {
    if (_content.length < length) {
      return;
    }

    ellipsis ??= '';

    final cutContent = content.substring(0, length - ellipsis.length);
    content = cutContent + ellipsis;
  }

  /// Add attachment
  void addAttachment(AttachmentBuilder attachment) {
    files ??= [];

    files!.add(attachment);
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
  Future<IMessage> send(ISend entity) => entity.sendMessage(this);

  /// Returns if this instance of message builder can be used when editing message
  bool canBeUsedAsNewMessage() => content.isNotEmpty || (embeds != null && embeds!.isNotEmpty) || (files != null && files!.isNotEmpty);

  RawApiMap build([AllowedMentions? defaultAllowedMentions]) {
    allowedMentions ??= defaultAllowedMentions;

    return <String, dynamic>{
      ...?flags?.build(),
      "content": content.toString(),
      if (embeds != null) "embeds": [for (final e in embeds!) e.build()],
      if (allowedMentions != null) "allowed_mentions": allowedMentions!.build(),
      if (replyBuilder != null) "message_reference": replyBuilder!.build(),
      if (tts != null) "tts": tts,
      if (nonce != null) "nonce": nonce,
      if (attachments != null) "attachments": [for (final attachmentBuilder in attachments!) attachmentBuilder.build()],
    };
  }

  bool hasFiles() => files != null && files!.isNotEmpty;

  Iterable<http.MultipartFile> getMappedFiles() {
    if (!hasFiles()) {
      return [];
    }

    return mapMessageBuilderAttachments(files!);
  }
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

  /// Inline code text is surrounded with `` ` ``
  static const MessageDecoration codeSimple = MessageDecoration._new("`");

  /// Multiline code block is surrounded with `` ``` ``
  static const MessageDecoration codeLong = MessageDecoration._new("```");

  /// Underlined text is surrounded with `__`
  static const MessageDecoration underline = MessageDecoration._new("__");

  const MessageDecoration._new(String value) : super(value);

  @override
  String toString() => value;

  /// Creates formatted string
  String format(String text) => "$value$text$value";
}

Iterable<http.MultipartFile> mapMessageBuilderAttachments(List<AttachmentBuilder> files) sync* {
  for (var i = 0; i < files.length; i++) {
    final file = files[i];

    yield file.getMultipartFile(i);
  }
}
