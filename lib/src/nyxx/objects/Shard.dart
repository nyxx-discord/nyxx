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
  Map<Snowflake, Guild> guilds = {};

  ZLibDecoder _zlib;

  Shard._new(_WS ws, this.id) {
    this._ws = ws;
    this._onReady = new StreamController<Shard>.broadcast();
    this.onReady = this._onReady.stream;

    this._onDisconnect = new StreamController<Shard>.broadcast();
    this.onDisconnect = this._onDisconnect.stream;

    _zlib = new ZLibDecoder();
  }

  void setPresence({String status, bool afk, Game game}) {
    Map<String, dynamic> packet = {
      "afk": afk,
      "since": null,
      "status": status,
      "game": {
        "name": game != null ? game.name : null,
        "type":  game != null ? game.type : null,
        "url":  game != null ? game.url : null
      }
    };

    this.send("STATUS_UPDATE", packet);
  }

  /// Syncs all guild
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
      this._socket.listen((dynamic msg) async {
        await this._handleMsg(_decodeBytes(msg), resume);
      }, onDone: this._handleErr);
    });
  }

  Map<String, dynamic> _decodeBytes(dynamic bytes) {
    if (bytes is String) {
      return jsonDecode(bytes as String) as Map<String, dynamic>;
    } else {
      var decoded = _zlib.convert(bytes as List<int>);
      var rawStr = utf8.decode(decoded);
      return jsonDecode(rawStr) as Map<String, dynamic>;
    }
  }

  /// Sends WS data.
  void send(String op, dynamic d) => this._socket.
    add(jsonEncode(<String, dynamic>{"op": _Constants.opCodes[op], "d": d}));

  void _heartbeat() {
    if (this._socket.closeCode != null) return;
    this.send("HEARTBEAT", _sequence);
  }

  Future<Null> _handleMsg(Map<String, dynamic> msg, bool resume) async {
    new RawEvent._new(this._ws.client, this, msg);

    if (msg['s'] != null)
      this._sequence = msg['s'] as int;

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

        this._heartbeatTimer = new Timer.periodic(
            new Duration(milliseconds: msg['d']['heartbeat_interval'] as int),
            (Timer t) => this._heartbeat());
        break;

      case _OPCodes.INVALID_SESSION:
        this._connect(false);
        break;

      case _OPCodes.DISPATCH:
        if (this._ws.client._options.disabledEvents.contains(msg['t'])) break;

        var j = msg['t'] as String;
        switch (j) {
          case 'READY':
            this._sessionId = msg['d']['session_id'] as String;

            this._ws.client.user = new ClientUser._new(
                this._ws.client, msg['d']['user'] as Map<String, dynamic>);

            if (this._ws.client.user.bot) {
              this._ws.client.http.headers['Authorization'] =
                  "Bot ${this._ws.client._token}";
            } else {
              this._ws.client.http.headers['Authorization'] =
                  this._ws.client._token;
              this._ws.client._options.forceFetchMembers = false;
            }

            this._ws.client.http.headers['User-Agent'] =
                "${this._ws.client.user.username} (https://github.com/l7ssha/nyxx, ${_Constants.version})";

            msg['d']['guilds'].forEach((dynamic o) {
              var snow = new Snowflake(o['id'] as String);
              if (this._ws.client.user.bot)
                this._ws.client.guilds[snow] = null;
              else
                this._ws.client.guilds[snow] = new Guild._new(
                    this._ws.client, o as Map<String, dynamic>, true, true);
            });

            msg['d']['private_channels'].forEach((dynamic o) {
              if (o['type'] == 1) {
                new DMChannel._new(this._ws.client, o as Map<String, dynamic>);
              } else {
                new GroupDMChannel._new(
                    this._ws.client, o as Map<String, dynamic>);
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
            msg['d']['members'].forEach((dynamic o) {
              new Member._new(this._ws.client, o as Map<String, dynamic>,
                  this._ws.client.guilds[msg['d']['guild_id']]);
            });

            if (!_ws.client.ready)
              _ws.testReady();
            break;

          case 'MESSAGE_REACTION_REMOVE_ALL':
            new MessageReactionsRemovedEvent._new(this._ws.client, msg);
            break;

          case 'MESSAGE_REACTION_ADD':
            new MessageReactionEvent._new(this._ws.client, msg, true);
            break;

          case 'MESSAGE_REACTION_REMOVE':
            new MessageReactionEvent._new(this._ws.client, msg, false);
            break;

          case 'MESSAGE_DELETE_BULK':
            new MessageDeleteBulkEvent._new(this._ws.client, msg);
            break;

          case 'CHANNEL_PINS_UPDATE':
            new ChannelPinsUpdateEvent._new(this._ws.client, msg);
            break;

          case 'VOICE_STATE_UPDATE':
            new VoiceStateUpdateEvent._new(this._ws.client, msg);
            break;

          case 'VOICE_SERVER_UPDATE':
            new VoiceServerUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_EMOJIS_UPDATE':
            new GuildEmojisUpdateEvent._new(this._ws.client, msg);
            break;

          case 'MESSAGE_CREATE':
            new MessageEvent._new(this._ws.client, msg);
            break;

          case 'MESSAGE_DELETE':
            new MessageDeleteEvent._new(this._ws.client, msg);
            break;

          case 'MESSAGE_UPDATE':
            new MessageUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_CREATE':
            new GuildCreateEvent._new(this._ws.client, msg, this);
            break;

          case 'GUILD_UPDATE':
            new GuildUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_DELETE':
            if (msg['d']['unavailable'] == true)
              new GuildUnavailableEvent._new(this._ws.client, msg);
            else
              new GuildDeleteEvent._new(this._ws.client, msg, this);
            break;

          case 'GUILD_BAN_ADD':
            new GuildBanAddEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_BAN_REMOVE':
            new GuildBanRemoveEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_MEMBER_ADD':
            new GuildMemberAddEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_MEMBER_REMOVE':
            new GuildMemberRemoveEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_MEMBER_UPDATE':
            new GuildMemberUpdateEvent._new(this._ws.client, msg);
            break;

          case 'CHANNEL_CREATE':
            new ChannelCreateEvent._new(this._ws.client, msg);
            break;

          case 'CHANNEL_UPDATE':
            new ChannelUpdateEvent._new(this._ws.client, msg);
            break;

          case 'CHANNEL_DELETE':
            new ChannelDeleteEvent._new(this._ws.client, msg);
            break;

          case 'TYPING_START':
            new TypingEvent._new(this._ws.client, msg);
            break;

          case 'PRESENCE_UPDATE':
            new PresenceUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_ROLE_CREATE':
            new RoleCreateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_ROLE_UPDATE':
            new RoleUpdateEvent._new(this._ws.client, msg);
            break;

          case 'GUILD_ROLE_DELETE':
            new RoleDeleteEvent._new(this._ws.client, msg);
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
        throw new Exception("1005: No Status Recvd - 'No status code was provided even though one was expected.'");
      case 4004:
        throw new Exception("4004: Authentication Failed - 'The account token sent with your identify payload is incorrect.'");
      case 4010:
        throw new Exception("4010: Invalid Shard - 'You sent us an invalid shard when identifying.'");
      case 4007:
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
