part of nyxx_interactions;

/// Thrown when you have already responded to an interaction
class AlreadyRespondedError implements Error {
  /// Returns a string representation of this object.
  @override
  String toString() =>
      "AlreadyRespondedError: Interaction has already been acknowledged, you can now only send channel messages (with/without source)";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
