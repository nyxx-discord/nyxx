part of nyxx;

/// The main place to start with interacting with the Discord API and creating discord bot.
/// From there you can subscribe to various [Stream]s to listen to [Events](https://github.com/l7ssha/nyxx/wiki/EventList)
/// and fetch data from API with provided methods or get cached data.
///
/// Creating new instance of bot:
/// ```
/// Nyxx('<TOKEN>');
/// ```
/// After initializing nyxx you can subscribe to events:
/// ```
/// client.onReady.listen((e) => print('Ready!'));
///
/// client.onRoleCreate.listen((e) {
///   print('Role created with name: ${e.role.name});
/// });
/// ```
/// or setup `CommandsFramework` and `Voice`.
class Nyxx implements Disposable {
  String _token;
  ClientOptions _options;
  DateTime _startTime;
  _WS _ws;
  _EventController _events;
  Http _http;

  /// The current bot user.
  ClientUser self;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// All of the guilds the bot is in. Can be empty or can miss guilds on (READY_EVENT).
  Cache<Snowflake, Guild> guilds;

  /// All of the channels the bot can see.
  ChannelCache channels;

  /// All of the users the bot can see. Does not have offline users
  /// without `forceFetchUsers` enabled.
  Cache<Snowflake, User> users;

  /// True if client is ready.
  bool ready = false;

  /// The current version of `nyxx`
  String version = _Constants.version;

  Shard shard;

  /// Generic Stream for message like events. It includes added reactions, and message deletions.
  /// For received messages refer to [onMessageReceived]
  Stream<MessageEvent> onMessage;

  /// Emitted when packet is received from gateway.
  Stream<RawEvent> onRaw;

  /// Emitted when a shard is disconnected from the websocket.
  Stream<DisconnectEvent> onDisconnect;

  /// Emitted before all HTTP requests are sent. (You can edit them)
  /// This is single subscription Stream - only one listener.
  ///
  /// **WARNING:** Once you listen to this stream, all requests
  /// will be halted until you call `request.send()`
  Stream<BeforeHttpRequestSendEvent> beforeHttpRequestSend;

  /// Emitted when a successful HTTP response is received.
  Stream<HttpResponseEvent> onHttpResponse;

  /// Emitted when a HTTP request failed.
  Stream<HttpErrorEvent> onHttpError;

  /// Sent when the client is ratelimited, either by the ratelimit handler itself,
  /// or when a 429 is received.
  Stream<RatelimitEvent> onRatelimited;

  /// Emitted when the client is ready. Should be sent only once.
  Stream<ReadyEvent> onReady;

  /// Emitted when a message is received. It includes private messages.
  Stream<MessageReceivedEvent> onMessageReceived;

  /// Emitted when private message is received.
  Stream<MessageReceivedEvent> onDmReceived;

  /// Emitted when channel's pins are updated.
  Stream<ChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Emitted when guild's emojis are changed.
  Stream<GuildEmojisUpdateEvent> onGuildEmojisUpdate;

  /// Emitted when a message is edited. Old message can be null if isn't cached.
  Stream<MessageUpdateEvent> onMessageUpdate;

  /// Emitted when a message is deleted.
  Stream<MessageDeleteEvent> onMessageDelete;

  /// Emitted when a channel is created.
  Stream<ChannelCreateEvent> onChannelCreate;

  /// Emitted when a channel is updated.
  Stream<ChannelUpdateEvent> onChannelUpdate;

  /// Emitted when a channel is deleted.
  Stream<ChannelDeleteEvent> onChannelDelete;

  /// Emitted when a member is banned.
  Stream<GuildBanAddEvent> onGuildBanAdd;

  /// Emitted when a user is unbanned.
  Stream<GuildBanRemoveEvent> onGuildBanRemove;

  /// Emitted when the client joins a guild.
  Stream<GuildCreateEvent> onGuildCreate;

  /// Emitted when a guild is updated.
  Stream<GuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  Stream<GuildDeleteEvent> onGuildDelete;

  /// Emitted when a guild becomes unavailable during a guild outage.
  Stream<GuildUnavailableEvent> onGuildUnavailable;

  /// Emitted when a member joins a guild.
  Stream<GuildMemberAddEvent> onGuildMemberAdd;

  /// Emitted when a member is updated.
  Stream<GuildMemberUpdateEvent> onGuildMemberUpdate;

  /// Emitted when a user leaves a guild.
  Stream<GuildMemberRemoveEvent> onGuildMemberRemove;

  /// Emitted when a member's presence is changed.
  Stream<PresenceUpdateEvent> onPresenceUpdate;

  /// Emitted when a user starts typing.
  Stream<TypingEvent> onTyping;

  /// Emitted when a role is created.
  Stream<RoleCreateEvent> onRoleCreate;

  /// Emitted when a role is updated.
  Stream<RoleUpdateEvent> onRoleUpdate;

  /// Emitted when a role is deleted.
  Stream<RoleDeleteEvent> onRoleDelete;

  /// Emitted when many messages are deleted at once
  Stream<MessageDeleteBulkEvent> onMessageDeleteBulk;

  /// Emitted when a user adds a reaction to a message.
  Stream<MessageReactionEvent> onMessageReactionAdded;

  /// Emitted when a user deletes a reaction to a message.
  Stream<MessageReactionEvent> onMessageReactionRemove;

  /// Emitted when a user explicitly removes all reactions from a message.
  Stream<MessageReactionsRemovedEvent> onMessageReactionsRemoved;

  /// Emitted when someone joins/leaves/moves voice channel.
  Stream<VoiceStateUpdateEvent> onVoiceStateUpdate;

  /// Emitted when a guild's voice server is updated.
  /// This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  Stream<VoiceServerUpdateEvent> onVoiceServerUpdate;

  /// Emitted when user was updated
  Stream<UserUpdateEvent> onUserUpdate;

  /// Emitted when bot is mentioned
  Stream<MessageReceivedEvent> onSelfMention;

  /// Logger instance
  Logger _logger = Logger("Client");

  /// Gets an bot invite link with zero permissions
  String get inviteLink => app.getInviteUrl();

  /// Creates and logs in a new client. If [ignoreExceptions] is true (by default is)
  /// isolate will ignore all exceptions and continue to work.
  Nyxx(this._token, {ClientOptions options, bool ignoreExceptions = true}) {
    if (!setup || (_token == null || _token == "")) throw NotSetupError();

    if (ignoreExceptions && !browser) {
      Isolate.current.setErrorsFatal(false);

      ReceivePort errorsPort = ReceivePort();
      errorsPort.listen((err) {
        _logger.severe("ERROR: ${err[0]} \n ${err[1]}");
      });
      Isolate.current.addErrorListener(errorsPort.sendPort);
    }

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      String color = "";
      if (rec.level == Level.WARNING)
        color = "\u001B[33m";
      else if (rec.level == Level.SEVERE)
        color = "\u001B[31m";
      else if (rec.level == Level.INFO)
        color = "\u001B[32m";
      else
        color = "\u001B[0m";

      print('[${DateTime.now()}] '
          '$color[${rec.level.name}] [${rec.loggerName}]\u001B[0m: '
          '${rec.message}');
    });

    this._options = options ?? ClientOptions();

    this.guilds = _SnowflakeCache();
    this.channels = ChannelCache._new();
    this.users = _SnowflakeCache();

    this._http = Http._new(this);
    this._events = _EventController(this);
    this.onSelfMention = this.onMessageReceived.where((event) =>
        event.message.mentions != null &&
        event.message.mentions.containsKey(this.self.id));
    this.onDmReceived = this.onMessageReceived.where((event) =>
        event.message.channel is DMChannel ||
        event.message.channel is GroupDMChannel);
    this._ws = _WS(this);
  }

  /// The client's uptime.
  Duration get uptime => DateTime.now().difference(_startTime);

  /// [DateTime] when client was started
  DateTime get startTime => _startTime;

  /// Returns channel with specified id.
  /// If channel is in cache - will be taken from it otherwise API will be called.
  ///
  /// ```
  /// var channel = await client.getChannel<TextChannel>(Snowflake('473853847115137024'));
  /// ```
  Future<T> getChannel<T>(Snowflake id, {Guild guild}) async {
    if (this.channels.hasKey(id)) return this.channels[id] as T;

    var raw = (await this._http.send("GET", "/channels/${id.toString()}")).body
        as Map<String, dynamic>;

    switch (T) {
      case MessageChannel:
        return MessageChannel._new(raw, raw['type'] as int, this) as T;
      case DMChannel:
        return DMChannel._new(raw, this) as T;
      case GroupDMChannel:
        return GroupDMChannel._new(raw, this) as T;
      case TextChannel:
        return TextChannel._new(raw, guild, this) as T;
      case VoiceChannel:
        return VoiceChannel._new(raw, guild, this) as T;
      case CategoryChannel:
        return CategoryChannel._new(raw, guild, this) as T;
      default:
        return null;
    }
  }

  /// Get user instance with specified id.
  /// If [id] is present in cache it'll be got from cache, otherwise API
  /// will be called.
  ///
  /// ```
  /// var user = client.getClient(Snowflake("302359032612651009"));
  /// ``
  Future<User> getUser(Snowflake id) async {
    if (this.users.hasKey(id)) return this.users[id];

    var r = await this._http.send("GET", "/users/${id.toString()}");
    return User._new(r.body as Map<String, dynamic>, this);
  }

  /// Gets Guild with specified id.
  ///
  /// ```
  /// var guild = client.getGuild(Snowflake("302360552993456135"));
  /// ```
  Guild getGuild(Snowflake id) => this.guilds[id];

  /// Creates new guild with provided builder.
  /// Only for bots with less than 10 guilds otherwise it will return Future with error.
  ///
  /// ```
  /// var guildBuilder = GuildBuilder()
  ///                       ..name = "Example Guild"
  ///                       ..roles = [RoleBuilder()..name = "Example Role]
  /// var newGuild = await client.createGuild(guildBuilder);
  /// ```
  Future<Guild> createGuild(GuildBuilder builder) async {
    if (this.guilds.count >= 10)
      return Future.error(
          "Guild cannot be created if bot is in 10 or more guilds");

    var r = await this._http.send("POST", "/guilds", body: builder._build());
    return Guild._new(this, r.body as Map<String, dynamic>);
  }

  /// Gets a webhook by its ID and token.
  Future<Webhook> getWebhook(String id, {String token = ""}) async {
    HttpResponse r = await _http.send('GET', "/webhooks/$id/$token");
    return Webhook._new(r.body as Map<String, dynamic>, this);
  }

  @deprecated

  /// Block isolate until client is ready.
  Future<ReadyEvent> blockToReady() async => await onReady.first;

  /// Gets an [Invite] object with given code.
  /// If the [code] is in cache - it will be taken from it, otherwise API will be called.
  ///
  /// ```
  /// var inv = client.getInvite("YMgffU8");
  /// ```
  Future<Invite> getInvite(String code) async {
    final HttpResponse r = await this._http.send('GET', '/invites/$code');
    return Invite._new(r.body as Map<String, dynamic>, this);
  }

  /// Closes websocket connections and cleans everything up.
  Future<void> close() async => await dispose();

  int get shards => this._options.shardCount;

  @override
  Future<void> dispose() async {
    await shard.dispose();
    await guilds.dispose();
    await users.dispose();
    await guilds.dispose();
    await this._events.dispose();
  }
}
