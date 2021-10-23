/// Thrown when embed doesnt meet requirements to be valid
class EmbedBuilderArgumentException implements Exception {
  /// Custom error message specific to context of exception
  final String message;

  /// Creates an instance of [EmbedBuilderArgumentException]
  EmbedBuilderArgumentException(this.message);

  @override
  String toString() => "EmbedBuilderArgumentException: $message";
}
