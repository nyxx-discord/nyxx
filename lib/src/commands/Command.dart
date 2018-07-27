part of nyxx.commands;

class Command {
  /// Name of command. Text which will trigger execution
  final String name;

  /// Help message
  final String help;

  /// Example usage of command
  final String usage;

  /// List of aliases for command
  final List<String> aliases;

  const Command(this.name, this.help, this.usage, {this.aliases});
}

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

  /// Reply to messsage which fires command.
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

  /// Delays execution of command and waits for nex matching command based on [prefix]. Has static timemout of 30 seconds
  Future<MessageEvent> delay(
      {String prefix: "", bool ensureUser = false}) async {
    return await message.client.onMessage.firstWhere((i) {
      if (!i.message.content.startsWith(prefix)) return false;

      if (ensureUser) return i.message.author.id == message.author.id;

      return true;
    }).timeout(const Duration(seconds: 30), onTimeout: () {
      //print("Timed out");
      return null;
    });
  }

  /// Gets next [num] number of any messages sent within one context (same channel) with optional timeout(default 30 sec)
  Future<List<Message>> nextMessages(int num,
      {Duration timeout = const Duration(seconds: 30)}) async {
    List<Message> tmpData = new List();

    var tmp = await channel.onMessage.take(num).forEach((i) {
      tmpData.add(i.message);
    }).timeout(timeout);

    return tmpData;
  }
}