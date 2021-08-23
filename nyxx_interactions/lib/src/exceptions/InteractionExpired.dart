part of nyxx_interactions;

/// Thrown when 15 minutes has passed since an interaction was called.
class InteractionExpiredError implements Error {
  late final String _timeFrameString;

  InteractionExpiredError._15mins() {
    this._timeFrameString = "15mins";
  }

  InteractionExpiredError._3secs() {
    this._timeFrameString = "3secs";
  }

  /// Returns a string representation of this object.
  @override
  String toString() => "InteractionExpiredError: Interaction tokens are only valid for $_timeFrameString. It has been over $_timeFrameString and the token is now invalid.";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
