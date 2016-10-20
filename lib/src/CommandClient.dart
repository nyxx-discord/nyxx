part of discord;

/// The command client.
class CommandClient {
  Client _client;

  /// A map of all commands and aliases.
  Map<String, Command> commands = {};

  CommandClient._new(this._client) {
    this.addCommand(new _Help());
    this._client.onMessage.listen((MessageEvent e) {
      if (!e.message.content.startsWith(_client._options.prefix)) return;

      Command command = commands[e.message.content
          .replaceFirst(_client._options.prefix, "")
          .split(" ")[0]];
      if (command == null) {
        onInvalidCommand(e.message);
        return;
      }
      if (command.enabled == false) return;
      if (command.guildOnly && e.message.guild == null) return;

      args.ArgParser parser = new args.ArgParser(allowTrailingOptions: true);

      command.args.forEach((Argument arg) {
        if (arg._type == 1) {
          parser.addFlag(arg.name,
              negatable: arg.negatable,
              abbr: arg.abbr,
              defaultsTo: arg.defaultValue);
        } else if (arg._type == 2) {
          parser.addOption(arg.name,
              abbr: arg.abbr,
              defaultsTo: arg.defaultValue,
              allowed: arg.allowed,
              allowMultiple: arg.allowMultiple,
              splitCommas: arg.splitCommas);
        }
      });

      List<String> unparsedArgs = e.message.content
          .replaceFirst(_client._options.prefix, "")
          .split(" ");
      unparsedArgs.removeAt(0);

      Map<String, dynamic> parsedArgs = {};

      args.ArgResults results;
      try {
        results = parser.parse(unparsedArgs);
      } catch (err) {
        onParserException(e.message, command, err);
        return;
      }

      for (Argument arg in command.args) {
        if (arg._type == 0) continue;
        try {
          if (arg.required && results[arg.name] == arg.defaultValue) {
            onMissingArg(e.message, command, arg);
            return;
          }
          parsedArgs[arg.name] = results[arg.name];
        } catch (err) {
          if (arg.required) {
            onMissingArg(e.message, command, arg);
            return;
          }
        }
      }

      int counter = 0;
      for (Argument arg in command.args) {
        if (arg._type != 0) continue;
        try {
          parsedArgs[arg.name] = results.rest[counter];
          counter++;
        } catch (err) {
          if (arg.required) {
            onMissingArg(e.message, command, arg);
            return;
          }
        }
      }

      for (Argument arg in command.args) {
        if (parsedArgs[arg.name] == null)
          parsedArgs[arg.name] = arg.defaultValue;
      }

      command.run(_client, e.message, parsedArgs);
    });
  }

  /// Called when an argument is missing.
  void onMissingArg(Message msg, Command cmd, Argument arg) {
    msg.channel.sendMessage("You are missing the argument `${arg.name}`!");
  }

  /// Called when the parser encounters an error.
  void onParserException(Message msg, Command cmd, err) {
    msg.channel.sendMessage(err.message);
  }

  /// Called when an invalid command is received.
  void onInvalidCommand(Message msg) {
    return;
  }

  /// Adds a command.
  void addCommand(Command command) {
    commands[command.name] = command;
    command.aliases.forEach((String alias) {
      commands[alias] = command;
    });
  }
}

/// The default help command.
class _Help implements Command {
  @override
  String name = "help";

  @override
  List<String> aliases = [];

  @override
  String description = "Help command";

  @override
  String usage = "help";

  @override
  bool enabled = true;

  @override
  bool guildOnly = false;

  @override
  List<Argument> args = [new Argument.positional("command", required: false)];

  @override
  void run(Client bot, Message msg, Map<String, dynamic> args) {
    if (bot.commands.commands[args['command']] != null) {
      Command command = bot.commands.commands[args['command']];
      msg.channel.sendMessage([
        "```",
        "       Name: ${command.name}",
        "Description: ${command.description}",
        "      Usage: ${command.usage}",
        "     Aliaes: ${command.aliases.join(', ')}",
        "```"
      ].join("\n"));
    } else {
      List<List<String>> table = [
        ["Command", "Discription", "Usage"]
      ];
      bot.commands.commands.forEach((String name, Command command) {
        table.add([name, command.description, command.usage]);
      });
      msg.channel.sendMessage("```" + Util.textTable(table) + "```");
    }
  }
}
