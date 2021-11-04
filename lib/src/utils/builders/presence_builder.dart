import 'package:nyxx/src/core/guild/status.dart';
import 'package:nyxx/src/core/user/presence.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';

/// Allows to change status and presence of bot
class ActivityBuilder implements Builder {
  /// The activity name.
  late final String name;

  /// The activity type.
  late final ActivityType type;

  /// The game URL, if provided.
  String? url;

  /// Creates new instance of [ActivityBuilder]
  ActivityBuilder(this.name, this.type, {this.url});

  /// Sets activity to game
  factory ActivityBuilder.game(String name) => ActivityBuilder(name, ActivityType.game);

  /// Sets activity to streaming
  factory ActivityBuilder.streaming(String name, String url) => ActivityBuilder(name, ActivityType.streaming, url: url);

  /// Sets activity to listening
  factory ActivityBuilder.listening(String name) => ActivityBuilder(name, ActivityType.listening);

  @override
  RawApiMap build() => {
        "name": name,
        "type": type.value,
        if (type == ActivityType.streaming) "url": url,
      };
}

/// Allows to build object of user presence used later when setting user presence.
class PresenceBuilder extends Builder {
  /// Status of user.
  UserStatus? status;

  /// If is afk
  bool? afk;

  /// Type of activity.
  ActivityBuilder? activity;

  /// WHen activity was started
  DateTime? since;

  /// Empty constructor to when setting all values manually.
  PresenceBuilder();

  /// Default builder constructor.
  factory PresenceBuilder.of({UserStatus? status, ActivityBuilder? activity}) => PresenceBuilder()
    ..status = status
    ..activity = activity;

  /// Sets client status to idle. [since] indicates how long client is afking
  factory PresenceBuilder.idle({DateTime? since}) => PresenceBuilder()
    ..since = since
    ..afk = true;

  @override
  RawApiMap build() => <String, dynamic>{
        "status": (status != null) ? status.toString() : UserStatus.online.toString(),
        "afk": (afk != null) ? afk : false,
        if (activity != null)
          "activities": [
            activity!.build(),
          ],
        "since": (since != null) ? since!.millisecondsSinceEpoch : null
      };
}
