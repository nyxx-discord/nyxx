import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:nyxx/src/core/guild/client_user.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/events/channel_events.dart';
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
import 'package:nyxx/src/internal/shard/message.dart';
import 'package:nyxx/src/internal/shard/shard_handler.dart';
import 'package:nyxx/src/internal/shard/shard_manager.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/presence_builder.dart';

/// A connection to the [Discord Gateway](https://discord.com/developers/docs/topics/gateway).
///
/// One client can have multiple shards. Each shard moves the decompressing and decoding steps of the Gateway connection to their own thread which can lessen
/// the load on the main thread for large bots which might receive thousands of events per minute.
abstract class IShard implements Disposable {
  /// The ID of this shard.
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

class Shard implements IShard {
  @override
  final int id;

  @override
  final ShardManager manager;

  @override
  final List<Snowflake> guilds = [];

  @override
  Duration gatewayLatency = Duration.zero;

  @override
  bool connected = false;

  /// The receive port on which events from the isolate will be received.
  final ReceivePort receivePort = ReceivePort();

  /// A stream on which events from the shard will be received.
  ///
  /// Should only be accessed after [readyFuture] has completed.
  late final Stream<ShardMessage<ShardToManager>> shardMessages;

  /// The send port on which messages to the isolate should be added.
  ///
  /// Should only be accessed after [readyFuture] has completed.
  late final SendPort sendPort;

  /// A future that completes once the handler isolate is running.
  late final Future<void> readyFuture;

  /// The URL to which this shard should make the initial connection.
  final String gatewayHost;

  late final Logger logger = Logger('Shard $id');

  /// The last sequence number
  // Start at 0 and count up to avoid collisions with seq from the shard handler
  int seq = 0;

  Shard(this.id, this.manager, this.gatewayHost) {
    readyFuture = spawn();

    // Automatically connect once the shard runner is ready.
    readyFuture.then((_) => connect());

    // Start handling messages from the shard.
    readyFuture.then((_) => shardMessages.listen(handle));
  }

  /// Spawns the handler isolate and initializes [sendPort] and [shardMessages];
  Future<void> spawn() async {
    logger.fine("Starting shard runner...");

    await Isolate.spawn(shardHandler, receivePort.sendPort, debugName: "Shard Runner #$id");

    final rawShardMessages = receivePort.asBroadcastStream();

    sendPort = await rawShardMessages.first as SendPort;
    shardMessages = rawShardMessages.cast<ShardMessage<ShardToManager>>();

    logger.fine("Shard runner ready");
  }

  /// Sends a message to the shard isolate.
  void execute(ShardMessage<ManagerToShard> message) async {
    await readyFuture;

    logger.fine('Sending ${message.type.name} message to runner');
    logger.finer([
      'Sequence: ${message.seq}',
      if (message.data != null) 'Data: ${message.data}',
    ].join('\n'));

    sendPort.send(message);
  }

  Future<void> _connectReconnectHelper(int seq, {required bool isReconnect}) async {
    // These need to be accessible both in the main callback, in retryIf and in the catch block below
    bool shouldReconnect = false;
    late String errorMessage;

    try {
      await manager.connectionManager.client.options.shardReconnectOptions.retry(
        retryIf: (_) => shouldReconnect,
        () async {
          execute(ShardMessage(
            isReconnect ? ManagerToShard.reconnect : ManagerToShard.connect,
            seq: seq,
            data: {
              'gatewayHost': shouldResume && canResume ? resumeGatewayUrl : gatewayHost,
              'useCompression': manager.connectionManager.client.options.compressedGatewayPayloads,
            },
          ));

          final message = await shardMessages.firstWhere((element) => element.seq == seq);

          switch (message.type) {
            case ShardToManager.connected:
            case ShardToManager.reconnected:
              return;
            case ShardToManager.error:
              shouldReconnect = message.data['shouldReconnect'] as bool? ?? false;
              errorMessage = message.data['message'] as String;
              throw Exception();
            default:
              assert(false, 'Unreachable');
              return;
          }
        },
      );
    } on Exception {
      // Callback failed too many times, throw an unrecoverable error with the message we were given
      throw UnrecoverableNyxxError(errorMessage);
    }
  }

  Future<void> connect() => _connectReconnectHelper(seq, isReconnect: false);

  /// Triggers a reconnection to the shard.
  ///
  /// If the connection is to be resumed, [resumeGatewayUrl] is used as the connection. Otherwise, [gatewayHost] is used.
  Future<void> reconnect([int? seq]) async {
    logger.info('Reconnecting to gateway on shard $id');
    resetConnectionProperties();

    int realSeq = seq ?? (this.seq++);

    await _connectReconnectHelper(realSeq, isReconnect: true);
  }

  void resetConnectionProperties() {
    connected = false;
    heartbeatTimer?.cancel();
    lastHeartbeatSent = null;
  }

  /// Handler for incoming messages from the isolate.
  ///
  /// These messages are not raw messages from the websocket! Those are handled in [handlePayload].
  Future<void> handle(ShardMessage<ShardToManager> message) async {
    logger.fine('Handling ${message.type.name} message from runner');
    logger.finer([
      'Sequence: ${message.seq}',
      if (message.data != null) 'Data: ${message.data}',
    ].join('\n'));

    switch (message.type) {
      case ShardToManager.received:
        return handlePayload(message.data);
      case ShardToManager.connected:
      case ShardToManager.reconnected:
        return handleConnected();
      case ShardToManager.disconnected:
        return handleDisconnect(message.data['closeCode'] as int, message.data['closeReason'] as String?, message.seq);
      case ShardToManager.error:
        return handleError(message.data['message'] as String, message.seq);
      case ShardToManager.disposed:
        logger.info("Shard $id disposed.");
        break;
    }
  }

  /// A handler for when the shard connection disconnects.
  Future<void> handleDisconnect(int closeCode, String? closeReason, int seq) async {
    resetConnectionProperties();

    manager.onDisconnectController.add(this);

    for (final element in manager.connectionManager.client.plugins) {
      element.onConnectionClose(manager.connectionManager.client, element.logger, closeCode, closeReason);
    }

    // https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
    const warnings = <int, String>{
      4000: 'Unknown error',
      4001: 'Unknown opcode',
      4002: 'Decode error (invalid payload)',
      4003: 'Payload sent before authentication',
      4005: 'Already authenticated',
      4007: 'Invalid seq',
      4008: 'Rate limited',
      4009: 'Session timed out',
    };

    const errors = <int, String>{
      4004: 'Invalid authentication',
      4010: 'Invalid shard',
      4011: 'Sharding required',
      4012: 'Invalid API version',
      4013: 'Invalid intents',
      4014: 'Disallowed intent',
    };

    if (errors.containsKey(closeCode)) {
      throw UnrecoverableNyxxError('Shard $id disconnected: ${errors[closeCode]!}');
    } else if (warnings.containsKey(closeCode)) {
      logger.warning('Shard disconnected: ${warnings[closeCode]!}');

      // Try to resume on all warnings apart from invalid sequence, which prevents us from resuming
      shouldResume = closeCode != 4007;
    } else {
      // If we get an unknown error, try to resume.
      shouldResume = true;
    }

    // Reconnect by default
    reconnect(seq);
  }

  /// A handler for when the shard establishes a connection to the Gateway.
  Future<void> handleConnected() async {
    logger.info('Shard connected to gateway');
    connected = true;
    manager.onConnectController.add(this);

    // There was no previous heartbeat on a new connection.
    // Setting this to true prevents us from reconnecting upon receiving the first heartbeat due to the previous heartbeat "not being acked".
    lastHeartbeatAcked = true;
  }

  /// A handler for when the shard encounters an error. These can occur if the runner is in an invalid state or fails to open the websocket connection.
  Future<void> handleError(String message, int seq) async {
    logger.shout('Shard reported error', message);

    for (final element in manager.connectionManager.client.plugins) {
      element.onConnectionError(manager.connectionManager.client, element.logger, message);
    }
  }

  /// A handler for when a payload from the gateway is received.
  Future<void> handlePayload(dynamic data) async {
    final opcode = data['op'] as int;
    final d = data['d'];

    switch (opcode) {
      case OPCodes.dispatch:
        dispatch(data['s'] as int, data['t'] as String, data as RawApiMap);
        break;

      case OPCodes.heartbeat:
        heartbeat();
        break;

      case OPCodes.hello:
        hello(d['heartbeat_interval'] as int);
        break;

      case OPCodes.heartbeatAck:
        heartbeatAck();
        break;

      case OPCodes.invalidSession:
        // https://discord.com/developers/docs/topics/gateway#invalid-session
        shouldResume = d as bool;

        if (shouldResume) {
          reconnect();
        } else {
          // https://discord.com/developers/docs/topics/gateway#resuming
          Future.delayed(
            Duration(seconds: 1) + Duration(seconds: 4) * Random().nextDouble(),
            identify,
          );
        }
        break;

      case OPCodes.reconnect:
        shouldResume = true;
        reconnect();
        break;

      default:
        logger.severe('Unhandled opcode $opcode');
        break;
    }
  }

  /// The timer than handles sending regular heartbeats to the gateway.
  Timer? heartbeatTimer;

  /// Whether this shard should attempt to resume upon connecting.
  ///
  /// Note that a result will only be sent if this shard [shouldResume] and [canResume].
  bool shouldResume = false;

  /// Whether this shard can resume upon connecting.
  bool get canResume => seqNum != null && sessionId != null && resumeGatewayUrl != null;

  /// A handler for [OPCodes.hello].
  void hello(int heartbeatInterval) {
    // https://discord.com/developers/docs/topics/gateway#heartbeating
    final heartbeatDuration = Duration(milliseconds: heartbeatInterval);

    final jitter = Random().nextDouble();

    heartbeatTimer = Timer(heartbeatDuration * jitter, () {
      heartbeat();

      heartbeatTimer = Timer.periodic(heartbeatDuration, (timer) => heartbeat());
    });

    if (shouldResume && canResume) {
      resume();
    } else {
      identify();
    }
  }

  /// Sends the identify payload to the gateway.
  // https://discord.com/developers/docs/topics/gateway#identifying
  void identify() => send(OPCodes.identify, {
        "token": manager.connectionManager.client.token,
        "properties": {
          "os": Platform.operatingSystem,
          "browser": "nyxx",
          "device": "nyxx",
        },
        "large_threshold": manager.connectionManager.client.options.largeThreshold,
        "intents": manager.connectionManager.client.intents,
        if (manager.connectionManager.client.options.initialPresence != null) "presence": manager.connectionManager.client.options.initialPresence!.build(),
        "shard": <int>[id, manager.totalNumShards]
      });

  /// Sends the resume payload to the gateway.
  ///
  /// Will throw if [canResume] is false.
  // https://discord.com/developers/docs/topics/gateway#resuming
  void resume() => send(OPCodes.resume, {
        "token": manager.connectionManager.client.token,
        "session_id": sessionId!,
        "seq": seqNum!,
      });

  /// The time at which the last heartbeat was sent.
  ///
  /// Used for calculating gateway latency.
  DateTime? lastHeartbeatSent;

  /// Whether the last heartbeat sent has been acknowledged.
  bool lastHeartbeatAcked = true;

  /// A handler for [OPCodes.heartbeat].
  ///
  /// Also called regularly in the callback of [heartbeatTimer].
  ///
  /// Triggers a reconnect if it is invoked before the last heartbeat was acked. See
  /// https://discord.com/developers/docs/topics/gateway#heartbeating-example-gateway-heartbeat-ack.
  void heartbeat() {
    send(OPCodes.heartbeat, seqNum);

    if (!lastHeartbeatAcked) {
      shouldResume = true;
      reconnect();
      return;
    }

    lastHeartbeatSent = DateTime.now();
    lastHeartbeatAcked = false;
  }

  /// A handler for [OPCodes.heartbeatAck].
  ///
  /// Updates the gateway latency.
  void heartbeatAck() {
    gatewayLatency = DateTime.now().difference(lastHeartbeatSent!);
    lastHeartbeatAcked = true;
  }

  /// The session ID found in the READY event.
  String? sessionId;

  /// The URL to use for resuming gateway connections, found in the READY event.
  String? resumeGatewayUrl;

  /// The last known sequence number.
  int? seqNum;

  /// A handler for [OPCodes.dispatch].
  void dispatch(int seqNum, String type, RawApiMap data) async {
    final eventController = manager.connectionManager.client.eventsWs as WebsocketEventController;

    this.seqNum = seqNum;

    switch (type) {
      case "READY":
        sessionId = data["d"]["session_id"] as String;
        resumeGatewayUrl = data["d"]["resume_gateway_url"] as String;

        manager.connectionManager.client.self = ClientUser(manager.connectionManager.client, data["d"]["user"] as RawApiMap);

        logger.info("Shard ready!");

        if (!shouldResume) {
          await manager.connectionManager.propagateReady();
        }

        break;
      case "RESUMED":
        shouldResume = false;
        manager.onResumeController.add(this);
        break;

      case "GUILD_MEMBERS_CHUNK":
        manager.onMemberChunkController.add(MemberChunkEvent(data, manager.connectionManager.client, id));
        break;

      case "MESSAGE_REACTION_REMOVE_ALL":
        eventController.onMessageReactionsRemovedController.add(MessageReactionsRemovedEvent(data, manager.connectionManager.client));
        break;

      case "MESSAGE_REACTION_ADD":
        eventController.onMessageReactionAddedController.add(MessageReactionAddedEvent(data, manager.connectionManager.client));
        break;

      case "MESSAGE_REACTION_REMOVE":
        eventController.onMessageReactionRemoveController.add(MessageReactionRemovedEvent(data, manager.connectionManager.client));
        break;

      case "MESSAGE_DELETE_BULK":
        eventController.onMessageDeleteBulkController.add(MessageDeleteBulkEvent(data, manager.connectionManager.client));
        break;

      case "CHANNEL_PINS_UPDATE":
        eventController.onChannelPinsUpdateController.add(ChannelPinsUpdateEvent(data, manager.connectionManager.client));
        break;

      case "VOICE_STATE_UPDATE":
        eventController.onVoiceStateUpdateController.add(VoiceStateUpdateEvent(data, manager.connectionManager.client));
        break;

      case "VOICE_SERVER_UPDATE":
        eventController.onVoiceServerUpdateController.add(VoiceServerUpdateEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_EMOJIS_UPDATE":
        eventController.onGuildEmojisUpdateController.add(GuildEmojisUpdateEvent(data, manager.connectionManager.client));
        break;

      case "MESSAGE_CREATE":
        eventController.onMessageReceivedController.add(MessageReceivedEvent(data, manager.connectionManager.client));
        break;

      case "MESSAGE_DELETE":
        eventController.onMessageDeleteController.add(MessageDeleteEvent(data, manager.connectionManager.client));
        break;

      case "MESSAGE_UPDATE":
        eventController.onMessageUpdateController.add(MessageUpdateEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_CREATE":
        final event = GuildCreateEvent(data, manager.connectionManager.client);
        guilds.add(event.guild.id);
        eventController.onGuildCreateController.add(event);
        break;

      case "GUILD_UPDATE":
        eventController.onGuildUpdateController.add(GuildUpdateEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_DELETE":
        eventController.onGuildDeleteController.add(GuildDeleteEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_BAN_ADD":
        eventController.onGuildBanAddController.add(GuildBanAddEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_BAN_REMOVE":
        eventController.onGuildBanRemoveController.add(GuildBanRemoveEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_MEMBER_ADD":
        eventController.onGuildMemberAddController.add(GuildMemberAddEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_MEMBER_REMOVE":
        eventController.onGuildMemberRemoveController.add(GuildMemberRemoveEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_MEMBER_UPDATE":
        eventController.onGuildMemberUpdateController.add(GuildMemberUpdateEvent(data, manager.connectionManager.client));
        break;

      case "CHANNEL_CREATE":
        eventController.onChannelCreateController.add(ChannelCreateEvent(data, manager.connectionManager.client));
        break;

      case "CHANNEL_UPDATE":
        eventController.onChannelUpdateController.add(ChannelUpdateEvent(data, manager.connectionManager.client));
        break;

      case "CHANNEL_DELETE":
        eventController.onChannelDeleteController.add(ChannelDeleteEvent(data, manager.connectionManager.client));
        break;

      case "TYPING_START":
        eventController.onTypingController.add(TypingEvent(data, manager.connectionManager.client));
        break;

      case "PRESENCE_UPDATE":
        eventController.onPresenceUpdateController.add(PresenceUpdateEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_ROLE_CREATE":
        eventController.onRoleCreateController.add(RoleCreateEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_ROLE_UPDATE":
        eventController.onRoleUpdateController.add(RoleUpdateEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_ROLE_DELETE":
        eventController.onRoleDeleteController.add(RoleDeleteEvent(data, manager.connectionManager.client));
        break;

      case "USER_UPDATE":
        eventController.onUserUpdateController.add(UserUpdateEvent(data, manager.connectionManager.client));
        break;

      case "INVITE_CREATE":
        eventController.onInviteCreatedController.add(InviteCreatedEvent(data, manager.connectionManager.client));
        break;

      case "INVITE_DELETE":
        eventController.onInviteDeleteController.add(InviteDeletedEvent(data, manager.connectionManager.client));
        break;

      case "MESSAGE_REACTION_REMOVE_EMOJI":
        eventController.onMessageReactionRemoveEmojiController.add(MessageReactionRemoveEmojiEvent(data, manager.connectionManager.client));
        break;

      case "THREAD_CREATE":
        eventController.onThreadCreatedController.add(ThreadCreateEvent(data, manager.connectionManager.client));
        break;

      case "THREAD_MEMBERS_UPDATE":
        eventController.onThreadMembersUpdateController.add(ThreadMembersUpdateEvent(data, manager.connectionManager.client));
        break;

      case "THREAD_DELETE":
        eventController.onThreadDeleteController.add(ThreadDeletedEvent(data, manager.connectionManager.client));
        break;

      case "THREAD_MEMBER_UPDATE":
        // Catch unnecessary OP, could be needed in future but unsure.
        break;

      case "GUILD_SCHEDULED_EVENT_CREATE":
        eventController.onGuildEventCreateController.add(GuildEventCreateEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_SCHEDULED_EVENT_UPDATE":
        eventController.onGuildEventUpdateController.add(GuildEventUpdateEvent(data, manager.connectionManager.client));
        break;

      case "GUILD_SCHEDULED_EVENT_DELETE":
        eventController.onGuildEventDeleteController.add(GuildEventDeleteEvent(data, manager.connectionManager.client));
        break;

      case 'WEBHOOKS_UPDATE':
        eventController.onWebhookUpdateController.add(WebhookUpdateEvent(data, manager.connectionManager.client));
        break;

      case 'AUTO_MODERATION_RULE_CREATE':
        eventController.onAutoModerationRuleCreateController.add(AutoModerationRuleCreateEvent(data, manager.connectionManager.client));
        break;

      case 'AUTO_MODERATION_RULE_UPDATE':
        eventController.onAutoModerationRuleUpdateController.add(AutoModerationRuleUpdateEvent(data, manager.connectionManager.client));
        break;

      case 'AUTO_MODERATION_RULE_DELETE':
        eventController.onAutoModerationRuleDeleteController.add(AutoModerationRuleDeleteEvent(data, manager.connectionManager.client));
        break;

      case 'AUTO_MODERATION_ACTION_EXECUTION':
        eventController.onAutoModerationActionExecutionController.add(AutoModeratioActionExecutionEvent(data, manager.connectionManager.client));
        break;

      default:
        if (manager.connectionManager.client.options.dispatchRawShardEvent) {
          manager.onRawEventController.add(RawEvent(this, data));
        } else {
          logger.severe("UNKNOWN OPCODE: $data");
        }
    }
  }

  @override
  void send(int opCode, dynamic d) => execute(ShardMessage(
        ManagerToShard.send,
        seq: seq++,
        data: {
          "op": opCode,
          "d": d,
        },
      ));

  @override
  Stream<IShard> get onDisconnect => manager.onDisconnect.where((event) => event.id == id);

  @override
  Stream<IMemberChunkEvent> get onMemberChunk => manager.onMemberChunk.where((event) => event.shardId == id);

  @override
  Stream<IShard> get onResume => manager.onResume.where((event) => event.id == id);

  @override
  void guildSync() => send(OPCodes.guildSync, guilds.map((e) => e.toString()));

  @override
  void setPresence(PresenceBuilder presenceBuilder) => send(OPCodes.statusUpdate, presenceBuilder.build());

  @override
  void changeVoiceState(Snowflake? guildId, Snowflake? channelId, {bool selfMute = false, bool selfDeafen = false}) => send(
        OPCodes.voiceStateUpdate,
        <String, dynamic>{
          "guild_id": guildId?.toString(),
          "channel_id": channelId?.toString(),
          "self_mute": selfMute,
          "self_deaf": selfDeafen,
        },
      );

  @override
  void requestMembers(
    /* Snowflake|Iterable<Snowflake> */ dynamic guild, {
    String? query,
    Iterable<Snowflake>? userIds,
    int limit = 0,
    bool presences = false,
    String? nonce,
  }) {
    if (query != null && userIds != null) {
      throw ArgumentError("At most one of `query` and `userIds` may be set");
    }

    if (guild is! Iterable<Snowflake>) {
      if (guild is! Snowflake) {
        throw ArgumentError("`guild` must be a Snowflake or an Iterable<Snowflake>");
      }

      guild = [guild];
    }

    for (final id in guild) {
      if (!guilds.contains(id)) {
        throw InvalidShardException("Cannot request guild $id on shard ${this.id} because it does not exist on this shard");
      }
    }

    final payload = <String, dynamic>{
      "guild_id": guild.map((id) => id.toString()).toList(),
      "limit": limit,
      "presences": presences,
      if (query != null) "query": query,
      if (userIds != null) "user_ids": userIds.map((e) => e.toString()).toList(),
      if (nonce != null) "nonce": nonce
    };

    send(OPCodes.requestGuildMember, payload);
  }

  @override
  Future<void> dispose() async {
    execute(ShardMessage(ManagerToShard.dispose, seq: seq++));

    // Wait for shard to dispose correctly
    await shardMessages.firstWhere((message) => message.type == ShardToManager.disposed);

    receivePort.close();
  }
}
