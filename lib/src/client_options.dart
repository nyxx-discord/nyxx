import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/models/user/user.dart';

/// Options for controlling the behavior of a [Nyxx] client.
abstract class ClientOptions {}

/// Options for controlling the behavior of a [NyxxRest] client.
class RestClientOptions implements ClientOptions {
  /// The [CacheConfig] to use for the cache of the [NyxxRest.users] manager.
  final CacheConfig<User> userCacheConfig;

  /// Create a new [RestClientOptions].
  RestClientOptions({this.userCacheConfig = const CacheConfig()});
}
