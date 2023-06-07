import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/gateway/opcode.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class ShardData with ToStringHelper {
  final int totalShards;

  final int id;

  final GatewayApiOptions apiOptions;

  final Uri originalConnectionUri;

  const ShardData({
    required this.totalShards,
    required this.id,
    required this.apiOptions,
    required this.originalConnectionUri,
  });
}

class ShardMessage with ToStringHelper {}

class EventReceived extends ShardMessage {
  final GatewayEvent event;

  EventReceived({required this.event});
}

class ErrorReceived extends ShardMessage {
  final String error;

  final StackTrace stackTrace;

  ErrorReceived({required this.error, required this.stackTrace});
}

class Disconnecting extends ShardMessage {
  final String reason;

  Disconnecting({required this.reason});
}

class GatewayMessage with ToStringHelper {}

class Send extends GatewayMessage {
  final Opcode opcode;

  final dynamic data;

  Send({required this.opcode, required this.data});
}

class Dispose extends GatewayMessage {}
