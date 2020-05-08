part of nyxx;

/// Presence is game or activity which user is playing/user participate.
/// Can be game, eg. Dota 2, VS Code or activity like Listening to song on Spotify.
class Activity {
  /// The activity name.
  late final String name;

  /// The activity type.
  late final ActivityType type;

  /// The game URL, if provided.
  String? url;

  /// Timestamp of when the activity was added to the user's session
  late final DateTime createdAt;

  /// Timestamps for start and/or end of the game
  ActivityTimestamps? timestamps;

  /// Application id for the game
  Snowflake? applicationId;

  /// What the player is currently doing
  String? details;

  /// The user's current party status
  String? state;

  /// The emoji used for a custom status
  ActivityEmoji? customStatusEmoji;

  /// Information for the current party of the player
  ActivityParty? party;

  /// Images for the presence and their hover texts
  GameAssets? assets;

  /// Secrets for Rich Presence joining and spectating
  GameSecrets? secrets;

  /// Whether or not the activity is an instanced game session
  bool? instance;

  ///	Activity flags ORd together, describes what the payload includes
  int? activityFlags;

  /// Makes a new game object.
  Activity.of(this.name, {this.type = ActivityType.game, this.url});

  Activity._new(Map<String, dynamic> raw) {
    this.name = raw['name'] as String;
    this.url = raw['url'] as String;
    this.type = ActivityType(raw['type'] as int);
    this.createdAt =
        DateTime.fromMillisecondsSinceEpoch(raw['created_at'] as int);
    this.details = raw['details'] as String;
    this.state = raw['state'] as String;

    if (raw['timestamps'] != null) {
      this.timestamps =
          ActivityTimestamps._new(raw['timestamps'] as Map<String, dynamic>);
    }

    if (raw['application_id'] != null) {
      applicationId = Snowflake(raw['application_id']);
    }

    if (raw['emoji'] != null) {
      this.customStatusEmoji =
          ActivityEmoji._new(raw['emoji'] as Map<String, dynamic>);
    }

    if (raw['party'] != null) {
      party = ActivityParty._new(raw['party'] as Map<String, dynamic>);
    }

    if (raw['assets'] != null) {
      assets = GameAssets._new(raw['assets'] as Map<String, dynamic>);
    }

    if (raw['secrets'] != null) {
      secrets = GameSecrets._new(raw['secrets'] as Map<String, dynamic>);
    }

    instance = raw['instance'] as bool;
    activityFlags = raw['flags'] as int;
  }
}

class ActivityEmoji {
  late final Snowflake? id;
  late final bool animated;

  ActivityEmoji._new(Map<String, dynamic> raw) {
    if (raw['id'] != null) {
      this.id = Snowflake(raw['id']);
    }

    if (raw['animated'] != null) {
      this.animated = raw['animated'] as bool? ?? false;
    }
  }
}

class ActivityTimestamps {
  /// DateTime when activity started
  late final DateTime? start;

  /// DateTime when activity ends
  late final DateTime? end;

  ActivityTimestamps._new(Map<String, dynamic> raw) {
    if (raw['start'] != null) {
      this.start = DateTime.fromMillisecondsSinceEpoch(raw['start'] as int);
    }

    if (raw['end'] != null) {
      this.end = DateTime.fromMillisecondsSinceEpoch(raw['end'] as int);
    }
  }
}

/// Represents type of presence activity
class ActivityType extends IEnum<int> {
  static const ActivityType game = ActivityType._create(0);
  static const ActivityType streaming = ActivityType._create(1);
  static const ActivityType listening = ActivityType._create(2);
  static const ActivityType custom = ActivityType._create(3);

  ActivityType(int value) : super(value);
  const ActivityType._create(int value) : super(value);

  @override
  bool operator ==(other) {
    if (other is int) {
      return other == this._value;
    }

    return super == other;
  }
}

/// Represents party of game.
class ActivityParty {
  /// Party id.
  late final String id;

  /// Current size of party.
  int? currentSize;

  /// Max size of party.
  int? maxSize;

  ActivityParty._new(Map<String, dynamic> raw) {
    id = raw['id'] as String;

    if (raw['size'] != null) {
      currentSize = raw['size'].first as int;
      maxSize = raw['size'].last as int;
    }
  }
}

/// Presence's assets
class GameAssets {
  /// The id for a large asset of the activity, usually a snowflake.
  late final String largeImage;

  /// Text displayed when hovering over the large image of the activity.
  late final String largeText;

  /// The id for a small asset of the activity, usually a snowflake
  late final String smallImage;

  /// Text displayed when hovering over the small image of the activity
  late final String smallText;

  GameAssets._new(Map<String, dynamic> raw) {
    largeImage = raw['large_image'] as String;
    largeText = raw['large_text'] as String;
    smallImage = raw['small_image'] as String;
    smallText = raw['small_text'] as String;
  }
}

/// Represents presence's secrets
class GameSecrets {
  /// Join secret
  late final String join;

  /// Spectate secret
  late final String spectate;

  /// Match secret
  late final String match;

  GameSecrets._new(Map<String, dynamic> raw) {
    join = raw['join'] as String;
    spectate = raw['spectate'] as String;
    match = raw['match'] as String;
  }
}
