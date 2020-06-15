part of nyxx;

class ShardManager implements Disposable {
  /// Emitted when the shard is ready.
  late Stream<Shard> onConnected = this._onConnect.stream;

  /// Emitted when the shard encounters an error.
  late Stream<Shard> onDisconnect = this._onDisconnect.stream;

  /// Emitted when shard receives member chunk.
  late Stream<MemberChunkEvent> onMemberChunk = this._onMemberChunk.stream;

  final StreamController<Shard> _onConnect = StreamController<Shard>.broadcast();
  final StreamController<Shard> _onDisconnect = StreamController<Shard>.broadcast();
  final StreamController<MemberChunkEvent> _onMemberChunk = StreamController.broadcast();

  final Logger _logger = Logger("Shard Manager");

  final _WS _ws;
  final int _numShards;
  final Map<int, Shard> _shards = {};

  /// List of shards
  Iterable<Shard> get shards => List.unmodifiable(_shards.values);

  /// Starts shard manager
  ShardManager(this._ws, this._numShards) {
    _connect(_numShards - 1);
  }

  /// Sets presences on every shard
  void setPresence(PresenceBuilder presenceBuilder) {
    for (final shard in shards) {
      shard.setPresence(presenceBuilder);
    }
  }

  void _connect(int shardId) {
    if(shardId < 0) {
      return;
    }

    final shard = Shard(shardId, this, _ws.gateway);
    _shards[shardId] = shard;

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () => _connect(shardId - 1));
  }

  @override
  Future<void> dispose() async {
    for(final shard in this._shards.values) {
      await shard.dispose();
    }

    await this._onConnect.close();
    await this._onDisconnect.close();
    await this._onMemberChunk.close();
  }
}

class Shard implements Disposable {
  /// Id of shard
  final int id;

  /// Reference to [ShardManager]
  ShardManager manager;

  /// List of handled guild ids
  final List<Snowflake> guilds = [];

  /// Gets the latest gateway latency.
  ///
  /// To calculate the gateway latency, nyxx measures the time it takes for Discord to answer the gateway
  /// heartbeat packet with a heartbeat ack packet. Note this value is updated each time gateway responses to ack.
  Duration get gatewayLatency => _gatewaylatency;

  late final Isolate _shardIsolate; // Reference to isolate
  late final Stream<dynamic> _receiveStream; // Broadcast stream on which data from isolate is received
  late final ReceivePort _receivePort; // Port on which data from isolate is received
  late final SendPort _isolateSendPort; // Port on which data can be sent to isolate
  String? _sessionId;
  int _sequence = 0;
  late Timer _heartbeatTimer;
  bool connected = false;
  bool resume = false;

  late SendPort sendPort;

  Duration _gatewaylatency = Duration();
  late DateTime _lastHeartbeatSent;
  bool _heartbeatAckReceived = false;

  /// Isolate
  Shard(this.id, this.manager, String gatewayUrl) {
    this._receivePort = ReceivePort();
    this._receiveStream = _receivePort.asBroadcastStream();
    this._isolateSendPort = _receivePort.sendPort;

    Isolate.spawn(_shardHandler, _isolateSendPort).then((value) async {
      this._shardIsolate = value;
      this.sendPort = await _receiveStream.first as SendPort;

      this.sendPort.send({"cmd" : "INIT", "gatewayUrl" : gatewayUrl });
      this._receiveStream.listen(_handle);
    });
  }

  /// Sends WS data.
  void send(int opCode, dynamic d) {
    this.sendPort.send({"cmd": "SEND", "data" : {"op": opCode, "d": d}});
  }

  /// Updates clients voice state for [Guild] with given [guildId]
  void changeVoiceState(Snowflake? guildId, Snowflake? channelId, {bool selfMute = false, bool selfDeafen = false}) {
    this.send(OPCodes.voiceStateUpdate, <String, dynamic> {
      "guild_id" : guildId.toString(),
      "channel_id" : channelId?.toString(),
      "self_mute" : selfMute,
      "self_deaf" : selfDeafen
    });
  }

  /// Allows to set presence for current shard.
  void setPresence(PresenceBuilder presenceBuilder) {
    this.send(OPCodes.statusUpdate, presenceBuilder._build());
  }

  /// Syncs all guilds
  void guildSync() => this.send(OPCodes.guildSync, this.guilds.map((e) => e.toString()));

  /// Allows to request members objects from gateway
  /// [guild] can be either Snowflake or Iterable<Snowflake>
  void requestMembers(/* Snowflake|Iterable<Snowflake> */ dynamic guild,
      {String? query, Iterable<Snowflake>? userIds, int limit = 0, bool presences = false, String? nonce}) {
    if (query != null && userIds != null) {
      throw Exception("Both `query` and userIds cannot be specified.");
    }

    dynamic guildPayload;

    if (guild is Snowflake) {
      if(!this.guilds.contains(guild)) {
        throw Exception("Cannot request member for guild on wrong shard");
      }

      guildPayload = guild.toString();
    } else if (guild is Iterable<Snowflake>) {
      if(!this.guilds.any((element) => guild.contains(element))) {
        throw Exception("Cannot request member for guild on wrong shard");
      }

      guildPayload = guild.map((e) => e.toString()).toList();
    } else {
      throw Exception("guild has to be either Snowflake or Iterable<Snowflake>");
    }

    final payload = <String, dynamic>{
      "guild_id": guildPayload,
      if (query != null) "query": query,
      if (userIds != null) "user_ids": userIds.map((e) => e.toString()).toList(),
      "limit": limit,
      "presences": presences,
      if (nonce != null) "nonce": nonce
    };

    this.send(OPCodes.requestGuildMember, payload);
  }

  void _heartbeat() {
    this.send(OPCodes.heartbeat, _sequence == 0 ? null : _sequence);
    this._lastHeartbeatSent = DateTime.now();

    if(!this._heartbeatAckReceived) {
      manager._logger.warning("Not received previous heartbeat ack");
      return;
    }

    this._heartbeatAckReceived = false;
  }

  void _handleError(dynamic data) {
    final closeCode = data["errorCode"] as int;

    this._heartbeatTimer.cancel();
    manager._logger.severe(
        "Shard $id disconnected. Error code: [${data['errorCode']}] | Error message: [${data['errorReason']}]");

    switch (closeCode) {
      case 4004:
      case 4010:
        exit(1);
        break;
      case 4013:
        manager._logger.shout("Cannot connect to gateway due intent value is invalid. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
        exit(1);
        break;
      case 4014:
        manager._logger.shout("You sent a disallowed intent for a Gateway Intent. "
            "You may have tried to specify an intent that you have not enabled or are not whitelisted for. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
        exit(1);
        break;
      case 4007:
      case 4009:
        _reconnect();
        break;
      default:
        _connect();
        break;
    }
  }

  // Connects to gateway
  void _connect() {

    this.resume = false;
    Future.delayed(const Duration(seconds: 2), () => this.sendPort.send({ "cmd" : "CONNECT"}))
        .then((_) => manager._logger.info("Connecting to gateway!"));
  }

  // Reconnects to gateway
  void _reconnect() {
    this.resume = true;
    Future.delayed(const Duration(seconds: 1), () => this.sendPort.send({ "cmd" : "CONNECT"}))
        .then((value) => manager._logger.info("Resuming connection to gateway!"));
  }

  Future<void> _handle(dynamic data) async {
    if(data["cmd"] == "CONNECT_ACK") {
      manager._logger.info("Shard $id connected to gateway!");

      return;
    }

    if(data["cmd"] == "ERROR" || data["cmd"] == "DISCONNECTED") {
      _handleError(data);
    }

    if(data["jsonData"] == null) {
      return;
    }

    final msg = data["jsonData"] as Map<String, dynamic>;

    if (msg["op"] == OPCodes.dispatch && manager._ws._client._options.ignoredEvents.contains(msg["t"] as String)) {
      return;
    }

    if (msg["s"] != null) {
      this._sequence = msg["s"] as int;
    }
    
    await _dispatch(msg);
  }
  
  Future<void> _dispatch(Map<String, dynamic> rawPayload) async {
    switch (rawPayload["op"] as int) {
      case OPCodes.heartbeatAck:
        this._heartbeatAckReceived = true;
        this._gatewaylatency = DateTime.now().difference(this._lastHeartbeatSent);

        break;
      case OPCodes.hello:
        if (this._sessionId == null || !resume) {
          final identifyMsg = <String, dynamic>{
            "token": manager._ws._client._token,
            "properties": <String, dynamic> {
              "\$os": Platform.operatingSystem,
              "\$browser": "nyxx",
              "\$device": "nyxx",
            },
            "large_threshold": manager._ws._client._options.largeThreshold,
            "compress": manager._ws._client._options.compressedGatewayPayloads,
            "guild_subscriptions" : manager._ws._client._options.guildSubscriptions,
            if (manager._ws._client._options.initialPresence != null)
              "presence" : manager._ws._client._options.initialPresence!._build()
          };

          if (manager._ws._client._options.gatewayIntents != null) {
            identifyMsg["intents"] = manager._ws._client._options.gatewayIntents!._calculate();
          }

          identifyMsg["shard"] = <int>[this.id, manager._numShards];

          this.send(OPCodes.identify, identifyMsg);
        } else if (resume) {
          this.send(OPCodes.resume,
              <String, dynamic>{"token": manager._ws._client._token, "session_id": this._sessionId, "seq": this._sequence});
        }

        this._heartbeatTimer = Timer.periodic(
            Duration(milliseconds: rawPayload["d"]["heartbeat_interval"] as int), (Timer t) => this._heartbeat());
        break;
      case OPCodes.invalidSession:
        manager._logger.severe("Invalid session on shard $id. ${(rawPayload["d"] as bool) ? "Resuming..." : "Reconnecting..."}");
        _heartbeatTimer.cancel();
        manager._ws._client._events.onDisconnect.add(DisconnectEvent._new(this, DisconnectEventReason.invalidSession));

        if (rawPayload["d"] as bool) {
          _reconnect();
        } else {
          _connect();
        }

        break;

      case OPCodes.dispatch:
        final j = rawPayload["t"] as String;

        switch (j) {
          case "READY":
            this._sessionId = rawPayload["d"]["session_id"] as String;
            manager._ws._client.self = ClientUser._new(rawPayload["d"]["user"] as Map<String, dynamic>, manager._ws._client);

            this.connected = true;
            manager._logger.info("Shard ${this.id} ready!");

            if (!resume) {
              await manager._ws.propagateReady();
            }

            break;

          case "GUILD_MEMBERS_CHUNK":
            manager._onMemberChunk.add(MemberChunkEvent._new(rawPayload, manager._ws._client));
            break;

          case "MESSAGE_REACTION_REMOVE_ALL":
            manager._ws._client._events.onMessageReactionsRemoved.add(MessageReactionsRemovedEvent._new(rawPayload, manager._ws._client));
            break;

          case "MESSAGE_REACTION_ADD":
            MessageReactionAddedEvent._new(rawPayload, manager._ws._client);
            break;

          case "MESSAGE_REACTION_REMOVE":
            MessageReactionRemovedEvent._new(rawPayload, manager._ws._client);
            break;

          case "MESSAGE_DELETE_BULK":
            manager._ws._client._events.onMessageDeleteBulk.add(MessageDeleteBulkEvent._new(rawPayload, manager._ws._client));
            break;

          case "CHANNEL_PINS_UPDATE":
            manager._ws._client._events.onChannelPinsUpdate.add(ChannelPinsUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "VOICE_STATE_UPDATE":
            manager._ws._client._events.onVoiceStateUpdate.add(VoiceStateUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "VOICE_SERVER_UPDATE":
            manager._ws._client._events.onVoiceServerUpdate.add(VoiceServerUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_EMOJIS_UPDATE":
            manager._ws._client._events.onGuildEmojisUpdate.add(GuildEmojisUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "MESSAGE_CREATE":
            manager._ws._client._events.onMessageReceived.add(MessageReceivedEvent._new(rawPayload, manager._ws._client));
            break;

          case "MESSAGE_DELETE":
            manager._ws._client._events.onMessageDelete.add(MessageDeleteEvent._new(rawPayload, manager._ws._client));
            break;

          case "MESSAGE_UPDATE":
            manager._ws._client._events.onMessageUpdate.add(MessageUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_CREATE":
            final event = GuildCreateEvent._new(rawPayload, manager._ws._client);
            this.guilds.add(event.guild.id);
            manager._ws._client._events.onGuildCreate.add(event);
            break;

          case "GUILD_UPDATE":
            manager._ws._client._events.onGuildUpdate.add(GuildUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_DELETE":
            manager._ws._client._events.onGuildDelete.add(GuildDeleteEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_BAN_ADD":
            manager._ws._client._events.onGuildBanAdd.add(GuildBanAddEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_BAN_REMOVE":
            manager._ws._client._events.onGuildBanRemove.add(GuildBanRemoveEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_MEMBER_ADD":
            manager._ws._client._events.onGuildMemberAdd.add(GuildMemberAddEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_MEMBER_REMOVE":
            manager._ws._client._events.onGuildMemberRemove.add(GuildMemberRemoveEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_MEMBER_UPDATE":
            manager._ws._client._events.onGuildMemberUpdate.add(GuildMemberUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "CHANNEL_CREATE":
            manager._ws._client._events.onChannelCreate.add(ChannelCreateEvent._new(rawPayload, manager._ws._client));
            break;

          case "CHANNEL_UPDATE":
            manager._ws._client._events.onChannelUpdate.add(ChannelUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "CHANNEL_DELETE":
            manager._ws._client._events.onChannelDelete.add(ChannelDeleteEvent._new(rawPayload, manager._ws._client));
            break;

          case "TYPING_START":
            manager._ws._client._events.onTyping.add(TypingEvent._new(rawPayload, manager._ws._client));
            break;

          case "PRESENCE_UPDATE":
            manager._ws._client._events.onPresenceUpdate.add(PresenceUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_ROLE_CREATE":
            manager._ws._client._events.onRoleCreate.add(RoleCreateEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_ROLE_UPDATE":
            manager._ws._client._events.onRoleUpdate.add(RoleUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "GUILD_ROLE_DELETE":
            manager._ws._client._events.onRoleDelete.add(RoleDeleteEvent._new(rawPayload, manager._ws._client));
            break;

          case "USER_UPDATE":
            manager._ws._client._events.onUserUpdate.add(UserUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "INVITE_CREATE":
            manager._ws._client._events.onInviteCreated.add(InviteCreatedEvent._new(rawPayload, manager._ws._client));
            break;

          case "INVITE_DELETE":
            manager._ws._client._events.onInviteDelete.add(InviteDeletedEvent._new(rawPayload, manager._ws._client));
            break;

          case "MESSAGE_REACTION_REMOVE_EMOJI":
            manager._ws._client._events.onMessageReactionRemoveEmoji
                .add(MessageReactionRemoveEmojiEvent._new(rawPayload, manager._ws._client));
            break;

          default:
            print("UNKNOWN OPCODE: ${jsonEncode(rawPayload)}");
        }
        break;
    }
  } 

  @override
  Future<void> dispose() async {
    //this._isolateSendPort.send({"cmd" : "TERMINATE" });
    //await this._receiveStream.firstWhere((element) => (element as Map<String, dynamic>)["cmd"] == "TERMINATE_OK");

    this._shardIsolate.kill();
  }
}

// Decodes zlib compresses string into string json
Map<String, dynamic> _decodeBytes(dynamic bytes) {
  if (bytes is String) {
    return jsonDecode(bytes) as Map<String, dynamic>;
  }

  final decoded = zlib.decoder.convert(bytes as List<int>);
  final rawStr = utf8.decode(decoded);
  return jsonDecode(rawStr) as Map<String, dynamic>;
}

/*
Protocol used to communicate with shard isolate.
  First message delivered to shardHandler will be init message with gateway uri

 * DATA - sent along with data received from websocket
 * DISCONNECTED - sent when shard disconnects
 * ERROR - sent when error occurs

 * CONNECT - sent when ws connection is established. additional data can contain if reconnected.
 * SEND - sent along with data to send via websocket
*/
Future<void> _shardHandler(SendPort shardPort) async {
  /// Port init
  final receivePort = ReceivePort();
  final receiveStream = receivePort.asBroadcastStream();

  final sendPort = receivePort.sendPort;
  shardPort.send(sendPort);

  /// Initial data init
  final initData = await receiveStream.first;
  final gatewayUri = Constants.gatewayUri(initData["gatewayUrl"] as String);

  transport.WebSocket? _socket;
  StreamSubscription? _socketSubscription;

  transport_vm.configureWTransportForVM();

  // Attempts to connect to ws
  Future<void> _connect() async {
    await transport.WebSocket.connect(gatewayUri).then((ws) {
      shardPort.send({ "cmd" : "CONNECT_ACK" });
      _socket = ws;
      _socketSubscription = _socket!.listen((data) {
        shardPort.send({ "cmd" : "DATA", "jsonData" : _decodeBytes(data) });
      }, onDone: () async {
        shardPort.send({ "cmd" : "DISCONNECTED", "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason });
      }, cancelOnError: true, onError: (err) => shardPort.send({ "cmd" : "ERROR", "error": err.toString(), "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason }));
    }, onError: (err, __) => shardPort.send({ "cmd" : "ERROR", "error": err.toString(), "errorCode" : _socket!.closeCode, "errorReason" : _socket!.closeReason }));
  }

  // Connects
  await _connect();

  await for(final message in receiveStream) {
    final cmd = message["cmd"];

    if(cmd == "SEND") {
      if(_socket?.closeCode == null) {
        _socket?.add(jsonEncode(message["data"]));
      }

      continue;
    }

    if(cmd == "CONNECT") {
      await _socketSubscription?.cancel();
      await _socket?.close(1000);
      await _connect();

      continue;
    }
/*
    if(cmd == "TERMINATE") {
      await _socketSubscription?.cancel();
      await _socket?.close(1000);
      shardPort.send({ "cmd" : "TERMINATE_OK" });
    }
*/
  }
}
