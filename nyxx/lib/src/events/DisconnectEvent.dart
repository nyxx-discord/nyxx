part of nyxx;

/// Sent when a shard disconnects from the websocket.
class DisconnectEvent {
  /// The shard that got disconnected.
  Shard shard;

  /// Reason of disconnection
  DisconnectEventReason reason;

  DisconnectEvent._new(this.shard, this.reason);
}

/// Reason why shard was disconnected.
class DisconnectEventReason extends IEnum<int> {
  /// When shard is disconnected due invalid shard session.
  static const DisconnectEventReason invalidSession = DisconnectEventReason._from(9);

  const DisconnectEventReason._from(int value) : super(value);
}
