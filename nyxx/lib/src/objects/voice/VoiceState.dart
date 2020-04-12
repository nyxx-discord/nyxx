part of nyxx;

/// Used to represent a user's voice connection status.
/// If [channel] is null, it means that user left channel.
class VoiceState {
  /// User this voice state is for
  User? user;

  /// Session id for this voice state
  late final String sessionId;

  /// Guild this voice state update is
  Guild? guild;

  /// Channel id user is connected
  late final VoiceChannel? channel;

  /// Whether this user is muted by the server
  late final bool deaf;

  /// Whether this user is locally deafened
  late final bool selfDeaf;

  /// Whether this user is locally muted
  late final bool selfMute;

  /// Whether this user is muted by the current user
  late final bool suppress;

  VoiceState._new(Map<String, dynamic> raw, Nyxx client, [Guild? guild]) {
    if(raw['channel_id'] != null) {
      this.channel =
          client.channels[Snowflake(raw['channel_id'])] as VoiceChannel?;
    }

    this.deaf = raw['deaf'] as bool;
    this.selfDeaf = raw['self_deaf'] as bool;
    this.selfMute = raw['self_mute'] as bool;
    this.suppress = raw['suppress'] as bool;
    this.sessionId = raw['session_id'] as String;

    if (guild != null)
      this.guild = guild;
    else
      this.guild = client.guilds[Snowflake(raw['guild_id'] as String)];

    if(this.guild != null) {
      this.user = this.guild!.members[Snowflake(raw['user_id'] as String)];
    }
  }
}
