import 'package:nyxx/nyxx.dart';
import 'package:test/fake.dart';

import 'message.mock.dart';

// Constants For DM Channel Testing.
final Snowflake testMessageId = 901383332011593750.toSnowflake();
final Snowflake testChannelId = 896714099226992671.toSnowflake();
const String testMessageContent = "Test Message.";

class MockThreadChannel extends SnowflakeEntity with Fake implements IThreadChannel {
  MockThreadChannel(Snowflake id) : super(id);
}

class MockVoiceChannel extends SnowflakeEntity with Fake implements IVoiceGuildChannel {
  MockVoiceChannel(Snowflake id) : super(id);
}

class MockTextChannel extends SnowflakeEntity with Fake implements ITextChannel {
  final bool shouldFail;

  MockTextChannel(Snowflake id, {this.shouldFail = false}) : super(id);

  @override
  Future<IMessage> fetchMessage(Snowflake id) {
    return Future.value(MockMessage({"content": testMessageContent}, id));
  }

  @override
  IMessage? getMessage(Snowflake id) {
    if (shouldFail) {
      return null;
    }

    return MockMessage({"content": testMessageContent}, id);
  }

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => Future.value(MockMessage(<String, dynamic>{"content": builder.content}, testMessageId));
}
