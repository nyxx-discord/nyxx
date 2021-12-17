import 'dart:io';
import 'dart:math';

import 'package:nyxx/nyxx.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'package:nyxx/src/internal/event_controller.dart';

final testChannelSnowflake = Snowflake(846139169818017812);
final testGuildSnowflake = Snowflake(846136758470443069);
final testUserBotSnowflake = Snowflake(476603965396746242);
final testUserHumanSnowflake = Snowflake(302359032612651009);

main() async {
  final bot = NyxxFactory.createNyxxWebsocket(Platform.environment["TEST_TOKEN"]!, GatewayIntents.guildMessages, ignoreExceptions: false)
    ..registerPlugin(Logging())
    ..connect();

  final random = Random();

  late ITextChannel channel;

  await bot.eventsWs.onReady.first.then((value) async {
    channel = await bot.fetchChannel<ITextGuildChannel>(testChannelSnowflake);

    await channel.sendMessage(MessageBuilder.content(getChannelLogMessage()));
  });

  test('base nyxx', () {
    expect(bot.appId, equals(Snowflake(846158316467650561)));
    expect(bot.ready, isTrue);
    expect(bot.startTime.isBefore(DateTime.now()), isTrue);
    expect(bot.inviteLink, contains('846158316467650561'));
    expect(bot.version, isA<String>());
    expect(bot.shards, equals(1));

    expect(bot.eventsWs, isA<WebsocketEventController>());
    expect(bot.eventsRest, isA<RestEventController>());
    expect(bot.shardManager, isA<IShardManager>());
  });

  test('get invite', () async {
    final invite = await bot.getInvite('nyxx');

    expect(invite.code, equals('nyxx'));
    expect(invite.guild?.id, isNotNull);
    expect(invite.guild?.id, equals(Snowflake(846136758470443069)));
    expect(invite.url, equals('https://discord.gg/nyxx'));
  });

  test('fetch guild preview', () async {
    final guildPreview = await bot.fetchGuildPreview(testGuildSnowflake);

    expect(guildPreview.id, equals(testGuildSnowflake));
    expect(guildPreview.name, equals('nyxx'));

    expect(guildPreview.discoveryURL(), isNull);
    expect(guildPreview.splashURL(), isNull);
    expect(guildPreview.iconURL(), isNull);
  });

  test("basic message functionality", () async {
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

    await messageEdit.suppressEmbeds();

    await messageEdit.pinMessage();
    final pinnedMessages = await (await messageEdit.channel.getOrDownload()).fetchPinnedMessages().toList();
    expect(pinnedMessages, hasLength(1));
    expect(pinnedMessages.first.pinned, isTrue);
    expect(pinnedMessages.first.id, messageEdit.id);
    await messageEdit.unpinMessage();

    await messageEdit.dispose(); // it does nothing

    expect(messageEdit.hashCode, equals(messageEdit.id.hashCode));
    expect(messageEdit, equals(messageEditWs));

    final toBuilder = messageEdit.toBuilder();
    expect(toBuilder.content, equals("Edit test"));

    await messageEdit.delete();
  });

  test("file upload tests", () async {
    final messageBuilder = MessageBuilder.files([
      AttachmentBuilder.path('test/files/1.png'),
      AttachmentBuilder.path('test/files/2.png'),
    ]);

    final message = await channel.sendMessage(messageBuilder);

    expect(message.attachments, hasLength(2));

    final editedMessage = await message.edit(
      MessageBuilder()
          ..attachments = [message.attachments.first.toBuilder()]
          ..files = [AttachmentBuilder.path('test/files/3.png')]
    );

    expect(editedMessage.attachments, hasLength(2));

    await editedMessage.delete();
  });

  test("user tests", () async {
    final userBot = await bot.fetchUser(testUserBotSnowflake);

    expect(userBot.discriminator, equals(1759));
    expect(userBot.formattedDiscriminator, equals("1759"));
    expect(userBot.bot, isTrue);
    expect(userBot.mention, "<@!${testUserBotSnowflake.toString()}>");
    expect(userBot.tag, equals("Running on Dart#1759"));
    expect(userBot.avatarURL(), equals('https://cdn.discordapp.com/avatars/476603965396746242/be6107505d7b9d15292da4e54d88836e.webp?size=128'));
  });

  test('member and guild tests', () async {
    final guild = await bot.fetchGuild(testGuildSnowflake);

    expect(guild.afkChannel, isNull);
    expect(guild.name, 'nyxx');
    expect(guild.features, contains(GuildFeature.verified));

    final memberBot = await guild.fetchMember(testUserBotSnowflake);

    expect(memberBot.guild.id, equals(guild.id));
    expect(memberBot.voiceState, isNull);
    expect(memberBot.mention, "<@${memberBot.id.toString()}>");
    expect(memberBot.avatarURL(), isNull);

    final effectivePermissions = await memberBot.effectivePermissions;
    expect(effectivePermissions.sendMessages, isTrue);
  });

  test("guild events tests", () async {
    final guild = await bot.fetchGuild(testGuildSnowflake);

    final events = await guild.fetchGuildEvents().toList();
    expect(events, isEmpty);
  });
}

String getChannelLogMessage() {
  final env = Platform.environment;

  if (env['GITHUB_RUN_NUMBER'] == null) {
    return "Testing new local build. Nothing to worry about 😀";
  }

  return "Running `nyxx` job `#${env['GITHUB_RUN_NUMBER']}` started by `${env['GITHUB_ACTOR']}` on `${env['GITHUB_REF']}` on commit `${env['GITHUB_SHA']}`";
}
