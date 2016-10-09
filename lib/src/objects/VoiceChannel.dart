part of discord;

/// A guild channel.
class VoiceChannel extends GuildChannel {
  /// The channel's bitrate.
  int bitrate;

  /// The channel's user limit.
  int userLimit;

  VoiceChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, guild, "voice") {
    this.bitrate = this._map['bitrate'] = data['bitrate'];
    this.userLimit = this._map['userLimit'] = data['user_limit'];
  }
}
