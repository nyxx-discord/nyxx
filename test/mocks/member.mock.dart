import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';

import 'nyxx_rest.mock.dart';

class MockMember extends SnowflakeEntity with Fake implements IMember {
  @override
  Cacheable<Snowflake, IUser> get user => UserCacheable(NyxxRestEmptyMock(), Snowflake.zero());

  // TODO: not ideal way of handling these kind of stuff. Should be moved to some kind of helper to maintain single logic for formatting everywhere
  @override
  String get mention => '<@$id>';

  MockMember(Snowflake id) : super(id);
}
