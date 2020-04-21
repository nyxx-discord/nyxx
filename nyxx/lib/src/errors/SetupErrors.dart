part of nyxx;

/// Thrown when client isn't set up.
class NoSetupError implements Exception {
  /// Returns a string representation of this object.
  @override
  String toString() =>
      "NotSetupError: Bot isn't set up properly! Use NyxxVm class from Vm package";
}

/// Thrown when token is empty or null
class NoTokenError implements Exception {
  /// Returns a string representation of this object.
  @override
  String toString() =>
      "NotSetupError: Token is null or empty!";
}
