part of nyxx;

/// Raw gateway event
/// RawEvent is dispatched ONLY for payload that doesn't match any event built in into Nyxx.
abstract class IRawEvent {
  /// Shard where event was received
  IShard get shard;

  /// Raw event data as deserialized json
  RawApiMap get rawData;
}

class RawEvent implements IRawEvent {
  /// Shard where event was received
  @override
  final IShard shard;

  /// Raw event data as deserialized json
  @override
  final RawApiMap rawData;

  /// Creates an instance of [RawEvent]
  RawEvent(this.shard, this.rawData);
}
