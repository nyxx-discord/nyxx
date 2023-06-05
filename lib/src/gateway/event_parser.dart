import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/gateway/opcodes.dart';

mixin class EventParser {
  GatewayEvent parseGatewayEvent(Map<String, Object?> raw) {
    final mapping = {
      Opcodes.dispatch.value: parseDispatch,
      Opcodes.heartbeat.value: parseHeartbeat,
      Opcodes.reconnect.value: parseReconnect,
      Opcodes.invalidSession.value: parseInvalidSession,
      Opcodes.hello.value: parseHello,
      Opcodes.heartbeatAck.value: parseHeartbeatAck,
    };

    return mapping[raw['op'] as int]!(raw);
  }

  HeartbeatEvent parseHeartbeat(Map<String, Object?> raw) {
    return HeartbeatEvent();
  }

  ReconnectEvent parseReconnect(Map<String, Object?> raw) {
    return ReconnectEvent();
  }

  InvalidSessionEvent parseInvalidSession(Map<String, Object?> raw) {
    return InvalidSessionEvent(
      isResumable: raw['d'] as bool,
    );
  }

  HelloEvent parseHello(Map<String, Object?> raw) {
    return HelloEvent(
      heartbeatInterval: Duration(
        milliseconds: (raw['d'] as Map<String, Object?>)['heartbeat_interval'] as int,
      ),
    );
  }

  HeartbeatAckEvent parseHeartbeatAck(Map<String, Object?> raw) {
    return HeartbeatAckEvent();
  }

  RawDispatchEvent parseDispatch(Map<String, Object?> raw) {
    return RawDispatchEvent(
      seq: raw['s'] as int,
      name: raw['t'] as String,
      payload: raw['d'] as Map<String, Object?>,
    );
  }
}
