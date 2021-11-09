import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';

import 'nyxx_rest.mock.dart';

class MockMember extends SnowflakeEntity with Fake implements IMember {
  @override
  Cacheable<Snowflake, IUser> get user => UserCacheable(NyxxRestEmptyMock(), Snowflake.zero());

  MockMember(Snowflake id) : super(id);
}
