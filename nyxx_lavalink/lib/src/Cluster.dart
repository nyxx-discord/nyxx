part of nyxx_lavalink;


/// Cluster of lavalink nodes
class Cluster {
  /// A reference to the client
  final Nyxx client;

  /// The client id provided to lavalink;
  final Snowflake clientId;

  /// Creates a new cluster ready to start adding connections
  Cluster(this.client, this.clientId);

  void addNode(NodeOptions node) {

  }
}