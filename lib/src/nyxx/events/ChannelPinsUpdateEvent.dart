part of nyxx;

/// Fired when channel's pinned messages are updated
class ChannelPinsUpdateEvent {
  /// Channel where pins were updated
  TextChannel channel;

  /// the time at which the most recent pinned message was pinned
  DateTime lastPingTimestamp;

  ChannelPinsUpdateEvent._new(Client client, Map<String, dynamic> json) {
    this.lastPingTimestamp =
        DateTime.parse(json['d']['last_pin_timestamp'] as String);
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as TextChannel;

    channel._pinsUpdated.add(this);
    client._events.onChannelPinsUpdate.add(this);
  }
}
