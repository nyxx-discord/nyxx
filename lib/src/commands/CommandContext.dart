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

  CommandContext();
  CommandContext._new(this.channel, this.author, this.guild, this.message);

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
      {Object content,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone}) async {
    return await channel.send(
        content: content,
        embed: embed,
        tts: tts,
        disableEveryone: disableEveryone);
  }

  /// Reply to messages, then delete it [duration] expieres.
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   await replyTemp(content: uset.avatarURL());
  /// }
  /// ```
  Future<Message> replyTemp(Duration duration,
      {Object content,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone}) async {
    var msg = await channel.send(
        content: content,
        embed: embed,
        tts: tts,
        disableEveryone: disableEveryone);

    Timer(duration, () async => await msg.delete());
    return msg;
  }

  /// Replies to messages after specified [duration]
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   await replyDelayed(content: uset.avatarURL());
  /// }
  /// ```
  Future<Message> replyDelayed(Duration duration,
      {Object content,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone}) async {
    return Future.delayed(
        duration,
        () async => await channel.send(
            content: content,
            embed: embed,
            tts: tts,
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
      await for (var r in msg.onReactionAdded) {
        if (m.containsKey(r.emoji))
          m[r.emoji] += 1;
        else
          m[r.emoji] = 1;
      }
    }).timeout(duration, onTimeout: () => m);
  }

  /// Waits for first [TypingEvent] and returns it. If timed out returns null.
  /// Can listen to specific user by specifying [user]
  Future<TypingEvent> waitForTyping(
      {User user,
      Duration timeout = const Duration(seconds: 30),
      bool everywhere = false}) async {
    return Future(() {
      if (everywhere) {
        if (user != null)
          return client.onTyping.firstWhere((e) => e.user == user);

        return client.onTyping.first;
      } else {
        if (user != null)
          return channel.onTyping.firstWhere((e) => e.user == user);

        return channel.onTyping.first;
      }
    }).timeout(timeout, onTimeout: () => null);
  }

  /// Gets all context channel messages that satisfies test. Has default timeout of 30 seconds.
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   var messages = await nextMessagesWhere((msg) => msg.content.startsWith("fuck"));
  /// }
  /// ```
  Future<List<Message>> nextMessagesWhere(bool func(Message msg),
      {Duration timeout = const Duration(seconds: 30)}) async {
    List<Message> tmpData = List();

    await channel.onMessage.forEach((i) {
      if (func(i.message)) tmpData.add(i.message);
    }).timeout(timeout);

    return tmpData;
  }

  /// Gets next [num] number of any messages sent within one context (same channel) with optional [timeout](default 30 sec)
  ///
  /// ```
  /// @Command()
  /// Future<void> getAv(User user) async {
  ///   // gets next 10 messages
  ///   var messages = await nextMessages(10);
  /// }
  /// ```
  Future<List<Message>> nextMessages(int num,
      {Duration timeout = const Duration(seconds: 30)}) async {
    List<Message> tmpData = List();

    await channel.onMessage.take(num).forEach((i) {
      tmpData.add(i.message);
    }).timeout(timeout);

    return tmpData;
  }

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
