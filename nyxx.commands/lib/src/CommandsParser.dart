part of nyxx.commands;

/// Handles command execution. [args] is list of all word after prefix and matched command name.
typedef Future<void> CommandHandler(
    Message message, Member author, MessageChannel channel, List<String> args);

/// Method to execute before any matched with prefix command.
typedef FutureOr<bool> Predicate(Message message, Member author, MessageChannel channel);

bool _isCommandMatching(List<String> command, List<String> message) {
  if(message.length < command.length)
    return false;

  for(var i = 0; i < command.length; i++) {
    if(command[i] != message[i])
      return false;
  }

  return true;
}

/// Lighter version of [CommandsFramework]. It's bare wraper around messages and allows to avoid boilerplate.
/// Does not offer powerful helper class and methods and is less powerful but is lighter and more perfomant.
class CommandParser {
  Map<String, CommandHandler> _commands;

  /// Prefix for commands
  String prefix;

  Predicate _predicate;

  /// Constructs and stars [CommandParser]. Allows to set additional [_predicate] to execute before any matched with prefix message.
  CommandParser(this.prefix, Nyxx client, [this._predicate]) {
    _commands = Map();

    client.onReady.listen((_) {
      client.onMessageReceived.listen((event) async {
        if (!event.message.content.startsWith(prefix)) return;


        if(_predicate != null && await _predicate(event.message, event.message.guild != null ? event.message.guild.members[event.message.author.id] : null, event.message.channel)) {
          return;
        }

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

  /// Binds [command] to [handler] which is action that will be invoked when message matched prefix and specified [command].
  void bind(String command, CommandHandler handler) => _commands[command] = handler;
}
