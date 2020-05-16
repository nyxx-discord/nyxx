part of nyxx;

/// Discord gateways implement a method of user-controlled guild sharding which allows for splitting events across a number of gateway connections.
/// Guild sharding is entirely user controlled, and requires no state-sharing between separate connections to operate.
///
/// Shard is basically represents single websocket connection to gateway. Each shard can operate on up to 2500 guilds.
class Shard implements Disposable {
  /// The shard id.
  late final int id;

  /// Whether or not the shard is ready.
  bool connected = false;

  /// Emitted when the shard is ready.
  late Stream<Shard> onConnected;

  /// Emitted when the shard encounters an error.
  late Stream<Shard> onDisconnect;

  /// Emitted when shard receives member chunk.
  late Stream<MemberChunkEvent> onMemberChunk;

  int get eventsSeen => _sequence;

  Logger _logger = Logger("Websocket");
  late final _WS _ws;

  bool _acked = false;
  late Timer _heartbeatTimer;
  transport.WebSocket? _socket;
  StreamSubscription? _socketSubscription;

  late int _sequence;
  String? _sessionId;

  late final StreamController<Shard> _onConnect;
  late final StreamController<Shard> _onDisconnect;
  late final StreamController<MemberChunkEvent> _onMemberChunk;

  Shard._new(this._ws, this.id) {
    this._onConnect = StreamController<Shard>.broadcast();
    this.onConnected = this._onConnect.stream;

    this._onDisconnect = StreamController<Shard>.broadcast();
    this.onDisconnect = this._onDisconnect.stream;

    this._onMemberChunk = StreamController.broadcast();
    this.onMemberChunk = this._onMemberChunk.stream;
  }

  /// Allows to set presence for current shard.
  void setPresence({UserStatus? status, bool? afk, Activity? game, DateTime? since}) {
    var packet = <String, dynamic> {
      'status' : (status != null) ? status.toString() : UserStatus.online.toString(),
      'afk' : (afk != null) ? afk : false,
      if(game != null) 'game' : <String, dynamic> {
        'name' : game.name,
        'type' : game.type.value,
        if(game.type == ActivityType.streaming) 'url' : game.url
      },
      'since': (since != null) ? since.millisecondsSinceEpoch : null
    };

    this.send(OPCodes.statusUpdate, packet);
  }

  /// Syncs all guilds
  void guildSync() => this.send(OPCodes.guildSync, this._ws._client.guilds.keys.toList());

  /// Sends WS data.
  void send(int opCode, dynamic d) {
    this._socket?.add(
        jsonEncode(<String, dynamic>{"op": opCode, "d": d}));
  }

  /// Allows to request members objects from gateway
  /// [guild] can be either Snowflake or Iterable<Snowflake>
  void requestMembers(/* Snowflake|Iterable<Snowflake> */ dynamic guild, {String? query,
    Iterable<Snowflake>? userIds, int limit = 0, bool presences = false, String? nonce}) {
    if(query != null && userIds != null) {
      throw Exception("Both `query` and userIds cannot be specified.");
    }

    late guildPayload;

    if(guild is Snowflake) {
      guildPayload = guild.toString();
    } else if(guild is Iterable<Snowflake>) {
      guildPayload = guild.map((e) => e.toString()).toList();
    } else {
      throw Exception("guild has to be either Snowflake or Iterable<Snowflake>");
    }

    var payload = <String, dynamic> {
      "guild_id" : guildPayload,
      if(query != null) "query" : query,
      if(userIds != null) "user_ids" : userIds.map((e) => e.toString()).toList(),
      "limit" : limit,
      "presences" : presences,
      if(nonce != null) "nonce" : nonce
    };

    this.send(OPCodes.requestGuildMember, payload);
  }

  // Attempts to connect to ws
  void _connect([bool resume = false, bool init = false]) {
    this.connected = false;

    if (!init && resume) {
      Future.delayed(const Duration(seconds: 3), () => _connect(true));
      return;
    }

    transport.WebSocket.connect(Uri.parse("${this._ws.gateway}?v=6&encoding=json")).then((ws) {
      _socket = ws;
      this._socketSubscription = _socket!.listen(
          (data) => this._handleMsg(_decodeBytes(data), resume),
          onDone: this._handleErr,
          onError: (err) => this._handleErr);
    }, onError: (_, __) => Future.delayed(
        const Duration(seconds: 6), () => this._connect()));
  }

  // Decodes zlib compresses string into string json
  Map<String, dynamic> _decodeBytes(dynamic bytes) {
    if (bytes is String) return jsonDecode(bytes) as Map<String, dynamic>;

    var decoded = zlib.decoder.convert(bytes as List<int>);
    var rawStr = utf8.decode(decoded);
    return jsonDecode(rawStr) as Map<String, dynamic>;
  }

  void _heartbeat() {
    if (this._socket?.closeCode != null) return;
    if (!this._acked) _logger.warning("No ACK received");
    this.send(OPCodes.heartbeat, _sequence);
    this._acked = false;
  }

  Future<void> _handleMsg(Map<String, dynamic> msg, bool resume) async {
    if (msg['op'] == OPCodes.dispatch &&
        this._ws._client._options.ignoredEvents.contains(msg['t'] as String)) {
      return;
    }

    if (msg['s'] != null) this._sequence = msg['s'] as int;

    switch (msg['op'] as int) {
      case OPCodes.heartbeatAck:
        this._acked = true;
        break;
      case OPCodes.hello:
        if (this._sessionId == null || !resume) {
          Map<String, dynamic> identifyMsg = <String, dynamic>{
            "token": _ws._client._token,
            "properties": <String, dynamic>{
              "\$os": Platform.operatingSystem,
              "\$browser": "nyxx",
              "\$device": "nyxx",
            },
            "large_threshold": this._ws._client._options.largeThreshold,
            "compress": true
          };

          if(_ws._client._options.gatewayIntents != null) {
            identifyMsg["intents"] = _ws._client._options.gatewayIntents!._calculate();
          }

          identifyMsg['shard'] = <int>[
            this.id,
            _ws._client._options.shardCount
          ];

          this.send(OPCodes.identify, identifyMsg);
        } else if (resume) {
          this.send(OPCodes.resume, <String, dynamic>{
            "token": _ws._client._token,
            "session_id": this._sessionId,
            "seq": this._sequence
          });
        }

        this._heartbeatTimer = Timer.periodic(
            Duration(milliseconds: msg['d']['heartbeat_interval'] as int),
            (Timer t) => this._heartbeat());

        break;

      case OPCodes.invalidSession:
        _logger.severe("Invalid session. Reconnecting...");
        _heartbeatTimer.cancel();
        _ws._client._events.onDisconnect.add(DisconnectEvent._new(this, 9));
        this._onDisconnect.add(this);

        if (msg['d'] as bool) {
          Future.delayed(const Duration(seconds: 3), () => _connect(true));
        } else {
          Future.delayed(const Duration(seconds: 6), () => _connect());
        }

        break;

      case OPCodes.dispatch:
        var j = msg['t'] as String;

        switch (j) {
          case 'READY':
            this._sessionId = msg['d']['session_id'] as String;
            _ws._client.self = ClientUser._new(
                msg['d']['user'] as Map<String, dynamic>, _ws._client);

            this.connected = true;
            _logger.info("Shard connected");
            this._onConnect.add(this);

            if(!resume) {
              await _ws.propagateReady();
            }

            break;

          case 'GUILD_MEMBERS_CHUNK':
            this._onMemberChunk.add(MemberChunkEvent._new(msg, _ws._client));
            break;

          case 'MESSAGE_REACTION_REMOVE_ALL':
            var m = MessageReactionsRemovedEvent._new(msg, _ws._client);

            if (m.message != null) {
              _ws._client._events.onMessageReactionsRemoved.add(m);
            }
            break;

          case 'MESSAGE_REACTION_ADD':
            MessageReactionAddedEvent._new(msg, _ws._client);
            break;

          case 'MESSAGE_REACTION_REMOVE':
            MessageReactionRemovedEvent._new(msg, _ws._client);
            break;

          case 'MESSAGE_DELETE_BULK':
            MessageDeleteBulkEvent._new(msg, _ws._client);
            break;

          case 'CHANNEL_PINS_UPDATE':
            var m = ChannelPinsUpdateEvent._new(msg, _ws._client);

            _ws._client._events.onChannelPinsUpdate.add(m);
            break;

          case 'VOICE_STATE_UPDATE':
            _ws._client._events.onVoiceStateUpdate
                .add(VoiceStateUpdateEvent._new(msg, _ws._client));
            break;

          case 'VOICE_SERVER_UPDATE':
            _ws._client._events.onVoiceServerUpdate
                .add(VoiceServerUpdateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_EMOJIS_UPDATE':
            _ws._client._events.onGuildEmojisUpdate
                .add(GuildEmojisUpdateEvent._new(msg, _ws._client));
            break;

          case 'MESSAGE_CREATE':
            var m = MessageReceivedEvent._new(msg, _ws._client);
            _ws._client._events.onMessageReceived.add(m);
            break;

          case 'MESSAGE_DELETE':
            var m = MessageDeleteEvent._new(msg, _ws._client);
            _ws._client._events.onMessageDelete.add(m);
            break;

          case 'MESSAGE_UPDATE':
            var m = MessageUpdateEvent._new(msg, _ws._client);
            break;

          case 'GUILD_CREATE':
            var guild = GuildCreateEvent._new(msg, this, _ws._client);
            _ws._client._events.onGuildCreate.add(guild);

            break;

          case 'GUILD_UPDATE':
            _ws._client._events.onGuildUpdate
                .add(GuildUpdateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_DELETE':
            _ws._client._events.onGuildDelete
                .add(GuildDeleteEvent._new(msg, this, _ws._client));
            break;

          case 'GUILD_BAN_ADD':
            _ws._client._events.onGuildBanAdd
                .add(GuildBanAddEvent._new(msg, _ws._client));
            break;

          case 'GUILD_BAN_REMOVE':
            _ws._client._events.onGuildBanRemove
                .add(GuildBanRemoveEvent._new(msg, _ws._client));
            break;

          case 'GUILD_MEMBER_ADD':
            _ws._client._events.onGuildMemberAdd
                .add(GuildMemberAddEvent._new(msg, _ws._client));
            break;

          case 'GUILD_MEMBER_REMOVE':
            _ws._client._events.onGuildMemberRemove
                .add(GuildMemberRemoveEvent._new(msg, _ws._client));
            break;

          case 'GUILD_MEMBER_UPDATE':
            _ws._client._events.onGuildMemberUpdate
                .add(GuildMemberUpdateEvent._new(msg, _ws._client));
            break;

          case 'CHANNEL_CREATE':
            _ws._client._events.onChannelCreate
                .add(ChannelCreateEvent._new(msg, _ws._client));
            break;

          case 'CHANNEL_UPDATE':
            _ws._client._events.onChannelUpdate
                .add(ChannelUpdateEvent._new(msg, _ws._client));
            break;

          case 'CHANNEL_DELETE':
            _ws._client._events.onChannelDelete
                .add(ChannelDeleteEvent._new(msg, _ws._client));
            break;

          case 'TYPING_START':
            var m = TypingEvent._new(msg, _ws._client);

            _ws._client._events.onTyping.add(m);
            break;

          case 'PRESENCE_UPDATE':
            _ws._client._events.onPresenceUpdate
                .add(PresenceUpdateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_ROLE_CREATE':
            _ws._client._events.onRoleCreate
                .add(RoleCreateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_ROLE_UPDATE':
            _ws._client._events.onRoleUpdate
                .add(RoleUpdateEvent._new(msg, _ws._client));
            break;

          case 'GUILD_ROLE_DELETE':
            _ws._client._events.onRoleDelete
                .add(RoleDeleteEvent._new(msg, _ws._client));
            break;

          case 'USER_UPDATE':
            _ws._client._events.onUserUpdate
                .add(UserUpdateEvent._new(msg, _ws._client));
            break;

          case 'INVITE_CREATE':
            _ws._client._events.onInviteCreated
                .add(InviteCreatedEvent._new(msg, _ws._client));
            break;

          case 'INVITE_DELETE':
            _ws._client._events.onInviteDelete
                .add(InviteDeletedEvent._new(msg, _ws._client));
            break;

          case 'MESSAGE_REACTION_REMOVE_EMOJI':
            _ws._client._events.onMessageReactionRemoveEmoji
                .add(MessageReactionRemoveEmojiEvent._new(msg, _ws._client));
            break;

          default:
            print("UNKNOWN OPCODE: ${jsonEncode(msg)}");
        }
        break;
    }
  }

  void _handleErr() {
    this._heartbeatTimer.cancel();
    _logger.severe(
        "Shard disconnected. Error code: [${this._socket?.closeCode}] | Error message: [${this._socket?.closeReason}]");
    this.dispose();

    switch (this._socket?.closeCode) {
      case 4004:
      case 4010:
        exit(1);
        break;
      case 4013:
        _logger.shout("Cannot connect to gateway due intent value is invalid. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
        exit(1);
        break;
      case 4014:
        _logger.shout("You sent a disallowed intent for a Gateway Intent. "
            "You may have tried to specify an intent that you have not enabled or are not whitelisted for. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
        exit(1);
        break;
      case 4007:
      case 4009:
        Future.delayed(const Duration(seconds: 3), () => this._connect(true));
        break;
      default:
        Future.delayed(const Duration(seconds: 6), () => _connect(false, true));
        break;
    }

    _ws._client._events.onDisconnect
        .add(DisconnectEvent._new(this, this._socket?.closeCode!));
    this._onDisconnect.add(this);
  }

  @override
  Future<void> dispose() async {
    await this._socketSubscription?.cancel();
    await this._socket?.close(1000);
    this._socket = null;
  }
}
