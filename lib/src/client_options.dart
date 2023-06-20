import 'package:logging/logging.dart';
import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/guild/ban.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/integration.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/webhook.dart';
import 'package:nyxx/src/plugin/plugin.dart';

/// Options for controlling the behavior of a [Nyxx] client.
abstract class ClientOptions {
  /// The plugins to use for this client.
  final List<NyxxPlugin> plugins;

  /// The name of the logger to use for this client.
  final String loggerName;

  /// The logger to use for this client.
  Logger get logger => Logger(loggerName);

  /// Create a new [ClientOptions].
  const ClientOptions({this.plugins = const [], this.loggerName = 'Nyxx'});
}

/// Options for controlling the behavior of a [NyxxRest] client.
class RestClientOptions extends ClientOptions {
  /// The [CacheConfig] to use for the cache of the [NyxxRest.users] manager.
  final CacheConfig<User> userCacheConfig;

  /// The [CacheConfig] to use for the cache of the [NyxxRest.channels] manager.
  final CacheConfig<Channel> channelCacheConfig;

  /// The [CacheConfig] to use for the cache of [TextChannel.messages] managers.
  final CacheConfig<Message> messageCacheConfig;

  /// The [CacheConfig] to use for the cache of the [NyxxRest.webhooks] manager.
  final CacheConfig<Webhook> webhookCacheConfig;

  /// The [CacheConfig] to use for the cache of the [NyxxRest.guilds] manager.
  final CacheConfig<Guild> guildCacheConfig;

  /// The [CacheConfig] to use for the [Guild.members] manager.
  final CacheConfig<Member> memberCacheConfig;

  /// The [CacheConfig] to use for the [Guild.roles] manager.
  final CacheConfig<Role> roleCacheConfig;

  /// The [CacheConfig] to use for [Ban]s in the [NyxxRest.guilds] manager.
  final CacheConfig<Ban> banCacheConfig;

  /// The [CacheConfig] to use for [StageInstance]s in the [NyxxRest.channels] manager.
  final CacheConfig<StageInstance> stageInstanceCacheConfig;

  /// The [CacheConfig] to use for the [Guild.scheduledEvents] manager.
  final CacheConfig<ScheduledEvent> scheduledEventCacheConfig;

  /// The [CacheConfig] to use for the [Guild.autoModerationRules] manager.
  final CacheConfig<AutoModerationRule> autoModerationRuleConfig;

  /// The [CacheConfig] to use for the [Guild.integrations] manager.
  final CacheConfig<Integration> integrationConfig;

  /// Create a new [RestClientOptions].
  const RestClientOptions({
    super.plugins,
    super.loggerName,
    this.userCacheConfig = const CacheConfig(),
    this.channelCacheConfig = const CacheConfig(),
    this.messageCacheConfig = const CacheConfig(),
    this.webhookCacheConfig = const CacheConfig(),
    this.guildCacheConfig = const CacheConfig(),
    this.memberCacheConfig = const CacheConfig(),
    this.roleCacheConfig = const CacheConfig(),
    this.banCacheConfig = const CacheConfig(),
    this.stageInstanceCacheConfig = const CacheConfig(),
    this.scheduledEventCacheConfig = const CacheConfig(),
    this.autoModerationRuleConfig = const CacheConfig(),
    this.integrationConfig = const CacheConfig(),
  });
}

/// Options for controlling the behavior of a [NyxxWebsocket] client.
class GatewayClientOptions extends RestClientOptions {
  const GatewayClientOptions({
    super.plugins,
    super.loggerName,
    super.userCacheConfig,
    super.channelCacheConfig,
    super.messageCacheConfig,
    super.webhookCacheConfig,
    super.guildCacheConfig,
    super.memberCacheConfig,
    super.roleCacheConfig,
    super.banCacheConfig,
    super.stageInstanceCacheConfig,
    super.scheduledEventCacheConfig,
    super.autoModerationRuleConfig,
    super.integrationConfig,
  });
}
