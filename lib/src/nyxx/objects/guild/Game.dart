part of nyxx;

/// A game.
class Game {
  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The game name.
  String name;

  /// The game type. 0 if not streamed, 1 if being streamed.
  int type;

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
  Game.of(this.name, {this.type: 0, this.url}) {
    this.raw = {"name": name, "type": type, "url": url};
  }

  Game._new(Client client, this.raw) {
    this.name = raw['name'] as String;
    this.url = raw['name'] as String;
    this.type = raw['type'] as int;

    if (raw['timestamps'] != null) {
      if(raw['timestamps']['start'] != null) {
        start = new DateTime.fromMillisecondsSinceEpoch(
          raw['timestamps']['start'] as int);
      }

      if(raw['timestamps']['end'] != null) {
         end = new DateTime.fromMillisecondsSinceEpoch(
          raw['timestamps']['end'] as int);
      }
    }

    if (raw['application_id'] != null)
      applicationId = new Snowflake(raw['application_id'] as String);

    details = raw['details'] as String;
    state = raw['state'] as String;

    if (raw['party'] != null)
      party = new GameParty._new(raw['party'] as Map<String, dynamic>);

    if (raw['assets'] != null)
      assets = new GameAssets._new(raw['assets'] as Map<String, dynamic>);

    if (raw['secrets'] != null)
      secrets = new GameSecrets._new(raw['secrets'] as Map<String, dynamic>);

    instance = raw['instance'] as bool;
    activityFlags = raw['flags'] as int;
  }
}

/// Represents party of game.
class GameParty {
  /// Party id.
  String id;

  /// Current size of party.
  int currentSize;

  /// Max size of party.
  int maxSize;

  /// Raw object returned by API.
  Map<String, dynamic> raw;

  GameParty._new(this.raw) {
    id = raw['id'] as String;

    if(raw['size'] != null) {
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

  /// Raw object returned by API.
  Map<String, dynamic> raw;

  GameAssets._new(this.raw) {
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

  /// Raw object returned by API.
  Map<String, dynamic> raw;

  GameSecrets._new(this.raw) {
    join = raw['join'] as String;
    spectate = raw['spectate'] as String;
    match = raw['match'] as String;
  }
}
