part of nyxx;

/// Used to represent a user"s voice connection status.
/// If [channel] is null, it means that user left channel.
class VoiceState {
  /// User this voice state is for
  late final Cacheable<Snowflake, User> user;

  /// Session id for this voice state
  late final String sessionId;

  /// Guild this voice state update is
  late final Cacheable<Snowflake, Guild>? guild;

  /// Channel id user is connected
  late final Cacheable<Snowflake, IChannel>? channel;

  /// Whether this user is muted by the server
  late final bool deaf;

  /// Whether this user is locally deafened
  late final bool selfDeaf;

  /// Whether this user is locally muted
  late final bool selfMute;

  /// Whether this user is muted by the current user
  late final bool suppress;

  /// Whether this user is streaming using "Go Live"
  late final bool selfStream;

  /// Whether this user's camera is enabled
  late final bool selfVideo;

  /// The time at which the user requested to speak
  late final DateTime? requestToSpeakTimeStamp;

  VoiceState._new(INyxx client, Map<String, dynamic> raw) {
    if (raw["channel_id"] != null) {
      this.channel = _ChannelCacheable(client, Snowflake(raw["channel_id"]));
    } else {
      this.channel = null;
    }

    this.deaf = raw["deaf"] as bool;
    this.selfDeaf = raw["self_deaf"] as bool;
    this.selfMute = raw["self_mute"] as bool;

    this.selfStream = raw["self_stream"] as bool? ?? false;
    this.selfVideo = raw["self_video"] as bool;

    this.requestToSpeakTimeStamp =
        raw["request_to_speak_timestamp"] == null ? null : DateTime.parse(raw["request_to_speak_timestamp"] as String);

    this.suppress = raw["suppress"] as bool;
    this.sessionId = raw["session_id"] as String;

    if (raw["guild_id"] == null) {
      this.guild = null;
    } else {
      this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"]));
    }

    this.user = _UserCacheable(client, Snowflake(raw["user_id"]));
  }
}
