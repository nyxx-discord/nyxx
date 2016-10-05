/// A game.
class Game {
  /// The game name.
  String name;

  /// The game type. 0 if not streamed, 1 if being streamed.
  int type;

  /// The game URL, if provided.
  String url;

  /// Constructs a game object.
  Game(Map<String, dynamic> data) {
    this.name = data['name'];
    this.type = data['type'];
    this.url = data['url'];    
  }
}