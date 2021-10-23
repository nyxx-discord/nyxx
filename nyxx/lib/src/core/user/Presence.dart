part of nyxx;

/// Presence is game or activity which user is playing/user participate.
/// Can be game, eg. Dota 2, VS Code or activity like Listening to song on Spotify.
class Activity implements IActivity {
  /// The activity name.
  late final String name;

  /// The activity type.
  late final ActivityType type;

  /// The game URL, if provided.
  late final String? url;

  /// Timestamp of when the activity was added to the user's session
  late final DateTime createdAt;

  /// Timestamps for start and/or end of the game
  late final ActivityTimestamps? timestamps;

  /// Application id for the game
  late final Snowflake? applicationId;

  /// What the player is currently doing
  late final String? details;

  /// The user's current party status
  late final String? state;

  /// The emoji used for a custom status
  late final ActivityEmoji? customStatusEmoji;

  /// Information for the current party of the player
  late final ActivityParty? party;

  /// Images for the presence and their hover texts
  late final GameAssets? assets;

  /// Secrets for Rich Presence joining and spectating
  late final GameSecrets? secrets;

  /// Whether or not the activity is an instanced game session
  late final bool? instance;

  ///	Activity flags ORd together, describes what the payload includes
  late final ActivityFlags activityFlags;

  /// Activity buttons. List of button labels
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
  late final int value;

  bool get isInstance => PermissionsUtils.isApplied(this.value, 1 << 0);
  bool get isJoin => PermissionsUtils.isApplied(this.value, 1 << 1);
  bool get isSpectate => PermissionsUtils.isApplied(this.value, 1 << 2);
  bool get isJoinRequest => PermissionsUtils.isApplied(this.value, 1 << 3);
  bool get isSync => PermissionsUtils.isApplied(this.value, 1 << 4);
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
  late final Snowflake? id;

  /// True if emoji is animated
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
  late final DateTime? start;

  /// DateTime when activity ends
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
      return other == this._value;
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
  late final String? id;

  /// Current size of party.
  late final int? currentSize;

  /// Max size of party.
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
  late final String? largeImage;

  /// Text displayed when hovering over the large image of the activity.
  late final String? largeText;

  /// The id for a small asset of the activity, usually a snowflake
  late final String? smallImage;

  /// Text displayed when hovering over the small image of the activity
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
  late final String join;

  /// Spectate secret
  late final String spectate;

  /// Match secret
  late final String match;

  /// Creates na instance of [GameSecrets]
  GameSecrets(RawApiMap raw) {
    this.join = raw["join"] as String;
    this.spectate = raw["spectate"] as String;
    this.match = raw["match"] as String;
  }
}
