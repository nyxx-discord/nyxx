import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';

import 'nyxx_rest.mock.dart';

class MockMessage extends SnowflakeEntity with Fake implements IMessage {
  @override
  late String content;

  @override
  Cacheable<Snowflake, IGuild>? get guild => GuildCacheable(NyxxRestEmptyMock(), Snowflake.zero());

  @override
  IMember? get member => null;

  MockMessage(RawApiMap rawData, Snowflake id) : super(id) {
    content = rawData["content"] as String;
  }
}
