part of nyxx;

/// Represents VoiceChannel within [Guild]
class VoiceChannel extends Channel with GuildChannel {
  /// The channel's bitrate.
  int? bitrate;

  /// The channel's user limit.
  int? userLimit;

  VoiceChannel._new(Map<String, dynamic> raw, Guild guild, Nyxx client)
      : super._new(raw, 2, client) {
    _initialize(raw, guild);

    this.bitrate = raw['bitrate'] as int?;
    this.userLimit = raw['user_limit'] as int?;
  }

  /// Allows to get [VoiceState]s of users connected to this channel
  Iterable<VoiceState> get connectedUsers =>
      this.guild.voiceStates.values.where((e) => e.channel?.id == this.id);

  /// Edits the channel.
  Future<VoiceChannel> edit(
      {String? name,
      int? bitrate,
      int? position,
      int? userLimit,
      String? auditReason}) async {
    var body = <String, dynamic> {
      if(name != null) "name" : name,
      if(bitrate != null) "bitrate" : bitrate,
      if(userLimit != null) "user_limit" : userLimit,
      if(position != null) "position" : position,
    };

    var response = await client._http._execute(
        BasicRequest._new("/channels/${this.id}", method: "PATCH",
            body: body, auditLog: auditReason));

    if(response is HttpResponseSuccess) {
      return VoiceChannel._new(
          response.jsonBody as Map<String, dynamic>, this.guild, client);
    }

    return Future.error(response);
  }
}
