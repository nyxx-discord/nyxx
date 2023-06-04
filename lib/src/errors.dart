class NyxxException implements Exception {
  final String message;

  NyxxException(this.message);

  @override
  String toString() => message;
}

class InvalidEvent extends NyxxException {
  InvalidEvent(String message) : super('Invalid gateway event: $message');
}
