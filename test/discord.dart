import 'dart:io';
import 'dart:async';

import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;
import 'package:nyxx/setup.wm.dart' as setup;

class StringService extends command.Service {
  String data = "Example data";

  StringService();
}

@command.Command("test", "Checks if everything is running", "~~test")
class TestCommand extends command.CommandContext {
  @command.Maincommand()
  Future<Null> run() async {
    await reply(content: "test is working correctly");
  }

  @command.Subcommand("ttest")
  Future<Null> test(int param, StringService service) async {
    await reply(content: "$param, ${service.data}");
  }
}

@command.Command("cooldown", "Checks if cooldown is working", "~~cooldown", aliases: const ["culdown"])
class CooldownCommand extends command.CommandContext {
  @command.Maincommand(cooldown: 10)
  run() async {}
}

void main() {
  setup.configureDiscordForVM();

  var env = Platform.environment;
  var bot = new nyxx.Client(env['DISCORD_TOKEN']);

  var commandsListener = new command.CommandsFramework('~~', bot)
    ..registerLibraryServices()
    ..registerLibraryCommands()
    ..commandNotFoundEvent.listen((m) {
      m.channel.send(content: "Command '${m.content}' not found!");
    })
    ..cooldownEvent.listen((m) {
      m.channel.send(content: "Command is on cooldown!. Wait a few seconds!");
    })
    ..ignoreBots = false;

  new Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });

  nyxx.EmbedBuilder createTestEmbed() {
    return new nyxx.EmbedBuilder("Test title")
      ..addField(name: "Test field", value: "Test value");
  }

  bot.onReady.listen((e) async {
    var channel = bot.channels['422285619952222208'] as nyxx.TextChannel;
    channel.send(
        content:
            "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}`");

    print("TESTING BASIC FUNCTIONALITY!");
    var m = await channel.send(content: "Message test.");
    await m.edit(content: "Edit test.");
    await m.delete();
    await channel.send(content: "--trigger-test");

    print("TESTING COMMANDS!");
    var mm = await channel.send(content: "~~test");
    await mm.delete();

    print("TESTING COMMAND - NOT FOUND!");
    var mmm = await channel.send(content: "~~notFound");
    await mmm.delete();

    print("TESTING COMMAND - COOLDOWN | ALIASES");
    var c = await channel.send(content: "~~culdown");
    var cc = await channel.send(content: "~~culdown");
    await c.delete();
    await cc.delete();

    print("TESTING COMMAND - SUBCOMMAND");
    var d = await channel.send(content: "~~test ttest 14");
    await d.delete();

    print("TESTING EMBEDS");
    var e =
        await channel.send(content: "Testing embed!", embed: createTestEmbed());
    await e.delete();
  });

  bot.onMessage.listen((e) async {
    var m = e.message;

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "--trigger-test") {
      await m.delete();
    }

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "test is working correctly") {
      await m.delete();
    }

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "Command '~~notFound' not found!") {
      await m.delete();
    }

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "Command is on cooldown!. Wait a few seconds!") {
      await m.delete();
    }

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "14 Example data") {
      await m.delete();
    }

    if (m.channel.id == "422285619952222208" &&
        m.author.id == bot.user.id &&
        m.content == "Testing embed!") {
      if (m.embeds.length > 0) {
        var embed = m.embeds.values.toList()[0];
        if (embed.title == "Test title" && embed.fields.length > 0) {
          var field = embed.fields.values.toList()[0];

          if (field.name == "Test field" &&
              field.content == "Test value" &&
              !field.inline) {
            await m.channel.send(content: "Tests completed successfully!");
            print("Nyxx tests completed successfully!");
            await bot.destroy();
            exit(0);
          }
        }
      }
    }
  });
}
