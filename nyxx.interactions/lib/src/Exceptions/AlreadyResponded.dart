part of nyxx_interactions;

/// Thrown when 15 minutes has passed since an interaction was called.
class AlreadyResponded implements Error {
  /// Returns a string representation of this object.
  @override
  String toString() =>
      "AlreadyRespondedError: Interaction has already been acknowledged, you can now only send channel messages (with/without source)";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}