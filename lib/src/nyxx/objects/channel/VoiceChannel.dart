part of nyxx;

/// Represents VoiceChannel within [Guild]
class VoiceChannel extends Channel with GuildChannel {
  /// The channel's bitrate.
  int bitrate;

  /// The channel's user limit.
  int userLimit;

  VoiceChannel._new(Map<String, dynamic> raw, Guild guild)
      : super._new(raw, 2) {
    _initialize(raw, guild);

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
    HttpResponse r = await _client._http.send('PATCH', "/channels/${this.id}",
        body: {
          "name": name ?? this.name,
          "bitrate": bitrate ?? this.bitrate,
          "user_limit": userLimit ?? this.userLimit,
          "position": position ?? this.position
        },
        reason: auditReason);
    return VoiceChannel._new(r.body as Map<String, dynamic>, this.guild);
  }

  @override
  String get nameString => "[${this.guild.name}] Voice Channel [${this.id}]";
}
