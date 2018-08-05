part of nyxx;

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
    this.name = raw['name'] as String;
    this.url = raw['name'] as String;
    this.type = raw['type'] as int;
  }
}
