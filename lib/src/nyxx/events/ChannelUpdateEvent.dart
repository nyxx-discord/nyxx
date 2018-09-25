part of nyxx;

/// Sent when a channel is updated.
class ChannelUpdateEvent {
  /// The channel prior to the update.
  GuildChannel oldChannel;

  /// The channel after the update.
  GuildChannel newChannel;

  ChannelUpdateEvent._new( Map<String, dynamic> json) {
    if (client.ready) {
      final Guild guild =
          client.guilds[Snowflake(json['d']['guild_id'] as String)];
      this.oldChannel =
          client.channels[Snowflake(json['d']['id'] as String)] as GuildChannel;

      var type = json['d']['type'] as int;

      if (type == 0) {
        this.newChannel =
            TextChannel._new(json['d'] as Map<String, dynamic>, guild);
      } else if (type == 2) {
        this.newChannel =
            VoiceChannel._new(json['d'] as Map<String, dynamic>, guild);
      } else if (type == 4) {
        this.newChannel =
            GroupChannel._new(json['d'] as Map<String, dynamic>, guild);
      }

      oldChannel._onUpdate.add(this);

      guild.channels[oldChannel.id] = newChannel;
      client.channels[oldChannel.id] = newChannel;
      client._events.onChannelUpdate.add(this);
    }
  }
}
