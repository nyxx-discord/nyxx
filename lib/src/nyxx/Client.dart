part of nyxx;

/// Class representing client - it's place to start with.
/// From there you can subscribe to varius [Stream]s to listen to [Events](https://github.com/l7ssha/nyxx/wiki/EventList)
/// Rememeber to close [Client] before terminating program:
/// ```dart
///  bot.destroy();
/// ```
/// It closes bot connections to discord servers and makes sure that everything is terminated correctly.
class Client {
  String _token;
  ClientOptions _options;
  DateTime _startTime;
  _WS _ws;
  _EventController _events;

  // Users state cache
  Map<Snowflake, UserVoiceState> _voiceStates;

  /// The HTTP client.
  Http http;

  /// The logged in user.
  ClientUser user;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// All of the guilds the bot is in.
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

  Logger logger = new Logger.detached("Client");

  /// Creates and logs in a new client.
  Client(this._token, [this._options]) {
    Isolate.current.setErrorsFatal(false);
    ReceivePort errorsPort = new ReceivePort();
    errorsPort.listen((err) {
      logger.severe("ERROR: ${err[0]} \n ${err[1]}");
    });
    Isolate.current.addErrorListener(errorsPort.sendPort);

    if (this._token == null || this._token == "")
      throw new Exception("Token cannot be null or empty");

    if (this._options == null) this._options = new ClientOptions();

    this._voiceStates = new Map<Snowflake, UserVoiceState>();
    this.guilds = new Map<Snowflake, Guild>();
    this.channels = new Map<Snowflake, Channel>();
    this.users = new Map<Snowflake, User>();
    this.shards = new Map<int, Shard>();

    this.http = new Http._new(this);
    this._events = new _EventController(this);
    this._ws = new _WS(this);

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('[${rec.level.name}] {${rec.loggerName}} - '
          '${rec.time.day}.${rec.time.month}.${rec.time.year}'
          '${rec.time.hour}:${rec.time.minute}:${rec.time.second}'
          ':${rec.time.millisecond} '
          '-- ${rec.message}');
    });
  }

  /// The client's uptime.
  Duration get uptime => new DateTime.now().difference(_startTime);

  /// Get user instance with specified id.
  Future<User> getUser(Snowflake id) async {
    if (this.users.containsKey(id)) return this.users[id];

    var r = await this.http.send("GET", "/users/${id.toString()}");
    return new User._new(this, r.body);
  }

  /// Gets Guild with specified id.
  Future<Guild> getGuild(Snowflake id) async {
    if (this.guilds.containsKey(id)) return this.guilds[id];

    var r = await this.http.send("GET", "/guilds/${id.toString()}");
    return new Guild._new(this, r.body);
  }

  /// Creates new guild with provided builder.
  Future<Guild> createGuild(GuildBuilder builder) async {
    var r = await this.http.send("POST", "/guilds", body: builder._build());

    return new Guild._new(this, r.body);
  }

  /// Destroys the websocket connection, and all streams.
  Future<void> destroy() async {
    await this._ws.close();
    await this._events.destroy();
  }

  /// Gets a webhook by its ID and token.
  Future<Webhook> getWebhook(String id, {String token: ""}) async {
    HttpResponse r = await http.send('GET', "/webhooks/$id/$token");
    return new Webhook._new(this, r.body);
  }

  /// Block isolate until client is ready
  Future<ReadyEvent> blockToReady() async => await onReady.first;

  /// Gets an [Invite] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getInvite("invite code");
  Future<Invite> getInvite(String code) async {
    final HttpResponse r = await this.http.send('GET', '/invites/$code');
    return new Invite._new(this, r.body);
  }

  /// Gets an [OAuth2Info] object.
  ///
  /// Throws an [Exception] if the HTTP request errored
  ///     Client.getOAuth2Info("app id");
  Future<OAuth2Info> getOAuth2Info(String userId) async {
    final HttpResponse r = await this
        .http
        .send('GET', '/oauth2/authorize?client_id=$userId&scope=bot');
    return new OAuth2Info._new(this, r.body);
  }
}
