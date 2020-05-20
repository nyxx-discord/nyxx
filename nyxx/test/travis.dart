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
  setupDefaultLogging();

  final env = Platform.environment;
  final bot = Nyxx(env["DISCORD_TOKEN"]!, ignoreExceptions: false);

  Timer(const Duration(seconds: 60), () {
    print("Timed out waiting for messages");
    exit(1);
  });

  bot.onReady.listen((e) async {
    final channel = bot.channels[Snowflake(422285619952222208)] as CachelessTextChannel?;
    test(channel != null, "Channel cannot be null");
    if (env["TRAVIS_BUILD_NUMBER"] != null) {
      await channel!.send(
          content:
              "Testing new Travis CI build `#${env['TRAVIS_BUILD_NUMBER']}` from commit `${env['TRAVIS_COMMIT']}` on branch `${env['TRAVIS_BRANCH']}` with Dart version: `${env['TRAVIS_DART_VERSION']}`");
    } else {
      await channel!.send(content: "Testing new local build");
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
    final m = await channel.send(content: "Message test.");
    await m.edit(content: "Edit test.");

    await m.createReaction(UnicodeEmoji("😂"));
    await m.deleteReaction(UnicodeEmoji("😂"));

    await m.delete();

    print("TESTING SENDING FILES");
    await channel.send(
        content: "PLIK SIEMA",
        files: [AttachmentBuilder.path("test/kitty.webp", spoiler: true)]).then((message) async => message.delete());

    print("TESTING ALLOWED MENTIONS");
    await channel.send(content: "@everyone HEJ", allowedMentions: AllowedMentions());

    print("TESTING EMBEDS");
    final e = await channel.send(content: "Testing embed!", embed: createTestEmbed());
    await e.delete();
  });

  bot.onMessageReceived.listen((e) async {
    if (e.message.channelId != Snowflake("422285619952222208") && e.message.author.id != bot.self.id) {
      return;
    }

    if (toDeleteMessageContent.any((d) => d.startsWith(e.message.content))) {
      await e.message.delete();
    }

    if (e.message.content == "PLIK SIEMA" && e.message.attachments.isNotEmpty) {
      final att = e.message.attachments.first;

      if (att.filename != "SPOILER_kitty.webp") {
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
            await e.message.channel?.send(content: "Tests completed successfully!");
            print("Nyxx tests completed successfully!");
            exit(0);
          }
        }
      }
    }
  });
}
