part of nyxx;

/// Raw gateway event
class RawEvent {
  /// Shard where event was received
  final Shard shard;

  /// Raw event data as deserialized json
  final Map<String, dynamic> rawData;

  RawEvent._new(this.shard, this.rawData);
}