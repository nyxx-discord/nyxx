part of discord;

class Commands {
  String _prefix;

  String get prefix => _prefix;

  List<Command> _commands;

  Commands(this._prefix) {
    _commands = [];
  }

  void dispatch(MessageEvent e) {
    if (!e.message.author.bot) {
      if (e.message.content.startsWith('!help'))
        e.message.channel.sendMessage(content: _createHelp());
      else if (e.message.content.startsWith(prefix)) {
        var matched_commands = _commands
            .where((i) => e.message.content.startsWith((_prefix + i.name)));
        matched_commands.first.run(e.message);
      }
    }
  }

  String _createHelp() {
    var buffer = new StringBuffer();

    buffer.writeln("Available commands:");

    _commands.forEach((item) {
      buffer.writeln("${item.name} - ${item.help}");
      buffer.writeln("\t Usage: ${item.usage}");
    });
  }

  void add(ICommand command) {
    _commands.add(command);
    print(_commands);
  }
}
