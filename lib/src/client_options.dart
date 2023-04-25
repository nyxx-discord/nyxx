import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/user/user.dart';

/// Options for controlling the behavior of a [Nyxx] client.
abstract class ClientOptions {}

/// Options for controlling the behavior of a [NyxxRest] client.
class RestClientOptions implements ClientOptions {
  /// The [CacheConfig] to use for the cache of the [NyxxRest.users] manager.
  final CacheConfig<User> userCacheConfig;

  /// The [CacheConfig] to use for the cache of the [NyxxRest.channels] manager.
  final CacheConfig<Channel> channelCacheConfig;

  /// The [CacheConfig] to use for the cache of [TextChannel.messages] managers.
  final CacheConfig<Message> messageCacheConfig;

  /// Create a new [RestClientOptions].
  RestClientOptions({
    this.userCacheConfig = const CacheConfig(),
    this.channelCacheConfig = const CacheConfig(),
    this.messageCacheConfig = const CacheConfig(),
  });
}
