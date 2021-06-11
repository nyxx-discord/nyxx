part of nyxx_lavalink;

/// Represents an active and running lavalink node
class Node {
  /// Node options, such as host, port, etc..
  NodeOptions options;

  /// A map with guild ids as keys and players as values
  Map<Snowflake, GuildPlayer> players = {};

  /// Http client used with this node
  _HttpClient client;

  /// Build a new Node
  Node(this.options)
  : this.client = new _HttpClient(options);
}