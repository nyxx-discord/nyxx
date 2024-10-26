import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/models/events/event.dart';
import 'package:nyxx/src/models/gateway/opcode.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template shard_data}
/// Information a shard needs to run itself.
/// {@endtemplate}
class ShardData with ToStringHelper {
  /// The total number of shards in the current session.
  final int totalShards;

  /// The ID of the current shard.
  final int id;

  /// The API options the client is using.
  final GatewayApiOptions apiOptions;

  /// The original connection URI from [GatewayManager.fetchGatewayBot].
  final Uri originalConnectionUri;

  /// {@macro shard_data}
  const ShardData({
    required this.totalShards,
    required this.id,
    required this.apiOptions,
    required this.originalConnectionUri,
  });
}

/// The base class for all control messages sent from the shard to the client.
abstract class ShardMessage with ToStringHelper {}

/// A shard message sent when an event is received on the Gateway.
class EventReceived extends ShardMessage {
  /// The event that was received.
  final Event event;

  /// Create a new [EventReceived].
  EventReceived({required this.event});
}

/// A shard message sent when the shard encounters an error.
class ErrorReceived extends ShardMessage {
  /// The error encountered.
  final Object error;

  /// The stack trace where the error occurred.
  final StackTrace stackTrace;

  /// Create a new [ErrorReceived].
  ErrorReceived({required this.error, required this.stackTrace});
}

/// A shard message sent when the shard is going to disconnect permanently.
class Disconnecting extends ShardMessage {
  /// The reason why the shard is disconnecting.
  final String reason;

  /// Create a new [Disconnecting].
  Disconnecting({required this.reason});
}

/// A shard message sent when the shard adds a payload to the connection.
class Sent extends ShardMessage {
  /// The payload that was sent.
  final Send payload;

  /// Create a new [Sent].
  Sent({required this.payload});
}

/// A shard message sent when the shard is waiting to identify on the Gateway.
class RequestingIdentify extends ShardMessage {}

/// The base class for all control messages sent from the client to the shard.
abstract class GatewayMessage with ToStringHelper {}

/// A gateway message sent to instruct the shard to send data on its connection.
class Send extends GatewayMessage {
  /// The opcode of the event to send.
  final Opcode opcode;

  /// The data of the event to send.
  final dynamic data;

  /// Create a new [Send].
  Send({required this.opcode, required this.data});
}

/// A gateway message sent when the [Gateway] instance is ready for the shard to start.
class StartShard extends GatewayMessage {}

/// A gateway message sent as a response to [RequestingIdentify] to allow the shard to identify.
class Identify extends GatewayMessage {}

/// A gateway message sent to instruct the shard to disconnect & stop handling any further messages.
///
/// The shard can no longer be used after this is sent.
class Dispose extends GatewayMessage {}
