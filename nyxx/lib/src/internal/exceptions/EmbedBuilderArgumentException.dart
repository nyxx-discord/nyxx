part of nyxx;

class EmbedBuilderArgumentException implements Exception {
  final String message;

  EmbedBuilderArgumentException(this.message);

  @override
  String toString() => "EmbedBuilderArgumentException: $message";
}