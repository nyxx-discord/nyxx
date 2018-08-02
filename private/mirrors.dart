library test;

import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

import 'dart:io';
import 'dart:async';

class Service extends command.Service {
  String data;

  Service() {
    this.data = "Siema";
  }
}

main() async {
  nyxx.Client bot = new nyxx.Client(Platform.environment['DISCORD_TOKEN']);
  /*
  var scheduler = new command.Scheduler(bot)
    ..runEvery = const Duration(seconds: 1)
    ..targets = ["422285619952222208"]
    ..func = (channel) {
      channel.send(content: "test");
    };

  new Timer(const Duration(seconds: 5), () => scheduler.stop());

  await scheduler.run();


  bot.onReady.listen((e) async {
    var ch = bot.channels["422285619952222208"] as nyxx.TextChannel;

    var siema = await command.Interactivity.paginate(ch, ["SIema", "Czy to dziala?", "Hope so"], timeout: const Duration(minutes: 15));
    var res = await command.Interactivity.createPoll(ch, "Ttul", {
      nyxx.EmojisUnicode.stopwatch: "Stopwatch",
      nyxx.EmojisUnicode.abcd: "abcd"
    }, timeout: const Duration(seconds: 10));

    print(res);

  });
  */
/*
  new command.CommandsFramework('!', bot)
    ..admins = ["302359032612651009"]
    ..registerLibraryServices()
    ..registerLibraryCommands()
    ..onCommandExecutionFail.listen((e) => print(e.exception));*/
}

@command.Command("alias", aliases: const ["aaa"])
class AliasCommand extends command.CommandContext {
  Service _service;

  AliasCommand(this._service);

  @command.Maincommand()
  main(String name) async {
    await reply(content: name);
    await reply(content: _service.data);
  }

  @command.Subcommand("witam")
  witam() async {
    var messages = await nextMessages(2);
    print(messages);
  }

  @command.Subcommand("yyy")
  Future yyy(nyxx.UnicodeEmoji emoji) {
    print(emoji.name);
  }

  @command.Subcommand("chuje")
  Future chuje(
      String first, @command.Remainder() List<String> remainder) async {
    var msg = await reply(content: first);
    var emojis = await collectEmojis(msg, const Duration(seconds: 10));

    print(emojis);
  }

  @command.Subcommand("nsfw", isNsfw: true)
  Future nsfw() async {
    await reply(content: "Working!");
  }

  @command.Subcommand("channel",
      requiredPermissions: const [nyxx.PermissionsConstants.ADMINISTRATOR],
      topics: const ["games"])
  Future getChannel(nyxx.TextChannel chan) async {
    await reply(content: chan.id.toString());
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
    buffer.writeln("* alias, aaa - Reply with given name");
    buffer.writeln("\t Usage: ![alias, aaa] <name>");
    buffer.writeln("\t - witam - Gets next 2 messages");
    buffer.writeln("\t - channel - returns id of channel");
  }
}
