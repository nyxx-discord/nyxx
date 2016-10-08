part of discord;

/// An error for when a method is called before the client is ready.
class ClientNotReadyError implements Exception {
  /// Returns a string representation of this object.
  @override
  String toString() => "ClientNotReadyError";
}
