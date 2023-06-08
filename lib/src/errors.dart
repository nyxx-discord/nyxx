/// The base class for all exceptions thrown by nyxx.
class NyxxException implements Exception {
  /// The message for this exception.
  final String message;

  /// Create a new [NyxxException] with the provided [message].
  NyxxException(this.message);

  @override
  String toString() => message;
}

/// An exception thrown when an unexpected event is received on the Gateway.
class InvalidEvent extends NyxxException {
  /// Create a new [InvalidEvent] with the provided [message].
  InvalidEvent(String message) : super('Invalid gateway event: $message');
}
