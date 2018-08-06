part of nyxx;

/// Emitted when webhook is edited (add, delete. modify)
class WebhookUpdateEvent {
  /// Channel on which event occured
  TextChannel channel;

  /// Guild on which event occured
  Guild guild;

  WebhookUpdateEvent._new(Client client, Map<String, dynamic> json) {
    this.channel = client.channels[new Snowflake(json['d']['channel_id'] as String)] as TextChannel;
    this.guild = client.guilds[new Snowflake(json['d']['guild_id'] as String)];

    client._events.onWebhookUpdate.add(this);
  }
}
