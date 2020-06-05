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

  late final Isolate _shardIsolate; // Reference to isolate
  late final Stream<dynamic> _receiveStream; // Broadcast stream on which data from isolate is received
  late final ReceivePort _receivePort; // Port on which data from isolate is received
  late final SendPort _isolateSendPort; // Port on which data can be sent to isolate
  String? _sessionId;
  int _sequence = 0;
  late Timer _heartbeatTimer;
  bool connected = false;

  late SendPort sendPort;

  /// Isolate
  Shard(this.id, this.manager, String gatewayUrl) {
    this._receivePort = ReceivePort();
    this._receiveStream = _receivePort.asBroadcastStream();
    this._isolateSendPort = _receivePort.sendPort;

    Isolate.spawn(_shardHandler, _isolateSendPort, errorsAreFatal: true).then((value) async {
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
    this.send(OPCodes.heartbeat, _sequence);
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
        Future.delayed(const Duration(seconds: 2), () => this.sendPort.send({ "cmd" : "RECONNECT" }));
        break;
      default:
        Future.delayed(const Duration(seconds: 3), () =>  this.sendPort.send({ "cmd" : "CONNECT" }));
        break;
    }
  }

  Future<void> _handle(dynamic data) async {
    if(data["cmd"] == "ERROR" || data["cmd"] == "DISCONNECTED") {
      _handleError(data);
    }

    if(data["jsonData"] == null) {
      return;
    }

    final msg = data["jsonData"] as Map<String, dynamic>;
    final resume = data["resume"] as bool;

    if (msg["op"] == OPCodes.dispatch && manager._ws._client._options.ignoredEvents.contains(msg["t"] as String)) {
      return;
    }

    if (msg["s"] != null) {
      this._sequence = msg["s"] as int;
    }

    switch (msg["op"] as int) {
      case OPCodes.heartbeatAck:
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
            Duration(milliseconds: msg["d"]["heartbeat_interval"] as int), (Timer t) => this._heartbeat());
        break;
      case OPCodes.invalidSession:
        manager._logger.severe("Invalid session on shard $id. ${(msg["d"] as bool) ? "Resuming..." : "Reconnecting..."}");
        _heartbeatTimer.cancel();
        manager._ws._client._events.onDisconnect.add(DisconnectEvent._new(this, DisconnectEventReason.invalidSession));

        if (msg["d"] as bool) {
          Future.delayed(const Duration(seconds: 1), () => this.sendPort.send({ "cmd" : "RECONNECT"}));
        } else {
          Future.delayed(const Duration(seconds: 2), () => this.sendPort.send({ "cmd" : "CONNECT"}));
        }

        break;

      case OPCodes.dispatch:
        final j = msg["t"] as String;

        switch (j) {
          case "READY":
            this._sessionId = msg["d"]["session_id"] as String;
            manager._ws._client.self = ClientUser._new(msg["d"]["user"] as Map<String, dynamic>, manager._ws._client);

            this.connected = true;
            manager._logger.info("Shard ${this.id} connected");

            if (!resume) {
              await manager._ws.propagateReady();
            }

            break;

          case "GUILD_MEMBERS_CHUNK":
            manager._onMemberChunk.add(MemberChunkEvent._new(msg, manager._ws._client));
            break;

          case "MESSAGE_REACTION_REMOVE_ALL":
            manager._ws._client._events.onMessageReactionsRemoved.add(MessageReactionsRemovedEvent._new(msg, manager._ws._client));
            break;

          case "MESSAGE_REACTION_ADD":
            MessageReactionAddedEvent._new(msg, manager._ws._client);
            break;

          case "MESSAGE_REACTION_REMOVE":
            MessageReactionRemovedEvent._new(msg, manager._ws._client);
            break;

          case "MESSAGE_DELETE_BULK":
            manager._ws._client._events.onMessageDeleteBulk.add(MessageDeleteBulkEvent._new(msg, manager._ws._client));
            break;

          case "CHANNEL_PINS_UPDATE":
            manager._ws._client._events.onChannelPinsUpdate.add(ChannelPinsUpdateEvent._new(msg, manager._ws._client));
            break;

          case "VOICE_STATE_UPDATE":
            manager._ws._client._events.onVoiceStateUpdate.add(VoiceStateUpdateEvent._new(msg, manager._ws._client));
            break;

          case "VOICE_SERVER_UPDATE":
            manager._ws._client._events.onVoiceServerUpdate.add(VoiceServerUpdateEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_EMOJIS_UPDATE":
            manager._ws._client._events.onGuildEmojisUpdate.add(GuildEmojisUpdateEvent._new(msg, manager._ws._client));
            break;

          case "MESSAGE_CREATE":
            manager._ws._client._events.onMessageReceived.add(MessageReceivedEvent._new(msg, manager._ws._client));
            break;

          case "MESSAGE_DELETE":
            manager._ws._client._events.onMessageDelete.add(MessageDeleteEvent._new(msg, manager._ws._client));
            break;

          case "MESSAGE_UPDATE":
            manager._ws._client._events.onMessageUpdate.add(MessageUpdateEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_CREATE":
            final event = GuildCreateEvent._new(msg, manager._ws._client);
            this.guilds.add(event.guild.id);
            manager._ws._client._events.onGuildCreate.add(event);
            break;

          case "GUILD_UPDATE":
            manager._ws._client._events.onGuildUpdate.add(GuildUpdateEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_DELETE":
            manager._ws._client._events.onGuildDelete.add(GuildDeleteEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_BAN_ADD":
            manager._ws._client._events.onGuildBanAdd.add(GuildBanAddEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_BAN_REMOVE":
            manager._ws._client._events.onGuildBanRemove.add(GuildBanRemoveEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_MEMBER_ADD":
            manager._ws._client._events.onGuildMemberAdd.add(GuildMemberAddEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_MEMBER_REMOVE":
            manager._ws._client._events.onGuildMemberRemove.add(GuildMemberRemoveEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_MEMBER_UPDATE":
            manager._ws._client._events.onGuildMemberUpdate.add(GuildMemberUpdateEvent._new(msg, manager._ws._client));
            break;

          case "CHANNEL_CREATE":
            manager._ws._client._events.onChannelCreate.add(ChannelCreateEvent._new(msg, manager._ws._client));
            break;

          case "CHANNEL_UPDATE":
            manager._ws._client._events.onChannelUpdate.add(ChannelUpdateEvent._new(msg, manager._ws._client));
            break;

          case "CHANNEL_DELETE":
            manager._ws._client._events.onChannelDelete.add(ChannelDeleteEvent._new(msg, manager._ws._client));
            break;

          case "TYPING_START":
            manager._ws._client._events.onTyping.add(TypingEvent._new(msg, manager._ws._client));
            break;

          case "PRESENCE_UPDATE":
            manager._ws._client._events.onPresenceUpdate.add(PresenceUpdateEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_ROLE_CREATE":
            manager._ws._client._events.onRoleCreate.add(RoleCreateEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_ROLE_UPDATE":
            manager._ws._client._events.onRoleUpdate.add(RoleUpdateEvent._new(msg, manager._ws._client));
            break;

          case "GUILD_ROLE_DELETE":
            manager._ws._client._events.onRoleDelete.add(RoleDeleteEvent._new(msg, manager._ws._client));
            break;

          case "USER_UPDATE":
            manager._ws._client._events.onUserUpdate.add(UserUpdateEvent._new(msg, manager._ws._client));
            break;

          case "INVITE_CREATE":
            manager._ws._client._events.onInviteCreated.add(InviteCreatedEvent._new(msg, manager._ws._client));
            break;

          case "INVITE_DELETE":
            manager._ws._client._events.onInviteDelete.add(InviteDeletedEvent._new(msg, manager._ws._client));
            break;

          case "MESSAGE_REACTION_REMOVE_EMOJI":
            manager._ws._client._events.onMessageReactionRemoveEmoji
                .add(MessageReactionRemoveEmojiEvent._new(msg, manager._ws._client));
            break;

          default:
            print("UNKNOWN OPCODE: ${jsonEncode(msg)}");
        }
        break;
    }
  }

  @override
  Future<void> dispose() async {
    this._isolateSendPort.send({"cmd" : "TERMINATE" });
    await this._receiveStream.firstWhere((element) => (element as Map<String, dynamic>)["cmd"] == "TERMINATE_OK");

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
Protocol used to comunicate with shard isolate.

 * INIT - sent along with map of initial data needed for connection
 * SEND - sent along with data to send via websocket
 * OK - last operation was completed with success
 * DATA - sent along with data received from websocket
 * CONNECTED - sent when ws connection is established. additional data can contain if reconnected.
 * DISCONNECTED - sent when shard disconnects
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
  Future<void> _connect([bool resume = false]) async {
    await transport.WebSocket.connect(gatewayUri).then((ws) {
      _socket = ws;
      _socketSubscription = _socket!.listen((data) {
        shardPort.send({ "cmd" : "DATA", "jsonData" : _decodeBytes(data), "resume" : resume});
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

    if(cmd == "RECONNECT") {
      await _socketSubscription?.cancel();
      await _socket?.close(1000);
      await _connect(true);

      continue;
    }

    if(cmd == "CONNECT") {
      await _socketSubscription?.cancel();
      await _socket?.close(1000);
      await _connect();

      continue;
    }

    if(cmd == "TERMINATE") {
      await _socketSubscription?.cancel();
      await _socket?.close(1000);
      shardPort.send({ "cmd" : "TERMINATE_OK" });
    }
  }
}
