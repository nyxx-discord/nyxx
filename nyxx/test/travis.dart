import 'dart:io';
import 'dart:async';

import 'package:nyxx/Vm.dart' as nyxx;
import 'package:nyxx/nyxx.dart' as nyxx;

// Replacement for assert. Throws if [test] isn't true.
void test(bool test, [String? name]) {
  if (!test) {
    throw new AssertionError();
  } else {
    print("Test ${name != null ? "[$name] " : ""}passed");
  }
}

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

// -------------------------------------------------------

nyxx.EmbedBuilder createTestEmbed() {
  return nyxx.EmbedBuilder()
    ..title = "Test title"
    ..addField(name: "Test field", content: "Test value");
}

// -------------------------------------------------------

void main() {
  nyxx.setupDefaultLogging();

  var env = Platform.environment;
  var bot = nyxx.NyxxVm(env['DISCORD_TOKEN'], ignoreExceptions: false);

  Timer(const Duration(seconds: 60), () {
    print('Timed out waiting for messages');
    exit(1);
  });

  bot.onReady.listen((e) async {
    var channel =
        bot.channels[nyxx.Snowflake('422285619952222208')] as nyxx.TextChannel?;
    test(channel != null, "Channel cannot be null");
    if (env['TRAVIS_BUILD_NUMBER'] != null) {
      channel!.send(
          content:
              "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}` with Dart version: `${env['TRAVIS_DART_VERSION']}`");
    } else {
      channel!.send(content: "Testing new local build");
    }

    print("TESTING CLIENT INTERNALS");

    nyxx.Snowflake a = nyxx.Snowflake.fromDateTime(new DateTime(2017));
    nyxx.Snowflake b = nyxx.Snowflake.fromDateTime(new DateTime(2018));

    test(a.timestamp.isBefore(b.timestamp),
        "Snowflake should be before timestamp");
    test(b.timestamp.isAfter(a.timestamp),
        "Snowflake should be after timestamp");

    test(a.timestamp.isAtSameMomentAs(DateTime(2017)),
        "Snowflake should repsresent proper date");
    test(b.timestamp.isAtSameMomentAs(DateTime(2018)),
        "Snowflake should repsresent proper date");

    test(bot.channels.count > 0,
        "Channel count shouldn't be less or equal zero");
    test(bot.users.count > 0,
        "Users coutn count should n't be less or equal zero");
    test(bot.shards == 1, "Shard count should be one");
    test(bot.ready, "Bot should be ready");
    //test(bot.inviteLink != null, "Bot's invite link shouldn't be null");

    print("TESTING BASIC FUNCTIONALITY!");
    var m = await channel.send(content: "Message test.");
    await m.edit(content: "Edit test.");

    await m.createReaction(nyxx.UnicodeEmoji('😂'));
    await m.deleteReaction(nyxx.UnicodeEmoji('😂'));

    await m.delete();

    print("TESTING SENDING FILES");
    channel.send(content: "PLIK SIEMA", files: [
      nyxx.AttachmentBuilder.path("test/kitty.webp", spoiler: true)
    ]).then((message) async => await message.delete());

    print("TESTING ALLOWED MENTIONS");
    channel.send(content: "@everyone HEJ", allowedMentions: nyxx.AllowedMentions());
    
    print("TESTING EMBEDS");
    var e =
        await channel.send(content: "Testing embed!", embed: createTestEmbed());
    await e.delete();
  });

  bot.onMessageReceived.listen((e) async {
    var m = e.message;

    if (m.channel.id != nyxx.Snowflake("422285619952222208") &&
        m.author.id != bot.self.id) return;

    if (ddel.any((d) => d.startsWith(m.content))) await m.delete();

    if (m.content == "PLIK SIEMA" && m.attachments.length > 0) {
      var att = m.attachments.first;

      if (att.filename != "SPOILER_kitty.webp") {
        exit(1);
      }
    }

    if(m.content.endsWith("HEJ")) {
      if(m.mentionEveryone) {
        exit(1);
      }

      await m.delete();
    }

    if (m.content == "Testing embed!") {
      if (m.embeds.length > 0) {
        var embed = m.embeds.first;
        if (embed.title == "Test title" && embed.fields.length > 0) {
          var field = embed.fields.first;

          if (field.name == "Test field" &&
              field.content == "Test value" &&
              !field.inline!) {
            await m.channel.send(content: "Tests completed successfully!");
            print("Nyxx tests completed successfully!");
            exit(0);
          }
        }
      }
    }
  });
}
