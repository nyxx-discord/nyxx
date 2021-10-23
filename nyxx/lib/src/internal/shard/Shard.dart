import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/guild/ClientUser.dart';
import 'package:nyxx/src/events/ChannelEvents.dart';
import 'package:nyxx/src/events/DisconnectEvent.dart';
import 'package:nyxx/src/events/GuildEvents.dart';
import 'package:nyxx/src/events/InviteEvents.dart';
import 'package:nyxx/src/events/MemberChunkEvent.dart';
import 'package:nyxx/src/events/MessageEvents.dart';
import 'package:nyxx/src/events/PresenceUpdateEvent.dart';
import 'package:nyxx/src/events/RawEvent.dart';
import 'package:nyxx/src/events/ThreadCreateEvent.dart';
import 'package:nyxx/src/events/ThreadDeletedEvent.dart';
import 'package:nyxx/src/events/ThreadMembersUpdateEvent.dart';
import 'package:nyxx/src/events/TypingEvent.dart';
import 'package:nyxx/src/events/UserUpdateEvent.dart';
import 'package:nyxx/src/events/VoiceServerUpdateEvent.dart';
import 'package:nyxx/src/events/VoiceStateUpdateEvent.dart';
import 'package:nyxx/src/internal/Constants.dart';
import 'package:nyxx/src/internal/EventController.dart';
import 'package:nyxx/src/internal/exceptions/InvalidShardException.dart';
import 'package:nyxx/src/internal/interfaces/Disposable.dart';
import 'package:nyxx/src/internal/shard/ShardManager.dart';
import 'package:nyxx/src/internal/shard/shardHandler.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/PresenceBuilder.dart';

abstract class IShard implements Disposable {
  /// Id of shard
  int get id;

  /// Reference to [ShardManager]
  IShardManager get manager;

  /// Emitted when the shard encounters a connection error
  Stream<IShard> get onDisconnect;

  /// Emitted when shard receives member chunk.
  Stream<IMemberChunkEvent> get onMemberChunk;

  /// Emitted when the shard resumed its connection
  Stream<IShard> get onResume;

  /// List of handled guild ids
  List<Snowflake> get guilds;

  /// Gets the latest gateway latency.
  ///
  /// To calculate the gateway latency, nyxx measures the time it takes for Discord to answer the gateway
  /// heartbeat packet with a heartbeat ack packet. Note this value is updated each time gateway responses to ack.
  Duration get gatewayLatency;

  /// Returns true if shard is connected to websocket
  bool get connected;

  /// Sends WS data.
  void send(int opCode, dynamic d);

  /// Updates clients voice state for [IGuild] with given [guildId]
  void changeVoiceState(Snowflake? guildId, Snowflake? channelId, {bool selfMute = false, bool selfDeafen = false});

  /// Allows to set presence for current shard.
  void setPresence(PresenceBuilder presenceBuilder);

  /// Syncs all guilds
  void guildSync();

  /// Allows to request members objects from gateway
  /// [guild] can be either Snowflake or Iterable<Snowflake>
  void requestMembers(/* Snowflake|Iterable<Snowflake> */ dynamic guild, {String? query, Iterable<Snowflake>? userIds, int limit = 0, bool presences = false, String? nonce});
}

/// Shard is single connection to discord gateway. Since bots can grow big, handling thousand of guild on same websocket connections would be very hand.
/// Traffic can be split into different connections which can be run on different processes or even different machines.
class Shard implements IShard {
  /// Id of shard
  @override
  final int id;

  /// Reference to [ShardManager]
  @override
  final ShardManager manager;

  /// Emitted when the shard encounters a connection error
  @override
  late final Stream<IShard> onDisconnect = manager.onDisconnect.where((event) => event.id == this.id);

  /// Emitted when shard receives member chunk.
  @override
  late final Stream<IMemberChunkEvent> onMemberChunk = manager.onMemberChunk.where((event) => event.shardId == this.id);

  /// Emitted when the shard resumed its connection
  @override
  late final Stream<IShard> onResume = manager.onResume.where((event) => event.id == this.id);

  /// List of handled guild ids
  @override
  final List<Snowflake> guilds = [];

  /// Gets the latest gateway latency.
  ///
  /// To calculate the gateway latency, nyxx measures the time it takes for Discord to answer the gateway
  /// heartbeat packet with a heartbeat ack packet. Note this value is updated each time gateway responses to ack.
  @override
  Duration get gatewayLatency => _gatewayLatency;

  /// Returns true if shard is connected to websocket
  @override
  bool get connected => _connected;

  late final Isolate _shardIsolate; // Reference to isolate
  late final Stream<dynamic> _receiveStream; // Broadcast stream on which data from isolate is received
  late final ReceivePort _receivePort; // Port on which data from isolate is received
  late final SendPort _isolateSendPort; // Port on which data can be sent to isolate
  late SendPort _sendPort; // Send Port for isolate
  String? _sessionId; // Id of gateway session
  int _sequence = 0; // Event sequence
  late Timer _heartbeatTimer; // Heartbeat time
  bool _connected = false; // Connection status
  bool _resume = false; // Resume status
  Duration _gatewayLatency = const Duration(); // latency of discord
  late DateTime _lastHeartbeatSent; // Datetime when last heartbeat was sent
  bool _heartbeatAckReceived = true; // True if last heartbeat was acked

  WebsocketEventController get eventController =>
      manager.connectionManager.client.eventsWs as WebsocketEventController;

  /// Creates an instance of [Shard]
  Shard(this.id, this.manager, String gatewayUrl) {
    this.manager.logger.finer("Starting shard with id: $id; url: $gatewayUrl");

    this._receivePort = ReceivePort();
    this._receiveStream = _receivePort.asBroadcastStream();
    this._isolateSendPort = _receivePort.sendPort;

    Isolate.spawn(shardHandler, _isolateSendPort).then((isolate) async {
      this._shardIsolate = isolate;
      this._sendPort = await _receiveStream.first as SendPort;

      this._sendPort.send({"cmd" : "INIT", "gatewayUrl" : gatewayUrl, "compression":  manager.connectionManager.client.options.compressedGatewayPayloads});
      this._receiveStream.listen(_handle);
    });
  }

  /// Sends WS data.
  @override
  void send(int opCode, dynamic d) {
    final rawData = {"cmd": "SEND", "data" : {"op": opCode, "d": d}};
    this.manager.logger.finest("Sending to shard isolate on shard [${this.id}]: [$rawData]");
    this._sendPort.send(rawData);
  }

  /// Updates clients voice state for [Guild] with given [guildId]
  @override
  void changeVoiceState(Snowflake? guildId, Snowflake? channelId, {bool selfMute = false, bool selfDeafen = false}) {
    this.send(OPCodes.voiceStateUpdate, <String, dynamic> {
      "guild_id" : guildId.toString(),
      "channel_id" : channelId?.toString(),
      "self_mute" : selfMute,
      "self_deaf" : selfDeafen
    });
  }

  /// Allows to set presence for current shard.
  @override
  void setPresence(PresenceBuilder presenceBuilder) {
    this.send(OPCodes.statusUpdate, presenceBuilder.build());
  }

  /// Syncs all guilds
  @override
  void guildSync() => this.send(OPCodes.guildSync, this.guilds.map((e) => e.toString()));

  /// Allows to request members objects from gateway
  /// [guild] can be either Snowflake or Iterable<Snowflake>
  @override
  void requestMembers(/* Snowflake|Iterable<Snowflake> */ dynamic guild,
      {String? query, Iterable<Snowflake>? userIds, int limit = 0, bool presences = false, String? nonce}) {
    if (query != null && userIds != null) {
      throw ArgumentError("Both `query` and userIds cannot be specified.");
    }

    dynamic guildPayload;

    if (guild is Snowflake) {
      if(!this.guilds.contains(guild)) {
        throw InvalidShardException("Cannot request member for guild on wrong shard");
      }

      guildPayload = [guild.toString()];
    } else if (guild is Iterable<Snowflake>) {
      if(!this.guilds.any((element) => guild.contains(element))) {
        throw InvalidShardException("Cannot request member for guild on wrong shard");
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
      manager.logger.warning("Not received previous heartbeat ack on shard: [${this.id}] on sequence: [{$_sequence}]");
      return;
    }

    this._heartbeatAckReceived = false;
  }

  void _handleError(dynamic data) {
    final closeCode = data["errorCode"] as int;

    this._connected = false;
    this._heartbeatTimer.cancel();
    manager.logger.severe("Shard $id disconnected. Error: [${data['error']}] Error code: [${data['errorCode']}] | Error message: [${data['errorReason']}]");
    this.manager.onDisconnectController.add(this);

    switch (closeCode) {
      case 4004:
      case 4010:
        exit(1);
      case 4013:
        manager.logger.shout("Cannot connect to gateway due intent value is invalid. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
        exit(1);
      case 4014:
        manager.logger.shout("You sent a disallowed intent for a Gateway Intent. "
            "You may have tried to specify an intent that you have not enabled or are not whitelisted for. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
        exit(1);
      case 4007:
      case 4009:
      case 1001:
        _reconnect();
        break;
      default:
        _connect();
        break;
    }
  }

  // Connects to gateway
  void _connect() {
    manager.logger.info("Connecting to gateway on shard $id!");
    this._resume = false;
    Future.delayed(const Duration(seconds: 2), () => this._sendPort.send({ "cmd" : "CONNECT"}));
  }

  // Reconnects to gateway
  void _reconnect() {
    manager.logger.info("Resuming connection to gateway on shard $id!");
    this._resume = true;
    Future.delayed(const Duration(seconds: 1), () => this._sendPort.send({ "cmd" : "CONNECT"}));
  }

  Future<void> _handle(dynamic rawData) async {
    this.manager.logger.finest("Received gateway payload on shard [${this.id}]: [$rawData]");

    if(rawData["cmd"] == "CONNECT_ACK") {
      manager.logger.info("Shard $id connected to gateway!");

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
            "token": manager.connectionManager.client.token,
            "properties": <String, dynamic> {
              "\$os": Platform.operatingSystem,
              "\$browser": "nyxx",
              "\$device": "nyxx",
            },
            "large_threshold": manager.connectionManager.client.options.largeThreshold,
            "guild_subscriptions" : manager.connectionManager.client.options.guildSubscriptions,
            "intents": manager.connectionManager.client.intents,
            if (manager.connectionManager.client.options.initialPresence != null)
              "presence" : manager.connectionManager.client.options.initialPresence!.build(),
            "shard": <int>[this.id, manager.numShards]
          };

          this.send(OPCodes.identify, identifyMsg);

          this.manager.onConnectController.add(this);
        } else if (_resume) {
          this.send(OPCodes.resume, <String, dynamic>{"token": manager.connectionManager.client.token, "session_id": this._sessionId, "seq": this._sequence});
        }

        Future.delayed(const Duration(milliseconds: 100), () {
          this._heartbeatTimer = Timer.periodic(Duration(milliseconds: rawPayload["d"]["heartbeat_interval"] as int), (Timer t) => this._heartbeat());
        });
        break;
      case OPCodes.invalidSession:
        manager.logger.severe("Invalid session on shard $id. ${(rawPayload["d"] as bool) ? "Resuming..." : "Reconnecting..."}");
        _heartbeatTimer.cancel();
        (manager.connectionManager.client.eventsWs as WebsocketEventController).onDisconnectController.add(DisconnectEvent(this, DisconnectEventReason.invalidSession));

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
            manager.connectionManager.client.self = ClientUser(manager.connectionManager.client, rawPayload["d"]["user"] as RawApiMap);

            this._connected = true;
            manager.logger.info("Shard ${this.id} ready!");

            if (!_resume) {
              await manager.connectionManager.propagateReady();
            }

            break;
          case "RESUME":
            this.manager.onResumeController.add(this);
            break;

          case "GUILD_MEMBERS_CHUNK":
            manager.onMemberChunkController.add(MemberChunkEvent(rawPayload, manager.connectionManager.client, this.id));
            break;

          case "MESSAGE_REACTION_REMOVE_ALL":
            this.eventController.onMessageReactionsRemovedController.add(MessageReactionsRemovedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_REACTION_ADD":
            this.eventController.onMessageReactionAddedController.add(MessageReactionAddedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_REACTION_REMOVE":
            this.eventController.onMessageReactionRemoveController.add(MessageReactionRemovedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_DELETE_BULK":
            this.eventController.onMessageDeleteBulkController.add(MessageDeleteBulkEvent(rawPayload, manager.connectionManager.client));
            break;

          case "CHANNEL_PINS_UPDATE":
            this.eventController.onChannelPinsUpdateController.add(ChannelPinsUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "VOICE_STATE_UPDATE":
            this.eventController.onVoiceStateUpdateController.add(VoiceStateUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "VOICE_SERVER_UPDATE":
            this.eventController.onVoiceServerUpdateController.add(VoiceServerUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_EMOJIS_UPDATE":
            this.eventController.onGuildEmojisUpdateController.add(GuildEmojisUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_CREATE":
            this.eventController.onMessageReceivedController.add(MessageReceivedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_DELETE":
            this.eventController.onMessageDeleteController.add(MessageDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_UPDATE":
            this.eventController.onMessageUpdateController.add(MessageUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_CREATE":
            final event = GuildCreateEvent(rawPayload, manager.connectionManager.client);
            this.guilds.add(event.guild.id);
            this.eventController.onGuildCreateController.add(event);
            break;

          case "GUILD_UPDATE":
            this.eventController.onGuildUpdateController.add(GuildUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_DELETE":
            this.eventController.onGuildDeleteController.add(GuildDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_BAN_ADD":
            this.eventController.onGuildBanAddController.add(GuildBanAddEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_BAN_REMOVE":
            this.eventController.onGuildBanRemoveController.add(GuildBanRemoveEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_MEMBER_ADD":
            this.eventController.onGuildMemberAddController.add(GuildMemberAddEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_MEMBER_REMOVE":
            this.eventController.onGuildMemberRemoveController.add(GuildMemberRemoveEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_MEMBER_UPDATE":
            this.eventController.onGuildMemberUpdateController.add(GuildMemberUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "CHANNEL_CREATE":
            this.eventController.onChannelCreateController.add(ChannelCreateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "CHANNEL_UPDATE":
            this.eventController.onChannelUpdateController.add(ChannelUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "CHANNEL_DELETE":
            this.eventController.onChannelDeleteController.add(ChannelDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case "TYPING_START":
            this.eventController.onTypingController.add(TypingEvent(rawPayload, manager.connectionManager.client));
            break;

          case "PRESENCE_UPDATE":
            this.eventController.onPresenceUpdateController.add(PresenceUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_ROLE_CREATE":
            this.eventController.onRoleCreateController.add(RoleCreateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_ROLE_UPDATE":
            this.eventController.onRoleUpdateController.add(RoleUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_ROLE_DELETE":
            this.eventController.onRoleDeleteController.add(RoleDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case "USER_UPDATE":
            this.eventController.onUserUpdateController.add(UserUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "INVITE_CREATE":
            this.eventController.onInviteCreatedController.add(InviteCreatedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "INVITE_DELETE":
            this.eventController.onInviteDeleteController.add(InviteDeletedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_REACTION_REMOVE_EMOJI":
            this.eventController.onMessageReactionRemoveEmojiController
                .add(MessageReactionRemoveEmojiEvent(rawPayload, manager.connectionManager.client));
            break;

          case "THREAD_CREATE":
            this.eventController.onThreadCreatedController.add(ThreadCreateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "THREAD_MEMBERS_UPDATE":
            this.eventController.onThreadMembersUpdateController.add(ThreadMembersUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "THREAD_DELETE":
            this.eventController.onThreadDeleteController.add(ThreadDeletedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "THREAD_MEMBER_UPDATE":
            // Catch unnecessary OP, could be needed in future but unsure.
            break;

          default:
            if (this.manager.connectionManager.client.options.dispatchRawShardEvent) {
              this.manager.onRawEventController.add(RawEvent(this, rawPayload));
            } else {
              print("UNKNOWN OPCODE: $rawPayload");
            }
        }
        break;
    }
  }

  @override
  Future<void> dispose() async {
    this.manager.logger.info("Started disposing shard $id...");

    await this._receiveStream.firstWhere((element) => (element as RawApiMap)["cmd"] == "TERMINATE_OK");
    this._shardIsolate.kill(priority: Isolate.immediate);

    this.manager.logger.info("Shard $id disposed.");
  }
}
