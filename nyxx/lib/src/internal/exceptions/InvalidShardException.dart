part of nyxx;

class InvalidShardException implements Exception {
  final String message;

  InvalidShardException(this.message);

  @override
  String toString() => "InvalidShardException: Unsupported shard operation: $message";
}