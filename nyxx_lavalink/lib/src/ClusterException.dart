part of nyxx_lavalink;

class ClusterException implements Exception {
  String error;
  
  ClusterException._new(this.error) : super();

  @override
  String toString() =>
      "Lavalink cluster error: $error";
}