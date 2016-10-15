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
    this.name = data['name'];
    this.url = data['url'];
    if (data['type'] is int) {
      this.type = data['type'];
    } else if (data['type'] is String) {
      try {
        this.type = int.parse(data['type']);        
      } catch(err) {
        this.type = null;
      }
    }
  }
}
