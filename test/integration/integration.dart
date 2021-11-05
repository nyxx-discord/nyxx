import 'dart:io';
import 'dart:math';

import 'package:nyxx/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

final testChannelSnowflake = Snowflake(846139169818017812);
final testGuildSnowflake = Snowflake(846136758470443069);
final testUserBotSnowflake = Snowflake(476603965396746242);
final testUserHumanSnowflake = Snowflake(302359032612651009);

main() async {
  final bot = NyxxFactory.createNyxxWebsocket(Platform.environment["TEST_TOKEN"]!, GatewayIntents.guildMessages, ignoreExceptions: false);
  final random = Random();

  await bot.eventsWs.onReady.first;

  test("basic message functionality", () async {
    final channel = await bot.fetchChannel<ITextGuildChannel>(testChannelSnowflake);

    final messageBuilder = MessageBuilder()
      ..content = "Test content"
      ..nonce = random.nextInt(1000000).toString();

    final wsMessageFuture = bot.eventsWs.onMessageReceived.firstWhere((element) => element.message.nonce == messageBuilder.nonce);

    final message = await channel.sendMessage(messageBuilder);
    final wsMessage = (await wsMessageFuture).message;

    expect(message.id, equals(wsMessage.id));
    expect(message.guild, isNull);
    expect(wsMessage.guild, isNotNull);

    expect(message.isByWebhook, equals(false));
    expect(message.isCrossPosting, equals(false));
    expect(wsMessage.url, equals("https://discordapp.com/channels/${wsMessage.guild!.id}/${message.channel.id}/${message.id}"));

    final messageEditBuilder = MessageBuilder()
      ..content = 'Edit test'
      ..nonce = random.nextInt(1000000).toString();

    final messageEditWsFuture = bot.eventsWs.onMessageUpdate.firstWhere((element) => element.messageId == message.id);
    final messageEdit = await message.edit(messageEditBuilder);
    final messageEditWs = await channel.fetchMessage((await messageEditWsFuture).messageId);

    expect(messageEdit.id, equals(messageEditWs.id));
    expect(messageEdit.content, equals("Edit test"));
    expect(messageEditWs.content, equals("Edit test"));

    await messageEdit.createReaction(UnicodeEmoji("😂"));
    await messageEdit.deleteSelfReaction(UnicodeEmoji("😂"));

    await messageEdit.delete();
  });

  test("user tests", () async {
    final userBot = await bot.fetchUser(testUserBotSnowflake);

    expect(userBot.discriminator, equals(1759));
    expect(userBot.formattedDiscriminator, equals("1759"));
    expect(userBot.bot, isTrue);
    expect(userBot.mention, "<@!${testUserBotSnowflake.toString()}>");
    expect(userBot.tag, equals("Running on Dart#1759"));
    expect(userBot.avatarURL(), equals('https://cdn.discordapp.com/avatars/476603965396746242/be6107505d7b9d15292da4e54d88836e.webp?size=128'));

    // final userHuman = await bot.fetchUser(testUserHumanSnowflake);
  });
}
