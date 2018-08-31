part of nyxx.commands;

/// All command have to inhertit from this class.
/// This class provides variuos helper methods to access discord world more easly
class CommandContext {
  /// Channel from where message come from
  MessageChannel channel;

  /// Author of message
  User author;

  /// Message that was sent
  Message message;

  /// Guild in which message was sent
  Guild guild;

  /// Additional Client instance
  Client client;

  CommandContext();

  CommandContext._new(
      this.channel, this.author, this.guild, this.client, this.message);

  /// Reply to message which fires command.
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

  /// Replys to messages then deletes it when duration expires
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

  /// Replies to messages after specified Duration
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

  /// Collects messages emojis.
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

  /// Delays execution of command and waits for nex matching command based on [prefix]. Has static timeout of 30 seconds
  Future<MessageEvent> nextMessage(
      {String prefix = "",
      bool ensureUser = false,
      Duration timeout = const Duration(seconds: 30)}) async {
    return await message.client.onMessage.firstWhere((i) {
      if (!i.message.content.startsWith(prefix)) return false;

      if (ensureUser) return i.message.author.id == message.author.id;

      return true;
    }).timeout(timeout, onTimeout: () {
      return null;
    });
  }

  /// Waits for first [TypingEvent] and returns it. If timed out returns null. Can listen to specific user
  Future<TypingEvent> waitForTyping(
      {User user,
      Duration timeout = const Duration(seconds: 30),
      bool everywhere = false}) async {
    return Future(() {
      if (everywhere) {
        if (user != null)
          return channel.client.onTyping.firstWhere((e) => e.user == user);

        return channel.client.onTyping.first;
      } else {
        if (user != null)
          return channel.onTyping.firstWhere((e) => e.user == user);

        return channel.onTyping.first;
      }
    }).timeout(timeout, onTimeout: () => null);
  }

  /// Gets all channel messages that satisfies test.
  Future<List<Message>> nextMessagesWhere(bool func(Message msg),
      {Duration timeout = const Duration(seconds: 30)}) async {
    List<Message> tmpData = List();

    await channel.onMessage.forEach((i) {
      if (func(i.message)) tmpData.add(i.message);
    }).timeout(timeout);

    return tmpData;
  }

  /// Gets next [num] number of any messages sent within one context (same channel) with optional [timeout](default 30 sec)
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

  /// Allows to create help String for command
  void getHelp(bool isAdmin, StringBuffer buffer) {}
}
