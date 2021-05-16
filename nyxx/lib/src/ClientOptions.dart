part of nyxx;

/// Options for configuring cache. Allows to specify where and which entities should be cached and preserved in cache
class CacheOptions {
  /// Defines in which locations members will be cached
  CachePolicyLocation memberCachePolicyLocation = CachePolicyLocation();

  /// Defines which members are preserved in cache
  CachePolicy<Member> memberCachePolicy = MemberCachePolicy.def;

  /// Defines where channel entities are preserved cache. Defaults to [CachePolicyLocation] with additional objectConstructor set to true
  CachePolicyLocation channelCachePolicyLocation = CachePolicyLocation()..objectConstructor = true;

  /// Defines which channel entities are preserved in cache.
  CachePolicy<IChannel> channelCachePolicy = ChannelCachePolicy.def;

  /// Defines in which places user can be cached
  CachePolicyLocation userCachePolicyLocation = CachePolicyLocation();
}

/// Optional client settings which can be used when creating new instance
/// of client. It allows to tune up client to your needs.
class ClientOptions {
  /// Whether or not to disable @everyone and @here mentions at a global level.
  /// **It means client won't send any of these. It doesn't mean filtering guild messages.**
  AllowedMentions? allowedMentions;

  /// The total number of shards.
  int? shardCount;

  /// The number of messages to cache for each channel.
  int messageCacheSize;

  /// Maximum size of guild for which offline member will be sent
  int largeThreshold;

  /// List of ignored events
  List<String> ignoredEvents;

  /// Allows to receive compressed payloads from gateway
  bool compressedGatewayPayloads;

  /// Enables dispatching of guild subscription events (presence and typing events)
  bool guildSubscriptions;

  /// Initial bot presence
  PresenceBuilder? initialPresence;

  /// Hook executed when disposing bots process.
  ///
  /// Most likely by when process receives SIGINT (*nix) or SIGTERM (*nix and windows).
  /// Not guaranteed to be completed or executed at all.
  ShutdownHook? shutdownHook;

  /// Hook executed when shard is disposing.
  ///
  /// It could be either when shards disconnects or when bots process shuts down (look [shutdownHook].
  ShutdownShardHook? shutdownShardHook;

  /// Allows to enable receiving raw gateway event
  bool dispatchRawShardEvent;

  /// Makes a new `ClientOptions` object.
  ClientOptions(
      {this.allowedMentions,
      this.shardCount,
      this.messageCacheSize = 400,
      this.largeThreshold = 50,
      this.ignoredEvents = const [],
      this.compressedGatewayPayloads = true,
      this.guildSubscriptions = true,
      this.initialPresence,
      this.shutdownHook,
      this.shutdownShardHook,
      this.dispatchRawShardEvent = false});
}

/// When identifying to the gateway, you can specify an intents parameter which
/// allows you to conditionally subscribe to pre-defined "intents", groups of events defined by Discord.
/// If you do not specify a certain intent, you will not receive any of the gateway events that are batched into that group.
/// [Reference](https://discordapp.com/developers/docs/topics/gateway#gateway-intents)
class GatewayIntents {
  /// Includes events: `GUILD_CREATE, GUILD_UPDATE, GUILD_DELETE, GUILD_ROLE_CREATE, GUILD_ROLE_UPDATE, GUILD_ROLE_DELETE, CHANNEL_DELETE, CHANNEL_CREATE, CHANNEL_UPDATE, CHANNEL_PINS_UPDATE`
  static const int guilds = 1 << 0;

  /// Includes events: `GUILD_MEMBER_ADD, GUILD_MEMBER_UPDATE, GUILD_MEMBER_REMOVE`
  static const int guildMembers = 1 << 1;

  /// Includes events: `GUILD_BAN_ADD, GUILD_BAN_REMOVE`
  static const int guildBans = 1 << 2;

  /// Includes event: `GUILD_EMOJIS_UPDATE`
  static const int guildEmojis = 1 << 3;

  /// Includes events: `GUILD_INTEGRATIONS_UPDATE`
  static const int guildIntegrations = 1 << 4;

  /// Includes events: `WEBHOOKS_UPDATE`
  static const int guildWebhooks = 1 << 5;

  /// Includes events: `INVITE_CREATE, INVITE_DELETE`
  static const int guildInvites = 1 << 6;

  /// Includes events: `VOICE_STATE_UPDATE`
  static const int guildVoiceState = 1 << 7;

  /// Includes events: `PRESENCE_UPDATE`
  static const int guildPresences = 1 << 8;

  /// Include events: `MESSAGE_CREATE, MESSAGE_UPDATE, MESSAGE_DELETE, MESSAGE_DELETE_BULK`
  static const int guildMessages = 1 << 9;

  /// Includes events: `MESSAGE_REACTION_ADD, MESSAGE_REACTION_REMOVE, MESSAGE_REACTION_REMOVE_ALL, MESSAGE_REACTION_REMOVE_EMOJI`
  static const int guildMessageReactions = 1 << 10;

  /// Includes events: `TYPING_START`
  static const int guildMessageTyping = 1 << 11;

  /// Includes events: `CHANNEL_CREATE, MESSAGE_CREATE, MESSAGE_UPDATE, MESSAGE_DELETE, CHANNEL_PINS_UPDATE`
  static const int directMessages = 1 << 12;

  /// Includes events: `MESSAGE_REACTION_ADD, MESSAGE_REACTION_REMOVE, MESSAGE_REACTION_REMOVE_ALL, MESSAGE_REACTION_REMOVE_EMOJI`
  static const int directMessageReactions = 1 << 13;

  /// Includes events: `TYPING_START`
  static const int directMessageTyping = 1 << 14;

  /// All unprivileged intents
  static const int allUnprivileged = guilds |
      guildBans |
      guildEmojis |
      guildIntegrations |
      guildWebhooks |
      guildInvites |
      guildVoiceState |
      guildMessages |
      guildMessageReactions |
      guildMessageTyping |
      directMessages |
      directMessageReactions |
      directMessageTyping;

  /// All privileged intents
  static const int allPrivileged = guildMembers | guildPresences;

  /// All intents
  static const int all = allUnprivileged | allPrivileged;

  /// No intents. Client shouldn't receive any events.
  static const int none = 0;
}

/// Hook executed when disposing bots process.
///
/// Executed most likely when process receives SIGINT (*nix) or SIGTERM (*nix and windows).
/// Not guaranteed to be completed or executed at all.
typedef ShutdownHook = Future<void> Function(Nyxx client);

/// Hook executed when shard is disposing.
///
/// It could be either when shards disconnects or when bots process shuts down (look [ShutdownHook].
typedef ShutdownShardHook = Future<void> Function(Nyxx client, Shard shard);
