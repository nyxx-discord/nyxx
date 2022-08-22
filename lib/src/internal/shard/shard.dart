import 'dart:async';
import 'dart:html';
import 'dart:io';
import 'dart:isolate';
import 'dart:js';

import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/guild/client_user.dart';
import 'package:nyxx/src/events/channel_events.dart';
import 'package:nyxx/src/events/disconnect_event.dart';
import 'package:nyxx/src/events/guild_events.dart';
import 'package:nyxx/src/events/invite_events.dart';
import 'package:nyxx/src/events/member_chunk_event.dart';
import 'package:nyxx/src/events/message_events.dart';
import 'package:nyxx/src/events/presence_update_event.dart';
import 'package:nyxx/src/events/raw_event.dart';
import 'package:nyxx/src/events/thread_create_event.dart';
import 'package:nyxx/src/events/thread_deleted_event.dart';
import 'package:nyxx/src/events/thread_members_update_event.dart';
import 'package:nyxx/src/events/typing_event.dart';
import 'package:nyxx/src/events/user_update_event.dart';
import 'package:nyxx/src/events/voice_server_update_event.dart';
import 'package:nyxx/src/events/voice_state_update_event.dart';
import 'package:nyxx/src/internal/constants.dart';
import 'package:nyxx/src/internal/event_controller.dart';
import 'package:nyxx/src/internal/exceptions/invalid_shard_exception.dart';
import 'package:nyxx/src/internal/exceptions/unrecoverable_nyxx_error.dart';
import 'package:nyxx/src/internal/interfaces/disposable.dart';
import 'package:nyxx/src/internal/shard/shard_manager.dart';
import 'package:nyxx/src/internal/shard/shard_handler.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/presence_builder.dart';

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
  void requestMembers(/* Snowflake|Iterable<Snowflake> */ dynamic guild,
      {String? query, Iterable<Snowflake>? userIds, int limit = 0, bool presences = false, String? nonce});
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
  late final Stream<IShard> onDisconnect = manager.onDisconnect.where((event) => event.id == id);

  /// Emitted when shard receives member chunk.
  @override
  late final Stream<IMemberChunkEvent> onMemberChunk = manager.onMemberChunk.where((event) => event.shardId == id);

  /// Emitted when the shard resumed its connection
  @override
  late final Stream<IShard> onResume = manager.onResume.where((event) => event.id == id);

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

  WebsocketEventController get eventController => manager.connectionManager.client.eventsWs as WebsocketEventController;

  /// Creates an instance of [Shard]
  Shard(this.id, this.manager, String gatewayUrl) {
    manager.logger.finer("Starting shard with id: $id; url: $gatewayUrl");

    _receivePort = ReceivePort();
    _receiveStream = _receivePort.asBroadcastStream();
    _isolateSendPort = _receivePort.sendPort;

    Isolate.spawn(shardHandler, _isolateSendPort).then((isolate) async {
      _shardIsolate = isolate;
      _sendPort = await _receiveStream.first as SendPort;

      _sendPort.send({"cmd": "INIT", "gatewayUrl": gatewayUrl, "compression": manager.connectionManager.client.options.compressedGatewayPayloads});
      _receiveStream.listen(_handle);
    });
  }

  /// Sends WS data.
  @override
  void send(int opCode, dynamic d) {
    final rawData = {
      "cmd": "SEND",
      "data": {"op": opCode, "d": d}
    };
    manager.logger.finest("Sending to shard isolate on shard [$id]: [$rawData]");
    _sendPort.send(rawData);
  }

  /// Updates clients voice state for [Guild] with given [guildId]
  @override
  void changeVoiceState(Snowflake? guildId, Snowflake? channelId, {bool selfMute = false, bool selfDeafen = false}) {
    send(OPCodes.voiceStateUpdate,
        <String, dynamic>{"guild_id": guildId.toString(), "channel_id": channelId?.toString(), "self_mute": selfMute, "self_deaf": selfDeafen});
  }

  /// Allows to set presence for current shard.
  @override
  void setPresence(PresenceBuilder presenceBuilder) {
    send(OPCodes.statusUpdate, presenceBuilder.build());
  }

  /// Syncs all guilds
  @override
  void guildSync() => send(OPCodes.guildSync, guilds.map((e) => e.toString()));

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
      if (!guilds.contains(guild)) {
        throw InvalidShardException("Cannot request member for guild on wrong shard");
      }

      guildPayload = [guild.toString()];
    } else if (guild is Iterable<Snowflake>) {
      if (!guilds.any((element) => guild.contains(element))) {
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

    send(OPCodes.requestGuildMember, payload);
  }

  void _heartbeat() {
    send(OPCodes.heartbeat, _sequence == 0 ? null : _sequence);
    _lastHeartbeatSent = DateTime.now();

    if (!_heartbeatAckReceived) {
      manager.logger.warning("Not received previous heartbeat ack on shard: [$id] on sequence: [{$_sequence}]");
      return;
    }

    _heartbeatAckReceived = false;
  }

  void _handleError(dynamic data) {
    final closeCode = data["errorCode"] as int?;

    if (closeCode == null) {
      manager.logger.warning("Received null close = client is probably closing. Payload: `$data`");
      return;
    }

    final closeReason = data['errorReason'] as String?;
    final socketError = data['error'] as String?;

    for (final plugin in manager.connectionManager.client.plugins) {
      plugin.onConnectionChange(manager.connectionManager.client, manager.logger, closeCode, closeReason, socketError);
    }

    _connected = false;
    _heartbeatTimer.cancel();
    manager.onDisconnectController.add(this);

    manager.logger.severe("Shard $id disconnected. Error: [$socketError] Error code: [$closeCode] | Error message: [$closeReason]");

    switch (closeCode) {
      case 4004:
      case 4010:
        throw UnrecoverableNyxxError("Gateway error: 4010");
      case 4013:
        throw UnrecoverableNyxxError("Gateway error: 4013: Cannot connect to gateway due intent value is invalid. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
      case 4014:
        throw UnrecoverableNyxxError("Gateway error: 4014: You sent a disallowed intent for a Gateway Intent. "
            "You may have tried to specify an intent that you have not enabled or are not whitelisted for. "
            "Check https://discordapp.com/developers/docs/topics/gateway#gateway-intents for more info.");
      case 4007:
      case 4009:
      case 1005:
      case 1001:
        _reconnect();
        break;
      case -1:
        _connect(delay: 10);
        break;
      default:
        _connect();
        break;
    }
  }

  // Connects to gateway
  void _connect({int delay = 2}) {
    manager.logger.info("Connecting to gateway on shard $id!");
    _resume = false;
    Future.delayed(Duration(seconds: delay), () => _sendPort.send({"cmd": "CONNECT"}));
  }

  // Reconnects to gateway
  void _reconnect() {
    manager.logger.info("Resuming connection to gateway on shard $id!");
    _resume = true;
    Future.delayed(const Duration(seconds: 1), () => _sendPort.send({"cmd": "CONNECT"}));
  }

  Future<void> _handle(dynamic rawData) async {
    manager.logger.finest("Received gateway payload on shard [$id]: [$rawData]");

    if (rawData["cmd"] == "CONNECT_ACK") {
      manager.logger.info("Shard $id connected to gateway!");

      return;
    }

    if (rawData["cmd"] == "ERROR" || rawData["cmd"] == "DISCONNECTED") {
      _handleError(rawData);
      return;
    }

    if (rawData["jsonData"] == null) {
      return;
    }

    final discordPayload = rawData["jsonData"] as RawApiMap;

    if (discordPayload["s"] != null) {
      _sequence = discordPayload["s"] as int;
    }

    await _dispatch(discordPayload);
  }

  Future<void> _dispatch(RawApiMap rawPayload) async {
    switch (rawPayload["op"] as int) {
      case OPCodes.heartbeatAck:
        _heartbeatAckReceived = true;
        _gatewayLatency = DateTime.now().difference(_lastHeartbeatSent);

        break;
      case OPCodes.hello:
        if (_sessionId == null || !_resume) {
          final identifyMsg = <String, dynamic>{
            "token": manager.connectionManager.client.token,
            "properties": <String, dynamic>{
              "os": Platform.operatingSystem,
              "browser": "nyxx",
              "device": "nyxx",
            },
            "large_threshold": manager.connectionManager.client.options.largeThreshold,
            "guild_subscriptions": manager.connectionManager.client.options.guildSubscriptions,
            "intents": manager.connectionManager.client.intents,
            if (manager.connectionManager.client.options.initialPresence != null) "presence": manager.connectionManager.client.options.initialPresence!.build(),
            "shard": <int>[id, manager.totalNumShards]
          };

          send(OPCodes.identify, identifyMsg);

          manager.onConnectController.add(this);
        } else if (_resume) {
          send(OPCodes.resume, <String, dynamic>{"token": manager.connectionManager.client.token, "session_id": _sessionId, "seq": _sequence});
        }

        Future.delayed(const Duration(milliseconds: 100), () {
          _heartbeatTimer = Timer.periodic(Duration(milliseconds: rawPayload["d"]["heartbeat_interval"] as int), (Timer t) => _heartbeat());
        });
        break;
      case OPCodes.invalidSession:
        manager.logger.severe("Invalid session on shard $id. ${(rawPayload["d"] as bool) ? "Resuming..." : "Reconnecting..."}");
        _heartbeatTimer.cancel();
        (manager.connectionManager.client.eventsWs as WebsocketEventController)
            .onDisconnectController
            .add(DisconnectEvent(this, DisconnectEventReason.invalidSession));

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
            _sessionId = rawPayload["d"]["session_id"] as String;
            manager.connectionManager.client.self = ClientUser(manager.connectionManager.client, rawPayload["d"]["user"] as RawApiMap);

            _connected = true;
            manager.logger.info("Shard $id ready!");

            if (!_resume) {
              await manager.connectionManager.propagateReady();
            }

            break;
          case "RESUME":
            manager.onResumeController.add(this);
            break;

          case "GUILD_MEMBERS_CHUNK":
            manager.onMemberChunkController.add(MemberChunkEvent(rawPayload, manager.connectionManager.client, id));
            break;

          case "MESSAGE_REACTION_REMOVE_ALL":
            eventController.onMessageReactionsRemovedController.add(MessageReactionsRemovedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_REACTION_ADD":
            eventController.onMessageReactionAddedController.add(MessageReactionAddedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_REACTION_REMOVE":
            eventController.onMessageReactionRemoveController.add(MessageReactionRemovedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_DELETE_BULK":
            eventController.onMessageDeleteBulkController.add(MessageDeleteBulkEvent(rawPayload, manager.connectionManager.client));
            break;

          case "CHANNEL_PINS_UPDATE":
            eventController.onChannelPinsUpdateController.add(ChannelPinsUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "VOICE_STATE_UPDATE":
            eventController.onVoiceStateUpdateController.add(VoiceStateUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "VOICE_SERVER_UPDATE":
            eventController.onVoiceServerUpdateController.add(VoiceServerUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_EMOJIS_UPDATE":
            eventController.onGuildEmojisUpdateController.add(GuildEmojisUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_CREATE":
            eventController.onMessageReceivedController.add(MessageReceivedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_DELETE":
            eventController.onMessageDeleteController.add(MessageDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_UPDATE":
            eventController.onMessageUpdateController.add(MessageUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_CREATE":
            final event = GuildCreateEvent(rawPayload, manager.connectionManager.client);
            guilds.add(event.guild.id);
            eventController.onGuildCreateController.add(event);
            break;

          case "GUILD_UPDATE":
            eventController.onGuildUpdateController.add(GuildUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_DELETE":
            eventController.onGuildDeleteController.add(GuildDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_BAN_ADD":
            eventController.onGuildBanAddController.add(GuildBanAddEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_BAN_REMOVE":
            eventController.onGuildBanRemoveController.add(GuildBanRemoveEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_MEMBER_ADD":
            eventController.onGuildMemberAddController.add(GuildMemberAddEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_MEMBER_REMOVE":
            eventController.onGuildMemberRemoveController.add(GuildMemberRemoveEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_MEMBER_UPDATE":
            eventController.onGuildMemberUpdateController.add(GuildMemberUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "CHANNEL_CREATE":
            eventController.onChannelCreateController.add(ChannelCreateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "CHANNEL_UPDATE":
            eventController.onChannelUpdateController.add(ChannelUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "CHANNEL_DELETE":
            eventController.onChannelDeleteController.add(ChannelDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case "TYPING_START":
            eventController.onTypingController.add(TypingEvent(rawPayload, manager.connectionManager.client));
            break;

          case "PRESENCE_UPDATE":
            eventController.onPresenceUpdateController.add(PresenceUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_ROLE_CREATE":
            eventController.onRoleCreateController.add(RoleCreateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_ROLE_UPDATE":
            eventController.onRoleUpdateController.add(RoleUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_ROLE_DELETE":
            eventController.onRoleDeleteController.add(RoleDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case "USER_UPDATE":
            eventController.onUserUpdateController.add(UserUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "INVITE_CREATE":
            eventController.onInviteCreatedController.add(InviteCreatedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "INVITE_DELETE":
            eventController.onInviteDeleteController.add(InviteDeletedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "MESSAGE_REACTION_REMOVE_EMOJI":
            eventController.onMessageReactionRemoveEmojiController.add(MessageReactionRemoveEmojiEvent(rawPayload, manager.connectionManager.client));
            break;

          case "THREAD_CREATE":
            eventController.onThreadCreatedController.add(ThreadCreateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "THREAD_MEMBERS_UPDATE":
            eventController.onThreadMembersUpdateController.add(ThreadMembersUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "THREAD_DELETE":
            eventController.onThreadDeleteController.add(ThreadDeletedEvent(rawPayload, manager.connectionManager.client));
            break;

          case "THREAD_MEMBER_UPDATE":
            // Catch unnecessary OP, could be needed in future but unsure.
            break;

          case "GUILD_SCHEDULED_EVENT_CREATE":
            eventController.onGuildEventCreateController.add(GuildEventCreateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_SCHEDULED_EVENT_UPDATE":
            eventController.onGuildEventUpdateController.add(GuildEventUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case "GUILD_SCHEDULED_EVENT_DELETE":
            eventController.onGuildEventDeleteController.add(GuildEventDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case 'WEBHOOKS_UPDATE':
            eventController.onWebhookUpdateController.add(WebhookUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case 'AUTO_MODERATION_RULE_CREATE':
            eventController.onAutoModerationRuleCreateController.add(AutoModerationRuleCreateEvent(rawPayload, manager.connectionManager.client));
            break;

          case 'AUTO_MODERATION_RULE_UPDATE':
            eventController.onAutoModerationRuleUpdateController.add(AutoModerationRuleUpdateEvent(rawPayload, manager.connectionManager.client));
            break;

          case 'AUTO_MODERATION_RULE_DELETE':
            eventController.onAutoModerationRuleDeleteController.add(AutoModerationRuleDeleteEvent(rawPayload, manager.connectionManager.client));
            break;

          case 'AUTO_MODERATION_ACTION_EXECUTION':
            eventController.onAutoModerationActionExecutionController.add(AutoModeratioActionExecutionEvent(rawPayload, manager.connectionManager.client));
            break;

          default:
            if (manager.connectionManager.client.options.dispatchRawShardEvent) {
              manager.onRawEventController.add(RawEvent(this, rawPayload));
            } else {
              manager.logger.info("UNKNOWN OPCODE: $rawPayload");
            }
        }
        break;
    }
  }

  @override
  Future<void> dispose() async {
    manager.logger.info("Started disposing shard $id...");

    _sendPort.send({"cmd": "KILL"});

    final killFuture = _receiveStream.firstWhere((element) => (element as RawApiMap)["cmd"] == "TERMINATE_OK");
    await killFuture;

    _receivePort.close();
    _heartbeatTimer.cancel();

    manager.logger.info("Shard $id disposed.");
  }
}
