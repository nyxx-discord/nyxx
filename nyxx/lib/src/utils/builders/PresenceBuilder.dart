part of nyxx;

/// Allows to build object of user presence used later when setting user presence.
class PresenceBuilder implements Builder {
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
  PresenceBuilder.of({this.status, this.afk, this.game, this.since});

  @override
  Map<String, dynamic> _build() => <String, dynamic>{
        "status":
            (status != null) ? status.toString() : UserStatus.online.toString(),
        "afk": (afk != null) ? afk : false,
        if (game != null)
          "game": <String, dynamic>{
            "name": game!.name,
            "type": game!.type.value,
            if (game!.type == ActivityType.streaming) "url": game!.url
          },
        "since": (since != null) ? since!.millisecondsSinceEpoch : null
      };
}
