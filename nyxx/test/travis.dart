import "dart:async";
import "dart:io";

import "package:nyxx/nyxx.dart";

// Replacement for assert. Throws if [test] isn't true.
void test(bool test, [String? name]) {
  if (!test) {
    throw AssertionError();
  } else {
    print("Test ${name != null ? "[$name] " : ""}passed");
  }
}

// Messages content on which we delete message
const toDeleteMessageContent = [
  "--trigger-test",
  "test is working correctly",
  "test is working correctly",
  "Command '~~notFound' not found!",
  "Command is on cooldown!. Wait a few seconds!",
  "14 Example data",
  "Converting successfull"
];

// -------------------------------------------------------

EmbedBuilder createTestEmbed() => EmbedBuilder()
  ..title = "Test title"
  ..addField(name: "Test field", content: "Test value");

// -------------------------------------------------------

void main() {
  final env = Platform.environment;
  final bot = Nyxx(env["DISCORD_TOKEN"]!, ignoreExceptions: false);

  Timer(const Duration(seconds: 60), () {
    print("Timed out waiting for messages");
    exit(1);
  });

  bot.onReady.listen((e) async {
    final channel = bot.channels[Snowflake(422285619952222208)] as TextGuildChannel?;
    test(channel != null, "Channel cannot be null");
    if (env["TRAVIS_BUILD_NUMBER"] != null) {
      await channel!.sendMessage(
          content:
              "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}` with Dart version: `${env['TRAVIS_DART_VERSION']}`");
    } else {
      await channel!.sendMessage(content: "Testing new local build");
    }

    print("TESTING CLIENT INTERNALS");

    final snowflakeA = Snowflake.fromDateTime(DateTime(2017));
    final snowflakeB = Snowflake.fromDateTime(DateTime(2018));

    test(snowflakeA.timestamp.isBefore(snowflakeB.timestamp), "Snowflake should be before timestamp");
    test(snowflakeB.timestamp.isAfter(snowflakeA.timestamp), "Snowflake should be after timestamp");

    test(snowflakeA.timestamp.isAtSameMomentAs(DateTime(2017)), "Snowflake should repsresent proper date");
    test(snowflakeB.timestamp.isAtSameMomentAs(DateTime(2018)), "Snowflake should repsresent proper date");

    test(bot.channels.count > 0, "Channel count shouldn't be less or equal zero");
    test(bot.users.count > 0, "Users coutn count should n't be less or equal zero");
    test(bot.shards == 1, "Shard count should be one");
    test(bot.ready, "Bot should be ready");
    //test(bot.inviteLink != null, "Bot's invite link shouldn't be null");

    print("TESTING BASIC FUNCTIONALITY!");
    final m = await channel.sendMessage(content: "Message test.");
    await m.edit(content: "Edit test.");

    await m.createReaction(UnicodeEmojiNew("😂"));
    await m.deleteSelfReaction(UnicodeEmojiNew("😂"));

    await m.delete();

    print("TESTING SENDING FILES");

    await channel.sendMessage(
        content: "PLIK SIEMA",
        files: [AttachmentBuilder.path("${Directory.current.path}/kitty.webp", spoiler: true)]).then((message) async => message.delete());

    print("TESTING ALLOWED MENTIONS");
    await channel.sendMessage(content: "@everyone HEJ", allowedMentions: AllowedMentions());

    print("TESTING EMBEDS");
    final e = await channel.sendMessage(content: "Testing embed!", embed: createTestEmbed());
    await e.delete();
  });

  bot.onMessageReceived.listen((e) async {
    if (e.message.channel.id != Snowflake("422285619952222208") && e.message.author.id != bot.self.id) {
      return;
    }

    if (toDeleteMessageContent.any((d) => d.startsWith(e.message.content))) {
      await e.message.delete();
    }

    if (e.message.content == "PLIK SIEMA" && e.message.attachments.isNotEmpty) {
      final att = e.message.attachments.first;

      if (att.filename != "SPOILER_kitty.webp" || !att.isSpoiler) {
        exit(1);
      }
    }

    if (e.message.content.endsWith("HEJ")) {
      if (e.message.mentionEveryone) {
        exit(1);
      }

      await e.message.delete();
    }

    if (e.message.content == "Testing embed!") {
      if (e.message.embeds.isNotEmpty) {
        final embed = e.message.embeds.first;
        if (embed.title == "Test title" && embed.fields.isNotEmpty) {
          final field = embed.fields.first;

          if (field.name == "Test field" && field.content == "Test value" && !field.inline!) {
            await (await e.message.channel.getOrDownload()).sendMessage(content: "Tests completed successfully!");
            print("Nyxx tests completed successfully!");
            print("Final memory usage: ${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB");
            exit(0);
          }
        }
      }
    }
  });
}
