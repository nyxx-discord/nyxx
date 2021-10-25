import 'dart:io';
import 'dart:math';

import 'package:nyxx/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

main() async {
  final bot = NyxxFactory.createNyxxWebsocket(Platform.environment["TEST_TOKEN"]!, GatewayIntents.guildMessages, ignoreExceptions: false);
  final random = Random();

  await bot.eventsWs.onReady.first;

  final channel = await bot.fetchChannel<ITextGuildChannel>(Snowflake(846139169818017812));

  test("basic message functionality", () async {
    final messageBuilder = MessageBuilder()
        ..content = "Test content"
        ..nonce = random.nextInt(1000000).toString();

    final wsMessageFuture = bot.eventsWs.onMessageReceived.firstWhere((element) => element.message.nonce == messageBuilder.nonce);

    final message = await channel.sendMessage(messageBuilder);
    final wsMessage = await wsMessageFuture;

    expect(message.id, equals(wsMessage.message.id));

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
}
