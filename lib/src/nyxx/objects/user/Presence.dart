part of nyxx;

/// Presence is game or activity which user is playing/user participate.
/// Can be game, eg. Dota 2, VS Code or activity like Listening to song on Spotify.
class Presence {
  /// The activity name.
  String name;

  /// The activity type.
  PresenceType type;

  /// DateTime when activity started
  DateTime start;

  /// DateTime when activity ends
  DateTime end;

  /// Application id for the game
  Snowflake applicationId;

  /// What the player is currently doing
  String details;

  /// The user's current party status
  String state;

  /// Information for the current party of the player
  GameParty party;

  /// Images for the presence and their hover texts
  GameAssets assets;

  /// Secrets for Rich Presence joining and spectating
  GameSecrets secrets;

  /// Whether or not the activity is an instanced game session
  bool instance;

  ///	Activity flags ORd together, describes what the payload includes
  int activityFlags;

  /// The game URL, if provided.
  String url;

  /// Makes a new game object.
  Presence.of(this.name, {this.type = PresenceType.normal, this.url});

  Presence._new(Map<String, dynamic> raw) {
    this.name = raw['name'] as String;
    this.url = raw['url'] as String;
    this.type = PresenceType(raw['type'] as int);

    if (raw['timestamps'] != null) {
      if (raw['timestamps']['start'] != null) {
        start = DateTime.fromMillisecondsSinceEpoch(
            raw['timestamps']['start'] as int);
      }

      if (raw['timestamps']['end'] != null) {
        end = DateTime.fromMillisecondsSinceEpoch(
            raw['timestamps']['end'] as int);
      }
    }

    if (raw['application_id'] != null)
      applicationId = Snowflake(raw['application_id'] as String);

    details = raw['details'] as String;
    state = raw['state'] as String;

    if (raw['party'] != null)
      party = GameParty._new(raw['party'] as Map<String, dynamic>);

    if (raw['assets'] != null)
      assets = GameAssets._new(raw['assets'] as Map<String, dynamic>);

    if (raw['secrets'] != null)
      secrets = GameSecrets._new(raw['secrets'] as Map<String, dynamic>);

    instance = raw['instance'] as bool;
    activityFlags = raw['flags'] as int;
  }
}

/// Represents type of presence activity
class PresenceType {
  static const PresenceType streaming = PresenceType._create(1);
  static const PresenceType normal = PresenceType._create(0);

  final int _value;

  PresenceType(this._value);
  const PresenceType._create(this._value);

  @override
  String toString() => _value.toString();

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) => other is int && other == _value
      || other is String && other == _value.toString();

}

/// Represents party of game.
class GameParty {
  /// Party id.
  String id;

  /// Current size of party.
  int currentSize;

  /// Max size of party.
  int maxSize;

  GameParty._new(Map<String, dynamic> raw) {
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
  String largeImage;

  /// Text displayed when hovering over the large image of the activity.
  String largeText;

  /// The id for a small asset of the activity, usually a snowflake
  String smallImage;

  /// Text displayed when hovering over the small image of the activity
  String smallText;

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
  String join;

  /// Spectate secret
  String spectate;

  /// Match secret
  String match;

  GameSecrets._new(Map<String, dynamic> raw) {
    join = raw['join'] as String;
    spectate = raw['spectate'] as String;
    match = raw['match'] as String;
  }
}
