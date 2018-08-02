import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';
import 'dart:async';

// Main function
void main() {
  // Create new bot instance
  nyxx.Client bot = nyxx.Client(Platform.environment['DISCORD_TOKEN']);

  // Creating new CommandsFramework object and registering commands.
  command.CommandsFramework('!', bot)
    ..admins = ["302359032612651009"]
    ..registerLibraryCommands();
}

// Command have to extends CommandContext class and have @Command annotation.
// Method with @Maincommand is main point of command object
// Methods annotated with @Subcommand are defined as subcommands
@command.Command("ping")
class PongCommand extends command.CommandContext {
  @command.Maincommand()
  Future run() async {
    await reply(content: "Pong!");
  }

  @override
  void getHelp(bool isAdmin, StringBuffer buffer) =>
      buffer.writeln("* ping - Checks if bot is working");
}

@command.Command("echo")
class EchoCommand extends command.CommandContext {
  @command.Maincommand()
  Future run() async {
    await reply(content: message.content);
  }

  @command.Subcommand("perm")
  Future perms() async {
    print((channel as nyxx.GuildChannel).permissions);

    await (channel as nyxx.GuildChannel).editChannelPermission(
        new nyxx.PermissionsBuilder()
          ..sendMessages = true
          ..sendTtsMessages = false,
        new nyxx.Snowflake("471349482307715102"));

    for (var perm in (channel as nyxx.GuildChannel).permissions) {
      var role = guild.roles.values.firstWhere((i) => i.id == perm.entityId);
      print(
          "Entity: ${perm.entityId} with ${perm.type} as ${role.name} can?: ${perm.permissions.viewChannel}");
    }
  }

  @override
  void getHelp(bool isAdmin, StringBuffer buffer) {
    buffer.writeln("* echo - Echoes yor message");
  }
}

// Aliases have to be `const`
@command.Command("alias", aliases: const ["aaa"])
class AliasCommand extends command.CommandContext {
  @command.Maincommand()
  Future run() async {
    await reply(content: message.content);
  }
}
