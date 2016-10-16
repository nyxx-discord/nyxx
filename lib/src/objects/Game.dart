part of discord;

/// A game.
class Game {
  /// The game name.
  String name;

  /// The game type. 0 if not streamed, 1 if being streamed.
  int type;

  /// The game URL, if provided.
  String url;

  /// Makes a new game object.
  Game(this.name, {this.type: 0, this.url});

  Game._new(Client client, Map<String, dynamic> data) {
    try {
      this.name = data['name'].toString();
    } catch (err) {
      this.name = null;
    }

    try {
      this.url = data['url'].toString();
    } catch (err) {
      this.url = null;
    }

    if (data['type'] is int) {
      this.type = data['type'];
    } else if (data['type'] is String) {
      try {
        this.type = int.parse(data['type']);
      } catch (err) {
        this.type = null;
      }
    }
  }

  Map<String, dynamic> _toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['name'] = this.name;
    map['type'] = this.type;
    map['url'] = this.url;
    return map;
  }
}
