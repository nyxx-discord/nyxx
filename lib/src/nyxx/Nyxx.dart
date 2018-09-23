part of nyxx;

Nyxx _client;
Nyxx get client => _client;

/// The main hub for interacting with the Discord API, and the starting point for any bot.
/// From there you can subscribe to various [Stream]s to listen to [Events](https://github.com/l7ssha/nyxx/wiki/EventList)
/// and fetch data provided and collected by bot.
///
/// Creating new instance of bot:
/// ```
/// var bot = new Client("<TOKEN>");
/// ```
/// From this place bot will try to connect to gateway and listen to events:
/// ```
/// bot.onReady.listen((e) => print('Ready!'));
///
/// bot.onRoleCreate.listen((e) {
///   print('Role created with name: ${e.role.name});
/// });
/// ```
class Nyxx {
  String _token;
  ClientOptions _options;
  DateTime _startTime;
  _WS _ws;
  _EventController _events;

  /// The HTTP client.
  Http http;

  /// The logged in user.
  ClientUser self;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// All of the guilds the bot is in. Can be empty or can miss guilds on (READY_EVENT).
  Map<Snowflake, Guild> guilds;

  /// All of the channels the bot is in.
  Map<Snowflake, Channel> channels;

  /// All of the users the bot can see. Does not always have offline users
  /// without forceFetchUsers enabled.
  Map<Snowflake, User> users;

  /// Whether or not the client is ready.
  bool ready = false;

  /// The current version.
  String version = _Constants.version;

  /// The client's internal shards.
  Map<int, Shard> shards;

  /// Emitted when a raw packet is received from the websocket connection.
  Stream<RawEvent> onRaw;

  /// Emitted when a shard is disconnected from the websocket.
  Stream<DisconnectEvent> onDisconnect;

  /// Emitted before all HTTP requests are sent. (You can edit them)
  /// This is single subscription Stream.
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

  /// Emitted when the client is ready.
  Stream<ReadyEvent> onReady;

  /// Emitted when a message is received.
  Stream<MessageEvent> onMessage;

  /// Emitted when channel's pins are updated.
  Stream<ChannelPinsUpdateEvent> onChannelPinsUpdate;

  /// Emitted when guild's emojis are changed.
  Stream<GuildEmojisUpdateEvent> onGuildEmojisUpdate;

  /// Emitted when a message is edited.
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

  /// Emitted when a guild is updated..
  Stream<GuildUpdateEvent> onGuildUpdate;

  /// Emitted when the client leaves a guild.
  Stream<GuildDeleteEvent> onGuildDelete;

  /// Emitted when a guild becomes unavailable.
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

  /// Emittedwhen someone joins/leaves/moves voice channels.
  Stream<VoiceStateUpdateEvent> onVoiceStateUpdate;

  /// Emitted when a guild channel's webhook is created, updated, or deleted.
  Stream<WebhookUpdateEvent> onWebhookUpdate;

  /// Emitted when a guild's voice server is updated. This is sent when initially connecting to voice, and when the current voice instance fails over to a new server.
  Stream<VoiceServerUpdateEvent> onVoiceServerUpdate;

  /// Logger instance
  Logger logger = Logger.detached("Client");

  /// Gets an bot invite link with zero permissions
  String get inviteLink => app.makeOAuth2Url();

  /// Creates and logs in a new client.
  Nyxx(this._token, {ClientOptions options, bool ignoreExceptions = true}) {
    if (ignoreExceptions) {
      Isolate.current.setErrorsFatal(false);
      ReceivePort errorsPort = ReceivePort();
      errorsPort.listen((err) {
        logger.severe("ERROR: ${err[0]} \n ${err[1]}");
      });
      Isolate.current.addErrorListener(errorsPort.sendPort);
    }

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      String color;
      if (rec.level == Level.WARNING)
        color = "\u001B[33m";
      else if (rec.level == Level.SEVERE)
        color = "\u001B[31m";
      else
        color = "\u001B[0m";

      print('$color[${rec.level.name}] \u001B[0m {${rec.loggerName}} - '
          '${rec.time.day}.${rec.time.month}.${rec.time.year} '
          '${rec.time.hour}:${rec.time.minute}:${rec.time.second}'
          ':${rec.time.millisecond} '
          '-- ${rec.message}');
    });

    if (this._token == null || this._token == "")
      throw Exception("Token cannot be null or empty");
    if (this._options == null) this._options = ClientOptions();

    this.guilds = Map<Snowflake, Guild>();
    this.channels = Map<Snowflake, Channel>();
    this.users = Map<Snowflake, User>();
    this.shards = Map<int, Shard>();

    _client = this;

    this.http = Http._new();
    this._events = _EventController();
    this._ws = _WS();
  }

  /// The client's uptime.
  Duration get uptime => DateTime.now().difference(_startTime);

  /// Get user instance with specified id.
  /// If [id] is present in cache it'll be got from cache, otherwise API
  /// will be called.
  ///
  /// ```
  /// var user = client.getClient(Snowflake("302359032612651009"));
  /// ``
  Future<User> getUser(Snowflake id) async {
    if (this.users.containsKey(id)) return this.users[id];

    var r = await this.http.send("GET", "/users/${id.toString()}");
    return User._new(r.body as Map<String, dynamic>);
  }

  /// Gets Guild with specified id.
  /// If the [id] will be in cache - it will be taken from it, otherwise API will be called.
  ///
  /// ```
  /// var guild = client.getGuild(Snowflake("302360552993456135"));
  /// ```
  Future<Guild> getGuild(Snowflake id) async {
    if (this.guilds.containsKey(id)) return this.guilds[id];

    var r = await this.http.send("GET", "/guilds/${id.toString()}");
    return Guild._new(r.body as Map<String, dynamic>);
  }

  /// Creates new guild with provided builder.
  /// If the [id] will be in cache - it will be taken from it, otherwise API will be called.
  ///
  /// ```
  /// var guildBuilder = GuildBuilder()
  ///                       ..name = "Example Guild"
  ///                       ..roles = [RoleBuilder()..name = "Example Role]
  /// var newGuild = await client.createGuild(guildBuilder);
  /// ```
  Future<Guild> createGuild(GuildBuilder builder) async {
    var r = await this.http.send("POST", "/guilds", body: builder._build());

    return Guild._new(r.body as Map<String, dynamic>);
  }

  /// Gets a webhook by its ID and token.
  /// If the [id] will be in cache - it will be taken from it, otherwise API will be called.
  Future<Webhook> getWebhook(String id, {String token = ""}) async {
    HttpResponse r = await http.send('GET', "/webhooks/$id/$token");
    return Webhook._new(r.body as Map<String, dynamic>);
  }

  /// Block isolate until client is ready.
  Future<ReadyEvent> blockToReady() async => await onReady.first;

  /// Gets an [Invite] object with given code.
  /// If the [id] will be in cache - it will be taken from it, otherwise API will be called.
  ///
  /// ```
  /// var inv = client.getInvite("YMgffU8");
  /// ```
  Future<Invite> getInvite(String code) async {
    final HttpResponse r = await this.http.send('GET', '/invites/$code');
    return Invite._new(r.body as Map<String, dynamic>);
  }
}
