import 'package:nyxx/nyxx.dart';
import 'package:test/fake.dart';

import 'Message.mocks.dart';

// Constants For DM Channel Testing.
final Snowflake testMessageId = 901383332011593750.toSnowflake();
final Snowflake testChannelId = 896714099226992671.toSnowflake();
const String testMessageContent = "Test Message.";

class MockTextChannel extends SnowflakeEntity with Fake implements ITextChannel {
	final bool shouldFail;

  MockTextChannel(Snowflake id, {this.shouldFail = false}) : super(id);

  @override
  Future<void> bulkRemoveMessages(Iterable<IMessage> messages) {
    throw UnimplementedError();
  }

  @override
  ChannelType get channelType => throw UnimplementedError();

  @override
  INyxx get client => throw UnimplementedError();

  @override
  Future<void> delete() {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) {
    throw UnimplementedError();
  }

  @override
  Future<IMessage> fetchMessage(Snowflake id) {
    return Future.value(MockMessage({
			"content": testMessageContent
		}, id));
  }

  @override
  Stream<IMessage> fetchPinnedMessages() {
    throw UnimplementedError();
  }

  @override
  Future<int> get fileUploadLimit => throw UnimplementedError();

  @override
  IMessage? getMessage(Snowflake id) {
    if(shouldFail) {
			return null;
		}

		return MockMessage({
			"content": testMessageContent
		}, id);
  }

  @override
  bool get isGroupDM => throw UnimplementedError();

  @override
  Map<Snowflake, IMessage> get messageCache => throw UnimplementedError();

  @override
  IUser get participant => throw UnimplementedError();

  @override
  Iterable<IUser> get participants => throw UnimplementedError();

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => Future.value(MockMessage(<String, dynamic>{
			"content": builder.content
		}, testMessageId));

  @override
  Future<void> startTyping() {
    throw UnimplementedError();
  }

  @override
  void startTypingLoop() {
		throw UnimplementedError();
  }

  @override
  void stopTypingLoop() {
		throw UnimplementedError();
  }

}