import '../discord.dart' as discord;
import 'package:events/events.dart' as events;

/// Send when a new command is received.
class CommandEvent {
  /// A list of arguments provided.
  List<String> args;

  /// The message;
  discord.Message message;

  /// Constructs a `CommandEvent`.
  CommandEvent(Client client, String command, this.args, this.message) {
    client.emit(command, this);
  }
}

/// The base class for the command client.
class Client extends events.Events {
  /// The main discord client.
  discord.Client client;

  /// The client's prefix.
  String prefix;

  /// Makes a new command client.
  Client(this.client, this.prefix) {
    this.client.on('message', (discord.MessageEvent e) {
      if (e.message.content.startsWith(this.prefix)) {
        final String command = e.message.content.split(" ")[0].replaceFirst(this.prefix, "");
        final List<String> args = e.message.content.split(" ");
        args.remove(this.prefix + command);
        new CommandEvent(this, command, args, e.message);
      }
    });
  }
}
