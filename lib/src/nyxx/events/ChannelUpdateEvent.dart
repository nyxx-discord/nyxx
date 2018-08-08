part of nyxx;

/// Sent when a channel is updated.
class ChannelUpdateEvent {
  /// The channel prior to the update.
  GuildChannel oldChannel;

  /// The channel after the update.
  GuildChannel newChannel;

  ChannelUpdateEvent._new(Client client, Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild = client.guilds[new Snowflake(json['d']['guild_id'] as String)];
      this.oldChannel = client.channels[new Snowflake(json['d']['id'] as String)] as GuildChannel;

      var type = json['d']['type'] as int;

      if (type== 0) {
        this.newChannel = new TextChannel._new(
            client, json['d'] as Map<String, dynamic>, guild);
      } else if (type == 2){
        this.newChannel = new VoiceChannel._new(
            client, json['d'] as Map<String, dynamic>, guild);
      } else if(type == 4) {
        this.newChannel = new GroupChannel._new(
            client, json['d'] as Map<String, dynamic>, guild);
      }

      oldChannel._onUpdate.add(this);
      client._events.onChannelUpdate.add(this);
    }
  }
}
