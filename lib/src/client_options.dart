import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/guild/ban.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/webhook.dart';

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

  /// The [CacheConfig] to use for the cache of the [NyxxRest.webhooks] manager.
  final CacheConfig<Webhook> webhookCacheConfig;

  final CacheConfig<Guild> guildCacheConfig;

  final CacheConfig<Member> memberCacheConfig;

  final CacheConfig<Role> roleCacheConfig;

  final CacheConfig<Ban> banCacheConfig;

  /// Create a new [RestClientOptions].
  RestClientOptions({
    this.userCacheConfig = const CacheConfig(),
    this.channelCacheConfig = const CacheConfig(),
    this.messageCacheConfig = const CacheConfig(),
    this.webhookCacheConfig = const CacheConfig(),
    this.guildCacheConfig = const CacheConfig(),
    this.memberCacheConfig = const CacheConfig(),
    this.roleCacheConfig = const CacheConfig(),
    this.banCacheConfig = const CacheConfig(),
  });
}
