part of nyxx;

/// Sent when a shard disconnects from the websocket.
class DisconnectEvent {
  /// The shard that got disconnected.
  Shard shard;

  /// Reason of disconnection
  DisconnectEventReason reason;

  DisconnectEvent._new(this.shard, this.reason);
}

class DisconnectEventReason extends IEnum<int> {
  static const DisconnectEventReason invalidSession = const DisconnectEventReason._from(9);

  const DisconnectEventReason._from(int value) : super(value);
}