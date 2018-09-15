part of nyxx;

/// Represents VoiceChannel within [Guild]
class VoiceChannel extends Channel with GuildChannel {
  /// The channel's bitrate.
  int bitrate;

  /// The channel's user limit.
  int userLimit;

  VoiceChannel._new(Map<String, dynamic> data, Guild guild)
      : super._new(data, 2) {
    _initialize(data, guild);

    this.bitrate = raw['bitrate'] as int;
    this.userLimit = raw['user_limit'] as int;
  }

  /// Edits the channel.
  Future<VoiceChannel> edit(
      {String name,
      int bitrate,
      int position,
      int userLimit,
      String auditReason}) async {
    HttpResponse r =
        await _client.http.send('PATCH', "/channels/${this.id}",
            body: {
              "name": name != null ? name : this.name,
              "bitrate": bitrate != null ? bitrate : this.bitrate,
              "user_limit": userLimit != null ? userLimit : this.userLimit,
              "position": position != null ? position : this.position
            },
            reason: auditReason);
    return VoiceChannel._new(r.body as Map<String, dynamic>, this.guild);
  }
}
