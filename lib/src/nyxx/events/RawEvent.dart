part of nyxx;

/// Sent when the client is ready.
class RawEvent {
  /// The shard the packet was received on.
  Shard shard;

  /// The received packet.
  Map<String, dynamic> packet;

  RawEvent._new(Nyxx client, this.shard, this.packet) {
    client._events.onRaw.add(this);
  }
}
