part of nyxx_interactions;

/// Thrown when you haven't sent a response yet
class ResponseRequiredError implements Error {
  /// Returns a string representation of this object.
  @override
  String toString() => "ResponseRequiredError: Interaction needs an initial response before followups can be sent.";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}