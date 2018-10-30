part of nyxx;

/// Thrown when you don't setup the client first.
/// See configureDiscordForBrowser()
/// or configureDiscordForVM()
class NotSetupError implements Exception {
  /// Returns a string representation of this object.
  @override
  String toString() => "NotSetupError";
}
