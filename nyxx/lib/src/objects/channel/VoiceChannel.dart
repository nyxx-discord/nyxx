part of nyxx;

/// Represents VoiceChannel within [Guild]
class VoiceChannel extends Channel with GuildChannel {
  /// The channel's bitrate.
  int bitrate;

  /// The channel's user limit.
  int userLimit;

  VoiceChannel._new(Map<String, dynamic> raw, Guild guild, Nyxx client)
      : super._new(raw, 2, client) {
    _initialize(raw, guild);

    this.bitrate = raw['bitrate'] as int;
    this.userLimit = raw['user_limit'] as int;
  }

  /// Allows to get [VoiceState]s of users connected to this channel
  Iterable<VoiceState> get connectedUsers =>
      this.guild.voiceStates.values.where((e) => e.channel.id == this.id);

  /// Edits the channel.
  Future<VoiceChannel> edit(
      {String name,
      int bitrate,
      int position,
      int userLimit,
      String auditReason}) async {
    HttpResponse r = await client._http.send('PATCH', "/channels/${this.id}",
        body: {
          "name": name ?? this.name,
          "bitrate": bitrate ?? this.bitrate,
          "user_limit": userLimit ?? this.userLimit,
          "position": position ?? this.position
        },
        reason: auditReason);
    return VoiceChannel._new(
        r.body as Map<String, dynamic>, this.guild, client);
  }
}
