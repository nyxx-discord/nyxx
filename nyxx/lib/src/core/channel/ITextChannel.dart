part of nyxx;

/// Represents text channel. Can be either [CachelessTextChannel] or [DMChannel] or [GroupDMChannel]
abstract class ITextChannel implements Channel, MessageChannel {
  /// Returns message with given [id]. Allows to force fetch message from api
  /// with [ignoreCache] property. By default it checks if message is in cache and fetches from api if not.
  Future<Message?> getMessage(Snowflake id, {bool ignoreCache = false});

  /// Sends message to channel. Performs `toString()` on thing passed to [content]. Allows to send embeds with [embed] field.
  ///
  /// ```
  /// await chan.send(content: "Very nice message!");
  /// ```
  ///
  /// Can be used in combination with [Emoji]. Just run `toString()` on [Emoji] instance:
  /// ```
  /// var emoji = guild.emojis.values.firstWhere((e) => e.name.startsWith("dart"));
  /// await chan.send(content: "Dart is superb! ${emoji.toString()}");
  /// ```
  /// Embeds can be sent very easily:
  /// ```
  /// var embed = new EmbedBuilder()
  ///   ..title = "Example Title"
  ///   ..addField(name: "Memory usage", value: "${ProcessInfo.currentRss / 1024 / 1024}MB");
  ///
  /// await chan.send(embed: embed);
  /// ```
  ///
  ///
  /// Method also allows to send file and optional [content] with [embed].
  /// Use `expandAttachment(String file)` method to expand file names in embed
  ///
  /// ```
  /// await chan.send(files: [new File("kitten.png"), new File("kitten.jpg")], content: "Kittens ^-^"]);
  /// ```
  /// ```
  /// var embed = new nyxx.EmbedBuilder()
  ///   ..title = "Example Title"
  ///   ..thumbnailUrl = "${attach("kitten.jpg")}";
  ///
  /// await e.message.channel
  ///   .send(files: [new File("kitten.jpg")], embed: embed, content: "HEJKA!");
  /// ```
  @override
  Future<Message> send(
      {dynamic content,
        List<AttachmentBuilder>? files,
        EmbedBuilder? embed,
        bool? tts,
        AllowedMentions? allowedMentions,
        MessageBuilder? builder});

  /// Starts typing.
  Future<void> startTyping();

  /// Loops `startTyping` until `stopTypingLoop` is called.
  void startTypingLoop();

  /// Stops a typing loop if one is running.
  void stopTypingLoop();

  /// Bulk removes many messages by its ids. [messagesIds] is list of messages ids to delete.
  ///
  /// ```
  /// var toDelete = chan.messages.keys.take(5);
  /// await chan.bulkRemoveMessages(toDelete);
  /// ```
  Future<void> bulkRemoveMessages(Iterable<Message> messagesIds);

  /// Gets several [Message] objects from API. Only one of [after], [before], [around] can be specified,
  /// otherwise, it will throw.
  ///
  /// ```
  /// var messages = await chan.getMessages(limit: 100, after: Snowflake("222078108977594368"));
  /// ```
  Stream<Message> getMessages({int limit = 50, Snowflake? after, Snowflake? before, Snowflake? around});
}
