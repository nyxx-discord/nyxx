part of nyxx_interactions;

/// Thrown when 15 minutes has passed since an interaction was called.
class InteractionExpiredError implements Error {
  /// Returns a string representation of this object.
  @override
  String toString() => "InteractionExpiredError: Interaction tokens are only valid for 15mins. It has been over 15mins and the token is now invalid.";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
