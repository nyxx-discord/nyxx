part of nyxx_lavalink;

/// An exception related to cluster functions
class ClusterException implements Exception {
  /// The actual error description
  String error;
  
  ClusterException._new(this.error);

  @override
  String toString() =>
      "Lavalink cluster error: $error";
}
