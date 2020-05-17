part of nyxx;

/// Thrown when token is empty or null
class NoTokenError implements Exception {
  /// Returns a string representation of this object.
  @override
  String toString() => "NotSetupError: Token is null or empty!";
}
