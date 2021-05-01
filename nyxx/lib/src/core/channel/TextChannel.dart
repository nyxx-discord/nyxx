part of nyxx;

/// Generic interface for all text channels types
abstract class TextChannel implements IChannel, ISend {
  /// File upload limit for channel in bytes.
  Future<int> get fileUploadLimit;

  /// A collection of messages sent to this channel.
  MessageCache get messageCache;

  /// Returns [Message] with given id from CACHE
  Message? getMessage(Snowflake id);

  /// Returns [Message] downloaded from API
  Future<Message> fetchMessage(Snowflake id);

  /// Sends message to channel. Performs `toString()` on thing passed to [content]. Allows to send embeds with [embed] field.
  ///
  /// ```
  /// await channel.sendMessage(content: "Very nice message!");
  /// ```
  ///
  /// Can be used in combination with Emoji. Just run `toString()` on Emoji instance:
  /// ```
  /// final emoji = guild.emojis.findOne((e) => e.name.startsWith("dart"));
  /// await channel.send(content: "Dart is superb! ${emoji.toString()}");
  /// ```
  /// Embeds can be sent very easily:
  /// ```
  /// var embed = EmbedBuilder()
  ///   ..title = "Example Title"
  ///   ..addField(name: "Memory usage", value: "${ProcessInfo.currentRss / 1024 / 1024}MB");
  ///
  /// await channel.sendMessage(embed: embed);
  /// ```
  ///
  /// Method also allows to send file and optional [content] with [embed].
  /// Use `expandAttachment(String file)` method to expand file names in embed
  ///
  /// ```
  /// await channel.sendMessage(files: [new File("kitten.png"), new File("kitten.jpg")], content: "Kittens ^-^"]);
  /// ```
  /// ```
  /// var embed = new nyxx.EmbedBuilder()
  ///   ..title = "Example Title"
  ///   ..thumbnailUrl = "${attach("kitten.jpg")}";
  ///
  /// channel.sendMessage(files: [new File("kitten.jpg")], embed: embed, content: "HEJKA!");
  /// ```
  @override
  Future<Message> sendMessage(MessageBuilder builder);

  /// Bulk removes many messages by its ids. [messages] is list of messages ids to delete.
  ///
  /// ```
  /// var toDelete = channel.messages.take(5);
  /// await channel.bulkRemoveMessages(toDelete);
  /// ```
  Future<void> bulkRemoveMessages(Iterable<Message> messages);

  /// Gets several [Message] objects from API. Only one of [after], [before], [around] can be specified,
  /// otherwise, it will throw.
  ///
  /// ```
  /// var messages = await channel.downloadMessages(limit: 100, after: Snowflake("222078108977594368"));
  /// ```
  Stream<Message> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before});

  /// Starts typing.
  Future<void> startTyping();

  /// Loops `startTyping` until `stopTypingLoop` is called.
  void startTypingLoop();

  /// Stops a typing loop if one is running.
  void stopTypingLoop();
}
