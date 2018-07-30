part of nyxx;

/// An internal shard.
class Shard {
  /// The shard id.
  int id;

  /// Whether or not the shard is ready.
  bool ready;

  Timer _heartbeatTimer;
  _WS _ws;
  w_transport.WebSocket _socket;
  int _sequence;
  String _sessionId;
  StreamController<Shard> _onReady;
  StreamController<Shard> _onDisconnect;

  /// Emitted when the shard is ready.
  Stream<Shard> onReady;

  /// Emitted when the shard encounters an error.
  Stream<Shard> onDisconnect;

  /// A map of guilds the shard is on.
  Map<String, Guild> guilds = {};

  Shard._new(_WS ws, this.id) {
    this._ws = ws;
    this._onReady = new StreamController<Shard>.broadcast();
    this.onReady = this._onReady.stream;

    this._onDisconnect = new StreamController<Shard>.broadcast();
    this.onDisconnect = this._onDisconnect.stream;
  }

  /// Updates the presence for this shard.
  void setPresence({String status: null, bool afk: false, activity: null}) {
    if (activity == null)
      activity = {
        'name': null,
        'type': 0,
        'url': null,
      };

    Map<String, dynamic> packet = {
      'afk': afk,
      'since': null,
      'status': status,
      'game': {
        'name': activity != null ? activity['name'] : null,
        'type': activity != null ? activity['type'] : 0,
        'url': activity != null ? activity['url'] : null
      }
    };

    this.send("STATUS_UPDATE", packet);
  }

  /// Syncs all guilds; this is automatically called every 30 seconds.
  /// Users only.
  void guildSync() {
    this.send("GUILD_SYNC", this.guilds.keys.toList());
  }

  void _connect([bool resume = true, bool init = false]) {
    this.ready = false;
    if (this._socket != null) this._socket.close();
    if (!init) {
      new Timer(new Duration(seconds: 2), () => _connect(resume));
      return;
    }
    w_transport.WebSocket
        .connect(Uri.parse('${this._ws.gateway}?v=6&encoding=json'))
        .then((w_transport.WebSocket socket) {
      this._socket = socket;
      this._socket.listen((dynamic msg) => this._handleMsg(msg, resume),
          onDone: this._handleErr);
    });
  }

  /// Sends WS data.
  void send(String op, dynamic d) {
    this._socket.add(
        JSON.encode(<String, dynamic>{"op": _Constants.opCodes[op], "d": d}));
  }

  void _heartbeat() {
    if (this._socket.closeCode != null) return;
    this.send("HEARTBEAT", _sequence);
  }

  Future<Null> _handleMsg(String msg, bool resume) async {
    final json = JSON.decode(msg) as Map<String, dynamic>;

    new RawEvent._new(this._ws.client, this, json);

    if (json['s'] != null) {
      this._sequence = json['s'];
    }

    switch (json['op']) {
      case _OPCodes.hello:
        if (this._sessionId == null || !resume) {
          Map<String, dynamic> identifyMsg = <String, dynamic>{
            "token": this._ws.client._token,
            "properties": <String, dynamic>{
              "\$os": Platform.operatingSystem,
              "\$browser": "nyxx",
              "\$device": "nyxx",
              "\$referrer": "",
              "\$referring_domain": ""
            },
            "large_threshold": 100,
            "compress": false
          };
          if (this._ws.bot)
            identifyMsg['shard'] = <int>[
              this.id,
              this._ws.client._options.shardCount
            ];
          this.send("IDENTIFY", identifyMsg);
        } else if (resume) {
          this.send("RESUME", <String, dynamic>{
            "token": this._ws.client._token,
            "session_id": this._sessionId,
            "seq": this._sequence
          });
        }

        this._heartbeatTimer = new Timer.periodic(
            new Duration(milliseconds: json['d']['heartbeat_interval']),
            (Timer t) => this._heartbeat());
        break;

      case _OPCodes.invalidSession:
        this._connect(false);
        break;

      case _OPCodes.dispatch:
        if (this._ws.client._options.disabledEvents.contains(json['t'])) break;

        switch (json['t']) {
          case 'READY':
            this._sessionId = json['d']['session_id'];

            this._ws.client.user = new ClientUser._new(
                this._ws.client, json['d']['user'] as Map<String, dynamic>);

            if (this._ws.client.user.bot) {
              this._ws.client.http.headers['Authorization'] =
                  "Bot ${this._ws.client._token}";
            } else {
              this._ws.client.http.headers['Authorization'] =
                  this._ws.client._token;
              this._ws.client._options.forceFetchMembers = false;
              new Timer.periodic(
                  new Duration(seconds: 30), (Timer t) => guildSync());
            }

            this._ws.client.http.headers['User-Agent'] =
                "${this._ws.client.user.username} (https://github.com/l7ssha/nyxx, ${_Constants.version})";

            json['d']['guilds'].forEach((Map<String, dynamic> o) {
              if (this._ws.client.user.bot)
                this._ws.client.guilds[o['id']] = null;
              else
                this._ws.client.guilds[o['id']] =
                    new Guild._new(this._ws.client, o, true, true);
            });

            json['d']['private_channels'].forEach((Map<String, dynamic> o) {
              if (o['type'] == 1) {
                new DMChannel._new(this._ws.client, o);
              } else {
                new GroupDMChannel._new(this._ws.client, o);
              }
            });

            this.ready = true;
            this._onReady.add(this);

            if (!this._ws.client.user.bot) {
              this._ws.client.ready = true;
              this._ws.client._startTime = new DateTime.now();
              new ReadyEvent._new(this._ws.client);
            }

            break;

          case 'GUILD_MEMBERS_CHUNK':
            json['d']['members'].forEach((Map<String, dynamic> o) {
              new Member._new(this._ws.client, o,
                  this._ws.client.guilds[json['d']['guild_id']]);
            });
            if (!_ws.client.ready) {
              _ws.testReady();
            }
            break;

          case 'MESSAGE_REACTION_REMOVE_ALL':
            new MessageReactionsRemovedEvent._new(this._ws.client, json);
            break;

          case 'MESSAGE_REACTION_ADD':
            new MessageReactionEvent._new(this._ws.client, json, true);
            break;

          case 'MESSAGE_REACTION_REMOVE':
            new MessageReactionEvent._new(this._ws.client, json, false);
            break;

          case 'MESSAGE_DELETE_BULK':
            new MessageDeleteBulkEvent._new(this._ws.client, json);
            break;

          case 'CHANNEL_PINS_UPDATE':
            new ChannelPinsUpdateEvent._new(this._ws.client, json);
            break;

          case 'VOICE_STATE_UPDATE':
            new VoiceStateUpdateEvent._new(this._ws.client, json);
            break;

          case 'GUILD_EMOJIS_UPDATE':
            new GuildEmojisUpdateEvent._new(this._ws.client, json);
            break;

          case 'VOICE_SERVER_UPDATE':
            new VoiceServerUpdateEvent._new(this._ws.client, json);
            break;

          case 'MESSAGE_CREATE':
            new MessageEvent._new(this._ws.client, json);
            break;

          case 'MESSAGE_DELETE':
            new MessageDeleteEvent._new(this._ws.client, json);
            break;

          case 'MESSAGE_UPDATE':
            new MessageUpdateEvent._new(this._ws.client, json);
            break;

          case 'GUILD_CREATE':
            new GuildCreateEvent._new(this._ws.client, json, this);
            break;

          case 'GUILD_UPDATE':
            new GuildUpdateEvent._new(this._ws.client, json);
            break;

          case 'GUILD_DELETE':
            if (json['d']['unavailable'] == true)
              new GuildUnavailableEvent._new(this._ws.client, json);
            else
              new GuildDeleteEvent._new(this._ws.client, json, this);
            break;

          case 'GUILD_BAN_ADD':
            new GuildBanAddEvent._new(this._ws.client, json);
            break;

          case 'GUILD_BAN_REMOVE':
            new GuildBanRemoveEvent._new(this._ws.client, json);
            break;

          case 'GUILD_MEMBER_ADD':
            new GuildMemberAddEvent._new(this._ws.client, json);
            break;

          case 'GUILD_MEMBER_REMOVE':
            new GuildMemberRemoveEvent._new(this._ws.client, json);
            break;

          case 'GUILD_MEMBER_UPDATE':
            new GuildMemberUpdateEvent._new(this._ws.client, json);
            break;

          case 'CHANNEL_CREATE':
            new ChannelCreateEvent._new(this._ws.client, json);
            break;

          case 'CHANNEL_UPDATE':
            new ChannelUpdateEvent._new(this._ws.client, json);
            break;

          case 'CHANNEL_DELETE':
            new ChannelDeleteEvent._new(this._ws.client, json);
            break;

          case 'TYPING_START':
            new TypingEvent._new(this._ws.client, json);
            break;

          case 'PRESENCE_UPDATE':
            new PresenceUpdateEvent._new(this._ws.client, json);
            break;

          case 'GUILD_ROLE_CREATE':
            new RoleCreateEvent._new(this._ws.client, json);
            break;

          case 'GUILD_ROLE_UPDATE':
            new RoleUpdateEvent._new(this._ws.client, json);
            break;

          case 'GUILD_ROLE_DELETE':
            new RoleDeleteEvent._new(this._ws.client, json);
            break;
        }
        break;
    }

    return null;
  }

  void _handleErr() {
    this._heartbeatTimer.cancel();

    switch (this._socket.closeCode) {
      case 1005:
        return;

      case 4004:
        throw new InvalidTokenError();

      case 4010:
        throw new InvalidShardError();

      case 4007:
        this._connect(false);
        break;

      case 4009:
        this._connect(false);
        break;

      default:
        this._connect();
        break;
    }
    new DisconnectEvent._new(this._ws.client, this, this._socket.closeCode);
    this._onDisconnect.add(this);
  }
}
