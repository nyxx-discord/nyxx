/// Thrown when operation is unsupported due invalid or wrong shard being accessed.
class InvalidShardException implements Exception {
  /// Custom error message specific to context of exception
  final String message;

  /// Creates an instance of [InvalidShardException]
  InvalidShardException(this.message);

  @override
  String toString() => "InvalidShardException: Unsupported shard operation: $message";
}
