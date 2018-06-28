import 'dart:io';
import 'dart:async';

import 'package:nyxx/discord.dart' as discord;
import 'package:nyxx/vm.dart' as discord;

class TestCommand extends discord.Command {
  TestCommand() : super("test", "Checks if everything is running", "~~test");

  @override
  run(discord.Message message) async {
    await message.channel.sendMessage(content: "test is working correctly");
  }
}

class CooldownCommand extends discord.Command {
  CooldownCommand()
      : super("cooldown", "Checks if cooldown is working", "~~cooldown") {
    cooldown = 10;
  }

  @override
  run(discord.Message message) async {}
}

void main() {
  discord.configureDiscordForVM();

  var env = Platform.environment;
  var bot = new discord.Client(env['DISCORD_TOKEN']);

  var commandsListener = new discord.Commands('~~', bot)
    ..add(new TestCommand())
    ..add(new CooldownCommand())
    ..commandNotFoundEvent.listen((m) {
      m.channel.send(content: "Command '${m.content}' not found!");
    })
    ..cooldownEvent.listen((m) {
      m.channel
          .send(content: "Command is on cooldown!. Wait a few seconds!");
    })
    ..ignoreBots = false;

  new Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });

  discord.EmbedBuilder createTestEmbed() {
    return new discord.EmbedBuilder("Test title")
        ..addField(name: "Test field", value: "Test value");
  }

  bot.onReady.listen((e) async {
    var channel = bot.channels['422285619952222208'];
    channel.sendMessage(
        content:
            "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}`");

    print("TESTING BASIC FUNCTIONALITY!");
    var m = await channel.sendMessage(content: "Message test.");
    await m.edit(content: "Edit test.");
    await m.delete();
    await channel.sendMessage(content: "--trigger-test");

    print("TESTING COMMANDS!");
    var mm = await channel.sendMessage(content: "~~test");
    await mm.delete();

    print("TESTING COMMAND - NOT FOUND!");
    var mmm = await channel.sendMessage(content: "~~notFound");
    await mmm.delete();

    print("TESTING COMMAND - COOLDOWN");
    var c = await channel.sendMessage(content: "~~cooldown");
    var cc = await channel.sendMessage(content: "~~cooldown");
    await c.delete();
    await cc.delete();

    print("TESTING EMBEDS");
    var e = await channel.send(content: "Testing embed!", embed: createTestEmbed());
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
      if(m.embeds.length > 0) {
        var embed = m.embeds.values.toList()[0];
        if(embed.title == "Test title" && embed.fields.length > 0) {
          var field = embed.fields.values.toList()[0];

          if(field.name == "Test field" && field.content == "Test value" && !field.inline) {
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
