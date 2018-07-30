part of nyxx.commands;

/// Abstract class to factory new command
abstract class CommandContext {
  /// Channel from where message come from
  MessageChannel channel;

  /// Author of message
  User author;

  /// Message that was sent
  Message message;

  /// Guild in which message was sent
  Guild guild;

  /// Logger for instance of command
  Logger logger;

  /// Reply to message which fires command.
  Future<Message> reply(
      {String content,
      EmbedBuilder embed,
      bool tts: false,
      String nonce,
      bool disableEveryone}) async {
    return await channel.send(
        content: content,
        embed: embed,
        tts: tts,
        nonce: nonce,
        disableEveryone: disableEveryone);
  }

  Future<Message> replyTemp(Duration duration,
      {String content,
      EmbedBuilder embed,
      bool tts: false,
      String nonce,
      bool disableEveryone}) async {
    var msg = await channel.send(
        content: content,
        embed: embed,
        tts: tts,
        nonce: nonce,
        disableEveryone: disableEveryone);

    new Timer(duration, () async => await msg.delete());
    return msg;
  }

  Future<Message> replyDelayed(Duration duration,
      {String content,
      EmbedBuilder embed,
      bool tts: false,
      String nonce,
      bool disableEveryone}) async {
    return new Future.delayed(
        duration,
        () async => await channel.send(
            content: content,
            embed: embed,
            tts: tts,
            nonce: nonce,
            disableEveryone: disableEveryone));
  }

  Future<Map<Emoji, int>> collectEmojis(Message msg, Duration duration) async {
    var m = new Map<Emoji, int>();

    return new Future<Map<Emoji, int>>(() async {
      await for (var r in msg.onReactionAdded) {
        if (!m.containsKey(r.emoji)) m[r.emoji] = 1;

        print("ELO");
        m[r.emoji] = ++m[r.emoji];
      }
    }).timeout(duration, onTimeout: () => m);
  }

  /// Delays execution of command and waits for nex matching command based on [prefix]. Has static timeout of 30 seconds
  Future<MessageEvent> nextMessage(
      {String prefix: "",
      bool ensureUser = false,
      Duration timeout: const Duration(seconds: 30)}) async {
    return await message.client.onMessage.firstWhere((i) {
      if (!i.message.content.startsWith(prefix)) return false;

      if (ensureUser) return i.message.author.id == message.author.id;

      return true;
    }).timeout(timeout, onTimeout: () {
      return null;
    });
  }

  /// Gets next [num] number of any messages sent within one context (same channel) with optional [timeout](default 30 sec)
  Future<List<Message>> nextMessages(int num,
      {Duration timeout = const Duration(seconds: 30)}) async {
    List<Message> tmpData = new List();

    await channel.onMessage.take(num).forEach((i) {
      tmpData.add(i.message);
    }).timeout(timeout);

    return tmpData;
  }

  void getHelp(bool isAdmin, StringBuffer buffer) {}
}
