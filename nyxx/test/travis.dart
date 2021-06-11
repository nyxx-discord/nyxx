import "dart:async";
import "dart:io";

import "package:nyxx/nyxx.dart";

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

EmbedBuilder createTestEmbed() => EmbedBuilder()
  ..title = "Test title"
  ..addField(name: "Test field", content: "Test value", inline: true);

void main() {
  final env = Platform.environment;
  final bot = Nyxx(env["TEST_TOKEN"]!, GatewayIntents.guildMessages, ignoreExceptions: false);

  Timer(const Duration(seconds: 60), () {
    print("Timed out waiting for messages");
    exit(1);
  });

  bot.onReady.listen((e) async {
    final channel = await bot.fetchChannel<TextGuildChannel>(Snowflake(846139169818017812));
    // test(channel != null, "Channel cannot be null");
    if (env["GITHUB_RUN_NUMBER"] != null) {
      await channel.sendMessage(
          MessageBuilder.content("Testing new build `#${env['GITHUB_RUN_NUMBER']}` (ID: `${env['GITHUB_RUN_ID']}`) from commit `${env['GITHUB_SHA']}` started by `${env['GITHUB_ACTOR']}`")
      );
    } else {
      await channel.sendMessage(MessageBuilder.content("Testing new local build"));
    }

    print("TESTING BASIC FUNCTIONALITY!");
    final m = await channel.sendMessage(MessageBuilder.content("Message test."));
    await m.edit(MessageBuilder.content("Edit test."));

    await m.createReaction(UnicodeEmoji("😂"));
    await m.deleteSelfReaction(UnicodeEmoji("😂"));

    await m.delete();

    print("TESTING SENDING FILES");

    await channel.sendMessage(MessageBuilder.content("PLIK SIEMA")..files = [AttachmentBuilder.path("./kitty.webp", spoiler: true)])
        .then((message) async => message.delete());

    print("TESTING ALLOWED MENTIONS");
    await channel.sendMessage(MessageBuilder.content("@everyone HEJ")..allowedMentions = AllowedMentions());

    print("TESTING EMBEDS");
    await channel.sendMessage(MessageBuilder.content("Testing embed!")..embeds = [createTestEmbed()]);
  });

  bot.onMessageReceived.listen((e) async {
    if (e.message.channel.id != Snowflake("846139169818017812") && e.message.author.id != bot.self.id) {
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

          if (field.name == "Test field" && field.content == "Test value" && field.inline!) {
            await (await e.message.channel.getOrDownload()).sendMessage(MessageBuilder.content("Tests completed successfully!"));
            await e.message.delete();
            print("Nyxx tests completed successfully!");
            print("Final memory usage: ${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB");
            exit(0);
          }
        }
      }
    }
  });
}
