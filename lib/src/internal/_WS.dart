part of discord;

/// The WS manager for the client.
class _WS {
  /// The base websocket URL.
  String gateway;

  /// The client that the WS manager belongs to.
  Client client;

  /// The websocket connection.
  WebSocket socket;

  /// The last sequence received from Discord.
  int sequence;

  /// The session ID.
  String sessionID;

  /// Makes a new WS manager.
  _WS(this.client) {
    this.client._http.get('/gateway').then((http.Response r) {
      this.gateway = JSON.decode(r.body)['url'];
      this.connect();
    });
  }

  /// COnnects to the websocket.
  void connect([bool resume = true]) {
    if (this.socket != null) {
      this.socket.close();
    }
    WebSocket
        .connect('${this.gateway}?v=6&encoding=json')
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
  }

  Future<Null> handleMsg(String msg, bool resume) async {
    final json = JSON.decode(msg) as Map<String, dynamic>;

    if (json['s'] != null) {
      this.sequence = json['s'];
    }

    if (json["op"] == _Constants.opCodes['HELLO']) {
      const Duration heartbeatInterval = const Duration(milliseconds: 41250);
      new Timer.periodic(heartbeatInterval, (Timer t) => this.heartbeat());

      if (this.sessionID == null || !resume) {
        this.client.ready = false;
        this.send("IDENTIFY", <String, dynamic>{
          "token": this.client._token,
          "properties": <String, dynamic>{"\$browser": "Discord Dart"},
          "large_threshold": 100,
          "compress": false,
          "shard": <int>[
            this.client._options.shardId,
            this.client._options.shardCount
          ]
        });
      } else if (resume) {
        this.send("RESUME", <String, dynamic>{
          "token": this.client._token,
          "session_id": this.sessionID,
          "seq": this.sequence
        });
      }
    } else if (json["op"] == _Constants.opCodes['INVALID_SESSION']) {
      this.connect(false);
    } else if (json["op"] == _Constants.opCodes['DISPATCH']) {
      switch (json['t']) {
        case 'READY':
          this.sessionID = json['d']['session_id'];
          this.client.user = new ClientUser._new(
              this.client, json['d']['user'] as Map<String, dynamic>);

          json['d']['guilds'].forEach((Map<String, dynamic> o) {
            this.client.guilds.map[o['id']] = null;
          });

          json['d']['private_channels'].forEach((Map<String, dynamic> o) {
            this.client.channels.add(new PrivateChannel._new(client, o));
          });

          if (this.client.user.bot) {
            this.client._http.headers['Authorization'] =
                "Bot ${this.client._token}";
          } else {
            this.client._http.headers['Authorization'] = this.client._token;
          }
          break;
        case 'MESSAGE_CREATE':
          MessageEvent msgEvent = new MessageEvent._new(this.client, json);
          if (msgEvent.message.channel.type == "private" &&
              this.client.ss is SSServer) {
            for (Socket socket in this.client.ss.sockets) {
              socket.write(JSON.encode(
                  <String, dynamic>{"op": 3, "t": client._token, "d": json}));
            }
          }
          break;

        case 'MESSAGE_DELETE':
          new MessageDeleteEvent._new(this.client, json);
          break;

        case 'MESSAGE_UPDATE':
          new MessageUpdateEvent._new(this.client, json);
          break;

        case 'GUILD_CREATE':
          new GuildCreateEvent._new(this.client, json);
          break;

        case 'GUILD_UPDATE':
          new GuildUpdateEvent._new(this.client, json);
          break;

        case 'GUILD_DELETE':
          if (json['d']['unavailable']) {
            new GuildUnavailableEvent._new(this.client, json);
          } else {
            new GuildDeleteEvent._new(this.client, json);
          }
          break;

        case 'GUILD_BAN_ADD':
          new GuildBanAddEvent._new(this.client, json);
          break;

        case 'GUILD_BAN_REMOVE':
          new GuildBanRemoveEvent._new(this.client, json);
          break;

        case 'GUILD_MEMBER_ADD':
          new GuildMemberAddEvent._new(this.client, json);
          break;

        case 'GUILD_MEMBER_REMOVE':
          new GuildMemberRemoveEvent._new(this.client, json);
          break;

        case 'GUILD_MEMBER_UPDATE':
          new GuildMemberUpdateEvent._new(this.client, json);
          break;

        case 'CHANNEL_CREATE':
          new ChannelCreateEvent._new(this.client, json);
          break;

        case 'CHANNEL_UPDATE':
          new ChannelUpdateEvent._new(this.client, json);
          break;

        case 'CHANNEL_DELETE':
          new ChannelDeleteEvent._new(this.client, json);
          break;

        case 'TYPING_START':
          new TypingEvent._new(this.client, json);
          break;

        case 'PRESENCE_UPDATE':
          new PresenceUpdateEvent._new(this.client, json);
          break;
      }
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
        return;

      case 4009:
        this.connect(false);
        return;

      default:
        this.connect();
        return;
    }
  }
}
