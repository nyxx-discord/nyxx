import 'package:nyxx/src/internal/shard/shard.dart';
import 'package:nyxx/src/utils/enum.dart';

abstract class IDisconnectEvent {
  /// The shard that got disconnected.
  IShard get shard;

  /// Reason of disconnection
  DisconnectEventReason get reason;
}

/// Sent when a shard disconnects from the websocket.
class DisconnectEvent implements IDisconnectEvent {
  /// The shard that got disconnected.
  @override
  final IShard shard;

  /// Reason of disconnection
  @override
  final DisconnectEventReason reason;

  /// Creates an instance of [DisconnectEvent]
  DisconnectEvent(this.shard, this.reason);
}

/// Reason why shard was disconnected.
class DisconnectEventReason extends IEnum<int> {
  /// When shard is disconnected due invalid shard session.
  static const DisconnectEventReason invalidSession = DisconnectEventReason(9);

  /// Create an instance of [DisconnectEventReason]
  const DisconnectEventReason(int value) : super(value);
}
