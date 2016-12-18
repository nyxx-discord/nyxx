part of discord;

/// A game.
class Game {
  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The game name.
  String name;

  /// The game type. 0 if not streamed, 1 if being streamed.
  int type;

  /// The game URL, if provided.
  String url;

  /// Makes a new game object.
  Game(this.name, {this.type: 0, this.url}) {
    this.raw = {"name": name, "type": type, "url": url};
  }

  Game._new(Client client, this.raw) {
    try {
      this.name = raw['name'].toString();
    } catch (err) {
      this.name = null;
    }

    try {
      this.url = raw['url'].toString();
    } catch (err) {
      this.url = null;
    }

    if (raw['type'] is int) {
      this.type = raw['type'];
    } else if (raw['type'] is String) {
      try {
        this.type = int.parse(raw['type']);
      } catch (err) {
        this.type = null;
      }
    }
  }
}
