part of nyxx;

/// Raw gateway event
/// RawEvent is dispatched ONLY for payload that doesn't match any event built in into Nyxx.
class RawEvent {
  /// Shard where event was received
  final Shard shard;

  /// Raw event data as deserialized json
  final RawApiMap rawData;

  RawEvent._new(this.shard, this.rawData);
}
