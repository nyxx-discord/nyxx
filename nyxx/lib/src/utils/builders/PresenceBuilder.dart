part of nyxx;

/// Allows to build object of user presence used later when setting user presence.
class PresenceBuilder extends Builder {
  /// Status of user.
  UserStatus? status;

  /// If is afk
  bool? afk;

  /// Type of activity.
  Activity? game;

  /// WHen activity was started
  DateTime? since;

  /// Empty constructor to when setting all values manually.
  PresenceBuilder();

  /// Default builder constructor.
  factory PresenceBuilder.of({UserStatus? status, bool? afk, Activity? game, DateTime? since}) =>
      PresenceBuilder()
        ..status = status
        ..afk = afk
        ..game = game
        ..since = since;

  /// Sets bot status to game type
  factory PresenceBuilder.game({required String gameName, UserStatus? status}) =>
      PresenceBuilder()
        ..game = Activity.of(gameName)
        ..status = status;

  /// Sets bot status to stream type
  factory PresenceBuilder.streaming({required String streamName, required String streamUrl, UserStatus? status}) =>
      PresenceBuilder()
        ..game = Activity.of(streamName, type: ActivityType.streaming, url: streamUrl)
        ..status = status;

  @override
  RawApiMap build() => <String, dynamic>{
        "status": (status != null) ? status.toString() : UserStatus.online.toString(),
        "afk": (afk != null) ? afk : false,
        if (game != null) "game": <String, dynamic>{
            "name": game!.name,
            "type": game!.type.value,
            if (game!.type == ActivityType.streaming) "url": game!.url
        },
        "since": (since != null) ? since!.millisecondsSinceEpoch : null
      };
}
