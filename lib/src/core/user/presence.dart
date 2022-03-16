import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/guild/status.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';
import 'package:nyxx/src/utils/permissions.dart';
import 'package:nyxx/src/core/user/user.dart';

abstract class IActivity {
  /// The activity name.
  String get name;

  /// The activity type.
  ActivityType get type;

  /// The game URL, if provided.
  String? get url;

  /// Timestamp of when the activity was added to the user's session
  DateTime get createdAt;

  /// Timestamps for start and/or end of the game
  IActivityTimestamps? get timestamps;

  /// Application id for the game
  Snowflake? get applicationId;

  /// What the player is currently doing
  String? get details;

  /// The user's current party status
  String? get state;

  /// The emoji used for a custom status
  IActivityEmoji? get customStatusEmoji;

  /// Information for the current party of the player
  IActivityParty? get party;

  /// Images for the presence and their hover texts
  IGameAssets? get assets;

  /// Secrets for Rich Presence joining and spectating
  IGameSecrets? get secrets;

  /// Whether or not the activity is an instanced game session
  bool? get instance;

  ///	Activity flags ORd together, describes what the payload includes
  IActivityFlags get activityFlags;

  /// Activity buttons. List of button labels
  Iterable<String> get buttons;
}

/// Presence is game or activity which user is playing/user participate.
/// Can be game, eg. Dota 2, VS Code or activity like Listening to song on Spotify.
class Activity implements IActivity {
  /// The activity name.
  @override
  late final String name;

  /// The activity type.
  @override
  late final ActivityType type;

  /// The game URL, if provided.
  @override
  late final String? url;

  /// Timestamp of when the activity was added to the user's session
  @override
  late final DateTime createdAt;

  /// Timestamps for start and/or end of the game
  @override
  late final ActivityTimestamps? timestamps;

  /// Application id for the game
  @override
  late final Snowflake? applicationId;

  /// What the player is currently doing
  @override
  late final String? details;

  /// The user's current party status
  @override
  late final String? state;

  /// The emoji used for a custom status
  @override
  late final ActivityEmoji? customStatusEmoji;

  /// Information for the current party of the player
  @override
  late final ActivityParty? party;

  /// Images for the presence and their hover texts
  @override
  late final GameAssets? assets;

  /// Secrets for Rich Presence joining and spectating
  @override
  late final GameSecrets? secrets;

  /// Whether or not the activity is an instanced game session
  @override
  late final bool? instance;

  ///	Activity flags ORd together, describes what the payload includes
  @override
  late final ActivityFlags activityFlags;

  /// Activity buttons. List of button labels
  @override
  late final Iterable<String> buttons;

  /// Creates na instance of [Activity]
  Activity(RawApiMap raw) {
    name = raw["name"] as String;
    url = raw["url"] as String?;
    type = ActivityType.from(raw["type"] as int);
    createdAt = DateTime.fromMillisecondsSinceEpoch(raw["created_at"] as int);
    details = raw["details"] as String?;
    state = raw["state"] as String?;

    if (raw["timestamps"] != null) {
      timestamps = ActivityTimestamps(raw["timestamps"] as RawApiMap);
    } else {
      timestamps = null;
    }

    if (raw["application_id"] != null) {
      applicationId = Snowflake(raw["application_id"]);
    } else {
      applicationId = null;
    }

    if (raw["emoji"] != null) {
      customStatusEmoji = ActivityEmoji(raw["emoji"] as RawApiMap);
    } else {
      customStatusEmoji = null;
    }

    if (raw["party"] != null) {
      party = ActivityParty(raw["party"] as RawApiMap);
    } else {
      party = null;
    }

    if (raw["assets"] != null) {
      assets = GameAssets(raw["assets"] as RawApiMap);
    } else {
      assets = null;
    }

    if (raw["secrets"] != null) {
      secrets = GameSecrets(raw["secrets"] as RawApiMap);
    } else {
      secrets = null;
    }

    instance = raw["instance"] as bool?;
    activityFlags = ActivityFlags(raw["flags"] as int?);
    buttons = [if (raw["buttons"] != null) ...raw["buttons"].cast<String>()];
  }
}

abstract class IActivityFlags {
  /// Flags value
  int get value;

  bool get isInstance;
  bool get isJoin;
  bool get isSpectate;
  bool get isJoinRequest;
  bool get isSync;
  bool get isPlay;
}

/// Flags of the activity
class ActivityFlags implements IActivityFlags {
  /// Flags value
  @override
  late final int value;

  @override
  bool get isInstance => PermissionsUtils.isApplied(value, 1 << 0);
  @override
  bool get isJoin => PermissionsUtils.isApplied(value, 1 << 1);
  @override
  bool get isSpectate => PermissionsUtils.isApplied(value, 1 << 2);
  @override
  bool get isJoinRequest => PermissionsUtils.isApplied(value, 1 << 3);
  @override
  bool get isSync => PermissionsUtils.isApplied(value, 1 << 4);
  @override
  bool get isPlay => PermissionsUtils.isApplied(value, 1 << 5);

  /// Creates na instance of [ActivityFlags]
  ActivityFlags(int? value) {
    this.value = value ?? 0;
  }
}

abstract class IActivityEmoji {
  /// Id of emoji.
  Snowflake? get id;

  /// True if emoji is animated
  bool get animated;
}

/// Represent emoji within activity
class ActivityEmoji implements IActivityEmoji {
  /// Id of emoji.
  @override
  late final Snowflake? id;

  /// True if emoji is animated
  @override
  late final bool animated;

  /// Creates na instance of [ActivityEmoji]
  ActivityEmoji(RawApiMap raw) {
    if (raw["id"] != null) {
      id = Snowflake(raw["id"]);
    }

    if (raw["animated"] != null) {
      animated = raw["animated"] as bool? ?? false;
    }
  }
}

abstract class IActivityTimestamps {
  /// DateTime when activity started
  DateTime? get start;

  /// DateTime when activity ends
  DateTime? get end;
}

/// Timestamp of activity
class ActivityTimestamps implements IActivityTimestamps {
  /// DateTime when activity started
  @override
  late final DateTime? start;

  /// DateTime when activity ends
  @override
  late final DateTime? end;

  /// Creates na instance of [ActivityTimestamps]
  ActivityTimestamps(RawApiMap raw) {
    if (raw["start"] != null) {
      start = DateTime.fromMillisecondsSinceEpoch(raw["start"] as int);
    }

    if (raw["end"] != null) {
      end = DateTime.fromMillisecondsSinceEpoch(raw["end"] as int);
    }
  }
}

/// Represents type of presence activity
class ActivityType extends IEnum<int> {
  /// Status type when playing a game
  static const ActivityType game = ActivityType._create(0);

  /// Status type when streaming a game. Only supports twitch.tv or youtube.com url
  static const ActivityType streaming = ActivityType._create(1);

  /// Status type when listening to Spotify
  static const ActivityType listening = ActivityType._create(2);

  /// Status type when watching
  static const ActivityType watching = ActivityType._create(3);

  /// Custom status, not supported for bot accounts
  static const ActivityType custom = ActivityType._create(4);

  /// Competing in something
  static const ActivityType competing = ActivityType._create(5);

  /// Creates [ActivityType] from [value]
  ActivityType.from(int value) : super(value);
  const ActivityType._create(int value) : super(value);

  @override
  bool operator ==(dynamic other) {
    if (other is int) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => value.hashCode;
}

abstract class IActivityParty {
  /// Party id.
  String? get id;

  /// Current size of party.
  int? get currentSize;

  /// Max size of party.
  int? get maxSize;
}

/// Represents party of game.
class ActivityParty implements IActivityParty {
  /// Party id.
  @override
  late final String? id;

  /// Current size of party.
  @override
  late final int? currentSize;

  /// Max size of party.
  @override
  late final int? maxSize;

  /// Creates na instance of [ActivityParty]
  ActivityParty(RawApiMap raw) {
    id = raw["id"] as String?;

    if (raw["size"] != null) {
      currentSize = raw["size"].first as int;
      maxSize = raw["size"].last as int;
    } else {
      currentSize = null;
      maxSize = null;
    }
  }
}

abstract class IGameAssets {
  /// The id for a large asset of the activity, usually a snowflake.
  String? get largeImage;

  /// Text displayed when hovering over the large image of the activity.
  String? get largeText;

  /// The id for a small asset of the activity, usually a snowflake
  String? get smallImage;

  /// Text displayed when hovering over the small image of the activity
  String? get smallText;
}

/// Presence"s assets
class GameAssets implements IGameAssets {
  /// The id for a large asset of the activity, usually a snowflake.
  @override
  late final String? largeImage;

  /// Text displayed when hovering over the large image of the activity.
  @override
  late final String? largeText;

  /// The id for a small asset of the activity, usually a snowflake
  @override
  late final String? smallImage;

  /// Text displayed when hovering over the small image of the activity
  @override
  late final String? smallText;

  /// Creates na instance of [GameAssets]
  GameAssets(RawApiMap raw) {
    largeImage = raw["large_image"] as String?;
    largeText = raw["large_text"] as String?;
    smallImage = raw["small_image"] as String?;
    smallText = raw["small_text"] as String?;
  }
}

abstract class IGameSecrets {
  /// Join secret
  String get join;

  /// Spectate secret
  String get spectate;

  /// Match secret
  String get match;
}

/// Represents presence"s secrets
class GameSecrets implements IGameSecrets {
  /// Join secret
  @override
  late final String join;

  /// Spectate secret
  @override
  late final String spectate;

  /// Match secret
  @override
  late final String match;

  /// Creates na instance of [GameSecrets]
  GameSecrets(RawApiMap raw) {
    join = raw["join"] as String;
    spectate = raw["spectate"] as String;
    match = raw["match"] as String;
  }
}

abstract class IPartialPresence {
  /// Reference to [INyxx]
  INyxx get client;

  /// The [IUser] object
  Cacheable<Snowflake, IUser>? get user;

  /// The status of the user indicating the platform they are on.
  IClientStatus? get clientStatus;

  /// The status of the user eg. online, idle, dnd, invisible, offline
  UserStatus? get status;

  List<IActivity?> get activities;
}

class PartialPresence implements IPartialPresence {
  /// Reference to [INyxx]
  @override
  final INyxx client;

  /// The [IUser] object
  @override
  late final Cacheable<Snowflake, IUser>? user;

  /// The status of the user indicating the platform they are on.
  @override
  late final IClientStatus? clientStatus;

  /// The status of the user eg. online, idle, dnd, invisible, offline
  @override
  late final UserStatus? status;

  /// The activities of the user
  @override
  late final List<IActivity?> activities;

  /// Creates na instance of [PartialPresence]
  PartialPresence(RawApiMap raw, this.client) {
    user = raw["user"] != null ? UserCacheable(client, Snowflake(raw['user']['id'])) : null;
    clientStatus = raw["client_status"] != null ? ClientStatus(raw["client_status"] as RawApiMap) : null;
    status = raw["status"] != null ? UserStatus.from(raw["status"] as String) : null;

    if (raw["activities"] != null) {
      activities = [for (final activity in raw["activities"]) Activity(activity as RawApiMap)];
    } else {
      activities = [];
    }
  }
}
