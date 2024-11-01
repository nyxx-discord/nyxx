import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/manager_mixin.dart';

import 'gateway.dart';

class MockNyxx with Mock, ManagerMixin implements NyxxRest {
  @override
  PartialApplication get application => applications[Snowflake.zero];

  @override
  PartialUser get user => users[Snowflake.zero];

  @override
  late final CacheManager cache = CacheManager(this);
}

class MockNyxxGateway with Mock, ManagerMixin implements NyxxGateway {
  @override
  Gateway get gateway => MockGateway();

  @override
  late final CacheManager cache = CacheManager(this);
}
