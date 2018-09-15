part of nyxx;

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent {
  /// Channel where reactions are removed
  MessageChannel channel;

  /// Message on which messages are removed
  Message message;

  /// Guild where event occurs
  Guild guild;

  MessageReactionsRemovedEvent._new( Map<String, dynamic> json) {
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel;

    this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];

    channel
        .getMessage(Snowflake(json['d']['message_id'] as String))
        .then((msg) => message = msg);

    client._events.onMessageReactionsRemoved.add(this);
  }
}
