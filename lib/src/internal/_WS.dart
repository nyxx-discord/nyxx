part of discord;

class _Shard {
  int id;
  Duration heartbeatInterval;
  _WS ws;
  WebSocket socket;
  int sequence;
  String sessionId;
  bool ready;
  bool master;

  StreamController<_Shard> onReady;
  StreamController<_Shard> onError;

  _Shard(this.ws, this.id, [this.master = false]) {
    this.onReady = new StreamController.broadcast();
    this.onError = new StreamController.broadcast();
  }

  /// Connects to the websocket.
  void connect([bool resume = true]) {
    this.ready = false;
    if (this.socket != null) {
      this.socket.close();
    }
    WebSocket
        .connect('${this.ws.gateway}?v=6&encoding=json')
        .then((WebSocket socket) {
      this.socket = socket;
      this.socket.listen((String msg) => this.handleMsg(msg, resume),
          onDone: () => this.handleErr());
    });
  }

  /// Sends WS data.
  void send(String op, dynamic d) {
    this.socket.add(
        JSON.encode(<String, dynamic>{"op": _Constants.opCodes[op], "d": d}));
  }

  /// Sends a heartbeat packet.
  void heartbeat() {
    this.send("HEARTBEAT", this.sequence);
    new Timer(heartbeatInterval, heartbeat);
  }

  Future<Null> handleMsg(String msg, bool resume) async {
    final json = JSON.decode(msg) as Map<String, dynamic>;

    if (json['s'] != null) {
      this.sequence = json['s'];
    }

    if (json['op'] == 11) print(11);

    switch (json['op']) {
      case _OPCodes.hello:
        if (this.sessionId == null || !resume) {
          this.send("IDENTIFY", <String, dynamic>{
            "token": this.ws.client._token,
            "properties": <String, dynamic>{"\$browser": "Discord Dart"},
            "large_threshold": 100,
            "compress": false,
            "shard": <int>[this.id, this.ws.client._options.shardCount]
          });
        } else if (resume) {
          this.send("RESUME", <String, dynamic>{
            "token": this.ws.client._token,
            "session_id": this.sessionId,
            "seq": this.sequence
          });
        }
        this.heartbeatInterval =
            new Duration(milliseconds: json['d']['heartbeat_interval']);
        new Timer.periodic(heartbeatInterval, (Timer t) => this.heartbeat());
        break;

      case _OPCodes.invalidSession:
        this.connect(false);
        break;

      case _OPCodes.dispatch:
        if (this.ws.client._options.disabledEvents.contains(json['t'])) break;

        switch (json['t']) {
          case 'READY':
            this.sessionId = json['d']['session_id'];

            this.ws.client.user = new ClientUser._new(
                this.ws.client, json['d']['user'] as Map<String, dynamic>);

            if (this.ws.client.user.bot) {
              this.ws.client._http.headers['Authorization'] =
                  "Bot ${this.ws.client._token}";
            } else {
              this.ws.client._http.headers['Authorization'] =
                  this.ws.client._token;
            }

            json['d']['guilds'].forEach((Map<String, dynamic> o) {
              this.ws.client.guilds.map[o['id']] = null;
            });

            json['d']['private_channels'].forEach((Map<String, dynamic> o) {
              this
                  .ws
                  .client
                  .channels
                  .add(new PrivateChannel._new(this.ws.client, o));
            });

            this.ready = true;
            this.onReady.add(this);
            break;

          case 'MESSAGE_CREATE':
            MessageEvent msgEvent = new MessageEvent._new(this.ws.client, json);
            if (msgEvent.message.channel.type == "private" &&
                this.ws.client.ss is SSServer) {
              for (Socket socket in this.ws.client.ss.sockets) {
                socket.write(JSON.encode(<String, dynamic>{
                  "op": 3,
                  "t": ws.client._token,
                  "d": json
                }));
              }
            }
            break;

          case 'MESSAGE_DELETE':
            new MessageDeleteEvent._new(this.ws.client, json);
            break;

          case 'MESSAGE_UPDATE':
            new MessageUpdateEvent._new(this.ws.client, json);
            break;

          case 'GUILD_CREATE':
            new GuildCreateEvent._new(this.ws.client, json, this.ws);
            break;

          case 'GUILD_UPDATE':
            new GuildUpdateEvent._new(this.ws.client, json);
            break;

          case 'GUILD_DELETE':
            if (json['d']['unavailable']) {
              new GuildUnavailableEvent._new(this.ws.client, json);
            } else {
              new GuildDeleteEvent._new(this.ws.client, json);
            }
            break;

          case 'GUILD_BAN_ADD':
            new GuildBanAddEvent._new(this.ws.client, json);
            break;

          case 'GUILD_BAN_REMOVE':
            new GuildBanRemoveEvent._new(this.ws.client, json);
            break;

          case 'GUILD_MEMBER_ADD':
            new GuildMemberAddEvent._new(this.ws.client, json);
            break;

          case 'GUILD_MEMBER_REMOVE':
            new GuildMemberRemoveEvent._new(this.ws.client, json);
            break;

          case 'GUILD_MEMBER_UPDATE':
            new GuildMemberUpdateEvent._new(this.ws.client, json);
            break;

          case 'CHANNEL_CREATE':
            new ChannelCreateEvent._new(this.ws.client, json);
            break;

          case 'CHANNEL_UPDATE':
            new ChannelUpdateEvent._new(this.ws.client, json);
            break;

          case 'CHANNEL_DELETE':
            new ChannelDeleteEvent._new(this.ws.client, json);
            break;

          case 'TYPING_START':
            new TypingEvent._new(this.ws.client, json);
            break;

          case 'PRESENCE_UPDATE':
            new PresenceUpdateEvent._new(this.ws.client, json);
            break;

          case 'GUILD_ROLE_CREATE':
            new RoleCreateEvent._new(this.ws.client, json);
            break;

          case 'GUILD_ROLE_UPDATE':
            new RoleUpdateEvent._new(this.ws.client, json);
            break;

          case 'GUILD_ROLE_DELETE':
            new RoleDeleteEvent._new(this.ws.client, json);
            break;
        }
        break;
    }

    return null;
  }

  void handleErr() {
    switch (this.socket.closeCode) {
      case 1005:
        return;

      case 4004:
        throw new InvalidTokenError();

      case 4010:
        throw new InvalidShardError();

      case 4007:
        this.connect(false);
        this.onError.add(this);
        return;

      case 4009:
        this.connect(false);
        this.onError.add(this);
        return;

      default:
        this.connect();
        this.onError.add(this);
        return;
    }
  }
}

/// The WS manager for the client.
class _WS {
  /// The base websocket URL.
  String gateway;

  /// The client that the WS manager belongs to.
  Client client;

  List<_Shard> shards = <_Shard>[];

  /// Makes a new WS manager.
  _WS(this.client) {
    this.client._http.get('/gateway', true).then((_HttpResponse r) {
      this.gateway = r.json['url'];
      for (int shardId in this.client._options.shardIds) {
        _Shard shard = new _Shard(
            this, shardId, shardId == this.client._options.shardIds[0]);
        this.shards.add(shard);

        shard.onReady.stream.listen((_Shard s) {
          if (!client.ready) {
            bool match = true;
            client.guilds.forEach((Guild o) {
              if (o == null) match = false;
            });

            bool match2 = true;
            shards.forEach((_Shard s) {
              if (!s.ready) match = false;
            });

            if (match && match2) {
              client.ready = true;
              if (client.user.bot) {
                client._http
                    .get('/oauth2/applications/@me', true)
                    .then((_HttpResponse r) {
                  client.app = new ClientOAuth2Application._new(client, r.json);
                  new ReadyEvent._new(client);
                });
              } else {
                new ReadyEvent._new(client);
              }
            }
          }
        });
      }
      this.connectShard(0);
    });
  }

  Future<Null> close() async {
    for (_Shard shard in this.shards) {
      await shard.socket.close();
    }
    return null;
  }

  void connectShard(int index) {
    this.shards[index].connect();
    if (index + 1 != this.client._options.shardIds.length)
      new Timer(new Duration(seconds: 6), () => connectShard(index + 1));
  }
}
