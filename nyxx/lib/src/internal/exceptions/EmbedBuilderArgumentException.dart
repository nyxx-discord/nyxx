part of nyxx;

/// Thrown when embed doesnt meet requirements to be valid
class EmbedBuilderArgumentException implements Exception {
  /// Custom error message specific to context of exception
  final String message;

  EmbedBuilderArgumentException._new(this.message);

  @override
  String toString() => "EmbedBuilderArgumentException: $message";
}
