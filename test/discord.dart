import 'dart:io';
import 'dart:async';

import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;
import 'package:nyxx/setup.wm.dart' as setup;

class TestCommand extends command.Command {
  TestCommand() {
    this.name = "test";
    this.help = "Checks if everything is running";
    this.usage = "~~test";
  }

  @override
  run() async {
    await context.message.channel.send(content: "test is working correctly");
  }
}

class CooldownCommand extends command.Command {
  CooldownCommand() {
    this.name = "cooldown";
    this.help = "Checks if cooldown is working";
    this.usage = "~~cooldown";
    this.aliases = ["culdown"];
    this.cooldown = 10;
  }

  @override
  run() async {}
}

void main() {
  setup.configureDiscordForVM();

  var env = Platform.environment;
  var bot = new nyxx.Client(env['DISCORD_TOKEN']);

  var commandsListener = new command.InstanceCommandFramework('~~', bot)
    ..add(new TestCommand())
    ..add(new CooldownCommand())
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
    var channel = bot.channels['422285619952222208'];
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
