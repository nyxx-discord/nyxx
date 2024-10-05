import 'package:logging/logging.dart';
import 'package:nyxx/src/cache/cache.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/commands/application_command.dart';
import 'package:nyxx/src/models/commands/application_command_permissions.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/entitlement.dart';
import 'package:nyxx/src/models/guild/audit_log.dart';
import 'package:nyxx/src/models/guild/auto_moderation.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/integration.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/sku.dart';
import 'package:nyxx/src/models/sticker/global_sticker.dart';
import 'package:nyxx/src/models/sticker/guild_sticker.dart';
import 'package:nyxx/src/models/subscription.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';
import 'package:nyxx/src/models/webhook.dart';
import 'package:nyxx/src/plugin/plugin.dart';

/// The default [CacheConfig].
///
/// 2500 is a relatively arbitrary value that corresponds to the maximum number
/// of guilds a single shard can handle. This doesn't mean a client can cache
/// all the guilds it is in as it may have more than one shard. However, 2500
/// is a large enough value that the cache will contain the most important
/// entities to avoid making network requests:
/// - The most active guilds.
/// - The most active channels.
/// - The most commonly used entitlements.
/// - (etc)
const _defaultCacheConfig = CacheConfig<Never>(maxSize: 2500);

/// A [CacheConfig] with a smaller maximum size than [_defaultCacheConfig],
/// ideal for certain caches.
///
/// Notably, the following types of caches may want to default to a smaller
/// maximum size:
/// - Caches that are not global (e.g that belong to a specific guild), as the
///   total number of entities cached is multiplied by the number of "parent"
///   entities. For example, setting the maximum member cache size to 100 on a
///   client which is in 1000 guilds means the total number of cached members
///   may still approach 100000.
/// - Caches that see a lot of ephemeral entries, for example the users cache.
///   Users are generally not needed over a long period of time, but rather for
///   a short burst (e.g when processing a command) before being discarded. We
///   don't need to cache these entities longer than the operations they are
///   involved in.
const _smallCacheConfig = CacheConfig<Never>(maxSize: 100);

/// Options for controlling the behavior of a [Nyxx] client.
abstract class ClientOptions {
  /// The plugins to use for this client.
  final List<NyxxPlugin> plugins;

  /// The name of the logger to use for this client.
  final String loggerName;

  /// The logger to use for this client.
  Logger get logger => Logger(loggerName);

  /// The threshold after which a warning will be logged if a request is waiting for rate limits.
  ///
  /// If this value is `null`, no warnings are emitted when a long rate limit is encountered.
  ///
  /// This value is also used to prevent log spam. Requests will only emit a warning once per [rateLimitWarningThreshold], even if they are rate limited
  /// multiple times during that period.
  final Duration? rateLimitWarningThreshold;

  /// Create a new [ClientOptions].
  const ClientOptions({
    this.plugins = const [],
    this.loggerName = 'Nyxx',
    this.rateLimitWarningThreshold = const Duration(seconds: 10),
  });
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

  /// The [CacheConfig] to use for the [Emoji]s in the [Guild.emojis] manager.
  final CacheConfig<Emoji> emojiCacheConfig;

  /// The [CacheConfig] to use for the [GuildSticker]s in the [Guild.stickers] manager.
  final CacheConfig<GuildSticker> stickerCacheConfig;

  /// The [CacheConfig] to use for the [GlobalSticker]s in the [NyxxRest.stickers] manager.
  final CacheConfig<GlobalSticker> globalStickerCacheConfig;

  /// The [CacheConfig] to use for [StageInstance]s in the [NyxxRest.channels] manager.
  final CacheConfig<StageInstance> stageInstanceCacheConfig;

  /// The [CacheConfig] to use for the [Guild.scheduledEvents] manager.
  final CacheConfig<ScheduledEvent> scheduledEventCacheConfig;

  /// The [CacheConfig] to use for the [Guild.autoModerationRules] manager.
  final CacheConfig<AutoModerationRule> autoModerationRuleConfig;

  /// The [CacheConfig] to use for the [Guild.integrations] manager.
  final CacheConfig<Integration> integrationConfig;

  /// The [CacheConfig] to use for the [Guild.auditLogs] manager.
  final CacheConfig<AuditLogEntry> auditLogEntryConfig;

  /// The [CacheConfig] to use for the [PartialGuild.voiceStates] cache.
  final CacheConfig<VoiceState> voiceStateConfig;

  /// The [CacheConfig] to use for the [NyxxRest.commands] manager.
  final CacheConfig<ApplicationCommand> applicationCommandConfig;

  /// The [CacheConfig] to use for the [GuildApplicationCommandManager.permissionsCache] cache.
  final CacheConfig<CommandPermissions> commandPermissionsConfig;

  /// The [CacheConfig] to use for the [Application.entitlements] manager.
  final CacheConfig<Entitlement> entitlementConfig;

  /// The [CacheConfig] to use for the [Application.skus] manager.
  final CacheConfig<Sku> skuConfig;

  /// Tje [CacheConfig] to use for the [Sku.subscriptions] manager.
  final CacheConfig<Subscription> subscriptionConfig;

  /// Create a new [RestClientOptions].
  const RestClientOptions({
    super.plugins,
    super.loggerName,
    super.rateLimitWarningThreshold,
    // Users are generally not needed over long periods of time; use a small
    // cache.
    this.userCacheConfig = _smallCacheConfig,
    this.channelCacheConfig = _defaultCacheConfig,
    // Messages are generally not needed over long periods of time and are
    // cached per channel anyway; use a small cache.
    this.messageCacheConfig = _smallCacheConfig,
    this.webhookCacheConfig = _defaultCacheConfig,
    this.guildCacheConfig = _defaultCacheConfig,
    // Members are generally not needed over long periods of time and are
    // cached per guild anyway; use a small cache.
    this.memberCacheConfig = _smallCacheConfig,
    // Guilds tend not to have a large amount of roles (relatively speaking),
    // but we also want to access all of a guild's roles during e.g permission
    // calculations; use a larger cache.
    this.roleCacheConfig = _defaultCacheConfig,
    // Bots don't tend to use emoji or sticker data. Don't bother caching too
    // many.
    this.emojiCacheConfig = _smallCacheConfig,
    this.stickerCacheConfig = _smallCacheConfig,
    // ...but there are not too many global stickers, and they are the most
    // used, so use a larger cache for these.
    this.globalStickerCacheConfig = _defaultCacheConfig,
    this.stageInstanceCacheConfig = _defaultCacheConfig,
    this.scheduledEventCacheConfig = _smallCacheConfig,
    this.autoModerationRuleConfig = _smallCacheConfig,
    this.integrationConfig = _smallCacheConfig,
    this.auditLogEntryConfig = _smallCacheConfig,
    // Voice states are saved per guild, so we don't need to store large amount
    // of them at a time.
    this.voiceStateConfig = _smallCacheConfig,
    this.applicationCommandConfig = _defaultCacheConfig,
    this.commandPermissionsConfig = _smallCacheConfig,
    this.entitlementConfig = _defaultCacheConfig,
    this.skuConfig = _defaultCacheConfig,
    this.subscriptionConfig = _defaultCacheConfig,
  });
}

/// Options for controlling the behavior of a [NyxxGateway] client.
class GatewayClientOptions extends RestClientOptions {
  /// The minimum number of session starts this client needs to connect.
  ///
  /// This is a safety feature to avoid API bans due to excessive connection starts.
  ///
  /// If the remaining number of session starts is below this number, an error will be thrown when connecting.
  final int minimumSessionStarts;

  /// Create a new [GatewayClientOptions].
  const GatewayClientOptions({
    this.minimumSessionStarts = 10,
    super.plugins,
    super.loggerName,
    super.rateLimitWarningThreshold,
    super.userCacheConfig,
    super.channelCacheConfig,
    super.messageCacheConfig,
    super.webhookCacheConfig,
    super.guildCacheConfig,
    super.memberCacheConfig,
    super.roleCacheConfig,
    super.stageInstanceCacheConfig,
    super.scheduledEventCacheConfig,
    super.autoModerationRuleConfig,
    super.integrationConfig,
    super.auditLogEntryConfig,
    super.voiceStateConfig,
    super.applicationCommandConfig,
    super.commandPermissionsConfig,
    super.entitlementConfig,
    super.skuConfig,
    super.emojiCacheConfig,
    super.globalStickerCacheConfig,
    super.stickerCacheConfig,
  });
}
