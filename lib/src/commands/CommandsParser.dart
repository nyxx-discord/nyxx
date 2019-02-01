part of nyxx.commands;

typedef Future<void> CommandHandler(
    Message message, Member author, MessageChannel channel, List<String> args);

class CommandParser {
  Map<String, CommandHandler> _commands;

  String prefix;

  CommandParser(this.prefix, Nyxx client) {
    _commands = Map();

    client.onReady.listen((_) {
      client.onMessageReceived.listen((event) {
        if (!event.message.content.startsWith(prefix)) return;

        var cont = event.message.content.replaceFirst(prefix, "");

        _commands.forEach((str, cmd) async {
          if (cont.startsWith(str)) {
            await cmd(
                event.message,
                event.message.guild != null
                    ? event.message.guild.members[event.message.author.id]
                    : null,
                event.message.channel,
                event.message.content.replaceFirst(str, "").split(" "));
            return;
          }
        });
      });
    });
  }

  void bind(String cmd, CommandHandler handler) => _commands[cmd] = handler;
}
