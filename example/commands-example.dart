import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';
import 'dart:async';

// Main function
void main() {
  // Create new bot instance
  // Dart 2 introduces optional new keyword, so we can leave it
  nyxx.Nyxx bot = nyxx.Nyxx(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands.
  command.CommandsFramework('!', bot)
    ..admins = [nyxx.Snowflake("302359032612651009")]
    ..registerLibraryCommands();
}

/// Example command preprocessor.
class IsGuildProcessor implements command.Preprocessor {
  const IsGuildProcessor();

  @override
  bool execute(List<Object> services, nyxx.Message message) {
    print("ELO");
    return message.guild != null;
  }
}

class PrintString implements command.Postprocessor {
  final void str;
  const PrintString(this.str);

  @override
  void execute(List<Object> services, returns, nyxx.Message message) {
    print("From postProcessor: $str");
  }
}

@command.Command(name: "single")
Future<void> single(command.CommandContext context) async {
  await context.reply(content: "WORKING");
}

// Command have to extends CommandContext class and have @Command annotation.
// Method with @Maincommand is main point of command object
// Methods annotated with @Subcommand are defined as subcommands
@command.Module("ping")
class PongCommand extends command.CommandContext {
  @command.Command(main: true)
  @command.Help("Pong!", usage: "ping")
  @IsGuildProcessor()
  @PrintString("WITAM SERDECZNIE")
  Future run() async {
    await reply(content: "Pong!");
  }
}

@command.Module("kk")
class SomeThings extends command.CommandContext {
  @command.Command()
  Future<void> main(String str) async {
    await reply(content: str);
  }

  @command.Command(name: "elo")
  Future<void> siema(String witam, @command.Remainder() List<String> rest) async {
    await reply(content: [witam, rest]);
  }
}

@command.Module("echo")
class EchoCommand extends command.CommandContext {
  @command.Command(main: true)
  Future<void> run() async {
    await reply(content: message.content);
  }

  @command.Command(name: "perm")
  Future perms() async {
    print((channel as nyxx.GuildChannel).permissions);

    await (channel as nyxx.GuildChannel).editChannelPermission(
        nyxx.PermissionsBuilder()
          ..sendMessages = true
          ..sendTtsMessages = false,
        client.users[nyxx.Snowflake("471349482307715102")]);

    for (var perm in (channel as nyxx.GuildChannel).permissions) {
      var role = guild.roles.values.firstWhere((i) => i.id == perm.id);
      print(
          "Entity: ${perm.id} with ${perm.type} as ${role.name} can?: ${perm.permissions.viewChannel}");
    }
  }
}

// Aliases have to be `const`
@command.Module("alias", aliases: ["aaa"])
class AliasCommand extends command.CommandContext {
  @command.Command(main: true)
  Future run() async {
    await reply(content: message.content);
  }
}
