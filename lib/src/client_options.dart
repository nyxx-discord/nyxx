import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/emoji/emoji.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/guild/ban.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
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

  /// The [CacheConfig] to use for the cache of the [NyxxRest.guilds] manager.
  final CacheConfig<Guild> guildCacheConfig;

  /// The [CacheConfig] to use for the [Guild.members] manager.
  final CacheConfig<Member> memberCacheConfig;

  /// The [CacheConfig] to use for the [Guild.roles] manager.
  final CacheConfig<Role> roleCacheConfig;

  /// The [CacheConfig] to use for [Ban]s in the [NyxxRest.guilds] manager.
  final CacheConfig<Ban> banCacheConfig;

  /// The [CacheConfig] to use for the [Emoji]s in the [Guild.emojis] manager.
  final CacheConfig<Emoji> emojiCacheConfig;

  /// The [CacheConfig] to use for [StageInstance]s in the [NyxxRest.channels] manager.
  final CacheConfig<StageInstance> stageInstanceCacheConfig;

  /// The [CacheConfig] to use for the [Guild.scheduledEvents] manager.
  final CacheConfig<ScheduledEvent> scheduledEventCacheConfig;

  /// The [CacheConfig] to use for the [Guild.autoModerationRules] manager.
  final CacheConfig<AutoModerationRule> autoModerationRuleConfig;

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
    this.emojiCacheConfig = const CacheConfig(),
    this.stageInstanceCacheConfig = const CacheConfig(),
    this.scheduledEventCacheConfig = const CacheConfig(),
    this.autoModerationRuleConfig = const CacheConfig(),
  });
}

/// Options for controlling the behavior of a [NyxxWebsocket] client.
class GatewayClientOptions extends RestClientOptions {
  GatewayClientOptions({
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
  });
}
