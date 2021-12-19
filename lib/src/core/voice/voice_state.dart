import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IVoiceState {
  /// User this voice state is for
  Cacheable<Snowflake, IUser> get user;

  /// Session id for this voice state
  String get sessionId;

  /// Guild this voice state update is
  Cacheable<Snowflake, IGuild>? get guild;

  /// Channel id user is connected
  Cacheable<Snowflake, IChannel>? get channel;

  /// Whether this user is muted by the server
  bool get deaf;

  /// Whether this user is locally deafened
  bool get selfDeaf;

  /// Whether this user is locally muted
  bool get selfMute;

  /// Whether this user is muted by the current user
  bool get suppress;

  /// Whether this user is streaming using "Go Live"
  bool get selfStream;

  /// Whether this user's camera is enabled
  bool get selfVideo;

  /// The time at which the user requested to speak
  DateTime? get requestToSpeakTimeStamp;
}

/// Used to represent a user"s voice connection status.
/// If [channel] is null, it means that user left channel.
class VoiceState implements IVoiceState {
  /// User this voice state is for
  @override
  late final Cacheable<Snowflake, IUser> user;

  /// Session id for this voice state
  @override
  late final String sessionId;

  /// Guild this voice state update is
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Channel id user is connected
  @override
  late final Cacheable<Snowflake, IChannel>? channel;

  /// Whether this user is muted by the server
  @override
  late final bool deaf;

  /// Whether this user is locally deafened
  @override
  late final bool selfDeaf;

  /// Whether this user is locally muted
  @override
  late final bool selfMute;

  /// Whether this user is muted by the current user
  @override
  late final bool suppress;

  /// Whether this user is streaming using "Go Live"
  @override
  late final bool selfStream;

  /// Whether this user's camera is enabled
  @override
  late final bool selfVideo;

  /// The time at which the user requested to speak
  @override
  late final DateTime? requestToSpeakTimeStamp;

  /// Creates an instance of [VoiceState]
  VoiceState(INyxx client, RawApiMap raw) {
    if (raw["channel_id"] != null) {
      channel = ChannelCacheable(client, Snowflake(raw["channel_id"]));
    } else {
      channel = null;
    }

    deaf = raw["deaf"] as bool;
    selfDeaf = raw["self_deaf"] as bool;
    selfMute = raw["self_mute"] as bool;

    selfStream = raw["self_stream"] as bool? ?? false;
    selfVideo = raw["self_video"] as bool;

    requestToSpeakTimeStamp = raw["request_to_speak_timestamp"] == null ? null : DateTime.parse(raw["request_to_speak_timestamp"] as String);

    suppress = raw["suppress"] as bool;
    sessionId = raw["session_id"] as String;

    if (raw["guild_id"] == null) {
      guild = null;
    } else {
      guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    }

    user = UserCacheable(client, Snowflake(raw["user_id"]));
  }
}
