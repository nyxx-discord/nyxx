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
      client = await Nyxx.connectRest(testToken!);
    });

    tearDownAll(() async {
      // Reset commands state in case we failed a test without deleting them.
      await client.commands.bulkOverride([]);

      await client.close();
    });

    test('client.user', () async {
      await expectLater(client.user.get(), completes);
    });

    test('client.application', () {
      expect(client.application.id, isNot(Snowflake.zero));
    });

    test('applications', () async {
      late Application application;

      await expectLater(() async => application = await client.applications.fetchCurrentApplication(), completes);
      await expectLater(client.applications.updateCurrentApplication(ApplicationUpdateBuilder(description: application.description)), completes);
    });

    test('skus', () async {
      await expectLater(client.application.skus.list(), completes);
    });

    test('users', () async {
      await expectLater(client.users.fetchCurrentUser(), completes);
      await expectLater(client.users.listCurrentUserGuilds(), completes);
      await expectLater(client.users.fetchCurrentUserConnections(), completes);

      final avatar = (await client.user.get()).avatar;

      try {
        await expectLater(
          client.users.updateCurrentUser(UserUpdateBuilder(
            avatar: ImageBuilder(data: await avatar.fetch(), format: avatar.defaultFormat.extension),
          )),
          completes,
        );
      } on HttpResponseError catch (e) {
        if (e.errorCode == 50053 && e.errorData?.fieldErrors['avatar']?.errorCode == 'AVATAR_RATE_LIMIT') {
          markTestSkipped('Avatar changes rate limited');
        } else {
          rethrow;
        }
      }
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

      try {
        await expectLater(message.pin(), completes);
        await expectLater(message.unpin(), completes);
      } on HttpResponseError catch (e) {
        // Missing permissions.
        if (e.errorCode != 50013) rethrow;
      }

      await expectLater(
        () async => message = await channel.sendMessage(MessageBuilder(
          referencedMessage: MessageReferenceBuilder.forward(messageId: message.id, channelId: channelId),
        )),
        completes,
      );

      await expectLater(
        message.reference?.message?.delete(),
        allOf(
          isNotNull,
          completes,
        ),
      );

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

      await expectLater(message.attachments.first.fetch(), completes);
      await expectLater(message.attachments.first.fetchStreamed().drain(), completes);

      late Message message2;
      await expectLater(
        () async => message2 = await channel.sendMessage(MessageBuilder(
          attachments: [
            await AttachmentBuilder.fromFile(File('test/files/2.png')),
            await AttachmentBuilder.fromFile(File('test/files/3.png')),
          ],
        )),
        completes,
      );

      try {
        await expectLater(channel.messages.bulkDelete([message.id, message2.id]), completes);
      } on HttpResponseError catch (e) {
        // Missing permissions.
        if (e.errorCode != 50013) rethrow;
      }

      await expectLater(
        () async => message = await channel.sendMessage(
          MessageBuilder(
            content: 'Components test',
            components: [
              ActionRowBuilder(components: [
                ButtonBuilder(style: ButtonStyle.primary, label: 'Primary', customId: 'a'),
                ButtonBuilder(style: ButtonStyle.secondary, label: 'Secondary', customId: 'b'),
                ButtonBuilder(style: ButtonStyle.success, label: 'Success', customId: 'c'),
                ButtonBuilder(style: ButtonStyle.danger, label: 'Danger', customId: 'd'),
                ButtonBuilder(style: ButtonStyle.link, label: 'Primary', url: Uri.https('pub.dev', '/packages/nyxx')),
              ]),
              ActionRowBuilder(components: [
                ButtonBuilder(style: ButtonStyle.primary, label: 'Primary', customId: 'e', isDisabled: true),
                ButtonBuilder(style: ButtonStyle.secondary, label: 'Secondary', customId: 'f', isDisabled: true),
                ButtonBuilder(style: ButtonStyle.success, label: 'Success', customId: 'g', isDisabled: true),
                ButtonBuilder(style: ButtonStyle.danger, label: 'Danger', customId: 'h', isDisabled: true),
                ButtonBuilder(style: ButtonStyle.link, label: 'Primary', url: Uri.https('pub.dev', '/packages/nyxx'), isDisabled: true),
              ]),
              ActionRowBuilder(components: [
                SelectMenuBuilder(
                  type: MessageComponentType.stringSelect,
                  customId: 'i',
                  options: [
                    SelectMenuOptionBuilder(label: 'One', value: '1'),
                    SelectMenuOptionBuilder(
                      label: 'Two',
                      value: '2',
                      emoji: TextEmoji(
                        id: Snowflake.zero,
                        manager: client.guilds[Snowflake.zero].emojis,
                        name: '❤️',
                      ),
                    ),
                    SelectMenuOptionBuilder(label: 'Three', value: '3'),
                  ],
                ),
              ]),
            ],
          ),
        ),
        completes,
      );

      await expectLater(message.delete(), completes);

      await expectLater(
        () async => message = await channel.sendMessage(
          MessageBuilder(
            content: 'Polls test',
            poll: PollBuilder(
                question: PollMediaBuilder(text: 'Question'),
                answers: [
                  PollAnswerBuilder(pollMedia: PollMediaBuilder(text: 'Answer 1')),
                  PollAnswerBuilder(
                      pollMedia:
                          PollMediaBuilder(text: 'Answer 2', emoji: TextEmoji(id: Snowflake.zero, manager: client.guilds[Snowflake.zero].emojis, name: '👽'))),
                  PollAnswerBuilder.text('Answer 3'),
                  PollAnswerBuilder.text('Answer 4', TextEmoji(id: Snowflake.zero, manager: client.guilds[Snowflake.zero].emojis, name: '👽'))
                ],
                duration: Duration(hours: 5)),
          ),
        ),
        completes,
      );

      expect(message.poll, isNotNull);
      final poll = message.poll!;

      expect(poll.answers, hasLength(4));

      await expectLater(message.fetchAnswerVoters(poll.answers[0].id), completes);
      await expectLater(message.endPoll(), completes);
      await expectLater(message.delete(), completes);

      await expectLater(
          () async => message = await channel.sendMessage(
                MessageBuilder(
                  flags: MessageFlags.isComponentsV2,
                  attachments: [
                    await AttachmentBuilder.fromFile(File('test/files/1.png')),
                    await AttachmentBuilder.fromFile(File('test/files/2.png')),
                    await AttachmentBuilder.fromFile(File('test/files/3.png')),
                  ],
                  components: [
                    TextDisplayComponentBuilder(content: 'Components V2! Yeah!'),
                    SectionComponentBuilder(
                      accessory: ThumbnailComponentBuilder(
                        media: UnfurledMediaItemBuilder(url: Uri(scheme: 'attachment', host: '1.png')),
                      ),
                      components: [
                        TextDisplayComponentBuilder(content: 'One line....'),
                        TextDisplayComponentBuilder(content: 'Two lines........'),
                        TextDisplayComponentBuilder(content: 'Three lines!'),
                      ],
                    ),
                    SeparatorComponentBuilder(),
                    ContainerComponentBuilder(
                      accentColor: DiscordColor.fromRgb(255, 150, 150),
                      components: [
                        TextDisplayComponentBuilder(content: 'This is a container. It can contain other stuff too:'),
                        MediaGalleryComponentBuilder(items: [
                          MediaGalleryItemBuilder(
                            media: UnfurledMediaItemBuilder(url: Uri(scheme: 'attachment', host: '1.png')),
                          ),
                          MediaGalleryItemBuilder(
                            media: UnfurledMediaItemBuilder(url: Uri(scheme: 'attachment', host: '2.png')),
                          ),
                          MediaGalleryItemBuilder(
                            media: UnfurledMediaItemBuilder(url: Uri(scheme: 'attachment', host: '3.png')),
                          ),
                        ]),
                        TextDisplayComponentBuilder(content: "And that's pretty cool ;)"),
                      ],
                    ),
                  ],
                ),
              ),
          completes);

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
        webhook.delete(auditLogReason: 'Testing Unicode in audit log reason 😀'),
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

    test('commands', () async {
      late ApplicationCommand command;

      await expectLater(
        () async => command = await client.commands.create(ApplicationCommandBuilder.chatInput(name: 'test', description: 'A test command', options: [])),
        completes,
      );

      await expectLater(command.fetch(), completes);
      await expectLater(command.update(ApplicationCommandUpdateBuilder.chatInput(name: 'new_name')), completes);
      await expectLater(client.commands.list(), completion(contains(command)));
      await expectLater(
        () async => command =
            (await client.commands.bulkOverride([ApplicationCommandBuilder.chatInput(name: 'test_2', description: 'A test command', options: [])])).single,
        completes,
      );

      if (testGuild != null) {
        final testGuildId = Snowflake.parse(testGuild);
        final guild = client.guilds[testGuildId];

        await expectLater(guild.commands.listPermissions(), completes);
        await expectLater(guild.commands.fetchPermissions(command.id), completes);
      }

      await expectLater(command.delete(), completes);
    });

    test('Soundboard', skip: testGuild != null ? false : 'No test guild provided', () async {
      final guildId = Snowflake.parse(testGuild!);
      final guild = client.guilds[guildId];

      await expectLater(guild.soundboard.list(), completion(isEmpty));

      late SoundboardSound sound;
      await expectLater(
        () async => sound = await guild.soundboard.create(
          SoundboardSoundBuilder(
            name: 'Test sound',
            volume: 0.5,
            sound: await SoundBuilder.fromFile(File('test/files/sound.ogg')),
          ),
        ),
        completes,
      );

      await expectLater(sound.update(SoundboardSoundUpdateBuilder(name: 'New name')), completes);
      await expectLater(sound.delete(), completes);
    });
  });
}
