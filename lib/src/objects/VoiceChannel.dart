part of discord;

/// A guild channel.
class VoiceChannel extends GuildChannel {
  /// The channel's bitrate.
  int bitrate;

  /// The channel's user limit.
  int userLimit;

  /// Constructs a new [GuildChannel].
  VoiceChannel(Client client, Map<String, dynamic> data, Guild guild)
      : super(client, data, guild, "voice") {
    this.bitrate = this.map['bitrate'] = data['bitrate'];
    this.userLimit = this.map['userLimit'] = data['user_limit'];
  }
}
