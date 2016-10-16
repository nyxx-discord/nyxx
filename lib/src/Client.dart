part of discord;

/// The base class.
/// It contains all of the methods.
class Client {
  String _token;
  ClientOptions _options;
  DateTime _startTime;
  _Http _http;
  _WS _ws;
  _EventController _events;
  _Util _util;

  /// The logged in user.
  ClientUser user;

  /// The bot's OAuth2 app.
  ClientOAuth2Application app;

  /// All of the guilds the bot is in.
  Map<String, Guild> guilds;

  /// All of the channels the bot is in.
  Map<String, dynamic> channels;

  /// All of the users the bot can see. Does not always have offline users
  /// without forceFetchUsers enabled.
  Map<String, User> users;

  /// Whether or not the client is ready.
  bool ready = false;

  /// The current version.
  String version = "0.13.3";

  /// The client's SS manager, null if the client is not sharded, [SSServer] if
  /// the current shard is 0, [SSClient] otherwise.
  dynamic ss;

  /// The client's internal shards.
  Map<int, Shard> shards;

  /// The client's uptime.
  Duration get uptime => new DateTime.now().difference(_startTime);

  /// Emitted when the client is ready.
  Stream<ReadyEvent> onReady;

  /// Emitted when a message is received.
  Stream<MessageEvent> onMessage;

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

  /// Creates and logs in a new client.
  Client(this._token, [this._options]) {
    if (this._options == null) {
      this._options = new ClientOptions();
    }

    this.guilds = new Map<String, Guild>();
    this.channels = new Map<String, dynamic>();
    this.users = new Map<String, User>();
    this.shards = new Map<int, Shard>();

    this._http = new _Http(this);
    this._events = new _EventController(this);
    this._util = new _Util();
    this._ws = new _WS(this);

    if (this._options.shardCount > 1) {
      if (this._options.shardIds.contains(0)) {
        this.ss = new SSServer(this);
      } else {
        this.ss = new SSClient(this);
      }
    }
  }

  /// Destroys the websocket connection, SS connection or server, and all streams.
  Future<Null> destroy() async {
    await this._ws.close();
    this._http.httpClient.close();
    await this._events.destroy();
    if (this.ss is SSServer) {
      await this.ss.close();
    } else if (this.ss is SSClient) {
      this.ss.destroy();
    }
    return null;
  }

  /// Gets a [User] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getUser("user id");
  Future<User> getUser(dynamic user) async {
    final String id = this._util.resolve('user', user);

    final _HttpResponse r = await this._http.get('/users/$id');
    return new User._new(this, r.json as Map<String, dynamic>);
  }

  /// Gets an [Invite] object.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Client.getInvite("invite code");
  Future<Invite> getInvite(String code) async {
    final _HttpResponse r = await this._http.get('/invites/$code');
    return new Invite._new(this, r.json as Map<String, dynamic>);
  }

  /// Gets an [OAuth2Info] object.
  ///
  /// Throws an [Exception] if the HTTP request errored
  ///     Client.getOAuth2Info("app id");
  Future<OAuth2Info> getOAuth2Info(dynamic app) async {
    final String id = this._util.resolve('app', app);

    final _HttpResponse r =
        await this._http.get('/oauth2/authorize?client_id=$id&scope=bot');
    return new OAuth2Info._new(this, r.json as Map<String, dynamic>);
  }
}
