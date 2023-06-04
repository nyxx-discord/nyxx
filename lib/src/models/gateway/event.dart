import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

abstract class GatewayEvent with ToStringHelper {
  final int opcode;

  GatewayEvent({required this.opcode});
}

class RawDispatchEvent extends GatewayEvent {
  final int seq;

  final String name;

  final Map<String, Object?> payload;

  RawDispatchEvent({required this.seq, required this.name, required this.payload}) : super(opcode: 0);
}

abstract class DispatchEvent extends GatewayEvent {
  DispatchEvent() : super(opcode: 0);
}

class UnknownDispatchEvent extends DispatchEvent {
  final RawDispatchEvent raw;

  UnknownDispatchEvent({required this.raw});
}

class HeartbeatEvent extends GatewayEvent {
  HeartbeatEvent() : super(opcode: 1);
}

class ReconnectEvent extends GatewayEvent {
  ReconnectEvent() : super(opcode: 7);
}

class InvalidSessionEvent extends GatewayEvent {
  final bool isResumable;

  InvalidSessionEvent({required this.isResumable}) : super(opcode: 9);
}

class HelloEvent extends GatewayEvent {
  final Duration heartbeatInterval;

  HelloEvent({required this.heartbeatInterval}) : super(opcode: 10);
}

class HeartbeatAckEvent extends GatewayEvent {
  HeartbeatAckEvent() : super(opcode: 11);
}
