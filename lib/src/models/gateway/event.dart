import 'package:nyxx/src/models/gateway/opcodes.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

abstract class GatewayEvent with ToStringHelper {
  final Opcodes opcode;

  GatewayEvent({required this.opcode});
}

class RawDispatchEvent extends GatewayEvent {
  final int seq;

  final String name;

  final Map<String, Object?> payload;

  RawDispatchEvent({required this.seq, required this.name, required this.payload}) : super(opcode: Opcodes.dispatch);
}

abstract class DispatchEvent extends GatewayEvent {
  DispatchEvent() : super(opcode: Opcodes.dispatch);
}

class UnknownDispatchEvent extends DispatchEvent {
  final RawDispatchEvent raw;

  UnknownDispatchEvent({required this.raw});
}

class HeartbeatEvent extends GatewayEvent {
  HeartbeatEvent() : super(opcode: Opcodes.heartbeat);
}

class ReconnectEvent extends GatewayEvent {
  ReconnectEvent() : super(opcode: Opcodes.reconnect);
}

class InvalidSessionEvent extends GatewayEvent {
  final bool isResumable;

  InvalidSessionEvent({required this.isResumable}) : super(opcode: Opcodes.invalidSession);
}

class HelloEvent extends GatewayEvent {
  final Duration heartbeatInterval;

  HelloEvent({required this.heartbeatInterval}) : super(opcode: Opcodes.hello);
}

class HeartbeatAckEvent extends GatewayEvent {
  HeartbeatAckEvent() : super(opcode: Opcodes.heartbeatAck);
}
