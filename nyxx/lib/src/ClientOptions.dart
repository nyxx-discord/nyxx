part of nyxx;

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

  /// Whether or not to force fetch all of the members the client can see.
  /// Can slow down ready times but is recommended if you rely on `Message.member`
  /// or the member cache.
  bool forceFetchMembers;

  /// Allows to disable member caching on `GUILD_CREATE` event.
  /// **It means client will collect members from other events**
  bool cacheMembers;

  /// Maximum size of guild for which offline member will be sent
  int largeThreshold;

  /// List of ignored events
  List<String> ignoredEvents;

  /// When identifying to the gateway, you can specify an intents parameter which
  /// allows you to conditionally subscribe to pre-defined "intents", groups of events defined by Discord.
  /// If you do not specify a certain intent, you will not receive any of the gateway events that are batched into that group.
  GatewayIntents? gatewayIntents;

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

  /// Makes a new `ClientOptions` object.
  ClientOptions(
      {this.allowedMentions,
      this.shardCount,
      this.messageCacheSize = 400,
      this.forceFetchMembers = false,
      this.cacheMembers = true,
      this.largeThreshold = 50,
      this.ignoredEvents = const [],
      this.gatewayIntents,
      this.compressedGatewayPayloads = true,
      this.guildSubscriptions = true,
      this.initialPresence,
      this.shutdownHook,
      this.shutdownShardHook });
}

/// When identifying to the gateway, you can specify an intents parameter which
/// allows you to conditionally subscribe to pre-defined "intents", groups of events defined by Discord.
/// If you do not specify a certain intent, you will not receive any of the gateway events that are batched into that group.
/// [Reference](https://discordapp.com/developers/docs/topics/gateway#gateway-intents)
class GatewayIntents {
  /// Includes events: `GUILD_CREATE, GUILD_UPDATE, GUILD_DELETE, GUILD_ROLE_CREATE, GUILD_ROLE_UPDATE, GUILD_ROLE_DELETE, CHANNEL_DELETE, CHANNEL_CREATE, CHANNEL_UPDATE, CHANNEL_PINS_UPDATE`
  bool guilds = false;

  /// Includes events: `GUILD_MEMBER_ADD, GUILD_MEMBER_UPDATE, GUILD_MEMBER_REMOVE`
  bool guildMembers = false;

  /// Includes events: `GUILD_BAN_ADD, GUILD_BAN_REMOVE`
  bool guildBans = false;

  /// Includes event: `GUILD_EMOJIS_UPDATE`
  bool guildEmojis = false;

  /// Includes events: `GUILD_INTEGRATIONS_UPDATE`
  bool guildIntegrations = false;

  /// Includes events: `WEBHOOKS_UPDATE`
  bool guildWebhooks = false;

  /// Includes events: `INVITE_CREATE, INVITE_DELETE`
  bool guildInvites = false;

  /// Includes events: `VOICE_STATE_UPDATE`
  bool guildVoiceState = false;

  /// Includes events: `PRESENCE_UPDATE`
  bool guildPresences = false;

  /// Include events: `MESSAGE_CREATE, MESSAGE_UPDATE, MESSAGE_DELETE, MESSAGE_DELETE_BULK`
  bool guildMessages = false;

  /// Includes events: `MESSAGE_REACTION_ADD, MESSAGE_REACTION_REMOVE, MESSAGE_REACTION_REMOVE_ALL, MESSAGE_REACTION_REMOVE_EMOJI`
  bool guildMessageReactions = false;

  /// Includes events: `TYPING_START`
  bool guildMessageTyping = false;

  /// Includes events: `CHANNEL_CREATE, MESSAGE_CREATE, MESSAGE_UPDATE, MESSAGE_DELETE, CHANNEL_PINS_UPDATE`
  bool directMessages = false;

  /// Includes events: `MESSAGE_REACTION_ADD, MESSAGE_REACTION_REMOVE, MESSAGE_REACTION_REMOVE_ALL, MESSAGE_REACTION_REMOVE_EMOJI`
  bool directMessageReactions = false;

  /// Includes events: `TYPING_START`
  bool directMessageTyping = false;

  bool _all = false;

  /// Constructs intens config object
  GatewayIntents();

  /// Return config with turned on all intents
  GatewayIntents.all() : _all = true;

  int _calculate() {
    if (_all) {
      return 0x7FFF;
    }

    var value = 0;

    if (guilds) value += 1 << 0;
    if (guildMembers) value += 1 << 1;
    if (guildBans) value += 1 << 2;
    if (guildEmojis) value += 1 << 3;
    if (guildIntegrations) value += 1 << 4;
    if (guildWebhooks) value += 1 << 5;
    if (guildInvites) value += 1 << 6;
    if (guildVoiceState) value += 1 << 7;
    if (guildPresences) value += 1 << 8;
    if (guildMessages) value += 1 << 9;
    if (guildMessageReactions) value += 1 << 10;
    if (guildMessageTyping) value += 1 << 11;
    if (directMessages) value += 1 << 12;
    if (directMessageReactions) value += 1 << 13;
    if (directMessageTyping) value += 1 << 14;

    return value;
  }
}

typedef ShutdownHook = Future<void> Function(Nyxx client);
typedef ShutdownShardHook = Future<void> Function(Nyxx client, Shard shard);
