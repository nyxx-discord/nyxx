part of nyxx;

/// Shard is single connection to discord gateway. Since bots can grow big, handling thousand of guild on same websocket connections would be very hand.
/// Traffic can be split into different connections which can be run on different processes or even different machines.
class Shard implements Disposable {
  /// Id of shard
  final int id;

  /// Reference to [ShardManager]
  final ShardManager manager;

  /// Emitted when the shard encounters a connection error
  late final Stream<Shard> onDisconnect = manager.onDisconnect.where((event) => event.id == this);

  /// Emitted when shard receives member chunk.
  late final Stream<MemberChunkEvent> onMemberChunk = manager.onMemberChunk.where((event) => event.shardId == this.id);

  /// List of handled guild ids
  final List<Snowflake> guilds = [];

  /// Gets the latest gateway latency.
  ///
  /// To calculate the gateway latency, nyxx measures the time it takes for Discord to answer the gateway
  /// heartbeat packet with a heartbeat ack packet. Note this value is updated each time gateway responses to ack.
  Duration get gatewayLatency => _gatewayLatency;

  /// Returns true if shard is connected to websocket
  bool get connected => _connected;

  late final Isolate _shardIsolate; // Reference to isolate
  late final Stream<dynamic> _receiveStream; // Broadcast stream on which data from isolate is received
  late final ReceivePort _receivePort; // Port on which data from isolate is received
  late final SendPort _isolateSendPort; // Port on which data can be sent to isolate
  late SendPort _sendPort; // Sendport for isolate

  String? _sessionId; // Id of gateway session
  int _sequence = 0; // Event sequence
  late Timer _heartbeatTimer; // Heartbeat time
  bool _connected = false; // Connection status
  bool _resume = false; // Resume status

  Duration _gatewayLatency = const Duration(); // latency of discord
  late DateTime _lastHeartbeatSent; // Datetime when last heartbeat was sent
  bool _heartbeatAckReceived = true; // True if last heartbeat was acked

  Shard._new(this.id, this.manager, String gatewayUrl) {
    this.manager._logger.finer("Starting shard with id: $id; url: $gatewayUrl");

    this._receivePort = ReceivePort();
    this._receiveStream = _receivePort.asBroadcastStream();
    this._isolateSendPort = _receivePort.sendPort;

    Isolate.spawn(_shardHandler, _isolateSendPort).then((isolate) async {
      this._shardIsolate = isolate;
      this._sendPort = await _receiveStream.first as SendPort;

      this._sendPort.send({"cmd" : "INIT", "gatewayUrl" : gatewayUrl, "compression":  manager._ws._client._options.compressedGatewayPayloads});
      this._receiveStream.listen(_handle);
    });
  }

  /// Sends WS data.
  void send(int opCode, dynamic d) {
    final rawData = {"cmd": "SEND", "data" : {"op": opCode, "d": d}};
    this.manager._logger.finest("Sending to shard isolate: [$rawData]");
    this._sendPort.send(rawData);
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
    this.send(OPCodes.statusUpdate, presenceBuilder.build());
  }

  /// Syncs all guilds
  void guildSync() => this.send(OPCodes.guildSync, this.guilds.map((e) => e.toString()));

  /// Allows to request members objects from gateway
  /// [guild] can be either Snowflake or Iterable<Snowflake>
  void requestMembers(/* Snowflake|Iterable<Snowflake> */ dynamic guild,
      {String? query, Iterable<Snowflake>? userIds, int limit = 0, bool presences = false, String? nonce}) {
    if (query != null && userIds != null) {
      throw ArgumentError("Both `query` and userIds cannot be specified.");
    }

    dynamic guildPayload;

    if (guild is Snowflake) {
      if(!this.guilds.contains(guild)) {
        throw InvalidShardException._new("Cannot request member for guild on wrong shard");
      }

      guildPayload = [guild.toString()];
    } else if (guild is Iterable<Snowflake>) {
      if(!this.guilds.any((element) => guild.contains(element))) {
        throw InvalidShardException._new("Cannot request member for guild on wrong shard");
      }

      guildPayload = guild.map((e) => e.toString()).toList();
    } else {
      throw ArgumentError("Guild has to be either Snowflake or Iterable<Snowflake>");
    }

    final payload = <String, dynamic>{
      "guild_id": guildPayload,
      "limit": limit,
      "presences": presences,
      if (query != null) "query": query,
      if (userIds != null) "user_ids": userIds.map((e) => e.toString()).toList(),
      if (nonce != null) "nonce": nonce
    };

    this.send(OPCodes.requestGuildMember, payload);
  }

  void _heartbeat() {
    this.send(OPCodes.heartbeat, _sequence == 0 ? null : _sequence);
    this._lastHeartbeatSent = DateTime.now();

    if(!this._heartbeatAckReceived) {
      manager._logger.warning("Not received previous heartbeat ack on shard: [${this.id}] on sequence: [{$_sequence}]");
      return;
    }

    this._heartbeatAckReceived = false;
  }

  void _handleError(dynamic data) {
    final closeCode = data["errorCode"] as int;

    this._connected = false;
    this._heartbeatTimer.cancel();
    manager._logger.severe("Shard $id disconnected. Error: [${data['error']}] Error code: [${data['errorCode']}] | Error message: [${data['errorReason']}]");

    switch (closeCode) {
      case 4004:
      case 4010:
        exit(1);
      case 4013:
        manager._logger.shout("Cannot connect to gateway due intent value is invalid. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
        exit(1);
      case 4014:
        manager._logger.shout("You sent a disallowed intent for a Gateway Intent. "
            "You may have tried to specify an intent that you have not enabled or are not whitelisted for. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
        exit(1);
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
    manager._logger.info("Connecting to gateway on shard $id!");
    this._resume = false;
    Future.delayed(const Duration(seconds: 2), () => this._sendPort.send({ "cmd" : "CONNECT"}));
  }

  // Reconnects to gateway
  void _reconnect() {
    manager._logger.info("Resuming connection to gateway on shard $id!");
    this._resume = true;
    Future.delayed(const Duration(seconds: 1), () => this._sendPort.send({ "cmd" : "CONNECT"}));
  }

  Future<void> _handle(dynamic rawData) async {
    this.manager._logger.finest("Received gateway payload: [$rawData]");

    if(rawData["cmd"] == "CONNECT_ACK") {
      manager._logger.info("Shard $id connected to gateway!");

      return;
    }

    if(rawData["cmd"] == "ERROR" || rawData["cmd"] == "DISCONNECTED") {
      _handleError(rawData);
      return;
    }

    if(rawData["jsonData"] == null) {
      return;
    }

    final discordPayload = rawData["jsonData"] as RawApiMap;

    if (discordPayload["op"] == OPCodes.dispatch && manager._ws._client._options.ignoredEvents.contains(discordPayload["t"] as String)) {
      return;
    }

    if (discordPayload["s"] != null) {
      this._sequence = discordPayload["s"] as int;
    }

    await _dispatch(discordPayload);
  }

  Future<void> _dispatch(RawApiMap rawPayload) async {
    switch (rawPayload["op"] as int) {
      case OPCodes.heartbeatAck:
        this._heartbeatAckReceived = true;
        this._gatewayLatency = DateTime.now().difference(this._lastHeartbeatSent);

        break;
      case OPCodes.hello:
        if (this._sessionId == null || !_resume) {
          final identifyMsg = <String, dynamic>{
            "token": manager._ws._client._token,
            "properties": <String, dynamic> {
              "\$os": Platform.operatingSystem,
              "\$browser": "nyxx",
              "\$device": "nyxx",
            },
            "large_threshold": manager._ws._client._options.largeThreshold,
            "guild_subscriptions" : manager._ws._client._options.guildSubscriptions,
            "intents": manager._ws._client.intents,
            if (manager._ws._client._options.initialPresence != null)
              "presence" : manager._ws._client._options.initialPresence!.build()
          };

          identifyMsg["shard"] = <int>[this.id, manager._numShards];

          this.send(OPCodes.identify, identifyMsg);
        } else if (_resume) {
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
        final dispatchType = rawPayload["t"] as String;

        switch (dispatchType) {
          case "READY":
            this._sessionId = rawPayload["d"]["session_id"] as String;
            manager._ws._client.self = ClientUser._new(manager._ws._client, rawPayload["d"]["user"] as RawApiMap);

            this._connected = true;
            manager._logger.info("Shard ${this.id} ready!");

            if (!_resume) {
              await manager._ws.propagateReady();
            }

            break;

          case "GUILD_MEMBERS_CHUNK":
            manager._onMemberChunk.add(MemberChunkEvent._new(rawPayload, manager._ws._client, this.id));
            break;

          case "MESSAGE_REACTION_REMOVE_ALL":
            manager._ws._client._events.onMessageReactionsRemoved.add(MessageReactionsRemovedEvent._new(rawPayload, manager._ws._client));
            break;

          case "MESSAGE_REACTION_ADD":
            manager._ws._client._events.onMessageReactionAdded.add(MessageReactionAddedEvent._new(rawPayload, manager._ws._client));
            break;

          case "MESSAGE_REACTION_REMOVE":
            manager._ws._client._events.onMessageReactionRemove.add(MessageReactionRemovedEvent._new(rawPayload, manager._ws._client));
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

          case "THREAD_CREATE":
            manager._ws._client._events.onThreadCreated.add(ThreadCreateEvent._new(rawPayload, manager._ws._client));
            break;

          case "THREAD_MEMBERS_UPDATE":
            manager._ws._client._events.onThreadMembersUpdate.add(ThreadMembersUpdateEvent._new(rawPayload, manager._ws._client));
            break;

          case "THREAD_DELETE":
            manager._ws._client._events.onThreadDelete.add(ThreadDeletedEvent._new(rawPayload, manager._ws._client));
            break;

          case "THREAD_MEMBER_UPDATE":
            // Catch unnecessary OP, could be needed in future but unsure.
            break;

          default:
            if (this.manager._ws._client._options.dispatchRawShardEvent) {
              this.manager._onRawEvent.add(RawEvent._new(this, rawPayload));
            } else {
              print("UNKNOWN OPCODE: ${jsonEncode(rawPayload)}");
            }
        }
        break;
    }
  }

  @override
  Future<void> dispose() async {
    this.manager._logger.info("Started disposing shard $id...");

    await this._receiveStream.firstWhere((element) => (element as RawApiMap)["cmd"] == "TERMINATE_OK");
    this._shardIsolate.kill(priority: Isolate.immediate);

    this.manager._logger.info("Shard $id disposed.");
  }
}
