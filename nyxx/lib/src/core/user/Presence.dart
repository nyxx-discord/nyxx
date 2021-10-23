import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/IEnum.dart';
import 'package:nyxx/src/utils/permissions.dart';

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
    this.name = raw["name"] as String;
    this.url = raw["url"] as String?;
    this.type = ActivityType.from(raw["type"] as int);
    this.createdAt = DateTime.fromMillisecondsSinceEpoch(raw["created_at"] as int);
    this.details = raw["details"] as String?;
    this.state = raw["state"] as String?;

    if (raw["timestamps"] != null) {
      this.timestamps = ActivityTimestamps(raw["timestamps"] as RawApiMap);
    } else {
      this.timestamps = null;
    }

    if (raw["application_id"] != null) {
      this.applicationId = Snowflake(raw["application_id"]);
    } else {
      this.applicationId = null;
    }

    if (raw["emoji"] != null) {
      this.customStatusEmoji = ActivityEmoji(raw["emoji"] as RawApiMap);
    } else {
      this.customStatusEmoji = null;
    }

    if (raw["party"] != null) {
      this.party = ActivityParty(raw["party"] as RawApiMap);
    } else {
      this.party = null;
    }

    if (raw["assets"] != null) {
      this.assets = GameAssets(raw["assets"] as RawApiMap);
    } else {
      this.assets = null;
    }

    if (raw["secrets"] != null) {
      this.secrets = GameSecrets(raw["secrets"] as RawApiMap);
    } else {
      this.secrets = null;
    }

    this.instance = raw["instance"] as bool?;
    this.activityFlags = ActivityFlags(raw["flags"] as int?);
    this.buttons = [
      if (raw["buttons"] != null)
        ...raw["buttons"].cast<String>()
    ];
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
  bool get isInstance => PermissionsUtils.isApplied(this.value, 1 << 0);
  @override
  bool get isJoin => PermissionsUtils.isApplied(this.value, 1 << 1);
  @override
  bool get isSpectate => PermissionsUtils.isApplied(this.value, 1 << 2);
  @override
  bool get isJoinRequest => PermissionsUtils.isApplied(this.value, 1 << 3);
  @override
  bool get isSync => PermissionsUtils.isApplied(this.value, 1 << 4);
  @override
  bool get isPlay => PermissionsUtils.isApplied(this.value, 1 << 5);

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
      this.id = Snowflake(raw["id"]);
    }

    if (raw["animated"] != null) {
      this.animated = raw["animated"] as bool? ?? false;
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
      this.start = DateTime.fromMillisecondsSinceEpoch(raw["start"] as int);
    }

    if (raw["end"] != null) {
      this.end = DateTime.fromMillisecondsSinceEpoch(raw["end"] as int);
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
      return other == this.value;
    }

    return super == other;
  }

  @override
  int get hashCode => this.value.hashCode;
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
    this.id = raw["id"] as String?;

    if (raw["size"] != null) {
      this.currentSize = raw["size"].first as int;
      this.maxSize = raw["size"].last as int;
    } else {
      this.currentSize = null;
      this.maxSize = null;
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
    this.largeImage = raw["large_image"] as String?;
    this.largeText = raw["large_text"] as String?;
    this.smallImage = raw["small_image"] as String?;
    this.smallText = raw["small_text"] as String?;
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
    this.join = raw["join"] as String;
    this.spectate = raw["spectate"] as String;
    this.match = raw["match"] as String;
  }
}
