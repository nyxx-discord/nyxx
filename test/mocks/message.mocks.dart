import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';

class MockMessage extends SnowflakeEntity with Fake implements IMessage {
  /// The message's content.
  @override
  late String content;

  MockMessage(RawApiMap rawData, Snowflake id) : super(id) {
    content = rawData["content"] as String;
  }
}
