part of nyxx;

class WebhookUpdateEvent {
  TextChannel channel;
  Guild guild;

  WebhookUpdateEvent._new(Client client, Map<String, dynamic> json) {
    this.channel = client.channels[json['d']['channel_id']] as TextChannel;
    this.guild = client.guilds[json['d']['guild_id']];

    client._events.onWebhookUpdate.add(this);
  }
}
