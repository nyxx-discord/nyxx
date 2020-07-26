part of nyxx;

/// Thrown when token is empty or null
class MissingTokenError implements Error {
  /// Returns a string representation of this object.
  @override
  String toString() => "MissingTokenError: Token is null or empty!";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
