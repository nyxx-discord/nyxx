import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/internal/interfaces/send.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';

abstract class ITextChannel implements IChannel, ISend {
  /// File upload limit for channel in bytes.
  Future<int> get fileUploadLimit;

  /// A collection of messages sent to this channel.
  Map<Snowflake, IMessage> get messageCache;

  /// Returns [Message] with given id from CACHE
  IMessage? getMessage(Snowflake id);

  /// Returns [IMessage] downloaded from API
  Future<IMessage> fetchMessage(Snowflake id);

  /// Sends message to channel. Allows to send embeds with [MessageBuilder.embed()] method.
  ///
  /// ```
  /// await channel.sendMessage(MessageBuilder.content("Very nice message!"));
  /// ```
  ///
  /// Can be used in combination with Emoji. Just run `toString()` on Emoji instance:
  /// ```
  /// final emoji = guild.emojis.findOne((e) => e.name.startsWith("dart"));
  /// await channel.send(MessageBuilder.content("Dart is superb! ${emoji.toString()}"));
  /// ```
  /// Embeds can be sent very easily:
  /// ```
  /// var embed = EmbedBuilder()
  ///   ..title = "Example Title"
  ///   ..addField(name: "Memory usage", value: "${ProcessInfo.currentRss / 1024 / 1024}MB");
  ///
  /// await channel.sendMessage(MessageBuilder.embed(embed));
  /// ```
  ///
  /// Method also allows to send multiple files and optional [content] with [embed].
  ///
  /// ```
  /// await event.message.channel.sendMessage(
  ///   MessageBuilder.files(
  ///     [
  ///       AttachmentBuilder.file(
  ///         File("kitten.png"),
  ///         name: "kitten.png",
  ///       ),
  ///     ],
  ///   )..content = "Kittens ^-^",
  /// );
  /// ```
  /// You can refer the sent attachments in embeds by prefixing them with `attachment://`:
  /// ```
  /// var embed = EmbedBuilder()
  ///   ..title = "Example Title"
  ///   ..thumbnailUrl = "attachment://kitten.jpg";
  ///
  /// await event.message.channel.sendMessage(
  ///   MessageBuilder.files(
  ///     [
  ///       AttachmentBuilder.file(
  ///         File("kitten.jpg"),
  ///       ),
  ///     ],
  ///   )
  ///     ..embeds = [embed]
  ///     ..content = "HEJKA!",
  /// );
  /// ```
  @override
  Future<IMessage> sendMessage(MessageBuilder builder);

  /// Bulk removes many messages by its ids. [messages] is list of messages ids to delete.
  ///
  /// ```
  /// var toDelete = channel.messages.take(5);
  /// await channel.bulkRemoveMessages(toDelete);
  /// ```
  Future<void> bulkRemoveMessages(Iterable<IMessage> messages);

  /// Gets several [IMessage] objects from API. Only one of [after], [before], [around] can be specified,
  /// otherwise, it will throw.
  ///
  /// ```
  /// var messages = await channel.downloadMessages(limit: 100, after: Snowflake("222078108977594368"));
  /// ```
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before});

  /// Returns pinned [IMessage]s for channel.
  Stream<IMessage> fetchPinnedMessages();

  /// Starts typing.
  Future<void> startTyping();

  /// Loops `startTyping` until `stopTypingLoop` is called.
  void startTypingLoop();

  /// Stops a typing loop if one is running.
  void stopTypingLoop();
}
