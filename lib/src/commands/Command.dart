part of nyxx.commands;

/// Absctract class to factory new command
abstract class AbstractCommand {
  /// Name of command. Text which will trigger execution
  String name;

  /// Help message
  String help;

  /// Example usage of command
  String usage;

  /// Indicates if commands is restricted to admins
  bool isAdmin = false;

  /// List of roles required to execute command
  List<String> requiredRoles = null;

  /// Cooldown for command in seconds
  int cooldown = 0;

  /// Indicated if command is hidden from help
  bool isHidden = false;

  /// List of aliases for command
  List<String> aliases = null;

  /// Execution context of command.
  CommandContext context;

  /// Logger for instance of command
  Logger logger;

  /// Reply to messsage which fires command.
  Future<Message> reply(
      {String content,
      EmbedBuilder embed,
      bool tts: false,
      String nonce,
      bool disableEveryone}) async {
    return await context.channel.send(
        content: content,
        embed: embed,
        tts: tts,
        nonce: nonce,
        disableEveryone: disableEveryone);
  }

  /// Delays execution of command and waits for nex matching command based on [prefix]. Has static timemout of 30 seconds
  Future<MessageEvent> delay(
      {String prefix: "", bool ensureUser = false}) async {
    return await context.message.client.onMessage.firstWhere((i) {
      if (!i.message.content.startsWith(prefix)) return false;

      if (ensureUser) return i.message.author.id == context.message.author.id;

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

    var tmp = await context.channel.onMessage.take(num).forEach((i) {
      tmpData.add(i.message);
    }).timeout(timeout);

    return tmpData;
  }
}

/// Absctract class to factory new command
abstract class Command extends AbstractCommand {
  /// Function which will be invoked when command triggers
  Future run();
}

abstract class MirrorsCommand extends AbstractCommand {}
