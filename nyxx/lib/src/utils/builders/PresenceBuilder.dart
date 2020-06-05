part of nyxx;

class PresenceBuilder implements Builder {
  final UserStatus? status;
  final bool? afk;
  final Activity? game;
  DateTime? since;

  PresenceBuilder({this.status, this.afk, this.game, this.since});

  @override
  Map<String, dynamic> _build() =>
      <String, dynamic> {
      "status": (status != null) ? status.toString() : UserStatus.online.toString(),
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