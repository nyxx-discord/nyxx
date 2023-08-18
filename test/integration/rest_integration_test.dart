import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart' hide completes;

import '../function_completes.dart';
import '../mocks/client.dart';

void main() {
  final testToken = Platform.environment['TEST_TOKEN'];
  final testTextChannel = Platform.environment['TEST_TEXT_CHANNEL'];
  final testGuild = Platform.environment['TEST_GUILD'];

  test('Nyxx.connectRest', skip: testToken != null ? false : 'No test token provided', () async {
    late NyxxRest client;

    await expectLater(() async => client = await Nyxx.connectRest(testToken!), completes);
    await expectLater(client.close(), completes);
  });

  group('HttpHandler', () {
    test('latency & realLatency', () async {
      final client = MockNyxx();
      when(() => client.apiOptions).thenReturn(RestApiOptions(token: 'TEST_TOKEN'));
      when(() => client.options).thenReturn(RestClientOptions());

      final handler = HttpHandler(client);
      final request = BasicRequest(HttpRoute(), method: 'HEAD');

      for (int i = 0; i < 5; i++) {
        await handler.execute(request);
      }

      expect(handler.latency, greaterThan(Duration.zero));
      expect(handler.realLatency, greaterThan(Duration.zero));
    });
  });

  group('NyxxRest', skip: testToken != null ? false : 'No test token provided', () {
    late NyxxRest client;

    // package:test doesn't seem to re-run the body of the group for each test, so
    // the tests end up conflicting & closing each other's clients since they all
    // refer to the same variable if we use setUp and tearDown. use the All variants
    // to mitigate this.
    setUpAll(() async {
      client = await Nyxx.connectRest(testToken!, options: RestClientOptions(applicationId: Snowflake.zero));
    });

    tearDownAll(() async {
      await client.close();
    });

    test('applications', () async {
      await expectLater(client.applications.fetchCurrentApplication(), completes);
    });

    test('users', () async {
      await expectLater(client.users.fetchCurrentUser(), completes);
      await expectLater(client.users.listCurrentUserGuilds(), completes);
      await expectLater(client.users.fetchCurrentUserConnections(), completes);
    });

    test('channels', skip: testTextChannel != null ? false : 'No test channel provided', () async {
      final channelId = Snowflake.parse(testTextChannel!);

      await expectLater(client.channels.fetch(channelId), completes);
    });

    test('messages', skip: testTextChannel != null ? false : 'No test channel provided', () async {
      final channelId = Snowflake.parse(testTextChannel!);
      final channel = await client.channels.get(channelId) as TextChannel;

      final env = Platform.environment;

      await expectLater(
        channel.sendMessage(MessageBuilder(
          content: env['GITHUB_RUN_NUMBER'] == null
              ? "Testing new local build. Nothing to worry about 😀"
              : "Running `nyxx` job `#${env['GITHUB_RUN_NUMBER']}` started by `${env['GITHUB_ACTOR']}` on `${env['GITHUB_REF']}` on commit `${env['GITHUB_SHA']}`",
        )),
        completes,
      );

      late Message message;
      await expectLater(
        () async => message = await channel.sendMessage(MessageBuilder(content: 'Test message')),
        completes,
      );

      expect(message.content, equals('Test message'));

      await expectLater(
        () async => message = await message.update(MessageUpdateBuilder(content: 'New content')),
        completes,
      );

      expect(message.content, equals('New content'));

      await expectLater(message.pin(), completes);
      await expectLater(message.unpin(), completes);

      await expectLater(message.delete(), completes);

      await expectLater(
        () async => message = await channel.sendMessage(MessageBuilder(
          attachments: [
            await AttachmentBuilder.fromFile(File('test/files/1.png')),
          ],
        )),
        completes,
      );

      expect(message.attachments, hasLength(1));
      expect(message.attachments.first.fileName, equals('1.png'));

      await expectLater(message.delete(), completes);
    });

    test('webhooks', skip: testTextChannel != null ? false : 'No test channel provided', () async {
      final channelId = Snowflake.parse(testTextChannel!);

      late Webhook webhook;
      await expectLater(
        () async => webhook = await client.webhooks.create(WebhookBuilder(
          name: 'Test webhook',
          channelId: channelId,
        )),
        completes,
      );

      expect(webhook.name, equals('Test webhook'));
      expect(webhook.token, isNotNull);

      await expectLater(
        () async => webhook = await webhook.update(WebhookUpdateBuilder(name: 'New name')),
        completes,
      );

      expect(webhook.name, equals('New name'));
      expect(webhook.token, isNotNull);

      final token = webhook.token!;

      late Message message;
      await expectLater(
        () async => message = (await webhook.execute(token: token, wait: true, MessageBuilder(content: 'Test webhook message')))!,
        completes,
      );

      expect(message.content, equals('Test webhook message'));
      expect(message.author.id, equals(webhook.id));

      await expectLater(
        () async => message = await webhook.updateMessage(message.id, token: token, MessageUpdateBuilder(content: 'New webhook content')),
        completes,
      );

      expect(message.content, equals('New webhook content'));

      await expectLater(
        webhook.deleteMessage(message.id, token: token),
        completes,
      );

      await expectLater(
        webhook.delete(),
        completes,
      );
    });

    test('voice', () async {
      await expectLater(client.voice.listRegions(), completes);
    });

    test('guilds', skip: testGuild != null ? false : 'No test guild provided', () async {
      final guildId = Snowflake.parse(testGuild!);

      late Guild guild;
      await expectLater(() async => guild = await client.guilds.fetch(guildId), completes);

      await expectLater(guild.fetchPreview(), completes);
      await expectLater(guild.fetchChannels(), completes);
      await expectLater(guild.listActiveThreads(), completes);
      await expectLater(guild.listVoiceRegions(), completes);

      if (guild.isWidgetEnabled) {
        await expectLater(guild.fetchWidget(), completes);
        await expectLater(guild.fetchWidgetImage(), completes);
      }

      if (guild.features.hasWelcomeScreenEnabled) {
        await expectLater(guild.fetchWelcomeScreen(), completes);
      }

      await expectLater(guild.fetchOnboarding(), completes);
    });

    test('members', skip: testGuild != null ? false : 'No test guild provided', () async {
      final guildId = Snowflake.parse(testGuild!);

      final user = await client.users.fetchCurrentUser();
      await expectLater(client.guilds[guildId].members.fetch(user.id), completes);
    });

    test('roles', skip: testGuild != null ? false : 'No test guild provided', () async {
      final guildId = Snowflake.parse(testGuild!);

      await expectLater(client.guilds[guildId].roles.list(), completes);
    });

    test('gateway', () async {
      await expectLater(client.gateway.fetchGatewayBot(), completes);
      await expectLater(client.gateway.fetchGatewayConfiguration(), completes);
    });

    test('scheduledEvents', skip: testGuild != null ? false : 'No test guild provided', () async {
      final guildId = Snowflake.parse(testGuild!);
      final guild = client.guilds[guildId];

      await expectLater(guild.scheduledEvents.list(), completes);
    });

    test('emojis', skip: testGuild != null ? false : 'No test guild provided', () async {
      final guildId = Snowflake.parse(testGuild!);

      await expectLater(client.guilds[guildId].emojis.list(), completes);
    });

    test('CDN assets', () async {
      final user = await client.users.fetchCurrentUser();

      await expectLater(user.avatar.fetch(), completes);

      if (user.banner != null) {
        await expectLater(user.banner!.fetch(), completes);
      }

      if (testGuild != null) {
        final guildId = Snowflake.parse(testGuild);
        final guild = await client.guilds[guildId].get();

        final emoji = guild.emojiList.firstOrNull as GuildEmoji?;
        if (emoji != null) {
          await expectLater(emoji.image.fetch(), completes);
        }

        final role = guild.roleList.firstOrNull;
        if (role != null && role.icon != null) {
          await expectLater(role.icon!.fetch(), completes);
        }

        if (guild.icon != null) {
          await expectLater(guild.icon!.fetch(), completes);
        }

        if (guild.splash != null) {
          await expectLater(guild.splash!.fetch(), completes);
        }

        if (guild.discoverySplash != null) {
          await expectLater(guild.discoverySplash!.fetch(), completes);
        }

        if (guild.banner != null) {
          await expectLater(guild.banner!.fetch(), completes);
        }

        final member = await guild.members[user.id].get();
        if (member.avatar != null) {
          await expectLater(member.avatar!.fetch(), completes);
        }
      }
    });
  });
}
