part of nyxx;

/// Optional client settings which can be used when creating new instance
/// of client. It allows to tune up client to your needs.
class ClientOptions {
  /// Whether or not to disable @everyone and @here mentions at a global level.
  /// **It means client won't send any of these. It doesn't mean filtering guild messages.**
  AllowedMentions? allowedMentions;

  /// The index of this shard
  int shardIndex;

  /// The total number of shards.
  int shardCount;

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

  /// Makes a new `ClientOptions` object.
  ClientOptions(
      {this.allowedMentions,
      this.shardIndex = 0,
      this.shardCount = 1,
      this.messageCacheSize = 400,
      this.forceFetchMembers = false,
      this.cacheMembers = true,
      this.largeThreshold = 50,
      this.ignoredEvents = const [],
      this.gatewayIntents});
}

/// When identifying to the gateway, you can specify an intents parameter which
/// allows you to conditionally subscribe to pre-defined "intents", groups of events defined by Discord.
/// If you do not specify a certain intent, you will not receive any of the gateway events that are batched into that group.
/// [Reference](https://discordapp.com/developers/docs/topics/gateway#gateway-intents)
class GatewayIntents {
  bool guilds = false;
  bool guildMembers = false;
  bool guildBans = false;
  bool guildEmojis = false;
  bool guildIntegrations = false;
  bool guildWebhooks = false;
  bool guildInvites = false;
  bool guildVoiceState = false;
  bool guildPresences = false;
  bool guildMessageReactions = false;
  bool guildMessageTyping = false;
  bool directMessages = false;
  bool directMessageReactions = false;
  bool directMessageTyping = false;

  bool _all = false;

  GatewayIntents();
  GatewayIntents.all() : _all = true;

  int _calculate() {
    if(_all) {
      return 0x7FFF;
    }

    int value = 0;

    if(guilds) value += 1 << 0;
    if(guildMembers) value += 1 << 1;
    if(guildBans) value += 1 << 2;
    if(guildEmojis) value += 1 << 3;
    if(guildIntegrations) value += 1 << 4;
    if(guildWebhooks) value += 1 << 5;
    if(guildInvites) value += 1 << 6;
    if(guildVoiceState) value += 1 << 8;
    if(guildPresences) value += 1 << 9;
    if(guildMessageReactions) value += 1 << 10;
    if(guildMessageTyping) value += 1 << 11;
    if(directMessages) value += 1 << 12;
    if(directMessageReactions) value += 1 << 13;
    if(directMessageTyping) value += 1 << 14;

    return value;
  }
}