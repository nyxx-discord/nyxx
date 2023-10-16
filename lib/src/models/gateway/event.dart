import 'package:nyxx/src/gateway/gateway.dart';
import 'package:nyxx/src/models/gateway/opcode.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template gateway_event}
/// The base class for all events received from the Gateway.
/// {@endtemplate}
abstract class GatewayEvent with ToStringHelper {
  /// The opcode of this event.
  final Opcode opcode;

  /// {@macro gateway_event}
  GatewayEvent({required this.opcode});
}

/// {@template raw_dispatch_event}
/// An unparsed dispatch event.
/// {@endtemplate}
class RawDispatchEvent extends GatewayEvent {
  /// The sequence number for this event.
  final int seq;

  /// The name of the event.
  final String name;

  /// The payload associated with the event.
  final Map<String, Object?> payload;

  /// {@macro raw_dispatch_event}
  RawDispatchEvent({required this.seq, required this.name, required this.payload}) : super(opcode: Opcode.dispatch);
}

/// {@template dispatch_event}
/// The base class for all events sent by dispatch.
/// {@endtemplate}
abstract class DispatchEvent extends GatewayEvent {
  /// The gateway that handled this event.
  final Gateway gateway;

  /// {@macro dispatch_event}
  DispatchEvent({required this.gateway}) : super(opcode: Opcode.dispatch);
}

/// {@template unknown_dispatch_event}
/// Emitted when a [RawDispatchEvent] could not be parsed to a [DispatchEvent] due to the event being unknown.
///
/// This either means the event is internal and not documented, or that nyxx has not yet updated to support it.
/// {@endtemplate}
class UnknownDispatchEvent extends DispatchEvent {
  /// The [RawDispatchEvent] that couldn't be parsed.
  final RawDispatchEvent raw;

  /// {@macro unknown_dispatch_event}
  UnknownDispatchEvent({required super.gateway, required this.raw});
}

/// {@template heartbeat_event}
/// Emitted when the client receives a request to heartbeat.
/// {@endtemplate}
class HeartbeatEvent extends GatewayEvent {
  /// {@macro heartbeat_event}
  HeartbeatEvent() : super(opcode: Opcode.heartbeat);
}

/// {@template reconnect_event}
/// Emitted when the client receives a request to reconnect.
/// {@endtemplate}
class ReconnectEvent extends GatewayEvent {
  /// {@macro reconnect_events}
  ReconnectEvent() : super(opcode: Opcode.reconnect);
}

/// {@template invalid_session_event}
/// Emitted when the client's session is invalid.
/// {@endtemplate}
class InvalidSessionEvent extends GatewayEvent {
  /// Whether the client can resume the session on a new connection.
  final bool isResumable;

  /// {@macro invalid_session_event}
  InvalidSessionEvent({required this.isResumable}) : super(opcode: Opcode.invalidSession);
}

/// {@template hello_event}
/// Emitted when the client first establishes a connection to the gateway.
/// {@endtemplate}
class HelloEvent extends GatewayEvent {
  /// The interval at which the client should heartbeat.
  final Duration heartbeatInterval;

  /// {@macro hello_event}
  HelloEvent({required this.heartbeatInterval}) : super(opcode: Opcode.hello);
}

/// {@template heartbeat_ack_event}
/// Emitted when the server acknowledges the client's heartbeat.
/// {@endtemplate}
class HeartbeatAckEvent extends GatewayEvent {
  /// The time taken for this event to be sent in response to the last [Opcode.heartbeat] message.
  final Duration latency;

  /// {@macro heartbeat_ack_event}
  HeartbeatAckEvent({required this.latency}) : super(opcode: Opcode.heartbeatAck);
}
