part of nyxx.commands;

typedef Future<void> CommandHandler(
    Message message, Member author, MessageChannel channel, List<String> args);

bool _isCommandMatching(List<String> command, List<String> message) {
  if(message.length < command.length)
    return false;

  for(var i = 0; i < command.length; i++) {
    if(command[i] != message[i])
      return false;
  }

  return true;
}

class CommandParser {
  Map<String, CommandHandler> _commands;

  String prefix;

  CommandParser(this.prefix, Nyxx client) {
    _commands = Map();

    client.onReady.listen((_) {
      client.onMessageReceived.listen((event) {
        if (!event.message.content.startsWith(prefix)) return;

        var trimmedContent = event.message.content.replaceFirst(prefix, "");
        var splittedContent = trimmedContent.split(" ");

        _commands.forEach((commandConstraints, commandHandler) async {
          if (_isCommandMatching(commandConstraints.split(" "), splittedContent)) {
            await commandHandler(
                event.message,
                event.message.guild != null
                    ? event.message.guild.members[event.message.author.id]
                    : null,
                event.message.channel,
                splittedContent);
            return;
          }
        });
      });
    });
  }

  void bind(String cmd, CommandHandler handler) => _commands[cmd] = handler;
}
