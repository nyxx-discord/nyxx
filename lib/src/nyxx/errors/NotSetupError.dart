part of nyxx;

/// Thrown when you don't setup the client first.
/// See configureNyxxForBrowser()
/// or configureNyxxForVM()
class NotSetupError implements Exception {
  /// Returns a string representation of this object.
  @override
  String toString() =>
      "NotSetupError: Token is null or empty or bot isn't setup!";
}
