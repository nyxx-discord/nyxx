import 'package:nyxx/src/gateway/shard.dart';

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
class InvalidEventException extends NyxxException {
  /// Create a new [InvalidEventException] with the provided [message].
  InvalidEventException(String message) : super('Invalid gateway event: $message');
}

/// An error thrown when a shard disconnects unexpectedly.
class ShardDisconnectedError extends Error {
  /// The shard that was disconnected.
  final Shard shard;

  /// Create a new [ShardDisconnectedError].
  ShardDisconnectedError(this.shard);
}
