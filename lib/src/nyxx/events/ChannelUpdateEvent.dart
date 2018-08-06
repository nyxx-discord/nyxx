part of nyxx;

/// Sent when a channel is updated.
class ChannelUpdateEvent {
  /// The channel prior to the update.
  GuildChannel oldChannel;

  /// The channel after the update.
  GuildChannel newChannel;

  ChannelUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[new Snowflake(json['d']['guild_id'] as String )];
      this.oldChannel = client.channels[new Snowflake(json['d']['id'] as String)] as GuildChannel;
      if (json['d']['type'] == 0) {
        this.newChannel = new TextChannel._new(
            client, json['d'] as Map<String, dynamic>, guild);
      } else {
        this.newChannel = new VoiceChannel._new(
            client, json['d'] as Map<String, dynamic>, guild);
      }
      client._events.onChannelUpdate.add(this);
    }
  }
}
