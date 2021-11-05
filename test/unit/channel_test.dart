import 'package:nyxx/nyxx.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

import '../mocks/channel.mocks.dart';

void main() {
  group("Channel:Text", () {
    test("Send message", () async {
      final mockChannel = MockTextChannel(testChannelId);

      final msg = await mockChannel.sendMessage(MessageBuilder.content(testMessageContent));

      expect(msg, isNotNull);
      expect(msg.id, testMessageId);
      expect(msg.content, testMessageContent);
    });

    group("Get Message", () {
      test("In Cache", () {
        final mockChannel = MockTextChannel(testChannelId);
        final messageId = 901383853648801823.toSnowflake();

        final msg = mockChannel.getMessage(messageId);

        expect(msg, isNotNull);
        expect(msg!.id, messageId);
      });

      test("Not In Cache", () {
        final mockChannel = MockTextChannel(testChannelId, shouldFail: true);
        final messageId = 901383853648801823.toSnowflake();

        final msg = mockChannel.getMessage(messageId);

        expect(msg, isNull);
      });
    });

    test("Fetch Message", () async {
      final mockChannel = MockTextChannel(testChannelId);
      final messageId = 901383024170631230.toSnowflake();

      final msg = await mockChannel.fetchMessage(messageId);

      expect(msg, isNotNull);
      expect(msg.id, messageId);
      expect(msg.content, testMessageContent);
    });
  });
}
