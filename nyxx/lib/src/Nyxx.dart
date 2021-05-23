part of nyxx;

/// Generic interface for Nyxx. Represents basic functionality of Nyxx that are always available.
abstract class INyxx implements Disposable {
  _HttpHandler get _http;
  _HttpEndpoints get _httpEndpoints;

  ClientOptions get _options;
  CacheOptions get _cacheOptions;

  String get _token;

  /// All of the guilds the bot is in. Can be empty or can miss guilds on (READY_EVENT).
  Cache<Snowflake, Guild> get guilds;

  /// All of the channels the bot can see.
  ChannelCache get channels;

  /// All of the users the bot can see. Does not have offline users
  /// without `forceFetchUsers` enabled.
  Cache<Snowflake, User> get users;

  /// Returns handler for all available REST API action.
  IHttpEndpoints get httpEndpoints => this._httpEndpoints;

  /// Emitted when a successful HTTP response is received.
  late final StreamController<HttpResponseEvent> _onHttpResponse;

  /// Emitted when a HTTP request failed.
  late final StreamController<HttpErrorEvent> _onHttpError;

  /// Sent when the client is rate limited, either by the rate limit handler itself,
  /// or when a 429 is received.
  late final StreamController<RatelimitEvent> _onRateLimited;

  /// Emitted when a successful HTTP response is received.
  late Stream<HttpResponseEvent> onHttpResponse;

  /// Emitted when a HTTP request failed.
  late Stream<HttpErrorEvent> onHttpError;

  /// Sent when the client is rate limited, either by the rate limit handler itself,
  /// or when a 429 is received.
  late Stream<RatelimitEvent> onRateLimited;
}

/// Lightweight client which do not start ws connections.
class NyxxRest extends INyxx {
  @override
  final String _token;

  final DateTime _startTime = DateTime.now();

  @override
  late final ClientOptions _options;
  @override
  late final CacheOptions _cacheOptions;
  @override
  late final _HttpHandler _http;
  @override
  late final _HttpEndpoints _httpEndpoints;

  /// When identifying to the gateway, you have to specify an intents parameter which
  /// allows you to conditionally subscribe to pre-defined "intents", groups of events defined by Discord.
  /// If you do not specify a certain intent, you will not receive any of the gateway events that are batched into that group.
  /// Since api v8 its required upon connecting to gateway.
  final int intents;

  /// The current bot user.
  late ClientUser self;

  /// The bot"s OAuth2 app.
  late ClientOAuth2Application app;

  /// All of the guilds the bot is in. Can be empty or can miss guilds on (READY_EVENT).
  @override
  late final Cache<Snowflake, Guild> guilds;

  /// All of the channels the bot can see.
  @override
  late final ChannelCache channels;

  /// All of the users the bot can see. Does not have offline users
  /// without `forceFetchUsers` enabled.
  @override
  late final Cache<Snowflake, User> users;

  /// True if client is ready.
  bool ready = false;

  /// The current version of `nyxx`
  final String version = Constants.version;

  /// Logger instance
  final Logger _logger = Logger("Client");

  /// Gets an bot invite link with zero permissions
  String get inviteLink => app.getInviteUrl();

  /// Can be used to edit options after client initialised. Used by Nyxx.interactions to enable raw events
  ClientOptions get options => this._options;

  /// Creates and logs in a new client. If [ignoreExceptions] is true (by default is)
  /// isolate will ignore all exceptions and continue to work.
  NyxxRest(this._token, this.intents,
      {ClientOptions? options,
        CacheOptions? cacheOptions,
        bool ignoreExceptions = true,
        bool useDefaultLogger = true,
        Level? defaultLoggerLogLevel}) {
    if (_token.isEmpty) {
      throw MissingTokenError();
    }

    if (useDefaultLogger) {
      Logger.root.level = defaultLoggerLogLevel ?? Level.ALL;

      Logger.root.onRecord.listen((LogRecord rec) {
        print(
            "[${rec.time}] [${rec.level.name}] [${rec.loggerName}] ${rec.message}");
      });
    }

    this._logger.info("Starting bot with pid: $pid. To stop the bot gracefully send SIGTERM or SIGKILL");

    if (!Platform.isWindows) {
      ProcessSignal.sigterm.watch().forEach((event) async {
        await this.dispose();
      });
    }

    ProcessSignal.sigint.watch().forEach((event) async {
      await this.dispose();
    });

    if (ignoreExceptions) {
      Isolate.current.setErrorsFatal(false);

      final errorsPort = ReceivePort();
      errorsPort.listen((err) {
        _logger.severe("ERROR: ${err[0]}");
      });
      Isolate.current.addErrorListener(errorsPort.sendPort);
    }

    this._options = options ?? ClientOptions();
    this._cacheOptions = cacheOptions ?? CacheOptions();

    this.guilds = _SnowflakeCache();
    this.channels = ChannelCache._new();
    this.users = _SnowflakeCache();

    this._http = _HttpHandler._new(this);
    this._httpEndpoints = _HttpEndpoints._new(this);

    this._onHttpError = StreamController.broadcast();
    this.onHttpError = _onHttpError.stream;

    this._onHttpResponse = StreamController.broadcast();
    this.onHttpResponse = _onHttpResponse.stream;

    this._onRateLimited = StreamController.broadcast();
    this.onRateLimited = _onRateLimited.stream;
  }

  @override
  Future<void> dispose() async {
    await this._onHttpResponse.close();
    await this._onHttpError.close();
    await this._onRateLimited.close();
  }
}

/// The main place to start with interacting with the Discord API and creating discord bot.
/// From there you can subscribe to various [Stream]s to listen to [Events](https://github.com/l7ssha/nyxx/wiki/EventList)
/// and fetch data from API with provided methods or get cached data.
///
/// Creating new instance of bot:
/// ```
/// Nyxx("<TOKEN>");
/// ```
/// After initializing nyxx you can subscribe to events:
/// ```
/// client.onReady.listen((e) => print("Ready!"));
///
/// client.onRoleCreate.listen((e) {
///   print("Role created with name: ${e.role.name});
/// });
/// ```
/// or setup `CommandsFramework` and `Voice`.
class Nyxx extends NyxxRest {
  late final _ConnectionManager _ws; // ignore: unused_field
  late final _EventController _events;

  /// Current client"s shard
  late ShardManager shardManager;

  /// Emitted when a shard is disconnected from the websocket.
  late Stream<DisconnectEvent> onDisconnect;

  /// Emitted when the client is ready. Should be sent only once.
  late Stream<ReadyEvent> onReady;

  /// Emitted when a message is received. It includes private messages.
  late Stream<MessageReceivedEvent> onMessageReceived;

  /// Emitted when private message is received.
  late Stream<MessageReceivedEvent> onDmReceived;

  /// Emitted when channel"s pins are updated.
  late Stream<ChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Emitted when guild"s emojis are changed.
  late Stream<GuildEmojisUpdateEvent> onGuildEmojisUpdate;

  /// Emitted when a message is edited. Old message can be null if isn"t cached.
  late Stream<MessageUpdateEvent> onMessageUpdate;

  /// Emitted when a message is deleted.
  late Stream<MessageDeleteEvent> onMessageDelete;

  /// Emitted when a channel is created.
  late Stream<ChannelCreateEvent> onChannelCreate;

  /// Emitted when a channel is updated.
  late Stream<ChannelUpdateEvent> onChannelUpdate;

  /// Emitted when a channel is deleted.
  late Stream<ChannelDeleteEvent> onChannelDelete;

  /// Emitted when a member is banned.
  late Stream<GuildBanAddEvent> onGuildBanAdd;

  /// Emitted when a user is unbanned.
  late Stream<GuildBanRemoveEvent> onGuildBanRemove;

  /// Emitted when the client joins a guild.
  late Stream<GuildCreateEvent> onGuildCreate;

  /// Emitted when a guild is updated.
  late Stream<GuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  late Stream<GuildDeleteEvent> onGuildDelete;

  /// Emitted when a member joins a guild.
  late Stream<GuildMemberAddEvent> onGuildMemberAdd;

  /// Emitted when a member is updated.
  late Stream<GuildMemberUpdateEvent> onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  late Stream<GuildMemberRemoveEvent> onGuildMemberRemove;

  /// Emitted when a member"s presence is changed.
  late Stream<PresenceUpdateEvent> onPresenceUpdate;

  /// Emitted when a user starts typing.
  late Stream<TypingEvent> onTyping;

  /// Emitted when a role is created.
  late Stream<RoleCreateEvent> onRoleCreate;

  /// Emitted when a role is updated.
  late Stream<RoleUpdateEvent> onRoleUpdate;

  /// Emitted when a role is deleted.
  late Stream<RoleDeleteEvent> onRoleDelete;

  /// Emitted when many messages are deleted at once
  late Stream<MessageDeleteBulkEvent> onMessageDeleteBulk;

  /// Emitted when a user adds a reaction to a message.
  late Stream<MessageReactionEvent> onMessageReactionAdded;

  /// Emitted when a user deletes a reaction to a message.
  late Stream<MessageReactionEvent> onMessageReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  late Stream<MessageReactionsRemovedEvent> onMessageReactionsRemoved;

  /// Emitted when someone joins/leaves/moves voice channel.
  late Stream<VoiceStateUpdateEvent> onVoiceStateUpdate;

  /// Emitted when a guild"s voice server is updated.
  /// This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  late Stream<VoiceServerUpdateEvent> onVoiceServerUpdate;

  /// Emitted when user was updated
  late Stream<UserUpdateEvent> onUserUpdate;

  /// Emitted when bot is mentioned
  late Stream<MessageReceivedEvent> onSelfMention;

  /// Emitted when invite is created
  late Stream<InviteCreatedEvent> onInviteCreated;

  /// Emitted when invite is deleted
  late Stream<InviteDeletedEvent> onInviteDeleted;

  /// Emitted when a bot removes all instances of a given emoji from the reactions of a message
  late Stream<MessageReactionRemoveEmojiEvent> onMessageReactionRemoveEmoji;

  /// Emitted when stage channel instance is created
  late Stream<StageInstanceEvent>  onStageInstanceCreate;

  /// Emitted when stage channel instance is updated
  late Stream<StageInstanceEvent>  onStageInstanceUpdate;

  /// Emitted when stage channel instance is deleted
  late Stream<StageInstanceEvent>  onStageInstanceDelete;

  /// Creates and logs in a new client. If [ignoreExceptions] is true (by default is)
  /// isolate will ignore all exceptions and continue to work.
  Nyxx(String token, int intents,
      {ClientOptions? options,
      CacheOptions? cacheOptions,
      bool ignoreExceptions = true,
      bool useDefaultLogger = true,
      Level? defaultLoggerLogLevel}) :
        super(token, intents, options: options, cacheOptions: cacheOptions,
              ignoreExceptions: ignoreExceptions, useDefaultLogger: useDefaultLogger,
              defaultLoggerLogLevel: defaultLoggerLogLevel
      ) {
    this._events = _EventController(this);
    this.onSelfMention = this
        .onMessageReceived
        .where((event) => event.message.mentions.contains(this.self));
    this.onDmReceived =
        this.onMessageReceived.where((event) => event.message is DMMessage);

    this._ws = _ConnectionManager(this);
  }

  /// The client's uptime.
  Duration get uptime => DateTime.now().difference(_startTime);

  /// [DateTime] when client was started
  DateTime get startTime => _startTime;

  /// This endpoint is only for public guilds if bot is not int the guild.
  Future<GuildPreview> fetchGuildPreview(Snowflake guildId) async =>
    this._httpEndpoints.fetchGuildPreview(guildId);

  /// Returns guild with given [guildId]
  Future<Guild> fetchGuild(Snowflake guildId) =>
      this._httpEndpoints.fetchGuild(guildId);

  /// Returns channel with specified id.
  /// ```
  /// var channel = await client.getChannel<TextChannel>(Snowflake("473853847115137024"));
  /// ```
  Future<T> fetchChannel<T extends IChannel>(Snowflake channelId) =>
      this._httpEndpoints.fetchChannel(channelId);

  /// Get user instance with specified id.
  /// ```
  /// var user = client.getUser(Snowflake("302359032612651009"));
  /// ``
  Future<User> fetchUser(Snowflake userId) =>
      this._httpEndpoints.fetchUser(userId);

  /// Gets a webhook by its id and/or token.
  /// If token is supplied authentication is not needed.
  Future<Webhook> fetchWebhook(Snowflake id, {String token = ""}) =>
      this._httpEndpoints.fetchWebhook(id, token: token);

  /// Gets an [Invite] object with given code.
  /// If the [code] is in cache - it will be taken from it, otherwise API will be called.
  ///
  /// ```
  /// var inv = client.getInvite("YMgffU8");
  /// ```
  Future<Invite> getInvite(String code) =>
      this._httpEndpoints.fetchInvite(code);

  /// Returns number of shards
  int get shards => this.shardManager._shards.length;

  /// Sets presence for bot.
  ///
  /// Code below will display bot presence as `Playing Super duper game`:
  /// ```dart
  /// bot.setPresence(game: Activity.of("Super duper game"))
  /// ```
  ///
  /// Bots cannot set custom status - only game, listening and stream available.
  ///
  /// To set bot presence to streaming use:
  /// ```dart
  /// bot.setPresence(game: Activity.of("Super duper game", type: ActivityType.streaming, url: "https://twitch.tv/l7ssha"))
  /// ```
  /// `url` property in `Activity` can be only set when type is set to `streaming`
  void setPresence(PresenceBuilder presenceBuilder) {
    this.shardManager.setPresence(presenceBuilder);
  }

  @override
  Future<void> dispose() async {
    this._logger.info("Disposing and closing bot...");

    if (this._options.shutdownHook != null) {
      await this._options.shutdownHook!(this);
    }

    await shardManager.dispose();
    await this._events.dispose();
    await guilds.dispose();
    await users.dispose();

    this._logger.info("Exiting...");
    exit(0);
  }
}
