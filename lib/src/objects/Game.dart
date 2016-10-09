part of discord;

/// A game.
class Game extends _BaseObj {
  /// The game name.
  String name;

  /// The game type. 0 if not streamed, 1 if being streamed.
  int type;

  /// The game URL, if provided.
  String url;

  Game._new(Client client, Map<String, dynamic> data) : super(client) {
    this.name = this._map['name'] = data['name'];
    this.type = this._map['type'] = data['type'];
    this.url = this._map['url'] = data['url'];
  }
}
