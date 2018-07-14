part of nyxx;

/// Class representing client - it's place to start with.
/// From there you can subscribe to varius [Stream]s to listen to [Events](https://github.com/l7ssha/nyxx/wiki/EventList)
/// Rememeber to close [Client] before terminating program:
/// ```dart
///  bot.destroy();
/// ```
/// It closes bot connections to discord servers and makes sure that everything is terminated correctly.
/// [Client] is also used when creating instance of [Commands] - Commands Framework.
class Client {
  String _token;
  ClientOptions _options;
  DateTime _startTime;
  _WS _ws;
  _EventController _events;

  /// The HTTP client.
  Http http;

  /// The logged in user.
  ClientUser user;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// All of the guilds the bot is in.
  Map<String, Guild> guilds;

  /// All of the channels the bot is in.
  Map<String, Channel> channels;

  /// All of the users the bot can see. Does not always have offline users
  /// without forceFetchUsers enabled.
  Map<String, User> users;

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

  /// Creates and logs in a new client.
  Client(this._token, [this._options]) {
    if (!internals.setup) throw new NotSetupError();

    if (this._token == null || this._token == "")
      throw new Exception("Token cannot be null or empty");

    if (this._options == null) {
      this._options = new ClientOptions();
    }

    this.guilds = new Map<String, Guild>();
    this.channels = new Map<String, dynamic>();
    this.users = new Map<String, User>();
    this.shards = new Map<int, Shard>();

    this.http = new Http._new(this);
    this._events = new _EventController(this);
    this._ws = new _WS(this);
  }

  /// The client's uptime.
  Duration get uptime => new DateTime.now().difference(_startTime);

  /// Destroys the websocket connection, and all streams.
  Future<Null> destroy() async {
    await this._ws.close();
    await this._events.destroy();
    return null;
  }

  /// Gets a [User] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getUser("user id");
  Future<User> getUser(String userId) async {
    final HttpResponse r = await this.http.send('GET', '/users/userId');
    return new User._new(this, r.body.asJson() as Map<String, dynamic>);
  }

  /// Gets an [Invite] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getInvite("invite code");
  Future<Invite> getInvite(String code) async {
    final HttpResponse r = await this.http.send('GET', '/invites/$code');
    return new Invite._new(this, r.body.asJson() as Map<String, dynamic>);
  }

  /// Gets an [OAuth2Info] object.
  ///
  /// Throws an [Exception] if the HTTP request errored
  ///     Client.getOAuth2Info("app id");
  Future<OAuth2Info> getOAuth2Info(String userId) async {
    final HttpResponse r = await this
        .http
        .send('GET', '/oauth2/authorize?client_id=$userId&scope=bot');
    return new OAuth2Info._new(this, r.body.asJson() as Map<String, dynamic>);
  }
}
