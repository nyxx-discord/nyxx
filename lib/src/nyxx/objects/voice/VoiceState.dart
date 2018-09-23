part of nyxx;

/// Used to represent a user's voice connection status.
class VoiceState extends UserVoiceState {
  /// User this voice state is for
  User user;

  /// Session id for this voice state
  String sessionId;

  /// Guild this voice state update is
  Guild guild;

  VoiceState._new(Map<String, dynamic> raw, [Guild guild]) : super(client, raw) {
    if(guild != null)
      this.guild = guild;
    else
      this.guild = client.guilds[Snowflake(raw['guild_id'] as String)];

    this.user = guild.members[Snowflake(raw['user_id'] as String)];
    this.sessionId = raw['session_id'] as String;
  }
}

/// Represents voice State for user
class UserVoiceState {
  /// Channel id user is connected
  VoiceChannel channel;

  /// Whether this user is muted by the server
  bool deaf;

  /// Whether this user is locally deafened
  bool selfDeaf;

  /// Whether this user is locally muted
  bool selfMute;

  /// Whether this user is muted by the current user
  bool suppress;

  /// Raw object returned by API
  Map<String, dynamic> raw;

  UserVoiceState(Nyxx client, this.raw) {
    this.channel =
        client.channels[Snowflake(raw['channel_id'] as String)] as VoiceChannel;
    this.deaf = raw['deaf'] as bool;
    this.selfDeaf = raw['self_deaf'] as bool;
    this.selfMute = raw['self_mute'] as bool;
    this.suppress = raw['suppress'] as bool;
  }
}
