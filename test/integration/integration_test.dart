import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

void main() {
  final testToken = Platform.environment['TEST_TOKEN'];
  final testTextChannel = Platform.environment['TEST_TEXT_CHANNEL'];

  test(
    'NyxxRest.connect',
    skip: testToken != null ? false : 'No test token provided',
    () async {
      expect(Nyxx.connectRest(testToken!), completes);
    },
  );

  group(
    'NyxxRest',
    skip: testToken != null ? false : 'No test token provided',
    () {
      late NyxxRest client;

      setUp(() async {
        client = await Nyxx.connectRest(testToken!);
      });

      group('users', () {
        test('fetchCurrentUser', () => expect(client.users.fetchCurrentUser(), completes));
        test('fetchCurrentUserConnections', () => expect(client.users.fetchCurrentUserConnections(), completes));
      });

      group(
        'channels',
        skip: testTextChannel != null ? false : 'No test channel provided',
        () {
          final channelId = Snowflake.parse(testTextChannel!);

          final env = Platform.environment;
          client.channels[channelId].sendMessage(MessageBuilder(
            content: env['GITHUB_RUN_NUMBER'] == null
                ? "Testing new local build. Nothing to worry about 😀"
                : "Running `nyxx` job `#${env['GITHUB_RUN_NUMBER']}` started by `${env['GITHUB_ACTOR']}` on `${env['GITHUB_REF']}` on commit `${env['GITHUB_SHA']}`",
          ));

          test('fetch', () => expect(client.channels.fetch(channelId), completes));

          test('basic message functionality', () async {
            Message message = await client.channels[channelId].sendMessage(MessageBuilder(
              content: 'A test message',
            ));

            expect(message.content, equals('A test message'));

            message = await message.update(MessageUpdateBuilder(
              content: 'Some different content',
            ));

            expect(message.content, equals('Some different content'));

            expect(message.delete(), completes);
          });

          test('upload files', () async {
            final message = await client.channels[channelId].sendMessage(MessageBuilder(
              attachments: [
                await AttachmentBuilder.fromFile(File('test/files/1.png')),
              ],
            ));

            expect(message.attachments, hasLength(1));
            expect(message.attachments.single.fileName, equals('1.png'));

            await message.delete();
          });
        },
      );
    },
  );
}
