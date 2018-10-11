part of nyxx;

/// Discord gateways implement a method of user-controlled guild sharding which allows for splitting events across a number of gateway connections.
/// Guild sharding is entirely user controlled, and requires no state-sharing between separate connections to operate.
class Shard {
  /// The shard id.
  int id;

  /// Whether or not the shard is ready.
  bool ready = false;

  /// Emitted when the shard is ready.
  Stream<Shard> onReady;

  /// Emitted when the shard encounters an error.
  Stream<Shard> onDisconnect;

  /// A map of guilds the shard is on.
  Map<Snowflake, Guild> guilds;

  Timer _heartbeatTimer;
  _WS _ws;
  WebSocket _socket;
  int _sequence;
  String _sessionId;
  StreamController<Shard> _onReady;
  StreamController<Shard> _onDisconnect;

  Logger _logger = Logger.detached("Websocket");

  Shard._new(_WS ws, this.id) {
    guilds = Map();

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
  void _connect([bool resume = false, bool init = false]) {
    if (resume) _logger.severe("DISCONNECTED. Trying to reconnect...");

    this.ready = false;
    if (this._socket != null) this._socket.close();

    if (!init && resume) {
      Timer(Duration(seconds: 2), () => _connect(false));
      return;
    }

    WebSocket.connect('${this._ws.gateway}?v=7&encoding=json').then(
        (WebSocket socket) {
      this._socket = socket;
      this._socket.pingInterval = const Duration(seconds: 3);
      this._socket.listen((dynamic msg) async {
        this.transfer += msg.length as int;
        await this._handleMsg(_decodeBytes(msg), resume);
      }, onDone: this._handleErr, onError: (err) {
        print(err);
        this._handleErr();
      });
    }, onError: (err) {
      print(err);
      this._handleErr();
    });
  }

  int transfer = 0;

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
    RawEvent._new(this, msg);

    if (msg['s'] != null) this._sequence = msg['s'] as int;

    switch (msg['op'] as int) {
      case _OPCodes.HELLP:
        if (this._sessionId == null || !resume) {
          Map<String, dynamic> identifyMsg = <String, dynamic>{
            "token": _client._token,
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

          identifyMsg['shard'] = <int>[this.id, _client._options.shardCount];
          this.send("IDENTIFY", identifyMsg);
        } else if (resume) {
          this.send("RESUME", <String, dynamic>{
            "token": _client._token,
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

            _client.self =
                ClientUser._new(msg['d']['user'] as Map<String, dynamic>);

            if (_client.self.bot) {
              _client.http._headers['Authorization'] = "Bot ${_client._token}";
            } else {
              _client.http._headers['Authorization'] = _client._token;
              _client._options.forceFetchMembers = false;
            }

            _client.http._headers['User-Agent'] =
                "${_client.self.username} (${_Constants.repoUrl}, ${_Constants.version})";

            msg['d']['guilds'].forEach((o) {
              var snow = Snowflake(o['id'] as String);
              if (o['unavailable'] as bool != true) {
                _client.guilds[snow] =
                    Guild._new(o as Map<String, dynamic>, true, true);
              }
            });

            msg['d']['private_channels'].forEach((o) {
              if (o['type'] == 1) {
                var ch = DMChannel._new(o as Map<String, dynamic>);
                client.channels[ch.id] = ch;
              } else {
                var ch = GroupDMChannel._new(o as Map<String, dynamic>);
                client.channels[ch.id] = ch;
              }
            });

            this.ready = true;
            this._onReady.add(this);

            break;

          case 'GUILD_MEMBERS_CHUNK':
            msg['d']['members'].forEach((dynamic o) {
              var mem = Member._new(o as Map<String, dynamic>,
                  _client.guilds[Snowflake(msg['d']['guild_id'])]);
              client.users[mem.id] = mem;
              mem.guild.members[mem.id] = mem;
            });

            if (!_client.ready) _ws.testReady();
            break;

          case 'MESSAGE_REACTION_REMOVE_ALL':
            MessageReactionsRemovedEvent._new(msg);
            break;

          case 'MESSAGE_REACTION_ADD':
            MessageReactionEvent._new(msg, false);
            break;

          case 'MESSAGE_REACTION_REMOVE':
            MessageReactionEvent._new(msg, true);
            break;

          case 'MESSAGE_DELETE_BULK':
            MessageDeleteBulkEvent._new(msg);
            break;

          case 'CHANNEL_PINS_UPDATE':
            ChannelPinsUpdateEvent._new(msg);
            break;

          case 'VOICE_STATE_UPDATE':
            VoiceStateUpdateEvent._new(msg);
            break;

          case 'VOICE_SERVER_UPDATE':
            VoiceServerUpdateEvent._new(msg);
            break;

          case 'GUILD_EMOJIS_UPDATE':
            GuildEmojisUpdateEvent._new(msg);
            break;

          case 'MESSAGE_CREATE':
            MessageEvent._new(msg);
            break;

          case 'MESSAGE_DELETE':
            MessageDeleteEvent._new(msg);
            break;

          case 'MESSAGE_UPDATE':
            MessageUpdateEvent._new(msg);
            break;

          case 'GUILD_CREATE':
            GuildCreateEvent._new(msg, this);
            break;

          case 'GUILD_UPDATE':
            GuildUpdateEvent._new(msg);
            break;

          case 'GUILD_DELETE':
            if (msg['d']['unavailable'] == true)
              GuildUnavailableEvent._new(msg);
            else
              GuildDeleteEvent._new(msg, this);
            break;

          case 'GUILD_BAN_ADD':
            GuildBanAddEvent._new(msg);
            break;

          case 'GUILD_BAN_REMOVE':
            GuildBanRemoveEvent._new(msg);
            break;

          case 'GUILD_MEMBER_ADD':
            GuildMemberAddEvent._new(msg);
            break;

          case 'GUILD_MEMBER_REMOVE':
            GuildMemberRemoveEvent._new(msg);
            break;

          case 'GUILD_MEMBER_UPDATE':
            GuildMemberUpdateEvent._new(msg);
            break;

          case 'CHANNEL_CREATE':
            ChannelCreateEvent._new(msg);
            break;

          case 'CHANNEL_UPDATE':
            ChannelUpdateEvent._new(msg);
            break;

          case 'CHANNEL_DELETE':
            ChannelDeleteEvent._new(msg);
            break;

          case 'TYPING_START':
            TypingEvent._new(msg);
            break;

          case 'PRESENCE_UPDATE':
            PresenceUpdateEvent._new(msg);
            break;

          case 'GUILD_ROLE_CREATE':
            RoleCreateEvent._new(msg);
            break;

          case 'GUILD_ROLE_UPDATE':
            RoleUpdateEvent._new(msg);
            break;

          case 'GUILD_ROLE_DELETE':
            RoleDeleteEvent._new(msg);
            break;

          case 'USER_UPDATE':
            UserUpdateEvent._new(msg);
            break;

          default:
            print("UNKNOWN OPCODE: ${jsonEncode(msg)}");
        }
        break;
    }
  }

  Exception _throw(String msg) => Exception(
      "${this._socket.closeCode}: ${this._socket.closeReason} - '$msg'");

  void _handleErr() {
    _socket.close(1001);
    this._heartbeatTimer.cancel();

    // Invalidate cache on error
    client.guilds.invalidate();
    client.users.invalidate();
    client.channels.invalidate();
    this.guilds.clear();

    switch (this._socket.closeCode) {
      //throw _throw(
      //    'No status code was provided even though one was expected.');
      case 4004:
        throw _throw(
            'The account token sent with your identify payload is incorrect.');
      case 4010:
        throw _throw('You sent an invalid shard when identifying.');
      case 4007:
      case 4009:
      case 1001:
      case 1005:
        this._connect(true);
        break;
      default:
        this._connect();
        break;
    }

    DisconnectEvent._new(this, this._socket.closeCode);
    this._onDisconnect.add(this);
  }
}
