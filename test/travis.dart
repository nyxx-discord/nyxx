import 'dart:io';
import 'dart:async';

import 'package:nyxx/Vm.dart' as nyxx;
import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:nyxx/commands.dart' as command;

// Messages on which we delete message
const ddel = [
  "--trigger-test",
  "test is working correctly",
  "test is working correctly",
  "Command '~~notFound' not found!",
  "Command is on cooldown!. Wait a few seconds!",
  "14 Example data",
  "Converting successfull"
];

// Example service
class StringService extends command.Service {
  String data = "Example data";

  StringService();
}

/*
class CustomType {
  String val;

  CustomType(this.val);
}

class RunesConverter implements command.TypeConverter<CustomType> {
  @override
  Future<CustomType> parse(String from, nyxx.Message msg) async => CustomType(from);
}*/

// Somme commands to test CommandsFramework behaviour
@command.Command(name: "test")
class TestCommand extends command.CommandContext {
  @command.Command(main: true)
  Future<Null> run() async {
    await reply(content: "test is working correctly");
  }

  @command.Command(name: "ttest")
  Future<Null> test(int param, StringService service) async {
    var msg = await reply(content: "$param, ${service.data}");
    await msg.delete();
  }
}

@command.Command(name: "cooldown", aliases: ["culdown"])
class CooldownCommand extends command.CommandContext {
  @command.Command(main: true)
  @command.Restrict(cooldown: 10)
  run() async {}
}

@command.Command(name: "runes")
Future<void> getRunes(command.CommandContext ctx, Runes runes) async {
    if(runes.length <= 0)
      throw Exception("Converting error");

    var msg = await ctx.reply(content: "Converting successfull");
    await msg.delete(auditReason: "This is reason");
}

// -------------------------------------------------------

nyxx.EmbedBuilder createTestEmbed() {
  return nyxx.EmbedBuilder()
    ..title = "Test title"
    ..addField(name: "Test field", content: "Test value");
}

// -------------------------------------------------------

void main() {
  nyxx.configureNyxxForVM();
  var env = Platform.environment;
  var bot = nyxx.Nyxx(env['DISCORD_TOKEN'], ignoreExceptions: false);

  command.CommandsFramework(bot, prefix: '~~', ignoreBots: false)
    ..discoverServices()
    ..discoverCommands()
    //..registerTypeConverters([RunesConverter()])
    ..onError.listen((err) async {
      if (err.type == command.ExecutionErrorType.commandNotFound)
        await err.message.channel
            .send(content: "Command '${err.message.content}' not found!");

      if (err.type == command.ExecutionErrorType.cooldown) {
        await err.message.channel
            .send(content: "Command is on cooldown!. Wait a few seconds!");
      }
    });

  Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });

  bot.onReady.listen((e) async {
    var channel =
        bot.channels[nyxx.Snowflake('422285619952222208')] as nyxx.TextChannel;
    assert(channel != null);
    if (env['TRAVIS_BUILD_NUMBER'] != null) {
      channel.send(
          content:
              "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}` with Dart version: `${env['TRAVIS_DART_VERSION']}`");
    } else {
      channel.send(
          content:
              "Testing new local build");
    }

    print("TESTING CLIENT INTERNALS");

    nyxx.Snowflake a = nyxx.Snowflake.fromDateTime(new DateTime(2017));
    nyxx.Snowflake b = nyxx.Snowflake.fromDateTime(new DateTime(2018));

    assert(a.compareTo(b) > 0);
    assert(b.compareTo(a) < 0);

    assert(a.timestamp == new DateTime(2017));
    assert(b.timestamp == new DateTime(2018));

    assert(bot.channels.count > 0);
    assert(bot.users.count > 0);
    assert(bot.shards.length == 1);
    assert(bot.ready);
    assert(bot.inviteLink != null);

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

    print("TESTING SENDING FILES");
    var f = await channel
        .send(content: "PLIK SIEMA", files: [new File("test/kitty.webp")]);
    await f.delete();

    /*
    print("TESTING TYPECONVERTER");
    var g = await channel.send(content: "~~runes SIEMA");
    await g.delete(auditReason: "Reason on deleting");
    */

    print("TESTING EMBEDS");
    var e =
        await channel.send(content: "Testing embed!", embed: createTestEmbed());
    await e.delete();
  });

  bot.onMessageReceived.listen((e) async {
    var m = e.message;

    if (m.channel.id != "422285619952222208" && m.author.id != bot.self.id)
      return;

    if (ddel.any((d) => d.startsWith(m.content))) await m.delete();

    if (m.content == "PLIK SIEMA" && m.attachments.values.length > 0) {
      var att = m.attachments.values.first;

      if (att.filename != "kitty.webp") {
        exit(1);
      }
    }

    if (m.content == "Testing embed!") {
      if (m.embeds.length > 0) {
        var embed = m.embeds.first;
        if (embed.title == "Test title" && embed.fields.length > 0) {
          var field = embed.fields.first;

          if (field.name == "Test field" &&
              field.content == "Test value" &&
              !field.inline) {
            await m.channel.send(content: "Tests completed successfully!");
            print("Nyxx tests completed successfully!");
            exit(0);
          }
        }
      }
    }
  });
}
