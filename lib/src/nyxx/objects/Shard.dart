part of nyxx;

//ZLibDecoder _zlib = new ZLibDecoder();

/// Discord gateways implement a method of user-controlled guild sharding which allows for splitting events across a number of gateway connections.
/// Guild sharding is entirely user controlled, and requires no state-sharing between separate connections to operate.
class Shard {
  /// The shard id.
  int id;

  /// Whether or not the shard is ready.
  bool ready;

  /// Emitted when the shard is ready.
  Stream<Shard> onReady;

  /// Emitted when the shard encounters an error.
  Stream<Shard> onDisconnect;

  /// A map of guilds the shard is on.
  Map<Snowflake, Guild> guilds = {};

  Timer _heartbeatTimer;
  _WS _ws;
  WebSocket _socket;
  int _sequence;
  String _sessionId;
  StreamController<Shard> _onReady;
  StreamController<Shard> _onDisconnect;

  Logger _logger = Logger.detached("Websocket");

  Shard._new(_WS ws, this.id) {
    this._ws = ws;
    this._onReady = StreamController<Shard>.broadcast();
    this.onReady = this._onReady.stream;

    this._onDisconnect = StreamController<Shard>.broadcast();
    this.onDisconnect = this._onDisconnect.stream;
  }

  void setPresence({String status, bool afk, Presence game}) {
    Map<String, dynamic> packet = {
      "afk": afk,
      "since": null,
      "status": status,
      "game": {
        "name": game != null ? game.name : null,
        "type": game != null ? game.type : null,
        "url": game != null ? game.url : null
      }
    };

    this.send("STATUS_UPDATE", packet);
  }

  /// Syncs all guild
  void guildSync() => this.send("GUILD_SYNC", this.guilds.keys.toList());

  // Attempts to connect to ws
  void _connect([bool resume = true, bool init = false]) {
    if (!resume) _logger.warning("DISCONNECTED. Trying to reconnect...");

    this.ready = false;
    if (this._socket != null) this._socket.close();
    if (!init) {
      Timer(Duration(seconds: 2), () => _connect(resume));
      return;
    }

    WebSocket.connect('${this._ws.gateway}?v=7&encoding=json')
        .then((WebSocket socket) {
      if (!resume) _logger.severe("RECONNECTED");

      this._socket = socket;
      this._socket.listen((dynamic msg) async {
        await this._handleMsg(_decodeBytes(msg), resume);
      }, onDone: this._handleErr);
    });
  }

  // Decodes zlib compresses string into string json
  Map<String, dynamic> _decodeBytes(dynamic bytes) {
    if (bytes is String) return jsonDecode(bytes) as Map<String, dynamic>;

    var decoded = zlib.decoder.convert(bytes as List<int>);
    var rawStr = utf8.decode(decoded);
    return jsonDecode(rawStr) as Map<String, dynamic>;
  }

  /// Sends WS data.
  void send(String op, d) => this._socket.add(
      jsonEncode(<String, dynamic>{"op": _OPCodes.matchOpCode(op), "d": d}));

  void _heartbeat() {
    if (this._socket.closeCode != null) return;
    this.send("HEARTBEAT", _sequence);
  }

  Future<void> _handleMsg(Map<String, dynamic> msg, bool resume) async {
    RawEvent._new(this._ws.client, this, msg);

    if (msg['s'] != null) this._sequence = msg['s'] as int;

    switch (msg['op'] as int) {
      case _OPCodes.HELLP:
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
            "compress": true
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

        this._heartbeatTimer = Timer.periodic(
            Duration(milliseconds: msg['d']['heartbeat_interval'] as int),
            (Timer t) => this._heartbeat());
        break;

      case _OPCodes.INVALID_SESSION:
        this._connect(false);
        break;

      case _OPCodes.DISPATCH:
        var j = msg['t'] as String;
        switch (j) {
          case 'READY':
            this._sessionId = msg['d']['session_id'] as String;

            this._ws.client.self = ClientUser._new(
                this._ws.client, msg['d']['user'] as Map<String, dynamic>);

            if (this._ws.client.self.bot) {
              this._ws.client.http.headers['Authorization'] =
                  "Bot ${this._ws.client._token}";
            } else {
              this._ws.client.http.headers['Authorization'] =
                  this._ws.client._token;
              this._ws.client._options.forceFetchMembers = false;
            }

            this._ws.client.http.headers['User-Agent'] =
                "${this._ws.client.self.username} (${_Constants.repoUrl}, ${_Constants.version})";

            msg['d']['guilds'].forEach((dynamic o) {
              var snow = Snowflake(o['id'] as String);
              if (this._ws.client.self.bot)
                this._ws.client.guilds[snow] = null;
              else
                this._ws.client.guilds[snow] = Guild._new(
                    this._ws.client, o as Map<String, dynamic>, true, true);
            });

            msg['d']['private_channels'].forEach((dynamic o) {
              if (o['type'] == 1) {
                DMChannel._new(this._ws.client, o as Map<String, dynamic>);
              } else {
                GroupDMChannel._new(this._ws.client, o as Map<String, dynamic>);
              }
            });

            this.ready = true;
            this._onReady.add(this);

            if (!this._ws.client.self.bot) {
              this._ws.client.ready = true;
              this._ws.client._startTime = DateTime.now();
              ReadyEvent._new(this._ws.client);
            }

            break;

          case 'GUILD_MEMBERS_CHUNK':
            msg['d']['members'].forEach((dynamic o) {
              Member._new(this._ws.client, o as Map<String, dynamic>,
                  this._ws.client.guilds[msg['d']['guild_id']]);
            });

            if (!_ws.client.ready) _ws.testReady();
            break;

          case 'MESSAGE_REACTION_REMOVE_ALL':
            MessageReactionsRemovedEvent._new(this._ws.client, msg);
            break;

          case 'MESSAGE_REACTION_ADD':
            MessageReactionEvent._new(this._ws.client, msg, false);
            break;

          case 'MESSAGE_REACTION_REMOVE':
            MessageReactionEvent._new(this._ws.client, msg, true);
            break;

          case 'MESSAGE_DELETE_BULK':
            MessageDeleteBulkEvent._new(this._ws.client, msg);
            break;

          case 'CHANNEL_PINS_UPDATE':
            ChannelPinsUpdateEvent._new(this._ws.client, msg);
            break;

          case 'VOICE_STATE_UPDATE':
            VoiceStateUpdateEvent._new(this._ws.client, msg);
            break;

          case 'VOICE_SERVER_UPDATE':
            VoiceServerUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_EMOJIS_UPDATE':
            GuildEmojisUpdateEvent._new(this._ws.client, msg);
            break;

          case 'MESSAGE_CREATE':
            MessageEvent._new(this._ws.client, msg);
            break;

          case 'MESSAGE_DELETE':
            MessageDeleteEvent._new(this._ws.client, msg);
            break;

          case 'MESSAGE_UPDATE':
            MessageUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_CREATE':
            GuildCreateEvent._new(this._ws.client, msg, this);
            break;

          case 'GUILD_UPDATE':
            GuildUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_DELETE':
            if (msg['d']['unavailable'] == true)
              GuildUnavailableEvent._new(this._ws.client, msg);
            else
              GuildDeleteEvent._new(this._ws.client, msg, this);
            break;

          case 'GUILD_BAN_ADD':
            GuildBanAddEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_BAN_REMOVE':
            GuildBanRemoveEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_MEMBER_ADD':
            GuildMemberAddEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_MEMBER_REMOVE':
            GuildMemberRemoveEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_MEMBER_UPDATE':
            GuildMemberUpdateEvent._new(this._ws.client, msg);
            break;

          case 'CHANNEL_CREATE':
            ChannelCreateEvent._new(this._ws.client, msg);
            break;

          case 'CHANNEL_UPDATE':
            ChannelUpdateEvent._new(this._ws.client, msg);
            break;

          case 'CHANNEL_DELETE':
            ChannelDeleteEvent._new(this._ws.client, msg);
            break;

          case 'TYPING_START':
            TypingEvent._new(this._ws.client, msg);
            break;

          case 'PRESENCE_UPDATE':
            PresenceUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_ROLE_CREATE':
            RoleCreateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_ROLE_UPDATE':
            RoleUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_ROLE_DELETE':
            RoleDeleteEvent._new(this._ws.client, msg);
            break;
        }
        break;
    }
  }

  Exception _throw(String msg) => Exception(
      "${this._socket.closeCode}: ${this._socket.closeReason} - '$msg'");

  void _handleErr() {
    this._heartbeatTimer.cancel();

    switch (this._socket.closeCode) {
      case 1005:
        throw _throw(
            'No status code was provided even though one was expected.');
      case 4004:
        throw _throw(
            'The account token sent with your identify payload is incorrect.');
      case 4010:
        throw _throw('You sent an invalid shard when identifying.');
      case 4007:
      case 4009:
        this._connect(false);
        break;
      default:
        this._connect();
        break;
    }

    DisconnectEvent._new(this._ws.client, this, this._socket.closeCode);
    this._onDisconnect.add(this);
  }
}
