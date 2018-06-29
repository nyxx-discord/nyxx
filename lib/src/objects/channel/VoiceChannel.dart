part of nyxx;

/// A guild channel.
class VoiceChannel extends GuildChannel {
  /// The channel's bitrate.
  int bitrate;

  /// The channel's user limit.
  int userLimit;

  VoiceChannel._new(Client client, Map<String, dynamic> data, Guild guild)
      : super._new(client, data, guild, "voice") {
    this.bitrate = raw['bitrate'];
    this.userLimit = raw['user_limit'];
  }

  /// Edits the channel.
  Future<VoiceChannel> edit(
      {String name: null,
      int bitrate: null,
      int position: null,
      int userLimit: null}) async {
    HttpResponse r =
        await this.client.http.send('PATCH', "/channels/${this.id}", body: {
      "name": name != null ? name : this.name,
      "bitrate": bitrate != null ? bitrate : this.bitrate,
      "user_limit": userLimit != null ? userLimit : this.userLimit,
      "position": position != null ? position : this.position
    });
    return new VoiceChannel._new(
        this.client, r.body.asJson() as Map<String, dynamic>, this.guild);
  }
}
