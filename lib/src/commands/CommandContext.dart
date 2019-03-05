part of nyxx.commands;

/// All command have to inherit from this class.
/// This class provides various helper methods to access discord world more easly
/// Can be overridden to create groups of commands (modules) or injected into top-level method commands.
///
/// Top-level method commands
/// ```
/// @Command(name: "cmd")
/// Future<void> cmd(CommandContext ctx) async {
///   // Command body
/// }
/// ```
///
/// Modules:
/// ```
/// @Module("mod")
/// class ExModule extends CommandContext {
///   // Class body
/// }
/// ```
class CommandContext {
  /// Channel from where message come from
  MessageChannel channel;

  /// Author of message
  User author;

  /// Message that was sent
  Message message;

  /// Guild in which message was sent
  Guild guild;

  /// Returns author as guild member
  Member get member => guild.members[author.id];

  Nyxx client;

  CommandContext();
  CommandContext._new(this.client, this.channel, this.author, this.guild, this.message);

  /// Reply to message. It allows to send regular message, Embed or both.
  ///
  /// ```
  /// /// Class body
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   await reply(content: uset.avatarURL());
  /// }
  /// ```
  Future<Message> reply(
      {Object content = "",
      EmbedBuilder embed,
      List<AttachmentBuilder> files,
      bool tts = false,
      bool disableEveryone,
      MessageBuilder builder}) async {
    return channel.send(
        content: content,
        embed: embed,
        tts: tts,
        files: files,
        builder: builder,
        disableEveryone: disableEveryone);
  }

  /// Reply to messages, then delete it when [duration] expires.
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   await replyTemp(content: user.avatarURL());
  /// }
  /// ```
  Future<Message> replyTemp(Duration duration,
      {Object content,
      List<AttachmentBuilder> files,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone,
      MessageBuilder builder}) async {
      return channel.send(
          content: content,
          embed: embed,
          files: files,
          tts: tts,
          builder: builder,
          disableEveryone: disableEveryone).then((msg) {
        Timer(duration, () => msg.delete());
        return msg;
      });
  }

  /// Replies to message after delay specified with [duration]
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   await replyDelayed(Duration(seconds: 2), content: user.avatarURL());
  /// }
  /// ```
  Future<Message> replyDelayed(Duration duration,
      {Object content,
      List<AttachmentBuilder> files,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone,
      MessageBuilder builder}) async {
    return Future.delayed(
        duration,
        () => channel.send(
            content: content,
            embed: embed,
            files: files,
            tts: tts,
            builder: builder,
            disableEveryone: disableEveryone));
  }

  /// Gather emojis of message in given time
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   var msg = await replyDelayed(content: uset.avatarURL());
  ///   var emojis = await collectEmojis(msg, Duration(seconds: 15));
  /// }
  /// ```
  Future<Map<Emoji, int>> collectEmojis(Message msg, Duration duration) async {
    var m = Map<Emoji, int>();

    return Future<Map<Emoji, int>>(() async {
      await for (var r in this.client.onMessageReactionAdded.where((evnt) => evnt.message.id == msg.id)) {
        if (m.containsKey(r.emoji))
          m[r.emoji] += 1;
        else
          m[r.emoji] = 1;
      }
    }).timeout(duration, onTimeout: () => m);
  }

  /// Waits for first [TypingEvent] and returns it. If timed out returns null.
  /// Can listen to specific user by specifying [user]
  Future<TypingEvent> waitForTyping(User user,
      {Duration timeout = const Duration(seconds: 30)}) async {
    return client.onTyping
        .firstWhere((e) => e.user == user && e.channel == this.channel)
        .timeout(timeout, onTimeout: () => null);
  }

  /// Gets all context channel messages that satisfies [predicate].
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   var messages = await nextMessagesWhere((msg) => msg.content.startsWith("fuck"));
  /// }
  /// ```
  Stream<MessageReceivedEvent> nextMessagesWhere(
          bool predicate(MessageReceivedEvent msg),
          {int limit = 100}) =>
      channel.onMessage.where(predicate).take(limit);

  /// Gets next [num] number of any messages sent within one context (same channel).
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   // gets next 10 messages
  ///   var messages = await nextMessages(10);
  /// }
  /// ```
  Stream<MessageReceivedEvent> nextMessages(int num) =>
      channel.onMessage.take(num);

  /// Returns stream of all code blocks in message
  /// For now it only parses codeblock which starts in first line
  /// Language string `dart, java` will be ignored and not included
  /// """
  /// n> eval ```(dart)?
  ///   await reply(content: 'no to elo');
  /// ```
  /// """
  Stream<String> getCodeBlocks() async* {
    var regex = RegExp(r"```(\w+)?(\s)?(((.+)(\s)?)+)```");

    var matches = regex.allMatches(message.content);
    for (var m in matches) yield m.group(3);
  }
}
